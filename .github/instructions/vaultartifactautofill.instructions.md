---
applyTo: '**'
---

# Vault Artifact Autofill — Coding Instructions

## Language & Platform

- Java 17 Forge mod for Minecraft 1.18.2 (Forge 40.3.11)
- Targets The Vault 3.21.x as a client-side quality-of-life helper
- Build system: Gradle 7.6.4 with ForgeGradle 5.1

## Scope Rules

- This mod is specifically for Vault artifact projector quality-of-life.
- Do not add ComputerCraft or Advanced Peripherals features here.
- Keep behavior client-side unless a future change is impossible without explicit server support.

## Interaction Rules

- Use vanilla inventory swap and block-use interactions where possible.
- Do not add custom networking or packet spoofing unless the user explicitly asks for a deeper protocol-based solution.
- Respect Vault's ownership and completion checks instead of duplicating authority client-side.

## Local Deploy

- After successful builds, deploy the jar to `%APPDATA%\PrismLauncher\instances\Vault Paradise\minecraft\mods\`.
- Use `scripts/build-and-deploy-vaultartifactautofill.ps1` for that local validation flow.

## Release Workflow

- Finish kept changes by running `.vscode/release.ps1`.
- If a GitHub remote is configured, the release script should push `main` and the tag.
- If no remote is configured, the release script should still produce a clean local release commit, tag, and deployed jar.