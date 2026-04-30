-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "everblush",
  transparency = true,

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },

  hl_add = {
    -- WhichKeyBorder = { fg = "#22292b" },
    -- WhichKeyNormal = { bg = "#141b1e" },
  },
}

M.ui = {
  cmp = {
    icons_left = true,
    style = "flat_dark",
    format_colors = { lsp = true },
  },

  telescope = {
    style = "bordered",
  },

  statusline = {
    theme = "minimal",
  },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
