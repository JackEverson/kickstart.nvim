vim.pack.add {
  gh 'folke/snacks.nvim',
  gh 'folke/persistence.nvim',
}

require('persistence').setup {} -- saves a session per project folder on exit

require('snacks').setup {
  dashboard = {
    enabled = true,
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      { pane = 2, icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
      { pane = 2, icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
      { text = { { 'Neovim ' .. tostring(vim.version()), hl = 'footer' } }, align = 'center' },
    },
  },
  picker = { enabled = true },
  explorer = { enabled = true },
  bigfile = { enabled = true },
}

vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Lazy[g]it' })
vim.keymap.set('n', '<leader>rs', function() require('persistence').load() end, { desc = '[R]estore [S]ession for this folder' })
vim.keymap.set('n', '<leader>rl', function() require('persistence').load { last = true } end, { desc = '[R]estore [L]ast session' })
vim.keymap.set('n', '<leader>fp', function() Snacks.picker.projects() end, { desc = '[F]ind [P]roject' })
vim.keymap.set('n', '<leader>e', function() Snacks.explorer() end, { desc = 'File explorer' })

-- actually for bufline but require snacks!
vim.keymap.set('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = '[B]uffer [D]elete' })
vim.keymap.set('n', '<leader>bD', function() Snacks.bufdelete.other() end, { desc = '[B]uffer delete others' })
