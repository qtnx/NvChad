local M = {}

local ts = vim.treesitter
local parsers = require "nvim-treesitter.parsers"

local get_function_content = function(function_name)
  -- Get the current buffer's file name and modify it to the corresponding implementation file
  local current_file = vim.api.nvim_buf_get_name(0)
  local target_file = current_file:gsub("_test", "")
  print(target_file)
  print(function_name)

  -- Load the target file in a buffer
  local bufnr = vim.fn.bufadd(target_file)
  vim.fn.bufload(bufnr)

  -- Setup Treesitter parser
  local lang = vim.bo[bufnr].filetype
  local parser = vim.treesitter.get_parser(bufnr, lang)
  local root_tree = parser:parse()[1]:root()

  -- Treesitter query to find the function implementation
  local query_string = [[
    (function_declaration name: (identifier) @function_name)
    (method_declaration name: (field_identifier) @function_name)
]]
  local query = vim.treesitter.query.parse(lang, query_string)
  for id, node in query:iter_captures(root_tree, bufnr, 0, -1) do
    print(vim.treesitter.get_node_text(node, bufnr))
    if vim.treesitter.get_node_text(node, bufnr) == function_name then
      local func_node = node:parent()
      local start_row, _, end_row, _ = func_node:range()
      local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
      return table.concat(lines, "\n")
    end
  end
  print "Function not found."
  return "Function not found."
  -- local bufnr = vim.api.nvim_get_current_buf()
  -- local lang = vim.bo[bufnr].filetype
  -- local parser = vim.treesitter.get_parser(bufnr, lang)
  -- local root_tree = parser:parse()[1]:root()
  --
  -- -- Update the query for Go language
  -- local query = vim.treesitter.query.parse(lang, "(function_declaration name: (identifier) @function_name)")
  -- for id, node in query:iter_captures(root_tree, bufnr, 0, -1) do
  --   if query.captures[id] == "function_name" and vim.treesitter.get_node_text(node, bufnr) == function_name then
  --     local func_node = node:parent()
  --     local start_row, _, end_row, _ = func_node:range()
  --     local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  --     print(table.concat(lines, "\n"))
  --     return table.concat(lines, "\n")
  --   end
  -- end
  -- print "Function not found."
  -- return "Function not found."

  -- vim.lsp.buf.definition()
  --
  -- vim.wait(1000, function() end)
  --
  -- local bufnr = vim.api.nvim_get_current_buf()
  -- local lang = vim.bo[bufnr].filetype
  -- local parser = vim.treesitter.get_parser(bufnr, lang)
  -- local root_tree = parser:parse()[1]:root()
  --
  -- local query = vim.treesitter.query.parse(lang, "(function_definition (identifier) @function_name)")
  -- for id, node in query:iter_captures(root_tree, bufnr, 0, -1) do
  --   if query.captures[id] == "function_name" and vim.treesitter.query.get_node_text(node, bufnr) == function_name then
  --     local func_node = node:parent()
  --     local start_row, _, end_row, _ = func_node:range()
  --     local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  --     return table.concat(lines, "\n")
  --   end
  -- end
end

M.find_nearest_tested_function_name = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local lang = vim.bo[bufnr].filetype
  local parser = vim.treesitter.get_parser(bufnr, lang)
  local root_tree = parser:parse()[1]:root()

  -- Get the current cursor line
  local cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1 -- Lua is 1-indexed, but Treesitter uses 0-indexed rows

  -- Treesitter query to find the test function
  local query_str = [[
        (function_declaration
            name: (identifier) @test_func
        )
    ]]
  local query = vim.treesitter.query.parse(lang, query_str)

  -- Find the nearest test function name from the cursor
  local closest_func_name = nil
  local closest_distance = math.huge

  for id, node in query:iter_captures(root_tree, bufnr, 0, -1) do
    if query.captures[id] == "test_func" then
      local node_text = vim.treesitter.get_node_text(node, bufnr)
      if node_text:match "Test" then
        local start_row, _, _, _ = node:range()
        local distance = math.abs(start_row - cursor_row)
        if distance < closest_distance then
          closest_distance = distance
          local method_name = node_text:match "%w+_%w+"
          if method_name then
            closest_func_name = method_name:match "_([%w_]+)"
          end
        end
      end
    end
  end

  return closest_func_name or "Function not found."
end

M.get_implementation_of_nearest_test_function = function()
  local function_name = M.find_nearest_tested_function_name()
  return get_function_content(function_name)
end

return M
