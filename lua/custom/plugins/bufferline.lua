
  vim.pack.add { gh 'akinsho/bufferline.nvim' }

  -- vim.o.showtabline = 0 -- always show the line, even with one buffer

  require('bufferline').setup {
    options = {
      diagnostics = 'nvim_lsp', -- error and warning counts on each tab
      offsets = { { filetype = 'snacks_layout_box' } }, -- shift right when the explorer is open
      always_show_bufferline = true,
    },
  }

  vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Previous buffer' })
  vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
  vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>', { desc = '[B]uffer [P]in' })
  vim.keymap.set('n', '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', { desc = '[B]uffer close [O]thers' })
