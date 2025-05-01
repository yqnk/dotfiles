local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Add breakpoint at line",
    },
    ["<leader>dcb"] = {
      "<cmd> DapClearBreakpoints <CR>",
      "Clear all breakpoints",
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Run or continue the debugger",
    },
    ["<leader>dsi"] = {
      "<cmd> DapStepInto <CR>",
      "Step in",
    },
    ["<leader>dso"] = {
      "<cmd> DapStepOut <CR>",
      "Step out",
    },
    ["<leader>dt"] = {
      "<cmd> DapTerminate <CR>",
      "Terminate debugger",
    },

    ["<leader>x"] = {
      "<cmd> bd <CR>",
      "Delete current buffer",
    },
  },
}

M.dap_go = {
  plugin = true,
  n = {
    ["<leader>dgt"] = {
      function()
        require("dap-go").debug_test()
      end,
      "Debug go test",
    },
    ["<leader>dgl"] = {
      function()
        require("dap-go").debug_last()
      end,
      "Debug go last test",
    },
  },
}

M.gopher = {
  plugin = true,
  n = {
    ["<leader>gsj"] = {
      "<cmd> GoTagAdd json <CR>",
      "Add json struct tags",
    },
    ["<leader>gsy"] = {
      "<cmd> GoTagAdd yaml <CR>",
    },
  },
}

return M
