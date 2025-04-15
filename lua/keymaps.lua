-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>n', '<cmd>e ~/notepad.md<CR>', { desc = 'Open notepad' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- vim: ts=2 sts=2 sw=2 et

-- Custom quality of life, got too used not to setup
vim.keymap.set('n', '<leader>c', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', 'Y', 'yy')

vim.keymap.set('n', ';', ':')

vim.keymap.set('n', '<leader>-', '<cmd>split<CR>')
vim.keymap.set('n', '<leader>\\', '<cmd>vsplit<CR>')

vim.keymap.set('n', '<C-s>', '<cmd>w<CR>')
vim.keymap.set('i', '<C-s>', '<esc><cmd>w<CR>')
vim.keymap.set('v', '<C-s>', '<esc><cmd>w<CR>')

vim.keymap.set('n', '<C-q>', '<cmd>q<CR>')
vim.keymap.set('i', '<C-q>', '<esc><cmd>q<CR>')
vim.keymap.set('v', '<C-q>', '<esc><cmd>q<CR>')

-- Custom terminal mode shortcuts
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true })
vim.keymap.set('t', '<C-h>', '<C-w>h', { noremap = true })
vim.keymap.set('t', '<C-j>', '<C-w>j', { noremap = true })
vim.keymap.set('t', '<C-k>', '<C-w>k', { noremap = true })
vim.keymap.set('t', '<C-l>', '<C-w>l', { noremap = true })

-- Quick session work
vim.keymap.set('n', '<leader>Sw', '<cmd>mksession! /tmp/se1.vim<CR>')
vim.keymap.set('n', '<leader>So', '<cmd>source /tmp/se1.vim<CR>')
