param(
    [switch]$SkipBuild,
    [switch]$SkipJarDeploy,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$commonPath = Join-Path $PSScriptRoot "vaultartifactautofill-common.ps1"
. $commonPath

$repoRoot = Get-RepoRoot -ScriptRoot $PSScriptRoot
$modsDir = Join-Path $env:APPDATA "PrismLauncher\instances\Vault Paradise\minecraft\mods"
$version = Get-ModVersion -RepoRoot $repoRoot
$javaHome = Get-Java17Home

Write-Host "Repo:    $repoRoot"
Write-Host "Version: $version"
Write-Host "Java 17: $javaHome"

if (-not $SkipBuild) {
    if ($DryRun) {
        Write-Host "[dry-run] Would run: .\gradlew.bat build under Java 17" -ForegroundColor Yellow
    } else {
        Invoke-GradleBuild -RepoRoot $repoRoot
        $version = Get-ModVersion -RepoRoot $repoRoot
    }
}

if (-not $SkipJarDeploy) {
    if ($DryRun) {
        Write-Host "[dry-run] Would deploy the latest vaultartifactautofill JAR to $modsDir" -ForegroundColor Yellow
    } else {
        if (-not (Test-Path $modsDir)) {
            throw "Mods directory not found: $modsDir"
        }

        $jar = Get-BuiltJar -RepoRoot $repoRoot -Version $version
        Get-ChildItem $modsDir -Filter "vaultartifactautofill-*.jar" -File -ErrorAction SilentlyContinue | Remove-Item -Force
        Copy-Item $jar.FullName $modsDir -Force
        Write-Host "Deployed $($jar.Name) to $modsDir" -ForegroundColor Green
    }
}