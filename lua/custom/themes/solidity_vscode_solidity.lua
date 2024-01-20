-- Thanks to original theme for existing https://github.com/microsoft/vscode/blob/main/extensions/theme-defaults/themes/dark_plus.json
-- this is a modified version of it

local M = {}

M.base_30 = {
  white = "#dee1e6",
  darker_black = "#1a1a1a",
  black = "#222336", --  nvim bg
  black2 = "#252525",
  one_bg = "#282828",
  one_bg2 = "#313131",
  one_bg3 = "#3a3a3a",
  grey = "#444444",
  grey_fg = "#4e4e4e",
  grey_fg2 = "#585858",
  light_grey = "#626262",
  red = "#D16969",
  baby_pink = "#ea696f",
  pink = "#bb7cb6",
  line = "#2e2e2e", -- for lines like vertsplit
  green = "#B5CEA8",
  green1 = "#4EC994",
  vibrant_green = "#bfd8b2",
  blue = "#75ceef",
  nord_blue = "#60a6e0",
  yellow = "#D7BA7D",
  sun = "#e1c487",
  purple = "#c68aee",
  dark_purple = "#b77bdf",
  teal = "#3fe2a7",
  orange = "#d3967d",
  cyan = "#569CD6",
  statusline_bg = "#242424",
  lightbg = "#303030",
  pmenu_bg = "#60a6e0",
  folder_bg = "#7A8A92",
}

M.base_16 = {
  --author of this template Tomas Iser, @tomasiser on github,
  base00 = "#222336",
  base01 = "#262626",
  base02 = "#303030",
  base03 = "#3C3C3C",
  base04 = "#808080",
  base05 = "#D4D4D4",
  base06 = "#E9E9E9",
  base07 = "#FFFFFF",
  base08 = "#D16969",
  base09 = "#B5CEA8",
  -- base0A = "#D7BA7D",
  -- base0A = "#3fe2a7",
  base0A = "#679ad1",
  base0B = "#608B4E",
  base0C = "#9CDCFE",
  base0D = "#569CD6",
  base0E = "#C586C0",
  base0F = "#CE9178",
}

M.polish_hl = {
  ["@parameter"] = { fg = M.base_16.base05 },
  ["@keyword"] = { fg = "#4aa8fd" },
  ["@variable.parameter"] = { fg = "#9CDCFE" },
  ["@type"] = { fg = M.base_30.blue },
  ["@variable"] = { fg = M.base_16.base05 },
  ["@property"] = { fg = M.base_16.base05 },
  ["@keyword.return"] = { fg = M.base_16.base0B },
  ["@keyword.function"] = { fg = M.base_30.teal },
  ["@comment"] = { fg = "#a7a7a7" },
  ["@tag"] = { fg = "#BE53E6" },
}

M.type = "dark"

M = require("base46").override_theme(M, "solidity_vscode_dark")

return M
