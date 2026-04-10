# Vault Artifact Autofill

Client-side Forge mod for Vault Hunters 1.18.2 that batch-places artifacts into your own artifact projector.

Download `vaultartifactautofill-1.0.4.jar` from Releases.

## Behavior
- Right-click your own incomplete artifact projector
- The mod scans your inventory for Vault artifacts
- Matching artifacts are moved into your selected hotbar slot temporarily and placed using normal vanilla interactions
- If the final placement completes the full 5x5 wall, the mod automatically triggers the projector's completion click
- The server still decides ownership, slot mapping, and whether placement is valid

## Target Stack
- Minecraft 1.18.2
- Forge 40.3.11
- The Vault 3.21.0
- Java 17

## Build
```powershell
.\gradlew.bat build
```

Output: `build/libs/vaultartifactautofill-1.0.4.jar`

## Release
```powershell
.\.vscode\release.ps1
```

If no GitHub remote is configured yet, the release script still builds, deploys, commits, and tags the release locally.
