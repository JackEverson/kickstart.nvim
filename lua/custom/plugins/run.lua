
local run_defaults = {
  rust = { F5 = 'cargo run', F6 = 'cargo build --release', F7 = 'cargo test' },
  python = { F5 = 'python %' },
  lua = { F5 = 'lua %' },
}

-- Parse `.run` in the cwd into { F5 = 'cmd', F6 = 'cmd', ... }
local function read_run_file()
  local map = {}
  local f = io.open '.run'
  if not f then return map end
  for line in f:lines() do
    local key, cmd = line:match '^%s*(F%d+)%s*=%s*(.-)%s*$'
    if key and cmd ~= '' then map[key] = cmd end
  end
  f:close()
  return map
end

local run_buf
local function run_in_term(cmd)
  if run_buf and vim.api.nvim_buf_is_valid(run_buf) then
    vim.api.nvim_buf_delete(run_buf, { force = true }) -- kills the previous run too
  end
  vim.cmd 'botright 15split'
  vim.cmd('terminal ' .. vim.fn.expandcmd(cmd)) -- expands % to the current file
  run_buf = vim.api.nvim_get_current_buf()
  vim.cmd 'wincmd p' -- cursor back to your code
end

for n = 1, 12 do
  local key = 'F' .. n
  vim.keymap.set('n', '<' .. key .. '>', function()
    local cmd = read_run_file()[key] or (run_defaults[vim.bo.filetype] or {})[key]
    if not cmd then
      vim.notify(key .. ' is not set in .run for this project', vim.log.levels.WARN)
      return
    end
    run_in_term(cmd)
  end, { desc = 'Run .run ' .. key })
end
