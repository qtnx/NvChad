local autocmd = vim.api.nvim_create_autocmd

-- Run gofmt + goimport on save

local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    require("go.format").gofmt()
    require("go.format").goimport()
  end,
  group = format_sync_grp,
})

vim.cmd "autocmd FileType dbout setlocal nofoldenable"

-- Auto resize panes when resizing nvim window
autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})
vim.g.copilot_assume_mapped = false

-- VS Code like snippet
-- get from custom/vssnippets
-- vim.g.vscode_snippets_path =
-- vim.g.vscode_snippets_path = vim.fn.stdpath("config") .. "/lua/custom/vssnippets"
vim.g.vscode_snippets_path = os.getenv "HOME" .. "/.config/nvim/lua/custom/vssnippets"
vim.g.snipmate_snippets_path = os.getenv "HOME" .. "/.config/nvim/lua/custom/snipmate_snippets"
-- vim.g.lua_snippets_path = vim.fn.stdpath("config") .. "/custom/lua_snippets"
--

-- relative number line by default
vim.opt.relativenumber = true

-- setup custom variable for snippet
local fn = require "custom.functions"

local get_nearest_solidity_function_name = function()
  local function_name = nil
  local search_pattern = "function%s+([_%w]+)%s*%("
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for line_number = current_line, 1, -1 do
    local line_content = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
    local match = string.match(line_content, search_pattern)
    if match then
      function_name = match
      break
    end
  end

  if function_name then
    return function_name
  else
    return ""
  end
end

vim.g.snippet_vars = {
  FN_NAME = fn.get_current_function_name_lsp,
  SOLIDITY_FUNCTION_NAME = get_nearest_solidity_function_name,
  UNIQUE_EMOIJ = fn.get_unique_emoji_for_file,
}

vim.lsp.set_log_level "debug"
vim.cmd [[
    autocmd BufEnter * let &titlestring = expand("%:p:h")
    set title
    autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter * call system("tmux rename-window 'nvim | " . expand("%:p:h") . "'")
    autocmd VimLeave * call system("tmux setw automatic-rename")
    au BufRead,BufNewFile .env set filetype=cfg
]]

local prefetch = vim.api.nvim_create_augroup("prefetch", { clear = true })

-- vim.api.nvim_create_autocmd("BufRead", {
--   group = prefetch,
--   pattern = "*.{js,jsx,ts,tsx,go,py,sol}",
--   callback = function()
--     require("cmp_tabnine"):prefetch(vim.fn.expand "%:p")
--   end,
-- })

-- Async formatting function
function format_async()
  vim.lsp.buf.format { async = true }
end

-- Autocommand to call format_async before saving any file
vim.cmd [[
  augroup FormatBeforeSave
    autocmd!
    autocmd BufWritePre * lua format_async()
  augroup END
]]

-- Config for copilot
-- Disable tab and move to <M-l>
vim.keymap.set("i", "<M-l>", 'copilot#Accept("\\<CR>")', {
  silent = true,
  expr = true,
  replace_keycodes = false,
})
vim.g.copilot_no_tab_map = true

vim.g.copilot_filetypes = {
  ["*"] = true,
  dotenv = false,
  conf = false,
  cfg = false,
  md = true,
  json = true,
}

-- require("tabnine").setup {
--   disable_auto_comment = true,
--   accept_keymap = "<Tab>",
--   dismiss_keymap = "<C-]>",
--   debounce_ms = 800,
--   suggestion_color = { gui = "#808080", cterm = 244 },
--   exclude_filetypes = { "TelescopePrompt", "NvimTree" },
--   log_file_path = nil, -- absolute path to Tabnine log file
-- }

-- highlight
-- highlight link CopilotLineNr LineNr

-- require("nvim-treesitter.configs").setup {
--   context_commentstring = {
--     enable = true,
--     enable_autocmd = false,
--   },
-- }
-- require('ts_context_commentstring').setup {
--   enable_autocmd = true,
--   languages = {
--     typescript = '// %s',
--   },
-- }
