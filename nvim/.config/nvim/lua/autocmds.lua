require "nvchad.autocmds"

-- Drop kitty window padding while nvim is running, restore it on exit
if vim.env.KITTY_LISTEN_ON then
  local function set_padding(value)
    vim.system({ "kitty", "@", "set-spacing", "padding=" .. value })
  end

  local group = vim.api.nvim_create_augroup("KittyPadding", { clear = true })

  vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
    group = group,
    callback = function()
      set_padding(0)
    end,
  })

  vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
    group = group,
    callback = function()
      set_padding("default")
    end,
  })
end
