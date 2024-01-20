
local M = {}
M.base_30 = {
  white = "#abb2bf",
  darker_black = "#1b1f27",
  black = "#171819", --  nvim bg
  black2 = "#252931",
  one_bg = "#252931", -- real bg of onedark
  one_bg2 = "#353b45",
  one_bg3 = "#373b43",
  grey = "#42464e",
  grey_fg = "#565c64",
  grey_fg2 = "#6f737b",
  light_grey = "#6f737b",
  red = "#e06c75",
  baby_pink = "#DE8C92",
  pink = "#ff75a0",
  line = "#31353d", -- for lines like vertsplit
  green = "#98c379",
  vibrant_green = "#7eca9c",
  nord_blue = "#81A1C1",
  blue = "#61afef",
  yellow = "#e7c787",
  sun = "#EBCB8B",
  purple = "#de98fd",
  dark_purple = "#c882e7",
  teal = "#519ABA",
  orange = "#fca2aa",
  cyan = "#a3b8ef",
  statusline_bg = "#22262e",
  lightbg = "#2d3139",
  pmenu_bg = "#61afef",
  folder_bg = "#61afef",
}

M.base_16 = {
  base00 = "#171819",
  base01 = "#9A7F54",
  base02 = "#B5BD68",
  base03 = "#A56C3A",
  base04 = "#C07C41",
  base05 = "#B294BB",
  base06 = "#8ABEB7",
  base07 = "#676968",
  base08 = "#C5C8C6",
  base09 = "#B0AAA0",
  base0A = "#748B63",
  base0B = "#DEB779",
  base0C = "#C07C41",
  base0D = "#B79968",
  base0E = "#8ABEB7",
  base0F = "#949CA5",
}

M.polish_hl = {
  ["@variable"] = { fg = M.base_16.base0F },
  ["@punctuation.bracket"] = { fg = M.base_30.purple },
  ["@method.call"] = { fg = M.base_30.red },
  ["@function.call"] = { fg = M.base_30.blue },
  ["@constant"] = { fg = M.base_30.orange },
  ["@parameter"] = { fg = M.base_30.orange },
}

M.type = "dark"

M = require("base46").override_theme(M, "qtnx")

return M
