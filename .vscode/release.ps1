param(
    [string]$ChangelogEntry,
    [string]$ChangelogFile,

    [switch]$SkipBuild,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$CommonPath = Join-Path $RepoRoot 'scripts\vaultartifactautofill-common.ps1'
. $CommonPath

function Invoke-Git {
    param([string[]]$Arguments)

    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed"
    }
}

function Get-GitHubRepoSlug {
    param([string]$RemoteName = 'origin')

    $remoteNames = @(& git remote 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not ($remoteNames -contains $RemoteName)) {
        return $null
    }

    $remoteUrl = (git remote get-url $RemoteName 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not $remoteUrl) {
        return $null
    }

    $match = [regex]::Match($remoteUrl.Trim(), 'github\.com[:/](?<slug>[^/]+/[^/.]+?)(?:\.git)?$')
    if ($match.Success) {
        return $match.Groups['slug'].Value
    }

    return $null
}

function Get-ReleaseNotes {
    param(
        [string]$ChangelogPath,
        [string]$InlineEntry,
        [string]$EntryFile
    )

    if ($InlineEntry -and $EntryFile) {
        throw "Use either -ChangelogEntry or -ChangelogFile, not both."
    }

    if ($EntryFile) {
        if (-not (Test-Path $EntryFile)) {
            throw "Changelog file not found: $EntryFile"
        }
        return (Get-Content $EntryFile -Raw).Trim()
    }

    if ($InlineEntry) {
        return $InlineEntry.Trim()
    }

    $content = (Get-Content $ChangelogPath -Raw).Replace("`r`n", "`n")
    $match = [regex]::Match($content, '(?ms)^## \[Unreleased\]\s*\n(?<body>.*?)(?=^## \[|\z)')
    if (-not $match.Success) {
        throw "CHANGELOG.md must contain an [Unreleased] section."
    }

    return $match.Groups['body'].Value.Trim()
}

function Test-OnlyAutoVersionBumpChange {
    $dirtyEntries = @(git status --porcelain=v1)
    if ($LASTEXITCODE -ne 0) {
        throw "git status --porcelain=v1 failed"
    }

    $dirtyEntries = @($dirtyEntries | Where-Object { $_.Trim() })
    if ($dirtyEntries.Count -ne 1 -or $dirtyEntries[0] -notmatch '^.M gradle\.properties$|^M. gradle\.properties$') {
        return $false
    }

    $diffLines = @(git diff --unified=0 -- gradle.properties)
    if ($LASTEXITCODE -ne 0) {
        throw "git diff --unified=0 -- gradle.properties failed"
    }

    $changedPropertyLines = @(
        $diffLines |
            Where-Object { $_ -match '^[+-]' -and $_ -notmatch '^\+\+\+' -and $_ -notmatch '^---' }
    )

    if (-not $changedPropertyLines) {
        return $false
    }

    foreach ($line in $changedPropertyLines) {
        if ($line -notmatch '^[+-]mod_(version|source_hash)=') {
            return $false
        }
    }

    return $true
}

function Update-ChangelogForRelease {
    param(
        [string]$ChangelogPath,
        [string]$Version,
        [string]$DateText,
        [string]$ReleaseNotes
    )

    $content = (Get-Content $ChangelogPath -Raw).Replace("`r`n", "`n")
    $match = [regex]::Match($content, '(?ms)^## \[Unreleased\]\s*\n(?<body>.*?)(?=^## \[|\z)')
    if (-not $match.Success) {
        throw "CHANGELOG.md must contain an [Unreleased] section."
    }

    $trimmedNotes = $ReleaseNotes.Trim()
    if (-not $trimmedNotes -or $trimmedNotes -eq '- No changes yet.') {
        throw "Release notes are empty. Update CHANGELOG.md [Unreleased] or pass -ChangelogEntry."
    }

    $replacement = @(
        '## [Unreleased]',
        '',
        '- No changes yet.',
        '',
        "## [$Version] - $DateText",
        '',
        $trimmedNotes,
        ''
    ) -join "`n"

    $updated = $content.Substring(0, $match.Index) + $replacement + $content.Substring($match.Index + $match.Length)
    Set-Utf8NoBomContent -Path $ChangelogPath -Content $updated
}

function Update-ReadmeVersionReferences {
    param(
        [string]$ReadmePath,
        [string]$Version
    )

    $content = (Get-Content $ReadmePath -Raw).Replace("`r`n", "`n")
    $content = [regex]::Replace(
        $content,
        'Download `vaultartifactautofill-\d+\.\d+\.\d+\.jar`',
        "Download ``vaultartifactautofill-$Version.jar``"
    )
    $content = [regex]::Replace(
        $content,
        'Output: `build/libs/vaultartifactautofill-\d+\.\d+\.\d+\.jar`',
        "Output: ``build/libs/vaultartifactautofill-$Version.jar``"
    )

    Set-Utf8NoBomContent -Path $ReadmePath -Content $content
}

Push-Location $RepoRoot
try {
    $changelogPath = Join-Path $RepoRoot 'CHANGELOG.md'
    $readmePath = Join-Path $RepoRoot 'README.md'
    $today = Get-Date -Format 'yyyy-MM-dd'

    Write-Host "`n=== Vault Artifact Autofill Release ===" -ForegroundColor Cyan

    if (-not (Test-Path (Join-Path $RepoRoot '.git'))) {
        throw 'This folder is not a git repository. Initialize git and commit source changes first.'
    }

    $dirty = git status --porcelain
    if ($dirty) {
        if (Test-OnlyAutoVersionBumpChange) {
            Write-Warning 'Working tree contains only the build-generated gradle.properties version/hash bump; continuing with release.'
        } else {
            throw 'Working tree is dirty. Commit or stash changes first.'
        }
    }

    $branch = git rev-parse --abbrev-ref HEAD
    if ($branch -ne 'main') {
        throw "Must be on 'main' branch (currently on '$branch')."
    }

    $hasOrigin = $null -ne (Get-GitHubRepoSlug)
    if ($hasOrigin) {
        Invoke-Git -Arguments @('fetch', '--tags', 'origin', 'main')
        $aheadBehind = (git rev-list --left-right --count HEAD...origin/main).Trim().Split()
        if ($aheadBehind.Count -ne 2 -or $aheadBehind[0] -ne '0' -or $aheadBehind[1] -ne '0') {
            throw 'Release script requires main to match origin/main exactly.'
        }
    }

    $startingVersion = Get-ModVersion -RepoRoot $RepoRoot
    $releaseNotes = Get-ReleaseNotes -ChangelogPath $changelogPath -InlineEntry $ChangelogEntry -EntryFile $ChangelogFile
    $javaHome = Get-Java17Home
    $repoSlug = Get-GitHubRepoSlug

    if ($DryRun) {
        Write-Host "[dry-run] Would build under Java 17 at $javaHome" -ForegroundColor Yellow
        Write-Host "[dry-run] Starting version: $startingVersion" -ForegroundColor Yellow
        Write-Host '[dry-run] Would freeze [Unreleased] into the next release section' -ForegroundColor Yellow
        Write-Host '[dry-run] Would deploy locally, commit, tag, and push if origin/main is configured' -ForegroundColor Yellow
        return
    }

    Write-Host "  Java 17:         $javaHome" -ForegroundColor Gray
    Write-Host "  Starting version: $startingVersion" -ForegroundColor Gray

    if (-not $SkipBuild) {
        Write-Host "`n[1/5] Building JAR under Java 17..." -ForegroundColor White
        Invoke-GradleBuild -RepoRoot $RepoRoot
    } else {
        Write-Host "`n[1/5] Skipping build (--SkipBuild)" -ForegroundColor Yellow
    }

    $version = Get-ModVersion -RepoRoot $RepoRoot
    $tag = "v$version"
    if (git tag -l $tag) {
        throw "Tag $tag already exists. Nothing new to release."
    }

    $jar = Get-BuiltJar -RepoRoot $RepoRoot -Version $version
    Write-Host "  Release version:  $version" -ForegroundColor Green
    Write-Host "  Built artifact:   $($jar.Name)" -ForegroundColor Green

    Write-Host '[2/5] Updating CHANGELOG.md...' -ForegroundColor White
    Update-ChangelogForRelease -ChangelogPath $changelogPath -Version $version -DateText $today -ReleaseNotes $releaseNotes

    Write-Host '[3/5] Updating README.md...' -ForegroundColor White
    Update-ReadmeVersionReferences -ReadmePath $readmePath -Version $version

    Write-Host '[4/5] Deploying locally...' -ForegroundColor White
    & (Join-Path $RepoRoot 'scripts\build-and-deploy-vaultartifactautofill.ps1') -SkipBuild
    if ($LASTEXITCODE -ne 0) {
        throw 'Local deploy failed.'
    }

    Write-Host '[5/5] Committing and tagging...' -ForegroundColor White
    Invoke-Git -Arguments @('add', '-A')
    Invoke-Git -Arguments @('commit', '-m', "Release $tag")
    Invoke-Git -Arguments @('tag', $tag)

    if ($hasOrigin) {
        Invoke-Git -Arguments @('push', 'origin', 'main')
        Invoke-Git -Arguments @('push', 'origin', $tag)
        if ($repoSlug) {
            Write-Host "  GitHub release workflow target: https://github.com/$repoSlug/releases/tag/$tag" -ForegroundColor Gray
        }
    } else {
        Write-Warning 'No GitHub origin remote is configured. Release commit and tag were created locally only.'
    }

    Write-Host "`n=== Release $tag complete! ===" -ForegroundColor Cyan
} finally {
    Pop-Location
}