# dtui

A zero-dependency terminal UI framework for Dart. 

## Features

- **Widget system** — composable widgets with `render()`, `measure()`, and `handleEvent()`
- **Layout engine** — flexible splits with `SplitSpec.flex()` and `SplitSpec.fixed()`
- **Diff renderer** — minimal ANSI output by diffing frame buffers
- **Input parsing** — full keyboard event parsing including modifiers, arrow keys, and escape sequences
- **Styling** — 256-color support with bold, dim, italic, underline, inverse, and strikethrough

## Widgets

| Widget | Description |
|---|---|
| `Text` | Single-style text with word wrapping |
| `RichText` | Multi-styled inline spans |
| `ListView` | Scrollable, selectable list with keyboard navigation |
| `SplitPane` | Horizontal or vertical layout splits |
| `Border` | Rounded border with optional title |
| `TextInput` | Single-line editable text field with cursor |
| `Popup` | Centered overlay with border and title |
| `Scrollbar` | Vertical scrollbar with proportional thumb |

## Installation

```yaml
dependencies:
  dtui: ^0.1.0
```

Or:

```bash
dart pub add dtui
```

## Quick start

```dart
import 'package:dtui/dtui.dart';

void main() async {
  late final DTuiApp app;

  app = DTuiApp(
    buildRoot: () {
      return Border(
        title: 'Hello',
        child: Text('Welcome to dtui!'),
      );
    },
    onEvent: (event) {
      if (event is KeyEvent && event.key == 'q') {
        app.exit();
      }
    },
  );

  await app.run();
}
```

See [`example/demo.dart`](example/demo.dart) for a full demo showcasing every widget.
