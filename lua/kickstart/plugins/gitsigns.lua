-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do

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
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = '[G]it Next Hunk' })

          map('n', '[g', function()
            if vim.wo.diff then
              return '[g'
            end
            vim.schedule(function()
              gs.prev_hunk()
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
