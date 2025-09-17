return {
  {
    'yetone/avante.nvim',
    enabled = false,
    event = 'VeryLazy',
    version = false, -- Never set this value to "*"! Never!
    opts = {
      provider = 'claude',
      auto_suggestions_provider = 'claude',
      mode = 'agentic',
      providers = {
        claude = {
          endpoint = 'https://api.anthropic.com',
          model = 'claude-3-5-sonnet-20241022',
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 4096,
          },
        },
        openai = {
          endpoint = 'https://api.openai.com/v1',
          model = 'o4-mini',
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_completion_tokens = 8192,
          },
        },
      },
      hints = { enabled = false },
      behaviour = {
        auto_suggestions = false, -- Set to true if you want automatic suggestions
        auto_suggestions_respect_ignore = true,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        minimize_diff = true,
        enable_token_counting = true,
        auto_approve_tool_permissions = false,
      },
      suggestion = {
        debounce = 600,
        throttle = 600,
      },
      mappings = {
        suggestion = {
          accept = '<C-CR>', -- Ctrl+Enter to accept
          next = '<C-]>',    -- Ctrl+] for next suggestion
          prev = '<C-[>',    -- Ctrl+[ for previous suggestion
          dismiss = '<C-\\>', -- Ctrl+\ to dismiss
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = 'make',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
      'echasnovski/mini.icons',
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'Avante' },
        },
        ft = { 'Avante' },
      },
    },
  },
}
