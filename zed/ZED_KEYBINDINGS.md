# Zed Editor - Custom Keybindings Reference

This document describes all custom keybindings configured for Zed Editor with Vim mode enabled.

## 📚 Table of Contents

- [Keybinding Syntax](#keybinding-syntax)
- [Pane Management](#pane-management)
- [Navigation](#navigation)
- [File & Project Operations](#file--project-operations)
- [Tab Management](#tab-management)
- [Editing & Text Manipulation](#editing--text-manipulation)
- [LSP & Code Intelligence](#lsp--code-intelligence)
- [Search & Replace](#search--replace)
- [Terminal](#terminal)
- [Git Operations](#git-operations)
- [Vim Mode Specific](#vim-mode-specific)

---

## Keybinding Syntax

Understanding the notation:

- **`ctrl-h`** (dash) = Hold `Ctrl` and press `H` **simultaneously**
- **`space f`** (space) = Press `Space`, release, then press `F` (sequence/chord)
- **`space l s`** = Press `Space`, release, press `L`, release, press `S` (3-key sequence)

---

## Pane Management

### Moving Tabs Between Panes (VSCode-style)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+Alt+L` | Move tab to right pane | Moves current tab to right pane (creates split if needed) |
| `Ctrl+Alt+H` | Move tab to left pane | Moves current tab to left pane (empty panes auto-close) |

**Behavior:**
- First `Ctrl+Alt+L`: Creates right pane and moves tab
- Second `Ctrl+Alt+L`: Creates 3rd pane (splits further right)
- `Ctrl+Alt+H`: Moves tab back left (auto-closes empty panes)

### Switching Focus Between Panes

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+H` | Focus left pane | Switch focus to the left pane |
| `Ctrl+L` | Focus right pane | Switch focus to the right pane |

### Resizing Panes

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+→` | Expand pane right | Increase current pane width (expand right) |
| `Ctrl+←` | Expand pane left | Decrease current pane width (expand left) |
| `Ctrl+↑` | Expand pane up | Increase current pane height (expand up) |
| `Ctrl+↓` | Expand pane down | Decrease current pane height (expand down) |

---

## Navigation

### Tab Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+J` | Previous tab | Switch to previous tab (workspace-wide) |
| `Ctrl+K` | Next tab | Switch to next tab (workspace-wide) |
| `Shift+H` | Previous tab (vim) | Switch to previous tab in current pane |
| `Shift+L` | Next tab (vim) | Switch to next tab in current pane |
| `Space 1-8` | Go to tab N | Jump directly to tab 1-8 |

### Scrolling

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+J` | Scroll down | Scroll viewport down without moving cursor |
| `Ctrl+K` | Scroll up | Scroll viewport up without moving cursor |

### List Navigation (Universal)

| Keybinding | Action | Context |
|------------|--------|---------|
| `Ctrl+N` | Select next | Works in file finder, autocomplete, menus, project panel |
| `Ctrl+P` | Select previous | Works in file finder, autocomplete, menus, project panel |

---

## File & Project Operations

### File Finder & Project Panel

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Space F` | File finder | Open fuzzy file finder |
| `Space E` | Toggle project panel focus | Toggle focus between editor and file tree |
| `Space P E` | Toggle left dock | Show/hide left dock (project panel) |

### Project Panel Operations (when focused)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `A` | New file | Create new file |
| `D` | Delete | Delete file/folder |
| `R` | Rename | Rename file/folder |
| `Space E` | Back to editor | Return focus to editor |

### Projects

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Space R P` | Open recent project | Show recent projects list |

---

## Tab Management

### Closing Tabs

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Space C` | Close current tab | Close active tab/buffer |
| `Space Q` | Close all tabs | Close all tabs in current pane |
| `Space B L` | Close tabs to the right | Close all tabs to the right of current |
| `Space B H` | Close tabs to the left | Close all tabs to the left of current |
| `Space B A` | Reopen closed tab | Reopen the last closed tab |

---

## Editing & Text Manipulation

### Line Movement

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt+J` | Move line down | Move current line or selection down |
| `Alt+K` | Move line up | Move current line or selection up |

### Selection

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+A` | Expand selection | Select enclosing symbol (expand) |
| `Ctrl+S` | Shrink selection | Select smaller syntax node (shrink) |

### Comments

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Space /` | Toggle comments | Comment/uncomment current line or selection |

### Code Folding

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Shift+F` | Unfold | Unfold code block (normal mode) |
| `Shift+F` | Fold | Fold selected code (visual mode) |

### Custom Formatting Macros

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Space Z F` | Format line | Format current line |
| `Space Z A` | Format file | Format entire file |

### Save Operations

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Space W` | Save file | Save current file |
| `Space A` | Save all | Save all modified files |

---

## LSP & Code Intelligence

### Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `G D` | Go to definition | Jump to symbol definition |
| `G I` | Go to implementation | Jump to symbol implementation |
| `G R` | Find all references | Find all references to symbol |
| `Space L I` | Go to implementation (split) | Open implementation in split pane |

### Code Actions

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Space L R` | Rename symbol | Rename symbol across project |
| `Space L J` | Go to diagnostic | Jump to next error/warning |
| `Space L S` | Project symbols | Toggle project symbols outline |

### Autocomplete & Code Actions Menu

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Tab` | Next suggestion | Navigate to next item in menu |
| `Shift+Tab` | Previous suggestion | Navigate to previous item in menu |
| `Page Down` | Last suggestion | Jump to last item |
| `Page Up` | First suggestion | Jump to first item |

---

## Search & Replace

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Space S T` | New search | Open workspace-wide search |
| `Escape` | Dismiss search | Close search buffer |

---

## Terminal

### Terminal Management

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Space T` | New terminal | Open new terminal in center |
| `Ctrl+Space` | Toggle terminal | Show/hide bottom dock (terminal) |
| `Ctrl+O` | New terminal tab | Create new terminal tab |

### Terminal Tab Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+N` | Next terminal tab | Switch to next terminal |
| `Ctrl+P` | Previous terminal tab | Switch to previous terminal |

### Terminal Tab Management

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+Q` | Close terminal tab | Close current terminal |
| `Ctrl+K` | Close inactive tabs | Close all inactive terminal tabs |
| `Ctrl+B` | Close tabs to left | Close terminal tabs to the left |
| `Ctrl+I` | Close tabs to right | Close terminal tabs to the right |

### Terminal Operations

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+L` | Clear terminal | Clear terminal screen |

---

## Git Operations

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Space G B` | Git branch | Open git branch operations |

---

## Vim Mode Specific

### Escape to Normal Mode

| Keybinding | Context | Description |
|------------|---------|-------------|
| `JK` | Insert mode | Quick escape to normal mode |
| `KJ` | Insert mode | Quick escape to normal mode |
| `J K` | Insert mode | Quick escape (with pause) |
| `K J` | Insert mode | Quick escape (with pause) |

### Visual Mode Line Movement

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Shift+K` | Move lines up | Move selected lines up |
| `Shift+J` | Move lines down | Move selected lines down |

### Vim Sneak Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `S` | Sneak forward | 2-character search forward |
| `Shift+S` | Sneak backward | 2-character search backward |

---

## Command Palette

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+Q` | Command palette | Open command palette |
| `Space R` | Command palette | Alternative binding |

---

## 🎯 Most Useful Keybindings (Quick Reference)

### Daily Essentials

```
Ctrl+Alt+L/H   → Move tabs between panes (VSCode-style split)
Ctrl+H/L       → Switch focus between panes
Space F        → Open file finder
Space E        → Toggle project panel
Space C        → Close current tab
Space W        → Save file
G D            → Go to definition
Space L R      → Rename symbol
Space /        → Toggle comments
JK             → Escape to normal mode (from insert)
Ctrl+Space     → Toggle terminal
```

### Power User Tips

1. **Split Workflow**: Use `Ctrl+Alt+L` to create splits, `Ctrl+H/L` to navigate between them
2. **Quick Tab Access**: Use `Space 1-8` to jump to specific tabs instantly
3. **Fuzzy Everything**: `Ctrl+N/P` works consistently across all menus and lists
4. **Clean Workspace**: Empty panes automatically close when you move tabs away
5. **Vim Escape**: Multiple escape sequences (`jk`, `kj`) make it easier to exit insert mode

---

## 📁 Configuration Location

- **Keymap file**: `~/.config/zed/keymap.json`
- **Settings file**: `~/.config/zed/settings.json`

## 🔗 Resources

- [Zed Keybindings Documentation](https://zed.dev/docs/key-bindings)
- [Zed Vim Mode Documentation](https://zed.dev/docs/vim)
- [All Zed Actions](https://zed.dev/docs/all-actions)

---

**Last Updated**: 2026-02-10
**Zed Version**: Stable
**Vim Mode**: Enabled
