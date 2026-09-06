local M = {
  window = {
    width = 30,
    mappings = {
      ["<tab>"] = "open",
      ["<cr>"] = "open",
    },
  },
  commands = {
    tab_open_or_expand = function(state)
      local node = state.tree:get_node()
      if node.type == "directory" then
        require("neo-tree.sources.filesystem.commands").toggle_node(state)
      else
        require("neo-tree.sources.filesystem.commands").open(state)
      end
    end,
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
