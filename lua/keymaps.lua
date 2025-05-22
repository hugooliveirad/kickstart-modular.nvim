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
vim.keymap.set('n', '<leader>SS', '<cmd>mksession! /tmp/se1.vim<CR><cmd>lua vim.notify("Session saved to /tmp/se1.vim")<CR>')
vim.keymap.set('n', '<leader>SO', '<cmd>source /tmp/se1.vim<CR><cmd>lua vim.notify("Session loaded from /tmp/se1.vim")<CR>')

-- Copy file path
vim.keymap.set('n', '<leader>yy', function()
  local path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path)
end, { desc = 'Copy relative file path' })

-- Copy all diagnostics from current buffer
vim.keymap.set('n', '<leader>yd', function()
  local bufnr = 0 -- current buffer
  local diagnostics = vim.diagnostic.get(bufnr)

  if #diagnostics == 0 then
    vim.notify('No diagnostics found', vim.log.levels.INFO)
    return
  end

  local path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local result = path .. ' - Diagnostics:\n\n'

  -- Sort diagnostics by line and column
  table.sort(diagnostics, function(a, b)
    if a.lnum == b.lnum then
      return a.col < b.col
    end
    return a.lnum < b.lnum
  end)

  -- Format each diagnostic
  for _, diag in ipairs(diagnostics) do
    local severity = vim.diagnostic.severity[diag.severity] or 'UNKNOWN'
    local line = diag.lnum + 1 -- Convert to 1-based line numbering
    local col = diag.col + 1 -- Convert to 1-based column numbering
    local message = diag.message:gsub('\n', ' ') -- Replace newlines in message

    result = result .. string.format('[%s] Line %d, Col %d: %s\n', severity, line, col, message)
  end

  -- Copy to clipboard
  vim.fn.setreg('+', result)
  vim.notify('Copied ' .. #diagnostics .. ' diagnostics', vim.log.levels.INFO)
end, { desc = 'Copy all diagnostics from current buffer' })

-- Copy file path with line numbers and selection in visual mode
vim.keymap.set('v', '<leader>yy', function()
  -- Save the current register content and selection type
  local old_reg = vim.fn.getreg '"'
  local old_regtype = vim.fn.getregtype '"'

  -- Yank the selected text to the unnamed register
  vim.cmd 'normal! y'

  -- Get the selected text from the unnamed register
  local selected_text = vim.fn.getreg '"'

  -- Get file path and line information
  local path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  local line_start = vim.fn.line "'<"
  local line_end = vim.fn.line "'>"
  local lines = line_start == line_end and 'L' .. line_start or 'L' .. line_start .. '-L' .. line_end

  -- Combine file path, line numbers, and selected text with markdown code block
  local result = path .. ':' .. lines .. '\n```\n' .. selected_text .. '\n```'

  -- Copy the result to the clipboard
  vim.fn.setreg('+', result)
  vim.notify('Copied: ' .. path .. ':' .. lines)

  -- Restore the original register content and selection type
  vim.fn.setreg('"', old_reg, old_regtype)
end, { desc = 'Copy file path, line numbers, and selection' })
