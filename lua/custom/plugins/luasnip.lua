
-- NOTE: You can also specify plugin using a version range for its git tag.
--  See `:help vim.version.range()` for more info
vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
require('luasnip').setup {}

local ls = require 'luasnip'
local s, f = ls.snippet, ls.function_node
ls.add_snippets('all', {
  s('date', f(function() return os.date '%Y-%m-%d' end)),
  s('datetime', f(function() return os.date '%Y-%m-%d %H:%M' end)),
})


