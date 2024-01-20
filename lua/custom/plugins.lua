local overrides = require "custom.configs.overrides"
local func = require "custom.func"
local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match "^%s*$" == nil
end

-- hello

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
      {
        "williamboman/mason.nvim",
        config = function(_, opts)
          dofile(vim.g.base46_cache .. "mason")
          require("mason").setup(opts)
          vim.api.nvim_create_user_command("MasonInstallAll", function()
            vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
          end, {})
          require "custom.configs.lspconfig" -- Load in lsp config
        end,
      },
      "williamboman/mason-lspconfig.nvim",
    },
    config = function() end, -- Override to setup mason-lspconfig
  },

  {
    "mhartington/formatter.nvim",
    lazy = true,
    event = "VeryLazy",
  },

  {
    "prettier/vim-prettier",
    lazy = true,
    run = "yarn install --frozen-lockfile --production",
    ft = {
      "javascript",
      "typescript",
      "css",
      "less",
      "scss",
      "json",
      "graphql",
      "markdown",
      "vue",
      "svelte",
      "yaml",
      "html",
      "lua",
      "go",
    },
  },

  -- overrde plugin configs
  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-ts-autotag").setup {
        -- your config
      }
    end,
    lazy = true,
    event = "VeryLazy",
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    "github/copilot.vim",
    lazy = true,

    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    -- enabled = false,
  },
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
    name = "copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      -- to map copilot to the cmp only, change these config to false
      suggestion = { enabled = true, auto_trigger = true, debounce = 0 },
      panel = { enabled = true, auto_refresh = true },
      filetypes = {
        cfg = false,
      },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "copilot.lua", "nvim-cmp", "zbirenbaum/copilot.lua" },
    enabled = false,
    event = "InsertEnter",
    -- event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      -- local copilot_cmp = require "copilot_cmp"
      require("copilot_cmp").setup {
        formatters = {
          insert_text = require("copilot_cmp.format").remove_existing,
        },
      }
      -- attach cmp source whenever copilot attaches
    end,
  },

  {
    "codota/tabnine-nvim",
    build = "./dl_binaries.sh",
    enabled = false,
    lazy = true,
    event = "VeryLazy",

    cmd = { "TabnineHub", "TabnineToggle" },
    config = function()
      require("tabnine").setup {
        disable_auto_comment = true,
        accept_keymap = "<Tab>",
        dismiss_keymap = "<C-]>",
        debounce_ms = 800,
        suggestion_color = { gui = "#808080", cterm = 244 },
        exclude_filetypes = { "TelescopePrompt", "NvimTree" },
        log_file_path = nil, -- absolute path to Tabnine log file
      }
    end,
  },

  {
    "tzachar/cmp-tabnine",
    enabled = true,
    name = "cmp-tabnine",
    event = "InsertEnter",
    dependencies = { "nvim-cmp", "hrsh7th/nvim-cmp" },
    build = "./install.sh",
    config = function()
      local tabnine = require "cmp_tabnine.config"
      tabnine:setup {
        max_lines = 1000,
        max_num_results = 20,
        sort = true,
        run_on_every_keystroke = true,
        snippet_placeholder = "..",
        ignored_file_types = {
          "cfg",
          -- default is not to ignore
          -- uncomment to ignore in lua:
          -- lua = true
        },
        show_prediction_strength = false,
      }
    end,
  },
  {
    "mlaursen/vim-react-snippets",
    dependencies = "L3MON4D3/LuaSnip",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  },
  -- To make a plugin not be loaded
  {
    "NvChad/nvim-colorizer.lua",
    enabled = true,
  },

  -- Uncomment if you want to re-enable which-key
  {
    "folke/which-key.nvim",
    enabled = true,
  },
  {
    "NvChad/nvterm",
    config = function()
      require("nvterm").setup {
        float = {
          width = 0.9,
          height = 0.8,
        },
        toggle = {
          horizontal = "<A-s>",
          vertical = "<A-v>",
        },
        behavior = {
          auto_insert = false,
        },
      }
    end,
  },
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    config = function(_, opts)
      require("mini.pairs").setup(opts)
    end,
  },
  {
    "ggandor/flit.nvim",
    keys = function()
      ---@type LazyKeys[]
      local ret = {}
      for _, key in ipairs { "f", "F", "t", "T" } do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
    opts = { labeled_modes = "nx" },
  },
  {
    "ggandor/leap.nvim",
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
      { "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
      { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
    },
    config = function(_, opts)
      local leap = require "leap"
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      leap.add_default_mappings(true)
      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")
    end,
  },
  -- { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },
  {
    "numToStr/Comment.nvim",
    opts = {
      -- pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      -- add any options here
    },
    lazy = false,
  },
  -- {"svermeulen/vim-easyclip", lazy = true },
  -- {
  --   "echasnovski/mini.comment",
  --   event = "VeryLazy",
  --   opts = {
  --     -- custom_commentstring = function()
  --     --   return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
  --     -- end,
  --     hooks = {
  --       pre = function()
  --         require("ts_context_commentstring.internal").update_commentstring {}
  --       end,
  --     },
  --   },
  --   config = function(_, opts)
  --     require("mini.comment").setup(opts)
  --   end,
  -- },
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = { delay = 200 },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
      { "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
      { "<leader>qf", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").previous { skip_groups = true, jump = true }
          else
            vim.cmd.cprev()
          end
        end,
        desc = "Previous trouble/quickfix item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next { skip_groups = true, jump = true }
          else
            vim.cmd.cnext()
          end
        end,
        desc = "Next trouble/quickfix item",
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    event = "VeryLazy",
    version = "*",
    config = function(_, opts)
      require("toggleterm").setup {
        open_mapping = [[<C-`>]],
      }
    end,
  },
  {
    "windwp/nvim-spectre",
    -- stylua: ignore
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
    },
  },
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension "lazygit"
    end,
  },
  {
    "klen/nvim-test",
    lazy = false,
    config = function()
      require("nvim-test").setup {
        run = true, -- run tests (using for debug)
        commands_create = true, -- create commands (TestFile, TestLast, ...)
        filename_modifier = ":.", -- modify filenames before tests run(:h filename-modifiers)
        silent = false, -- less notifications
        term = "terminal", -- a terminal to run ("terminal"|"toggleterm")
        termOpts = {
          direction = "vertical", -- terminal's direction ("horizontal"|"vertical"|"float")
          width = 96, -- terminal's width (for vertical|float)
          height = 24, -- terminal's height (for horizontal|float)
          go_back = false, -- return focus to original window after executing
          stopinsert = "auto", -- exit from insert mode (true|false|"auto")
          keep_one = true, -- keep only one terminal for testing
        },
        runners = { -- setup tests runners
          cs = "nvim-test.runners.dotnet",
          go = "nvim-test.runners.go-test",
          haskell = "nvim-test.runners.hspec",
          javascriptreact = "nvim-test.runners.jest",
          javascript = "nvim-test.runners.jest",
          lua = "nvim-test.runners.busted",
          python = "nvim-test.runners.pytest",
          ruby = "nvim-test.runners.rspec",
          rust = "nvim-test.runners.cargo-test",
          typescript = "nvim-test.runners.jest",
          typescriptreact = "nvim-test.runners.jest",
        },
      }
    end,
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" } },
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end,                desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
    },
  },
  { "mg979/vim-visual-multi", lazy = true, event = "VeryLazy" },
  {
    "jackMort/ChatGPT.nvim",
    cmd = { "ChatGPT", "ChatGPTActAs" },
    config = function()
      require("chatgpt").setup {
        openai_params = {
          model = "gpt-3.5-turbo",
        },
        openai_edit_params = {
          model = "code-cushman-001",
        },
        -- optional configuration
      }
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
  {
    "mfussenegger/nvim-dap",
    keys = { "<F5>" },
  },
  {
    "aklt/plantuml-syntax",
    lazy = true,
    event = "VeryLazy",
  },
  {
    "weirongxu/plantuml-previewer.vim",
    cmd = { "PlantumlOpen" },
    dependencies = { "tyru/open-browser.vim" },
  },
  {
    "tyru/open-browser.vim",
    lazy = false,
  },

  {
    "rhysd/git-messenger.vim",
    keys = { "<leader>gm" },
    cmd = { "GitMessenger" },
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    keys = { "<F5>" },
    config = function()
      require("dapui").setup()
    end,
  },
  {
    enabled = false,
    "simrat39/rust-tools.nvim",
    lazy = true,
    event = "VeryLazy",
    config = function()
      local rt = require "rust-tools"
      rt.setup {
        server = {
          on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
          end,
        },
      }
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    keys = { "<F5>" },
    -- lazy = true,
    -- event = "VeryLazy",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("mason-nvim-dap").setup {
        -- optional configuration
        ensure_installed = { "chome", "rust", "js" },
        automatic_setup = false,
        handlers = {
          function(source_name)
            -- all sources with no handler get passed here

            local dap = require "dap"
            dap.configurations.typescriptreact = {
              {
                name = "Launch chrome",
                type = "chrome",
                request = "launch",
                -- program = "${workspaceFolder}/${file}",
                url = "http://localhost:4200/dptp/trading/lite",
                cwd = vim.fn.getcwd(),
                sourceMaps = true,
                webRoot = "${workspaceFolder}/apps/dptp/",
                -- protocol = "inspector",
                -- console = "integratedTerminal",
                -- redirectOutput = true,
              },
            }
            dap.configurations.vue = {
              {
                name = "Launch chrome",
                type = "chrome",
                request = "launch",
                -- program = "${workspaceFolder}/${file}",
                url = "http://localhost:5173",
                cwd = vim.fn.getcwd(),
                sourceMaps = true,
                webRoot = "${workspaceFolder}/src",
                protocol = "inspector",
                breakOnLoad = true,
                sourceMapPathOverrides = {
                  ["webpack:///src/*"] = "${webRoot}/*",
                  ["webpack:///./*"] = "${webRoot}/*",
                  ["webpack:///*"] = "*",
                  ["webpack:///./~/*"] = "${webRoot}/node_modules/*",
                },
                -- console = "integratedTerminal",
                redirectOutput = true,
              },
            }
            dap.configurations.typescript = {
              {
                name = "Debug Hardhat test",
                type = "node2",
                request = "launch",
                program = "${workspaceFolder}/node_modules/.bin/hardhat",
                args = { "test", "${file}" },
                cwd = vim.fn.getcwd(),
              },
            }
            -- Keep original functionality of `automatic_setup = true`
            require "mason-nvim-dap.automatic_setup"(source_name)
          end,
          python = function(source_name)
            local dap = require "dap"
            dap.adapters.python = {
              type = "executable",
              command = "/usr/bin/python3",
              args = {
                "-m",
                "debugpy.adapter",
              },
            }

            dap.configurations.python = {
              {
                type = "python",
                request = "launch",
                name = "Launch file",
                program = "${file}", -- This configuration will launch the current file if used.
              },
            }
          end,
        },
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter",
    lazy = true,
    event = "VeryLazy",
  },

  {
    "HiPhish/nvim-ts-rainbow2",
    dependencies = "nvim-treesitter/nvim-treesitter",
    lazy = true,
    event = "VeryLazy",
    disable = { "tsx" },
    -- enabled = false
  },

  {
    "simrat39/symbols-outline.nvim",
    lazy = true,
    event = "VeryLazy",
  },
  { "echasnovski/mini.basics", lazy = true, event = "VeryLazy" },
  { "echasnovski/mini.splitjoin", lazy = true, event = "VeryLazy" },
  { "echasnovski/mini.surround", lazy = true, event = "VeryLazy" },
  { "echasnovski/mini.bracketed", lazy = true, event = "VeryLazy" },
  { "echasnovski/mini.indentscope", version = false, lazy = true, event = "VeryLazy" },
  -- { "sindrets/diffview.nvim", dependencies = "nvim-lua/plenary.nvim", lazy = true, event = "VeryLazy" },
  {
    "rmagatti/goto-preview",
    keys = { "gpd" },
    config = function()
      require("goto-preview").setup {
        default_mappings = true,
        height = 100,
      }
    end,
  },
  {
    "Wansmer/treesj",
    -- (<space>m - toggle, <space>j - join, <space>s - split)
    keys = { "<space>m", "<space>j", "<space>s" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesj").setup { --[[ your config ]]
      }
    end,
  },
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
  {
    "doums/darcula",
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = "tpope/vim-dadbod",
    cmd = { "DBUI" },
  },
  {
    "bobrown101/git-blame.nvim",
    keys = { "<leader>ge" },
  },
  {
    "andrewferrier/debugprint.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("debugprint").setup {
        -- options go here
      }
    end,
    keys = { "<leader>dp", "g?p", "g?d", "g?v" },
    event = "VeryLazy",
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
    keys = { "<leader>tn" },
  },
  { "akinsho/git-conflict.nvim", version = "*", config = true }, -- event = "VeryLazy"
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
  },
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  {
    "iamcco/markdown-preview.nvim",
    config = function()
      vim.fn["mkdp#util#install"]()
    end,
    run = "cd app && yarn install",
    ft = "markdown",
    cmd = { "MarkdownPreview" },
  },
  {
    "SmiteshP/nvim-navic",
    dependencies = "neovim/nvim-lspconfig",
    event = "VeryLazy",
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    enabled = false,
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o",               function() require("flash").remote() end,     desc = "Remote Flash" },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc =
        "Treesitter Search"
      },
      {
        "<c-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc =
        "Toggle Flash Search"
      },
    },
  },
  -- {
  --   "folke/todo-comments.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {
  --     -- your configuration comes here
  --     -- or leave it empty to use the default settings
  --     -- refer to the configuration section below
  --   },
  -- },
  {
    "onsails/lspkind.nvim",
    event = "VeryLazy",
    enabled = false,
  },
  {
    "robitx/gp.nvim",
    event = "VeryLazy",
    config = function()
      require("gp").setup {
        -- Please start with minimal config possible.
        -- Just openai_api_key if you don't have OPENAI_API_KEY env set up.
        -- Defaults change over time to improve things, options might get deprecated.
        -- It's better to change only things where the default doesn't fit your needs.

        -- required openai api key (string or table with command and arguments)
        -- openai_api_key = { "cat", "path_to/openai_api_key" },
        -- openai_api_key = { "bw", "get", "password", "OPENAI_API_KEY" },
        -- openai_api_key: "sk-...",
        -- openai_api_key = os.getenv("env_name.."),
        openai_api_key = os.getenv "OPENAI_API_KEY",
        -- api endpoint (you can change this to azure endpoint)
        openai_api_endpoint = "https://api.openai.com/v1/chat/completions",
        -- openai_api_endpoint = "https://$URL.openai.azure.com/openai/deployments/{{model}}/chat/completions?api-version=2023-03-15-preview",
        -- prefix for all commands
        cmd_prefix = "Gp",
        -- optional curl parameters (for proxy, etc.)
        -- curl_params = { "--proxy", "http://X.X.X.X:XXXX" }
        curl_params = {},

        -- directory for persisting state dynamically changed by user (like model or persona)
        state_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/persisted",

        -- default command agents (model + persona)
        -- name, model and system_prompt are mandatory fields
        -- to use agent for chat set chat = true, for command set command = true
        -- to remove some default agent completely set it just with the name like:
        -- agents = {  { name = "ChatGPT4" }, ... },
        agents = {
          {
            name = "ChatGPT4",
            chat = true,
            command = true,
            -- string with model name or table with model name and parameters
            model = { model = "gpt-4-1106-preview", temperature = 1.1, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = "You are a general AI assistant.\n\n"
              .. "The user provided the additional info about how they would like you to respond:\n\n"
              .. "- If you're unsure don't guess and say you don't know instead.\n"
              .. "- Ask question if you need clarification to provide better answer.\n"
              .. "- Think deeply and carefully from first principles step by step.\n"
              .. "- Zoom out first to see the big picture and then zoom in to details.\n"
              .. "- Use Socratic method to improve your thinking and coding skills.\n"
              .. "- Don't elide any code from your output if the answer requires coding.\n"
              .. "- Take a deep breath; You've got this!\n",
          },
          {
            name = "ChatGPT3-5",
            chat = false,
            command = false,
          },
          {
            name = "CodeGPT4",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            model = { model = "gpt-4-1106-preview", temperature = 0.8, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = "You are an AI working as a code editor.\n\n"
              .. "Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n"
              .. "START AND END YOUR ANSWER WITH:\n\n```",
          },
          {
            name = "CodeGPT3-5",
            chat = false,
            command = false,
            -- -- string with model name or table with model name and parameters
            -- model = { model = "gpt-3.5-turbo-1106", temperature = 0.8, top_p = 1 },
            -- -- system prompt (use this to specify the persona/role of the AI)
            -- system_prompt = "You are an AI working as a code editor.\n\n"
            --   .. "Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n"
            --   .. "START AND END YOUR ANSWER WITH:\n\n```",
          },
        },

        -- directory for storing chat files
        chat_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/chats",
        -- chat user prompt prefix
        chat_user_prefix = "🗨:",
        -- chat assistant prompt prefix (static string or a table {static, template})
        -- first string has to be static, second string can contain template {{agent}}
        -- just a static string is legacy and the [{{agent}}] element is added automatically
        -- if you really want just a static string, make it a table with one element { "🤖:" }
        chat_assistant_prefix = { "🤖:", "[{{agent}}]" },
        -- chat topic generation prompt
        chat_topic_gen_prompt = "Summarize the topic of our conversation above"
          .. " in two or three words. Respond only with those words.",
        -- chat topic model (string with model name or table with model name and parameters)
        chat_topic_gen_model = "gpt-3.5-turbo-16k",
        -- explicitly confirm deletion of a chat file
        chat_confirm_delete = true,
        -- conceal model parameters in chat
        chat_conceal_model_params = true,
        -- local shortcuts bound to the chat buffer
        -- (be careful to choose something which will work across specified modes)
        chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g><C-g>" },
        chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
        chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
        chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },
        -- default search term when using :GpChatFinder
        chat_finder_pattern = "topic ",
        -- if true, finished ChatResponder won't move the cursor to the end of the buffer
        chat_free_cursor = false,

        -- how to display GpChatToggle or GpContext: popup / split / vsplit / tabnew
        toggle_target = "vsplit",

        -- styling for chatfinder
        -- border can be "single", "double", "rounded", "solid", "shadow", "none"
        style_chat_finder_border = "single",
        -- margins are number of characters or lines
        style_chat_finder_margin_bottom = 8,
        style_chat_finder_margin_left = 1,
        style_chat_finder_margin_right = 2,
        style_chat_finder_margin_top = 2,
        -- how wide should the preview be, number between 0.0 and 1.0
        style_chat_finder_preview_ratio = 0.5,

        -- styling for popup
        -- border can be "single", "double", "rounded", "solid", "shadow", "none"
        style_popup_border = "single",
        -- margins are number of characters or lines
        style_popup_margin_bottom = 8,
        style_popup_margin_left = 1,
        style_popup_margin_right = 2,
        style_popup_margin_top = 2,
        style_popup_max_width = 160,

        -- command config and templates bellow are used by commands like GpRewrite, GpEnew, etc.
        -- command prompt prefix for asking user for input (supports {{agent}} template variable)
        command_prompt_prefix_template = "🤖 {{agent}} ~ ",
        -- auto select command response (easier chaining of commands)
        -- if false it also frees up the buffer cursor for further editing elsewhere
        command_auto_select_response = true,

        -- templates
        template_selection = "I have the following from {{filename}}:"
          .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}",
        template_rewrite = "I have the following from {{filename}}:"
          .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
          .. "\n\nRespond exclusively with the snippet that should replace the selection above.",
        template_append = "I have the following from {{filename}}:"
          .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
          .. "\n\nRespond exclusively with the snippet that should be appended after the selection above.",
        template_prepend = "I have the following from {{filename}}:"
          .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
          .. "\n\nRespond exclusively with the snippet that should be prepended before the selection above.",
        template_command = "{{command}}",

        -- https://platform.openai.com/docs/guides/speech-to-text/quickstart
        -- Whisper costs $0.006 / minute (rounded to the nearest second)
        -- by eliminating silence and speeding up the tempo of the recording
        -- we can reduce the cost by 50% or more and get the results faster
        -- directory for storing whisper files
        whisper_dir = (os.getenv "TMPDIR" or os.getenv "TEMP" or "/tmp") .. "/gp_whisper",
        -- multiplier of RMS level dB for threshold used by sox to detect silence vs speech
        -- decibels are negative, the recording is normalized to -3dB =>
        -- increase this number to pick up more (weaker) sounds as possible speech
        -- decrease this number to pick up only louder sounds as possible speech
        -- you can disable silence trimming by setting this a very high number (like 1000.0)
        whisper_silence = "1.75",
        -- whisper max recording time (mm:ss)
        whisper_max_time = "05:00",
        -- whisper tempo (1.0 is normal speed)
        whisper_tempo = "1.75",
        -- The language of the input audio, in ISO-639-1 format.
        whisper_language = "en",

        -- image generation settings
        -- image prompt prefix for asking user for input (supports {{agent}} template variable)
        image_prompt_prefix_template = "🖌️ {{agent}} ~ ",
        -- image prompt prefix for asking location to save the image
        image_prompt_save = "🖌️💾 ~ ",
        -- default folder for saving images
        image_dir = (os.getenv "TMPDIR" or os.getenv "TEMP" or "/tmp") .. "/gp_images",
        -- default image agents (model + settings)
        -- to remove some default agent completely set it just with the name like:
        -- image_agents = {  { name = "DALL-E-3-1024x1792-vivid" }, ... },
        image_agents = {
          {
            name = "DALL-E-3-1024x1024-vivid",
            model = "dall-e-3",
            quality = "standard",
            style = "vivid",
            size = "1024x1024",
          },
          {
            name = "DALL-E-3-1792x1024-vivid",
            model = "dall-e-3",
            quality = "standard",
            style = "vivid",
            size = "1792x1024",
          },
          {
            name = "DALL-E-3-1024x1792-vivid",
            model = "dall-e-3",
            quality = "standard",
            style = "vivid",
            size = "1024x1792",
          },
          {
            name = "DALL-E-3-1024x1024-natural",
            model = "dall-e-3",
            quality = "standard",
            style = "natural",
            size = "1024x1024",
          },
          {
            name = "DALL-E-3-1792x1024-natural",
            model = "dall-e-3",
            quality = "standard",
            style = "natural",
            size = "1792x1024",
          },
          {
            name = "DALL-E-3-1024x1792-natural",
            model = "dall-e-3",
            quality = "standard",
            style = "natural",
            size = "1024x1792",
          },
          {
            name = "DALL-E-3-1024x1024-vivid-hd",
            model = "dall-e-3",
            quality = "hd",
            style = "vivid",
            size = "1024x1024",
          },
          {
            name = "DALL-E-3-1792x1024-vivid-hd",
            model = "dall-e-3",
            quality = "hd",
            style = "vivid",
            size = "1792x1024",
          },
          {
            name = "DALL-E-3-1024x1792-vivid-hd",
            model = "dall-e-3",
            quality = "hd",
            style = "vivid",
            size = "1024x1792",
          },
          {
            name = "DALL-E-3-1024x1024-natural-hd",
            model = "dall-e-3",
            quality = "hd",
            style = "natural",
            size = "1024x1024",
          },
          {
            name = "DALL-E-3-1792x1024-natural-hd",
            model = "dall-e-3",
            quality = "hd",
            style = "natural",
            size = "1792x1024",
          },
          {
            name = "DALL-E-3-1024x1792-natural-hd",
            model = "dall-e-3",
            quality = "hd",
            style = "natural",
            size = "1024x1792",
          },
        },

        -- example hook functions (see Extend functionality section in the README)
        hooks = {
          InspectPlugin = function(plugin, params)
            local bufnr = vim.api.nvim_create_buf(false, true)
            local copy = vim.deepcopy(plugin)
            local key = copy.config.openai_api_key
            copy.config.openai_api_key = key:sub(1, 3) .. string.rep("*", #key - 6) .. key:sub(-3)
            local plugin_info = string.format("Plugin structure:\n%s", vim.inspect(copy))
            local params_info = string.format("Command params:\n%s", vim.inspect(params))
            local lines = vim.split(plugin_info .. "\n" .. params_info, "\n")
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
            vim.api.nvim_win_set_buf(0, bufnr)
          end,

          -- GpImplement rewrites the provided selection/range based on comments in it
          Implement = function(gp, params)
            local template = "Having following from {{filename}}:\n\n"
              .. "```{{filetype}}\n{{selection}}\n```\n\n"
              .. "Please rewrite this according to the contained instructions."
              .. "\n\nRespond exclusively with the snippet that should replace the selection above."

            local agent = gp.get_command_agent()
            gp.info("Implementing selection with agent: " .. agent.name)

            gp.Prompt(
              params,
              gp.Target.rewrite,
              nil, -- command will run directly without any prompting for user input
              agent.model,
              template,
              agent.system_prompt
            )
          end,

          GoUnitTests = function(gp, params)
            local implementation = func.get_implementation_of_nearest_test_function()
            gp.info("Implementation:\n" .. implementation)
            local template = "I have the following code from {{filename}}:\n\n"
              .. "```{{filetype}}\n{{selection}}\n```\n\n"
              .. "Here is the implementation of the function above:\n\n"
              .. "```{{filetype}}\n"
              .. implementation
              .. "\n```\n\n"
              .. "Please respond by writing table driven unit tests for the code above. Only give me code do not say anything else, don't need import, just rewrite the test function and focus on Implement it's logic. Remember to use github.com/stretchr/testify/assert for assertion. We use mockery to mock interfaces, repositories provided by package mocks"
            local agent = gp.get_command_agent()
            gp.Prompt(params, gp.Target.rewrite, nil, agent.model, template, agent.system_prompt)
          end,

          -- your own functions can go here, see README for more examples like
          -- :GpExplain, :GpUnitTests.., :GpTranslator etc.

          -- -- example of making :%GpChatNew a dedicated command which
          -- -- opens new chat with the entire current buffer as a context
          -- BufferChatNew = function(gp, _)
          -- 	-- call GpChatNew command in range mode on whole buffer
          -- 	vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
          -- end,

          -- -- example of adding command which opens new chat dedicated for translation
          -- Translator = function(gp, params)
          -- 	local agent = gp.get_command_agent()
          -- 	local chat_system_prompt = "You are a Translator, please translate between English and Chinese."
          -- 	gp.cmd.ChatNew(params, agent.model, chat_system_prompt)
          -- end,

          -- -- example of adding command which writes unit tests for the selected code
          -- UnitTests = function(gp, params)
          -- 	local template = "I have the following code from {{filename}}:\n\n"
          -- 		.. "```{{filetype}}\n{{selection}}\n```\n\n"
          -- 		.. "Please respond by writing table driven unit tests for the code above."
          -- 	local agent = gp.get_command_agent()
          -- 	gp.Prompt(params, gp.Target.enew, nil, agent.model, template, agent.system_prompt)
          -- end,

          -- -- example of adding command which explains the selected code
          -- Explain = function(gp, params)
          -- 	local template = "I have the following code from {{filename}}:\n\n"
          -- 		.. "```{{filetype}}\n{{selection}}\n```\n\n"
          -- 		.. "Please respond by explaining the code above."
          -- 	local agent = gp.get_chat_agent()
          -- 	gp.Prompt(params, gp.Target.popup, nil, agent.model, template, agent.system_prompt)
          -- end,
        },
      }

      -- or setup with your own config (see Install > Configuration in Readme)
      -- require("gp").setup(conf)

      -- shortcuts might be setup here (see Usage > Shortcuts in Readme)
    end,
  },
  {
    "dpayne/CodeGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require "codegpt.config"
    end,
  },
}

return plugins
