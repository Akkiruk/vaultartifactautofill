# vaultartifactautofill Instructions

## Scope

- This repo is the source of truth for the standalone `vaultartifactautofill` Forge mod.
- Primary branch: `main`
- Target stack: Java 17, Minecraft 1.18.2, Forge 40.3.11
- Runtime target: `%APPDATA%\PrismLauncher\instances\Vault Paradise\minecraft\`

## Project Layout

- `src/main/java/` for Java source
- `src/main/resources/` for Forge metadata and assets
- `scripts/` for local build and deploy helpers
- `.vscode/release.ps1` for the formal versioned release flow

## Build And Deploy

- Use `scripts/build-and-deploy-vaultartifactautofill.ps1` for intermediate local validation.
- That helper forces a Java 17 toolchain locally, builds with `gradlew.bat build`, and copies the latest `vaultartifactautofill-*.jar` into the runtime `mods/` folder.
- Build output lives at `build/libs/vaultartifactautofill-<mod_version>.jar`.
- After any kept change in this repo, finish with `.vscode/release.ps1`.
- If no remote is configured yet, `.vscode/release.ps1` still creates the release commit and tag locally and deploys the jar.

## Coding Conventions

- Keep this mod strictly scoped to non-ComputerCraft Vault artifact projector quality-of-life.
- Preserve server-authoritative behavior by using normal client interactions rather than custom packets.
- Keep Java changes minimal and compatible with Forge 1.18.2 / Java 17.

## Git Workflow Preference

- Default behavior after changes: run `.vscode/release.ps1`.
- Push only when a remote exists and the release script can do it safely.
- Do not rewrite history or force-push unless explicitly requested.