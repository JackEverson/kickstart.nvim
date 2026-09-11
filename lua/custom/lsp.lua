-- Rust
vim.lsp.config('rust_analyzer', {

  settings = {
    ['rust-analyzer'] = {

      check = { command = 'clippy' }, -- clippy lints as diagnostics on save
      cargo = { features = 'all' },
    },
  },
})
vim.lsp.enable 'rust_analyzer'
