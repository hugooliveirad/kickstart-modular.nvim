# CLAUDE.md

Guidance for Claude Code when working with this Neovim configuration.

## File Structure

```
init.lua                    # Entry point
lua/
├── options.lua             # Neovim settings (tabs, undo, search)
├── keymaps.lua             # Global keymaps
├── lazy-bootstrap.lua      # Lazy.nvim setup
├── lazy-plugins.lua        # Plugin orchestration
├── kickstart/
│   ├── health.lua          # Health check module
│   └── plugins/            # Base framework plugins
│       ├── lspconfig.lua   # LSP configuration
│       ├── cmp.lua         # Autocompletion
│       ├── telescope.lua   # Fuzzy finder
│       ├── treesitter.lua  # Syntax highlighting
│       ├── gitsigns.lua    # Git signs + hunk ops
│       ├── conform.lua     # Code formatting
│       ├── mini.lua        # Statusline, surround
│       ├── todo-comments.lua # TODO highlighting
│       ├── debug.lua       # DAP debugging
│       ├── indent_line.lua # Indent guides
│       └── tokyonight.lua  # Tokyo Night theme
└── custom/plugins/         # User additions
    ├── colorscheme.lua     # Vague (active) + alternatives
    ├── filetree.lua        # Neo-tree file explorer
    ├── trouble.lua         # Diagnostics panel
    ├── lazygit.lua         # Git UI
    ├── diffview.lua        # Diff viewer
    ├── typescript-tools.lua # TS-specific LSP
    ├── vim-obsession.lua   # Session management
    ├── autopairs.lua       # Auto bracket pairing
    ├── nvim-tmux-navigation.lua # Tmux integration
    ├── augmentcode.lua     # Code completion
    ├── avante.lua          # AI assistant (disabled)
    └── which-key.lua       # Keymap hints (disabled)
```

## Plugin Categories

| Category | Plugins |
|----------|---------|
| UI/Theme | vague (active), tokyonight, gruvbox, neo-tree |
| LSP | lspconfig, mason, typescript-tools |
| Completion | nvim-cmp, LuaSnip, autopairs |
| Search | telescope, fzf-native |
| Git | gitsigns, lazygit, diffview |
| Editing | mini.surround, conform, Comment.nvim |
| Navigation | vim-tmux-navigator |
| Utilities | trouble, vim-obsession, todo-comments |

## Key Keymaps

Leader: `<Space>`

| Prefix | Domain |
|--------|--------|
| `<leader>s*` | Search (telescope) |
| `<leader>g*` | Git operations |
| `<leader>d*` | Diagnostics/Diff |
| `<leader>y*` | Copy utilities |

Core:
- `<leader>.` - Neo-tree (float)
- `<leader>gs` - Git status (float)
- `<leader>gg` - LazyGit
- `<leader>sf` / `<C-p>` - Find files
- `<leader>sg` - Live grep
- `gd` / `gr` - Go to definition/references

## Configuration Patterns

1. **Lazy loading**: Most plugins load via events/commands
2. **Float-first UI**: Neo-tree, LSP dialogs use floating windows
3. **Buffer-local keymaps**: LSP keymaps attached per buffer
4. **Custom in `custom/`**: Never modify kickstart/ files

## Adding Plugins

1. Create file in `lua/custom/plugins/`
2. Return lazy.nvim spec: `return { 'author/plugin', opts = {} }`
3. Auto-loaded via `{ import = 'custom.plugins' }`

## Development Rules

1. Keep custom plugins in `lua/custom/plugins/`
2. Follow lazy.nvim plugin spec format
3. Document keymaps in plugin config
4. Never commit without asking first
