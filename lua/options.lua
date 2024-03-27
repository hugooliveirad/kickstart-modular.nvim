-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
-- vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = false

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- vim: ts=2 sts=2 sw=2 et
vim.opt.foldlevelstart = 50
vim.opt.foldmethod = 'indent'

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Undo saved
local prefix = vim.env.XDG_CONFIG_HOME or vim.fn.expand '~/.config'

vim.opt.undofile = true
vim.opt.undodir = { prefix .. '/nvim/.undo//' }
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000

-- Disable these features
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Highlighting and Search
vim.opt.gdefault = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.showmatch = true
vim.opt.hlsearch = true
