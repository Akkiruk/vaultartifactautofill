# Changelog

All notable changes to Vault Artifact Autofill are documented here.

## [Unreleased]

- No changes yet.

## [1.0.6] - 2026-04-09

- Switched artifact placement to direct wall placement, so identified artifacts can be placed into any projector wall instead of only the owner's projector.
- Kept full-inventory autofill support by swapping queued artifacts into the selected hotbar slot before each placement.
- Limited the final completion click to the actual projector owner because Vault still server-gates projector completion.
## [1.0.5] - 2026-04-09

- Added action-bar feedback when autofill finds no eligible artifacts, including clearer messaging for fragments and unidentified artifacts.
- Added runtime log messages for autofill startup and projector click decisions so latest.log is useful for debugging.
## [1.0.4] - 2026-04-09

- Added GitHub Actions build and release workflows for the standalone mod repo.
- Added repo instructions, issue templates, and local release/deploy workflow scaffolding.
## [1.0.2] - 2026-04-09

- Added automatic projector completion after the last artifact is placed.
