# annotate.nvim

A Neovim plugin for adding code review comments with virtual text display and [Trouble.nvim](https://github.com/folke/trouble.nvim) integration.

## Features

- **Visual Selection Annotations** - Select lines and add review comments
- **Virtual Text Display** - Comments appear as virtual text above annotated code
- **Sign Column Indicators** - Visual markers in the gutter for annotated ranges
- **Drift Detection** - Warns when annotated code has been modified
- **Trouble.nvim Integration** - Browse, filter, and manage annotations
- **Export/Import** - Save annotations to markdown files for sharing
- **Navigation** - Jump between annotations with `]r` / `[r`
- **Session Persistence** - Annotations survive buffer close/reopen (within session)

## Requirements

- Neovim >= 0.9.0
- [trouble.nvim](https://github.com/folke/trouble.nvim) (optional, for list view)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- lua/custom/plugins/annotate.lua
-- The plugin is self-contained and auto-initializes
return {}
```

Or if extracting to a separate repo:

```lua
{
  'username/annotate.nvim',
  config = function()
    require('annotate').setup()
  end,
}
```

## Configuration

```lua
require('annotate').setup({
  -- Keymaps (set to false to disable)
  keymaps = {
    add = '<leader>ra',           -- Add annotation (visual mode)
    list = '<leader>rl',          -- Open Trouble list
    yank = '<leader>ry',          -- Copy all to clipboard
    delete = '<leader>rd',        -- Delete under cursor
    edit = '<leader>re',          -- Edit under cursor
    delete_all = '<leader>rD',    -- Delete all (with confirm)
    undo = '<leader>ru',          -- Undo last delete
    write = '<leader>rw',         -- Export to markdown file
    import = '<leader>ri',        -- Import from markdown file
    next_annotation = ']r',       -- Jump to next
    prev_annotation = '[r',       -- Jump to previous
  },

  -- Floating input window
  float = {
    width = 40,
    height = 3,
    border = 'rounded',
  },

  -- Virtual text appearance
  virtual_text = {
    prefix = ' ',              -- Icon before comment text
    max_length = 60,              -- Truncate after this length
  },

  -- Sign column
  sign = {
    text = '',                   -- Sign icon
    hl = 'DiagnosticSignInfo',    -- Highlight group
  },

  -- Highlight groups
  highlights = {
    virtual_text = 'Comment',
    virtual_text_drifted = 'DiagnosticWarn',
    sign = 'DiagnosticSignInfo',
    sign_drifted = 'DiagnosticSignWarn',
  },
})
```

## Usage

### Adding Annotations

1. Visual select the lines you want to annotate
2. Press `<leader>ra`
3. Type your comment in the floating window
4. Press `<C-s>` to save or `<C-c>` / `<Esc>` to cancel

### Keymaps

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ra` | Visual | Add annotation to selection |
| `<leader>rl` | Normal | Open annotation list (Trouble) |
| `<leader>ry` | Normal | Yank all annotations to clipboard |
| `<leader>rd` | Normal | Delete annotation under cursor |
| `<leader>re` | Normal | Edit annotation under cursor |
| `<leader>rD` | Normal | Delete all annotations (with confirm) |
| `<leader>ru` | Normal | Undo last deletion |
| `<leader>rw` | Normal | Export to markdown file |
| `<leader>ri` | Normal | Import from markdown file |
| `]r` | Normal | Jump to next annotation |
| `[r` | Normal | Jump to previous annotation |

### Trouble Integration

When viewing annotations in Trouble (`<leader>rl`):

| Key | Action |
|-----|--------|
| `d` | Delete selected annotation |
| `e` | Edit selected annotation |
| `f` | Cycle filter (all → current buffer → drifted → all) |
| `q` | Close Trouble |

### Drift Detection

When the code under an annotation changes, the annotation is marked as "drifted":
- Virtual text changes to warning highlight (orange/yellow)
- Sign column indicator changes to warning color
- In Trouble, drifted annotations show a warning icon

This helps identify annotations that may need review after code changes.

## Export Format

Annotations export to markdown with the following format:

```markdown
# Code Review Annotations

## File: /path/to/file.luaL10:L15

```lua
original code
from lines 10-15
```

**Comment:** Your annotation text here

---
```

Drifted annotations include a `⚠️ DRIFTED` marker in the header.

## API

Access the plugin programmatically via `_G.Annotate` or `require('annotate')`:

```lua
local annotate = _G.Annotate

-- Add annotation programmatically
annotate.add(start_line, end_line)

-- Get annotation under cursor
local ann = annotate.get_under_cursor()

-- Get all annotations
local all = annotate.get_all()

-- Delete by ID
annotate.delete_by_id(id)

-- Edit by ID
annotate.edit_by_id(id)

-- Navigation
annotate.next_annotation()
annotate.prev_annotation()

-- Export/Import
annotate.write_to_file()
annotate.import_from_file()

-- List management
annotate.open_list()
annotate.yank_all()
annotate.delete_all()
annotate.undo_delete()
```

## Highlights

The plugin uses these highlight groups (customize in your colorscheme):

| Group | Default Link | Usage |
|-------|--------------|-------|
| `Comment` | - | Normal virtual text |
| `DiagnosticWarn` | - | Drifted virtual text |
| `DiagnosticSignInfo` | - | Normal sign |
| `DiagnosticSignWarn` | - | Drifted sign |

## Known Limitations

- Annotations are session-only by default (lost on Neovim quit)
- Use export/import for persistence across sessions
- No git integration (works on any file)

## Related Plugins

- [trouble.nvim](https://github.com/folke/trouble.nvim) - Diagnostics list (optional dependency)
- [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) - TODO comment highlighting
- [Comment.nvim](https://github.com/numToStr/Comment.nvim) - Code commenting

## License

MIT
