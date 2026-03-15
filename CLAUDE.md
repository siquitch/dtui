# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

All commands run from the workspace root. Dart workspace resolution means `dart pub get`, `dart analyze`, and `dart test` operate across both packages automatically.

```bash
dart pub get                                              # Install deps for entire workspace
dart analyze                                              # Lint all packages
dart test -r expanded packages/gittui/                    # Run all tests (tests live in gittui)
dart compile exe packages/gittui/bin/gittui.dart -o build/gittui  # Build executable

# Single test file
dart test packages/gittui/test/git/file_commands_test.dart
```

## Architecture

Three-layer monorepo with two packages (`packages/gittui` app, `packages/dtui` framework). `dtui` is a zero-dependency custom TUI framework; `gittui` depends on it via workspace path resolution.

### Layer 1: Git Abstraction (`gittui/lib/src/git/`)

`GitRepository` is a facade over command classes (`StatusCommands`, `FileCommands`, `BranchCommands`, etc.) that each wrap `GitCommandRunner`. The runner executes git via `Process.run()`, logs results to `CommandLogEntry`, and throws `GitCommandException` on failure. Use `runAllowFailure()` for commands where non-zero exit is expected.

Models (`git/models/`) are immutable value objects using `equatable`.

### Layer 2: App State & Controllers (`gittui/lib/src/app/`)

**State is immutable** with `copyWith()`:
- `AppState` → `GitState` (files, branches, commits, stashes, remotes, diff, repo state) + `UiState` (active tab, popup state, sidebar width, messages)

**Controllers** extend abstract `Controller`, receive `getState()`/`setState()` callbacks, maintain `selectedIndex`, and implement `refresh()` + action methods. They mutate state only through `updateGitState()`/`updateUiState()` helpers. No widget references.

**RefreshCoordinator** selectively reloads data by scope (`RefreshScope.{files, branches, commits, status, stash}`).

**KeybindingRegistry** resolves `KeyEvent` to handlers with context-specific precedence (popup → context-specific → global). Default bindings defined in `DefaultKeybindings`.

### Layer 3: TUI Framework (`dtui/`)

Render loop: `Terminal.inputEvents` → `Widget.render(Canvas, Rect)` → `Buffer` (2D Cell grid) → `DiffRenderer` (minimal ANSI diff) → stdout.

Layout: `LayoutEngine.split()` with `SplitSpec.flex(ratio)` or `SplitSpec.fixed(pixels)`.

Widgets extend base `Widget` class with `render()`, `measure()`, `handleEvent()`.

### Data flow

Unidirectional: State → Render → KeyEvent → Controller action → setState() → re-render.

## Adding Features

Use the slash commands for guided scaffolding:
- `/add-panel <name>` — new sidebar tab (model → commands → controller → keybindings → view wiring)
- `/add-git-command <class> <method>` — new method on an existing command class
- `/add-widget <name>` — new TUI widget with tests

## Conventions

- Snake_case files, PascalCase classes
- Barrel exports: `commands.dart`, `models.dart` re-export siblings
- Dart SDK ^3.12.0-113.2.beta; lints from `package:lints/recommended.yaml`
- Config file location: `~/.config/gittui/custom_commands.yaml`
