---
name: publish-dtui
description: Publish the dtui package to pub.dev. Runs checks, bumps version, commits, and publishes.
---

# Publish dtui

Publish `packages/dtui` to pub.dev with pre-flight checks and version management.

## Usage

- `/publish-dtui` — Publish with auto-detected version bump (patch)
- `/publish-dtui <version>` — Publish a specific version (e.g., `0.2.0`, `1.0.0`)
- `/publish-dtui patch|minor|major` — Bump by semver level

## Steps

1. **Ensure clean state.** Working tree must be clean and on the `main` branch. Refuse to publish from a feature branch.

2. **Run pre-flight checks:**
   ```bash
   dart analyze packages/dtui
   dart test -r expanded packages/dtui/
   dart pub publish --dry-run -C packages/dtui
   ```
   If any check fails, stop and report the issue.

3. **Determine the new version.**
   - Read the current version from `packages/dtui/pubspec.yaml`.
   - If the user provided an explicit version, use it.
   - If the user provided `patch`, `minor`, or `major`, bump accordingly.
   - If no argument was given, default to a `patch` bump.
   - Confirm the version with the user before proceeding.

4. **Update version in `packages/dtui/pubspec.yaml`.**

5. **Update `packages/dtui/CHANGELOG.md`.**
   - Add a new `## <version>` section at the top.
   - Ask the user for release notes, or generate from commits since the last version tag.

6. **Commit and tag:**
   ```bash
   git add packages/dtui/pubspec.yaml packages/dtui/CHANGELOG.md
   git commit -m "release: dtui v<version>"
   git tag dtui-v<version>
   ```

7. **Push commit and tag:**
   ```bash
   git push origin main
   git push origin dtui-v<version>
   ```

8. **Publish to pub.dev:**
   ```bash
   dart pub publish --force -C packages/dtui
   ```

9. **Confirm success.** Report the published version and link: `https://pub.dev/packages/dtui/versions/<version>`

## Rules

- Never publish from a dirty working tree or feature branch.
- Always run the full check suite before publishing.
- Always confirm the version with the user before making changes.
- Never skip the dry-run step.
- If the user has not authenticated with pub.dev (`dart pub token`), warn them and stop.
