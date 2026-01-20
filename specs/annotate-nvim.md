# annotate.nvim - Specification

A Neovim plugin for adding review comments to code with virtual text display and Trouble integration.

## Overview

**Purpose:** Enable code review workflow within Neovim by adding comments to selected lines, displaying them as virtual text, and navigating/exporting them.

**Scope:** Standalone plugin - works on any file, no git dependency.

## Core Features

### 1. Adding Comments

- **Trigger:** Visual select lines, press keybinding (`<leader>ra` in prototype)
- **Input:** Command line input at bottom of screen (vim.ui.input)
- **Storage:** Session-only (in-memory), lost on Neovim quit
- **Multiple comments:** Allow multiple independent comments on same/overlapping lines

### 2. Display

- **Virtual text:** Displayed at end of the first line of selection (EOL), truncated with `...` if long
- **Sign column:** Icon indicator on all lines within the commented range
- **Line highlight:** Optional background color on all annotated lines (configurable)
- **Drift detection:** Comments store original code snippet; if content changes, display with different (warning) highlight color

### 3. Comment List Panel

- **Implementation:** Trouble.nvim custom source
- **Shows:** All comments across all buffers in session
- **Navigation:** Standard Trouble keybindings to jump to comment locations
- **Full text:** List shows complete comment text (not truncated)

### 4. Edit/Delete Comments

- **Edit:** Re-opens same floating window pre-filled with existing comment
- **Delete:** Instant (no confirmation prompt)
- **Undo:** Support restoration of recently deleted comments (stack-based)

### 5. Copy/Export

- **Scope:** Single keybinding copies ALL comments in session
- **Format:**
```
File: path/to/file.luaL10:L15
```lua
original selected code
from lines 10-15
```
Comment: User's comment text here

---

File: path/to/other.luaL5:L5
```lua
single line
```
Comment: Another comment
```

## Data Structure

```lua
---@class Annotation
---@field id number Unique identifier
---@field bufnr number Buffer number
---@field file string Absolute file path
---@field start_line number 1-indexed start line
---@field end_line number 1-indexed end line
---@field original_content string[] Original lines (for drift detection)
---@field comment string The annotation text
---@field created_at number Timestamp
---@field extmark_id number|nil Extmark ID for tracking
---@field sign_ids number[] Sign IDs for the range
---@field drifted boolean Whether content has changed
```

## Keybindings

Configurable via setup(), prototype defaults:

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ra` | v | Add comment to visual selection |
| `<leader>rl` | n | Open Trouble list of all comments |
| `<leader>rs` | n | Open Telescope picker for comments |
| `<leader>ry` | n | Copy all comments to clipboard |
| `<leader>rd` | n | Delete comment under cursor |
| `<leader>re` | n | Edit comment under cursor |
| `<leader>rD` | n | Delete all comments (with confirmation) |
| `<leader>ru` | n | Undo last delete |
| `<leader>rw` | n | Write annotations to markdown file |
| `<leader>ri` | n | Import annotations from markdown file |
| `]r` | n | Jump to next annotation |
| `[r` | n | Jump to previous annotation |

## Commands

All operations available via `:Annotate` command with tab completion:

| Command | Action |
|---------|--------|
| `:Annotate` | Open Trouble list (default) |
| `:Annotate add` | Add annotation on current line |
| `:Annotate list` | Open Trouble list |
| `:Annotate telescope` | Open Telescope picker |
| `:Annotate delete` | Delete annotation under cursor |
| `:Annotate edit` | Edit annotation under cursor |
| `:Annotate yank` | Copy all annotations to clipboard |
| `:Annotate write` | Export to markdown file |
| `:Annotate import` | Import from markdown file |
| `:Annotate undo` | Undo last delete |
| `:Annotate clear` | Delete all annotations |
| `:Annotate next/prev` | Jump to next/prev annotation |
| `:Annotate help` | Show help |

Shortcuts: `:AnnotateAdd`, `:AnnotateList`, `:AnnotateTelescope`, `:AnnotateDelete`, `:AnnotateEdit`

## Configuration

```lua
require('annotate').setup({
  -- Keymaps (set to false to disable)
  keymaps = {
    add = '<leader>ra',
    list = '<leader>rl',
    telescope = '<leader>rs',
    yank = '<leader>ry',
    delete = '<leader>rd',
    edit = '<leader>re',
    delete_all = '<leader>rD',
    undo = '<leader>ru',
    write = '<leader>rw',
    import = '<leader>ri',
    next_annotation = ']r',
    prev_annotation = '[r',
  },

  -- Virtual text
  virtual_text = {
    prefix = ' ',  -- or custom icon
    max_length = 60,  -- truncate after this
  },

  -- Sign column
  sign = {
    text = '',  -- or '', ''
    hl = 'DiagnosticSignInfo',
  },

  -- Highlights
  highlights = {
    virtual_text = 'Comment',
    virtual_text_drifted = 'DiagnosticWarn',
    sign = 'DiagnosticSignInfo',
    sign_drifted = 'DiagnosticSignWarn',
    line = 'Visual',              -- Background highlight for annotated lines (or false to disable)
    line_drifted = 'DiffDelete',  -- Background highlight for drifted annotated lines
  },

  -- Persistence (optional)
  persist = {
    enabled = false,              -- Set to true to auto-save/load annotations
    path = '.annotations.json',   -- Path relative to cwd, or absolute
  },
})
```

## Implementation Notes

### Extmarks for Position Tracking

Use `nvim_buf_set_extmark()` with `right_gravity = false` to track line positions as buffer changes. Extmarks automatically move with text edits.

### Line Background Highlighting

Use extmarks with `line_hl_group` to highlight the background of annotated lines:

```lua
-- For each line in the annotated range
vim.api.nvim_buf_set_extmark(bufnr, namespace, line - 1, 0, {
  line_hl_group = config.highlights.line,  -- e.g., 'Visual' or custom highlight
  end_line = line,  -- Single line highlight
})
```

Store extmark IDs in annotation for cleanup. Set `highlights.line = false` to disable this feature.

### Drift Detection

On `BufEnter` or `TextChanged`, compare current line content against stored `original_content`. If mismatch, set `drifted = true` and update highlights.

### Trouble Integration

Register custom source with trouble.nvim:

```lua
-- Pseudo-code for Trouble source
require('trouble').register_source('annotate', {
  get = function()
    return annotations_to_trouble_items()
  end,
})
```

### Undo Stack

Maintain a stack of last N deleted annotations (default 10) for restoration:

```lua
local undo_stack = {}  -- { annotation, annotation, ... }
local max_undo = 10
```

## File Structure

```
lua/custom/plugins/annotate.lua   -- Plugin spec + implementation
```

Single-file plugin for simplicity. Can be extracted to separate repo later if desired.

## Edge Cases

1. **Buffer closed:** Annotations remain in memory, re-applied when buffer reopens
2. **File not saved:** Works on unsaved buffers, uses bufnr as fallback identifier
3. **Very long selection:** Sign column shows all lines, virtual text only above first line
4. **Empty selection:** Treat as single line annotation
5. **Binary files:** No special handling, works but may look odd

## Non-Goals (Out of Scope)

- File persistence across sessions
- Git/commit integration
- Team sharing/collaboration
- Diffview integration
- Markdown rendering in virtual text
