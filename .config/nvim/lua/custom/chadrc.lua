---@type ChadrcConfig
local M = {}

M.ui = { theme = "jellybeans", transparency = true, tabufline = { enabled = false } }
M.mappings = require "custom.mappings"
M.plugins = "custom.plugins"

return M
