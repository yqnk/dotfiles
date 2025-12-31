require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local nomap = vim.keymap.del

--general
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "v" }, "<A-j>", "<cmd> m +1 <CR>")
map({ "n", "v" }, "<A-k>", "<cmd> m -2 <CR>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- conform (format)
nomap({ "n", "x" }, "<leader>fm")
map({ "n", "x" }, "<leader>f", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "general format file " })

-- nvimtree
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
map("n", "<C-n>", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })

-- telescope
map("n", "<leader>sg", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
map("n", "<leader>sb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>sh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>sm", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
map("n", "<leader>so", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>sc", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
map("n", "<leader>st", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })

-- cmake-tools
map("n", "<leader>cmg", "<cmd>CMakeGenerate<cr>", { desc = "CMake Generate" })
map("n", "<leader>cmb", "<cmd>CMakeBuild<cr>", { desc = "CMake Build" })
map("n", "<leader>cmr", "<cmd>CMakeRun<cr>", { desc = "CMake Run" })
map("n", "<leader>cmk", "<cmd>CMakeSelectKit<cr>", { desc = "CMake Select Kit (Compiler)" })
map("n", "<leader>cmt", "<cmd>CMakeSelectBuildType<cr>", { desc = "CMake Build Type (Debug/Release)" })
map("n", "<leader>cml", "<cmd>CMakeSelectLaunchTarget<cr>", { desc = "CMake Select Launch Target" })
map("n", "<leader>cms", "<cmd>CMakeSelectBuildTarget<cr>", { desc = "CMake Select Build Target" })
map("n", "<leader>cmc", "<cmd>CMakeClean<cr>", { desc = "CMake Clean Files" })
map("n", "<leader>cmqe", "<cmd>CMakeStopExecutor<cr>", { desc = "CMake Stop Executor" })
map("n", "<leader>cmqr", "<cmd>CMakeStopRunner<cr>", { desc = "CMake Stop Runner" })
map("n", "<leader>cmoe", "<cmd>CMakeOpenExecutor<cr>", { desc = "CMake Open Output" })
map("n", "<leader>cmor", "<cmd>CMakeOpenRunner<cr>", { desc = "CMake Open Runner" })
map("n", "<leader>cmwe", "<cmd>CMakeCloseExecutor<cr>", { desc = "CMake Close Output" })
map("n", "<leader>cmwr", "<cmd>CMakeCloseRunner<cr>", { desc = "CMake Close Runner" })

nomap("n", "<leader>fw")
nomap("n", "<leader>fb")
nomap("n", "<leader>fh")
nomap("n", "<leader>ma")
nomap("n", "<leader>fo")
nomap("n", "<leader>fz")
nomap("n", "<leader>cm")
nomap("n", "<leader>gt")
nomap("n", "<leader>pt")
