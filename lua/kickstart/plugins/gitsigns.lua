-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do

-- Cross-file git hunk navigation
local function get_files_with_hunks()
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    return {}
  end

  -- Get both staged and unstaged changed files
  local files = vim.fn.systemlist 'git diff --name-only HEAD'
  if vim.v.shell_error ~= 0 then
    files = vim.fn.systemlist 'git diff --name-only'
  end

  -- Convert to absolute paths
  local abs_files = {}
  for _, f in ipairs(files) do
    if f ~= '' then
      table.insert(abs_files, git_root .. '/' .. f)
    end
  end
  return abs_files
end

local function find_current_file_index(files, current_file)
  for i, f in ipairs(files) do
    if f == current_file then
      return i
    end
  end
  return nil
end

local function nav_to_file_hunk(direction)
  local files = get_files_with_hunks()
  if #files == 0 then
    vim.notify('No files with git changes', vim.log.levels.INFO)
    return
  end

  local current_file = vim.fn.expand '%:p'
  local current_idx = find_current_file_index(files, current_file)
  local gs = package.loaded.gitsigns

  -- If current file has hunks, try navigating within it first
  if current_idx and gs then
    local hunks = gs.get_hunks()
    if hunks and #hunks > 0 then
      local cursor_line = vim.fn.line '.'

      if direction == 'next' then
        -- Check if there's a hunk after cursor in current file
        for _, hunk in ipairs(hunks) do
          if hunk.added.start > cursor_line then
            gs.nav_hunk 'next'
            return
          end
        end
      else
        -- Check if there's a hunk before cursor in current file
        for i = #hunks, 1, -1 do
          if hunks[i].added.start < cursor_line then
            gs.nav_hunk 'prev'
            return
          end
        end
      end
    end
  end

  -- Navigate to next/prev file with hunks
  local target_idx
  if direction == 'next' then
    if current_idx then
      target_idx = current_idx + 1
      if target_idx > #files then
        target_idx = 1 -- Loop to first file
      end
    else
      target_idx = 1
    end
  else
    if current_idx then
      target_idx = current_idx - 1
      if target_idx < 1 then
        target_idx = #files -- Loop to last file
      end
    else
      target_idx = #files
    end
  end

  local target_file = files[target_idx]
  if target_file == current_file then
    -- Only one file with changes, wrap within it
    if gs then
      gs.nav_hunk(direction == 'next' and 'first' or 'last')
    end
    return
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(target_file))
  -- Wait for gitsigns to attach, then jump to first/last hunk
  vim.schedule(function()
    local new_gs = package.loaded.gitsigns
    if new_gs then
      new_gs.nav_hunk(direction == 'next' and 'first' or 'last')
    end
  end)
end

-- Set up global cross-file hunk navigation keymaps
vim.keymap.set('n', '}G', function()
  nav_to_file_hunk 'next'
end, { desc = '[G]it Next Hunk (cross-file)' })

vim.keymap.set('n', '{G', function()
  nav_to_file_hunk 'prev'
end, { desc = '[G]it Prev Hunk (cross-file)' })

return {
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']g', function()
            if vim.wo.diff then
              return ']g'
            end
            vim.schedule(function()
              gs.nav_hunk 'next'
            end)
            return '<Ignore>'
          end, { expr = true, desc = '[G]it Next Hunk' })

          map('n', '[g', function()
            if vim.wo.diff then
              return '[g'
            end
            vim.schedule(function()
              gs.nav_hunk 'prev'
            end)
            return '<Ignore>'
          end, { expr = true, desc = '[G]it Previous Hunk' })

          map('n', '<leader>ga', gs.stage_hunk, { desc = '[G]it Stage Hunk ([A]dd)' })
          map('n', '<leader>gf', gs.stage_buffer, { desc = '[G]it Stage [F]ile' })
          map('n', '<leader>gb', gs.blame_line, { desc = '[G]it [B]lame Line' })
          map('n', '<leader>gdd', function()
            gs.diffthis()
          end, { desc = '[G]it [D]iff current changes' })
          map('n', '<leader>gdm', function()
            gs.diffthis('origin/main')
          end, { desc = '[G]it [D]iff [M]ain' })
          map('n', '<leader>gdn', function()
            gs.diffthis('origin/master')
          end, { desc = '[G]it [D]iff Master' })
        end,
      }
    end,
  },
}
