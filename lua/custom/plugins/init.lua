-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- Iterate over all Lua files in the plugins directory and load them.
-- `vim.fs.dir()` iteration order is unspecified and must not be relied upon.
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')
for file_name, type in vim.fs.dir(plugins_dir, { follow = true }) do
  if (type == 'file' or type == 'link') and file_name:match '%.lua$' and file_name ~= 'init.lua' then
    local module = file_name:gsub('%.lua$', '')
    require('custom.plugins.' .. module)
  end
end

local nontext = vim.api.nvim_create_augroup('nontext-files', { clear = true })

vim.api.nvim_create_autocmd('BufReadCmd', {
  group = nontext,
  pattern = {
    '*.png',
    '*.jpg',
    '*.jpeg',
    '*.gif',
    '*.webp',
    '*.bmp',
    '*.ico',
    '*.mp4',
    '*.mkv',
    '*.mov',
    '*.mp3',
    '*.wav',
    '*.pdf',
    '*.docx',
    '*.xlsx',
    '*.pptx',
    '*.zip',
    '*.7z',
  },
  callback = function(ev)
    vim.ui.open(ev.file)
    vim.schedule(function() vim.api.nvim_buf_delete(ev.buf, { force = true }) end)
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = nontext,
  callback = function(ev)
    for _, line in ipairs(vim.api.nvim_buf_get_lines(ev.buf, 0, 50, false)) do
      -- The buffer API shows a NUL byte as a newline inside a line.
      if line:find('\n', 1, true) then
        vim.bo[ev.buf].modifiable = false
        vim.bo[ev.buf].readonly = true
        vim.notify('binary file, opened read-only', vim.log.levels.WARN)
        return
      end
    end
  end,
})

vim.keymap.set('n', '<leader>x', function() vim.system({ vim.fn.expand '%:p' }, { detach = true }) end, { desc = 'Launch this file as a program' })
