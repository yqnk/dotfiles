local M = {
  window = {
    width = 30,
    mappings = {
      ["<Tab>"] = "open",
      ["<cr>"] = "open",
    },
  },
  -- nesting_rules = {},
  filesystem = {
    scan_mode = "deep",
    group_empty_dirs = true,

    filtered_items = {
      hide_dotfiles = false,
    },
  },
}

return M
