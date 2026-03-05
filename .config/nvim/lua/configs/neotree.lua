local M = {
  window = {
    width = 40,
    mappings = {
      ["<TAB>"] = "open",
    },
  },
  -- nesting_rules = {},
  filesystem = {
    scan_mode = "deep",
    group_empty_dirs = true,
  },
}

return M
