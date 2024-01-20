---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<leader>tr"] = {
      function()
        require("base46").toggle_transparency()
      end,
      "toggle transparency",
    },
    ["<leader>ga"] = { "<cmd>lua vim.lsp.buf.code_action()<CR>" },

    -- For GPTs
    ["<leader>gf"] = { "<cmd>GpChatFinder<CR>", "GPT Chat Finder" },
    ["<leader>gn"] = { "<cmd>GpChatNew<CR>", "GPT Chat New" },

    ["<leader>gta"] = { "<cmd>GpAppend<cr>", "GPT Append" },
    ["<leader>gb"] = { "<cmd>GpPrepend<cr>", "GPT Prepend" },
    ["<leader>gte"] = { "<cmd>GpEnew<cr>", "GPT Enew" },
    ["<leader>gp"] = { "<cmd>GpPopup<cr>", "GPT Popup" },
    ["<leader>gs"] = { "<cmd>GpStop<cr>", "GPT Stop" },
    ["<leader>bn"] = { "<cmd>:tabnext<cr>", "Tab next" },
    -- End For GPTs
    --
    ["<leader>sn"] = {
      function()
        require("luasnip.loaders").edit_snippet_files()
        -- edit snippets
      end,
      "Edit snippets",
    },

    ["<leader>ttf"] = {
      function()
        require("nvterm.terminal").toggle "float"
      end,
      "toggle nvterm float",
    },
    ["<leader>ttv"] = {
      function()
        require("nvterm.terminal").toggle "vertical"
      end,
      "toggle nvterm vertical",
    },
    ["<leader>tth"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "toggle nvterm horizontal",
    },

    ["<leader>ge"] = {
      function()
        require("git_blame").run()
      end,
      "Show git blame editor in the left",
    },

    ["<leader>tn"] = {
      function()
        require("neotest").run.run()
      end,
      "run nearest neotest",
    },
    ["<leader>td"] = {
      function()
        require("neotest").run.run { strategy = "dap" }
      end,
      "debug nearest neotest",
    },
    ["<leader>tf"] = {
      function()
        require("neotest").run.run(vim.fn.expand "%")
      end,
      "run neotest current file",
    },
    -- ["<C-`>"] = {function ()
    --   require("nvterm.terminal").toggle "horizontal"
    -- end, "toggle nvterm horizontal"},
    -- ["<leader>rht"] = {function ()
    --   require("nvterm.terminal").send('npx hardhat test')
    -- end, "run hardhat test"},
    ["<leader>rht"] = { '<cmd>TermExec size=80 cmd="npx hardhat test" direction=vertical<CR>', "run hardhat test" },
    ["<leader>rft"] = {
      function()
        local Terminal = require("toggleterm.terminal").Terminal
        Terminal:new({ cmd = "npx hardhat test", hidden = true, close_on_exit = false, direction = "float" }):toggle()
      end,
      "run hardhat test float",
    },

    ["<leader>rhc"] = {
      function()
        require("nvterm.terminal").send "npx hardhat compile"
      end,
      "run hardhat compile",
    },
    ["<leader>rlc"] = {
      function()
        require("nvterm.terminal").send("!!" .. "\n")
        -- vim.cmd("TermExec cmd=\"!!\" .. \n")
      end,
      "run last command",
    },
    ["<leader>gg"] = {
      function()
        local Terminal = require("toggleterm.terminal").Terminal
        local lazygit = Terminal:new { cmd = "lazygit", hidden = true, direction = "float" }
        lazygit:toggle()
      end,
      "open float lazygit",
    },

    ["]b"] = { "f(", "find next open parenthesis", opts = { noremap = true, silent = true } },
    ["[b"] = { "F(", "find previous open parenthesis", opts = { noremap = true, silent = true } },
    ["]B"] = { "f{", "find next open curly brace", opts = { noremap = true, silent = true } },
    ["[B"] = { "F{", "find previous open curly brace", opts = { noremap = true, silent = true } },
    ["gv"] = {
      ":vsplit | lua vim.lsp.buf.definition()<CR>",
      "open definition in virtical split",
      opts = { noremap = true, silent = true },
    },
  },
  v = {
    ["<leader>gr"] = { "<cmd>GpRewrite<cr>", "GPT Inline Rewrite" },
  },
  t = {
    ["<esc>"] = { "<C-\\><C-n>", "escape terminal mode" },
    ["<C-`>"] = { "<C-\\><C-n> :q<CR>", "Close terminal" },
  },
}

-- more keybinds!

-- Go to next error
vim.api.nvim_set_keymap(
  "n",
  "<F2>",
  ":lua require('trouble').next({skip_groups = true, jump = true})<CR>",
  { noremap = true, silent = true }
)
-- Go to previous error
vim.api.nvim_set_keymap(
  "n",
  "<S-F2>",
  ":lua require('trouble').previous({skip_groups = true, jump = true})<CR>",
  { noremap = true, silent = true }
)

local map = vim.api.nvim_set_keymap
local options = { noremap = true, silent = true }

vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})

map("n", "<C-w> =", ":NvimTreeToggler<CR>", options)
map("n", "<C-w |>", ":NvimTreeToggler<CR>", options)

map("n", "<F5>", ":lua require'dap'.continue()<CR>", options)
map("n", "<F10>", ":lua require'dap'.step_over()<CR>", options)
map("n", "<F11>", ":lua require'dap'.step_into()<CR>", options)
map("n", "<F12>", ":lua require'dap'.step_out()<CR>", options)
map("n", "\\b", ":lua require'dap'.toggle_breakpoint()<CR>", options)
map("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", options)
vim.keymap.set("n", "<Leader>lp", function()
  require("dap").set_breakpoint(nil, nil, vim.fn.input "Log point message: ")
end)
vim.keymap.set("n", "<Leader>dr", function()
  require("dap").repl.open()
end)
vim.keymap.set("n", "<Leader>dl", function()
  require("dap").run_last()
end)
vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
  require("dap.ui.widgets").hover()
end)
vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
  require("dap.ui.widgets").preview()
end)
vim.keymap.set("n", "<Leader>df", function()
  local widgets = require "dap.ui.widgets"
  widgets.centered_float(widgets.frames)
end)
vim.keymap.set("n", "<Leader>ds", function()
  local widgets = require "dap.ui.widgets"
  widgets.centered_float(widgets.scopes)
end)

return M
