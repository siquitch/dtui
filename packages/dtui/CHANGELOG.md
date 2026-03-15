## 0.1.0

Initial release of dtui — a zero-dependency terminal UI framework for Dart.

### Widgets
- `Text` — single-style text with word wrapping
- `RichText` — multi-styled inline spans
- `ListView` — scrollable, selectable list with keyboard navigation
- `SplitPane` — horizontal or vertical layout splits
- `Border` — rounded border with optional title
- `TextInput` — single-line editable text field with cursor
- `Popup` — centered overlay with border and title
- `Scrollbar` — vertical scrollbar with proportional thumb

### Core
- Flex/fixed layout engine via `LayoutEngine.split()` with `SplitSpec.flex()` and `SplitSpec.fixed()`
- 256-color styling with bold, dim, italic, underline, inverse, and strikethrough
- Full keyboard input parsing including modifiers, arrow keys, and escape sequences
- Diff-based ANSI renderer that minimizes terminal output by diffing frame buffers
- `DTuiApp` entry point for wiring the render loop and event handling
