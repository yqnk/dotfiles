local map = vim.keymap.set
local unmap = vim.keymap.del

map({ 'n', 'i', 'v' }, '<C-s>', '<cmd> w <cr>')
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- nvimtree
map('n', '<C-n>', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })
map('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })
-- leader quit
map('n', '<leader>Q', '<cmd> qall <CR>', {
  desc = 'Quit all',
})
map('n', '<leader>q', '<cmd> q <CR>', {
  desc = 'Quit',
})
map('n', '<leader>x', '<cmd> bd <CR>', {
  desc = 'Close buffer',
})

-- move one line
map('n', '<A-j>', '<cmd> m +1 <CR>', {
  desc = 'move current line',
})
map('n', '<A-k>', '<cmd> m -2 <CR>', {
  desc = 'move current line',
})

map('v', '<A-j>', ":move '>+1<CR>gv-gv", {
  desc = 'move selected line',
})
map('v', '<A-k>', ":move '<-2<CR>gv-gv", {
  desc = 'move selected line',
})
