local autocmd = vim.api.nvim_create_autocmd

-- Run gofmt + goimport on save

local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    -- require("go.format").gofmt()
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
-- vim.cmd [[
--   augroup FormatBeforeSave
--     autocmd!
--     autocmd BufWritePre * lua format_async()
--   augroup END
-- ]]

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


local function keymapOptions(desc)
    return {
        noremap = true,
        silent = true,
        nowait = true,
        desc = "GPT prompt " .. desc,
    }
end

-- Chat commands
vim.keymap.set({"n", "i"}, "<C-g>c", "<cmd>GpChatNew<cr>", keymapOptions("New Chat"))
vim.keymap.set({"n", "i"}, "<C-g>t", "<cmd>GpChatToggle<cr>", keymapOptions("Toggle Chat"))
vim.keymap.set({"n", "i"}, "<C-g>f", "<cmd>GpChatFinder<cr>", keymapOptions("Chat Finder"))

vim.keymap.set("v", "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", keymapOptions("Visual Chat New"))
vim.keymap.set("v", "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", keymapOptions("Visual Chat Paste"))
vim.keymap.set("v", "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", keymapOptions("Visual Toggle Chat"))

vim.keymap.set({ "n", "i" }, "<C-g><C-x>", "<cmd>GpChatNew split<cr>", keymapOptions("New Chat split"))
vim.keymap.set({ "n", "i" }, "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", keymapOptions("New Chat vsplit"))
vim.keymap.set({ "n", "i" }, "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", keymapOptions("New Chat tabnew"))

vim.keymap.set("v", "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", keymapOptions("Visual Chat New split"))
vim.keymap.set("v", "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", keymapOptions("Visual Chat New vsplit"))
vim.keymap.set("v", "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", keymapOptions("Visual Chat New tabnew"))

-- Prompt commands
vim.keymap.set({"n", "i"}, "<C-g>r", "<cmd>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
vim.keymap.set({"n", "i"}, "<C-g>a", "<cmd>GpAppend<cr>", keymapOptions("Append (after)"))
vim.keymap.set({"n", "i"}, "<C-g>b", "<cmd>GpPrepend<cr>", keymapOptions("Prepend (before)"))

vim.keymap.set("v", "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", keymapOptions("Visual Rewrite"))
vim.keymap.set("v", "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", keymapOptions("Visual Append (after)"))
vim.keymap.set("v", "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", keymapOptions("Visual Prepend (before)"))
vim.keymap.set("v", "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", keymapOptions("Implement selection"))

vim.keymap.set({"n", "i"}, "<C-g>gp", "<cmd>GpPopup<cr>", keymapOptions("Popup"))
vim.keymap.set({"n", "i"}, "<C-g>ge", "<cmd>GpEnew<cr>", keymapOptions("GpEnew"))
vim.keymap.set({"n", "i"}, "<C-g>gn", "<cmd>GpNew<cr>", keymapOptions("GpNew"))
vim.keymap.set({"n", "i"}, "<C-g>gv", "<cmd>GpVnew<cr>", keymapOptions("GpVnew"))
vim.keymap.set({"n", "i"}, "<C-g>gt", "<cmd>GpTabnew<cr>", keymapOptions("GpTabnew"))

vim.keymap.set("v", "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", keymapOptions("Visual Popup"))
vim.keymap.set("v", "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", keymapOptions("Visual GpEnew"))
vim.keymap.set("v", "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", keymapOptions("Visual GpNew"))
vim.keymap.set("v", "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", keymapOptions("Visual GpVnew"))
vim.keymap.set("v", "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", keymapOptions("Visual GpTabnew"))

vim.keymap.set({"n", "i"}, "<C-g>x", "<cmd>GpContext<cr>", keymapOptions("Toggle Context"))
vim.keymap.set("v", "<C-g>x", ":<C-u>'<,'>GpContext<cr>", keymapOptions("Visual Toggle Context"))

vim.keymap.set({"n", "i", "v", "x"}, "<C-g>s", "<cmd>GpStop<cr>", keymapOptions("Stop"))
vim.keymap.set({"n", "i", "v", "x"}, "<C-g>n", "<cmd>GpNextAgent<cr>", keymapOptions("Next Agent"))

-- optional Whisper commands with prefix <C-g>w
vim.keymap.set({"n", "i"}, "<C-g>ww", "<cmd>GpWhisper<cr>", keymapOptions("Whisper"))
vim.keymap.set("v", "<C-g>ww", ":<C-u>'<,'>GpWhisper<cr>", keymapOptions("Visual Whisper"))

vim.keymap.set({"n", "i"}, "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", keymapOptions("Whisper Inline Rewrite"))
vim.keymap.set({"n", "i"}, "<C-g>wa", "<cmd>GpWhisperAppend<cr>", keymapOptions("Whisper Append (after)"))
vim.keymap.set({"n", "i"}, "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", keymapOptions("Whisper Prepend (before) "))

vim.keymap.set("v", "<C-g>wr", ":<C-u>'<,'>GpWhisperRewrite<cr>", keymapOptions("Visual Whisper Rewrite"))
vim.keymap.set("v", "<C-g>wa", ":<C-u>'<,'>GpWhisperAppend<cr>", keymapOptions("Visual Whisper Append (after)"))
vim.keymap.set("v", "<C-g>wb", ":<C-u>'<,'>GpWhisperPrepend<cr>", keymapOptions("Visual Whisper Prepend (before)"))

vim.keymap.set({"n", "i"}, "<C-g>wp", "<cmd>GpWhisperPopup<cr>", keymapOptions("Whisper Popup"))
vim.keymap.set({"n", "i"}, "<C-g>we", "<cmd>GpWhisperEnew<cr>", keymapOptions("Whisper Enew"))
vim.keymap.set({"n", "i"}, "<C-g>wn", "<cmd>GpWhisperNew<cr>", keymapOptions("Whisper New"))
vim.keymap.set({"n", "i"}, "<C-g>wv", "<cmd>GpWhisperVnew<cr>", keymapOptions("Whisper Vnew"))
vim.keymap.set({"n", "i"}, "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", keymapOptions("Whisper Tabnew"))

vim.keymap.set("v", "<C-g>wp", ":<C-u>'<,'>GpWhisperPopup<cr>", keymapOptions("Visual Whisper Popup"))
vim.keymap.set("v", "<C-g>we", ":<C-u>'<,'>GpWhisperEnew<cr>", keymapOptions("Visual Whisper Enew"))
vim.keymap.set("v", "<C-g>wn", ":<C-u>'<,'>GpWhisperNew<cr>", keymapOptions("Visual Whisper New"))
vim.keymap.set("v", "<C-g>wv", ":<C-u>'<,'>GpWhisperVnew<cr>", keymapOptions("Visual Whisper Vnew"))
vim.keymap.set("v", "<C-g>wt", ":<C-u>'<,'>GpWhisperTabnew<cr>", keymapOptions("Visual Whisper Tabnew"))
