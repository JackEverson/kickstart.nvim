-- MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,

--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
require 'custom.options'

require 'custom.autocmd'
require 'custom.keymap'
require 'custom.lsp'
require 'custom.kickstart'

require 'custom.plugins'


--  Uncomment any of the lines below to enable them (you will need to restart nvim).
--
require 'kickstart.plugins.debug'
require 'kickstart.plugins.indent_line'
-- require 'kickstart.plugins.lint'
require 'kickstart.plugins.autopairs'
-- require 'kickstart.plugins.neo-tree'
