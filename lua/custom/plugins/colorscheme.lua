return {
  -- {
  --   'ellisonleao/gruvbox.nvim',
  --   priority = 1000,
  --   config = function()
  --     local gruvbox = require 'gruvbox'
  --     gruvbox.setup {
  --       transparent_mode = true,
  --       bold = false,
  --       overrides = {
  --         LspReferenceRead = { bg = gruvbox.palette.dark2 },
  --         LspReferenceText = { bg = gruvbox.palette.dark2 },
  --         LspReferenceWrite = { bg = gruvbox.palette.dark2 },
  --         Cursor = { fg = gruvbox.palette.dark3, bg = gruvbox.palette.dark3 },
  --         iCursor = { fg = gruvbox.palette.dark4, bg = gruvbox.palette.dark4 },
  --       },
  --     }

  --     vim.o.guicursor = 'n-v-c-sm:block,i-ci-ve:block-iCursor,r-cr-o:block-iCursor'
  --     vim.cmd 'colorscheme gruvbox'
  --   end,
  -- },
  -- {
  --   'morhetz/gruvbox',
  --   priority = 1000,
  --   config = function()
  --     vim.cmd 'let g:gruvbox_contrast_dark="medium"'
  --     vim.cmd 'let g:gruvbox_sign_column="bg0"'
  --     vim.cmd 'let g:gruvbox_bold=0'
  --     vim.cmd 'let g:gruvbox_invert_selection=0'
  --     vim.cmd 'colorscheme gruvbox'
  --   end,
  -- },
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`
    'folke/tokyonight.nvim',
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
      transparent = true,
    },
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      -- vim.cmd.colorscheme 'tokyonight-moon'

      -- You can configure highlights by doing something like
      vim.cmd.hi 'Comment gui=none'
    end,
  },

  {
    'vigoux/oak',
    priority = 1000,
    init = function()
      -- vim.cmd.colorscheme 'oak'

      -- You can configure highlights by doing something like
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'savq/melange-nvim',
    priority = 1000,
    init = function()
      -- vim.opt.termguicolors = true
      -- vim.cmd.colorscheme 'melange'
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'ellisonleao/gruvbox.nvim',

    priority = 1000,
    init = function()
      -- vim.opt.termguicolors = true
      -- vim.cmd.colorscheme 'gruvbox'
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },
  -- Lazy
  {
    'vague2k/vague.nvim',
    priority = 1000,
    config = function()
      -- NOTE: you do not need to call setup if you don't want to.
      require('vague').setup {
        -- optional configuration here
      }
    end,
    init = function()
      vim.cmd.colorscheme 'vague'

      -- Softer cursor hover highlights
      vim.cmd.hi 'CursorLine guibg=#2a2a2a'
      vim.cmd.hi 'LspReferenceRead guibg=#2a2a2a'
      vim.cmd.hi 'LspReferenceText guibg=#2a2a2a'
      vim.cmd.hi 'LspReferenceWrite guibg=#2a2a2a'

      -- Quickfix list highlights (based on tokyonight style)
      vim.cmd.hi 'QuickFixLine guibg=#333738 gui=bold' -- Using vague's visual color
      vim.cmd.hi 'qfFileName guifg=#7e98e8' -- Using vague's hint color (blue)
      vim.cmd.hi 'qfLineNr guifg=#606079' -- Using vague's comment color

      -- Neo-tree highlights (based on tokyonight style)
      vim.cmd.hi 'NeoTreeDimText guifg=#606079' -- Using comment color for dimmed text
      vim.cmd.hi 'NeoTreeFileName guifg=#cdcdcd' -- Using standard fg color
      vim.cmd.hi 'NeoTreeGitModified guifg=#f3be7c' -- Using warning/delta color (orange)
      vim.cmd.hi 'NeoTreeGitStaged guifg=#7fa563' -- Using plus color (green)
      vim.cmd.hi 'NeoTreeGitUntracked guifg=#bb9dbd' -- Using parameter color (dusty pink)
      vim.cmd.hi 'NeoTreeNormal guifg=#cdcdcd guibg=#141415' -- Standard colors
      vim.cmd.hi 'NeoTreeNormalNC guifg=#cdcdcd guibg=#141415' -- Same for non-current
      vim.cmd.hi 'NeoTreeTabActive guifg=#7e98e8 guibg=#252530 gui=bold' -- Blue with line bg
      vim.cmd.hi 'NeoTreeTabInactive guifg=#606079 guibg=#141415' -- Comment color with bg
      vim.cmd.hi 'NeoTreeTabSeparatorActive guifg=#7e98e8 guibg=#252530' -- Match active tab
      vim.cmd.hi 'NeoTreeTabSeparatorInactive guifg=#141415 guibg=#141415' -- Invisible separator
    end,
  },
}
