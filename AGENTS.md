# Repository Guidelines

## Project Structure & Module Organization
The Neovim entry point is `init.lua`, which bootstraps Lazy and loads core modules under `lua/kickstart`. Shared options, keymaps, and plugin bootstrap live in `lua/options.lua`, `lua/keymaps.lua`, and `lua/lazy-bootstrap.lua`. Add or adjust bundled plugin specs inside `lua/kickstart/plugins/`, and place custom extensions in `lua/custom/plugins/`—each file returns a Lazy spec table. Documentation lives in `doc/`, while pinned plugin versions are tracked in `lazy-lock.json` for reproducible setups.

## Build, Test & Development Commands
Run `nvim` to validate that the configuration loads without errors. Use `nvim --headless "+Lazy sync" +qa` after updating plugin specs to install or update dependencies. Apply formatters and linting with `stylua lua` (respects `.stylua.toml`) and `nvim --headless "+checkhealth" +qa` to surface runtime issues. Regenerate help tags after editing `doc/` via `nvim --headless ":helptags ALL" +qa`.

## Coding Style & Naming Conventions
Lua files use two-space indentation, Unix line endings, and prefer single quotes, matching `.stylua.toml`. Name modules after their Lazy feature (e.g., `telescope.lua`) and export a table keyed by plugin repo strings. Keep configuration functions small and favor local helper functions over globals. When adding keymaps or options, follow the comment style already present—top-level section headers explaining intent.

## Testing Guidelines
There is no automated test suite; rely on Neovim health checks and ad-hoc smoke testing. Before opening a pull request, run `nvim --headless "+checkhealth" +qa` and trigger relevant plugin commands in an interactive session. For significant changes, capture a minimal reproduction (e.g., sample buffer content or command sequence) in the pull request body.

## Commit & Pull Request Guidelines
Commits in this repo use imperative, sentence-case summaries under ~72 characters (e.g., `Add lazygit.nvim plugin`). Scope multi-file changes logically and avoid mixing formatting with functional edits. Pull requests should include: a short changelog-style summary, screenshots or terminal captures for UI tweaks, instructions for manual validation, and links to related issues or discussions. Reference updates to `lazy-lock.json` explicitly when plugin versions change, so reviewers can audit dependency impacts.

## Agent Workflow Tips
When scripting automated edits, load Neovim headless to verify changes and respect the lockfile by running Lazy sync afterwards. Prefer editing files within `lua/custom` for experimental plugins to keep core Kickstart modules stable, and upstream proven changes into `lua/kickstart` only after validation.
