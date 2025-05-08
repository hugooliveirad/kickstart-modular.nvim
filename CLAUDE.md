# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Neovim Configuration Structure

This repository contains a Neovim configuration based on the kickstart-modular.nvim framework, which provides a modular organization of Neovim settings.

The main configuration files are:
- `init.lua` - Main entry point that loads all other configuration modules
- `lua/options.lua` - General Neovim options and settings
- `lua/keymaps.lua` - Key mappings and shortcuts
- `lua/lazy-bootstrap.lua` - Sets up the lazy.nvim plugin manager
- `lua/lazy-plugins.lua` - Core plugin configuration

## Plugin Structure

Plugins are organized in two main directories:
- `lua/kickstart/plugins/` - Core plugins from the kickstart configuration
- `lua/custom/plugins/` - Custom user plugins

When adding new plugins:
1. Create a new Lua file in `lua/custom/plugins/`
2. Return a plugin specification table compatible with lazy.nvim
3. The plugin will be automatically loaded through the `{ import = 'custom.plugins' }` directive in `lua/lazy-plugins.lua`

## Key Plugins

This Neovim configuration includes several key plugins:
- **Tokyo Night** (tokyonight.nvim) - Primary colorscheme
- **Neo-Tree** (neo-tree.nvim) - File explorer
- **Trouble** (trouble.nvim) - Diagnostics viewer
- **Avante** (avante.nvim) - AI-powered coding assistant
- **Vim-Obsession** - Session management
- **Autopairs** - Automatic bracket/quote pairing
- **Vim-Tmux-Navigator** - Seamless navigation between Neovim and tmux panes

## Keyboard Shortcuts

Key mappings include:
- `<Space>` as leader key
- `<leader>.` - Open Neo-Tree file explorer
- `<leader>gs` - Open Neo-Tree git status view
- `<leader>wd` - Toggle Trouble workspace diagnostics
- `<leader>dd` - Toggle Trouble document diagnostics
- `<leader>wq` - Toggle Trouble quickfix list
- `<C-h/j/k/l>` - Navigate between splits (also works with tmux)
- `<leader>Sw` - Save session to /tmp/se1.vim
- `<leader>So` - Load session from /tmp/se1.vim

## Development Guidelines

When modifying this Neovim configuration:
1. Maintain the modular structure by organizing related settings in appropriate files
2. Follow the lazy.nvim plugin specification format for adding new plugins
3. Keep custom plugins in the `lua/custom/plugins/` directory
4. Document new keymaps in comments or in relevant plugin configurations
5. Never commit without asking first