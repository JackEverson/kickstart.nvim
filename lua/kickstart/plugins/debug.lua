-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  -- 'https://github.com/leoluz/nvim-dap-go',
}

-- Basic debugging keymaps, feel free to change to your liking!
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
-- Only step when a thread is actually stopped. Otherwise the previous step is still in
-- flight and nvim-dap would prompt 'Select thread to step in' with a stale thread list.
local function step(fn)
  return function()
    local s = require('dap').session()
    if s and s.stopped_thread_id then
      fn()
    else
      vim.notify('Debugger is still running - wait for it to stop', vim.log.levels.WARN)
    end
  end
end
vim.keymap.set('n', '<F8>', step(function() require('dap').step_into() end), { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F9>', step(function() require('dap').step_over() end), { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F10>', step(function() require('dap').step_out() end), { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set Breakpoint' })
-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
vim.keymap.set('n', '<F7>', function() require('dapui').toggle() end, { desc = 'Debug: See last session result.' })

local dap = require 'dap'
local dapui = require 'dapui'

-- Build with cargo and locate the binary, so <F5> needs no path prompt.
-- Returns a coroutine so the build can run without freezing the editor;
-- nvim-dap resumes it and waits for us to hand back the path. See `:help dap-configuration`.
local function cargo_binary()
  return coroutine.create(function(dap_run_co)
    local co = coroutine.running()

    -- Run a command, suspend until it finishes, hand back the result.
    local function await(cmd)
      vim.system(cmd, { text = true }, function(result)
        vim.schedule(function() coroutine.resume(co, result) end)
      end)
      return coroutine.yield()
    end

    local function abort(msg)
      if msg then vim.notify(msg, vim.log.levels.ERROR) end
      coroutine.resume(dap_run_co, dap.ABORT)
    end

    vim.notify 'cargo build...'
    local build = await { 'cargo', 'build' }
    if build.code ~= 0 then return abort('cargo build failed:\n' .. (build.stderr or '')) end

    local meta = await { 'cargo', 'metadata', '--no-deps', '--format-version', '1' }
    if meta.code ~= 0 then return abort 'cargo metadata failed - not inside a cargo project?' end
    local data = vim.json.decode(meta.stdout)

    -- Every binary target in the workspace.
    local bins = {}
    for _, pkg in ipairs(data.packages) do
      for _, target in ipairs(pkg.targets) do
        if vim.tbl_contains(target.kind, 'bin') then table.insert(bins, target.name) end
      end
    end
    if #bins == 0 then return abort 'no binary targets in this workspace' end

    local name = bins[1]
    if #bins > 1 then
      vim.ui.select(bins, { prompt = 'Debug which binary?' }, function(choice) coroutine.resume(co, choice) end)
      name = coroutine.yield()
      if not name then return abort() end
    end

    local exe = vim.fn.has 'win32' == 1 and '.exe' or ''
    coroutine.resume(dap_run_co, data.target_directory .. '/debug/' .. name .. exe)
  end)
end




require('mason-nvim-dap').setup {
  -- Makes a best effort to setup the various debuggers with
  -- reasonable debug configurations
  automatic_installation = true,





  -- You can provide additional configuration to the handlers,
  -- see mason-nvim-dap README for more information
  handlers = {
    codelldb = function(config)
      require('mason-nvim-dap').default_setup(config) -- adapter + default configs for C/C++
      dap.configurations.rust = {
        {
          name = 'Launch (cargo build)',
          type = 'codelldb',
          request = 'launch',
          program = cargo_binary,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          console = 'integratedTerminal', -- program stdout/stdin in a terminal split
          -- args = { '--flag', 'value' },
        },
      }
    end,
  },

  -- You'll need to check that you have the required things installed
  -- online, please don't ask me how to install them :)
  ensure_installed = {
    -- Update this to ensure that you have the debuggers for the langs you want
    -- 'delve',
    'codelldb',
  },
}

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
---@diagnostic disable-next-line: missing-fields
dapui.setup {
  -- Set icons to characters that are more likely to work in every terminal.
  --    Feel free to remove or use ones that you like more! :)
  --    Don't feel like these are good choices.
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  ---@diagnostic disable-next-line: missing-fields
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

-- Change breakpoint icons
-- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
-- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
-- local breakpoint_icons = vim.g.have_nerd_font
--     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
--   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
-- for type, icon in pairs(breakpoint_icons) do
--   local tp = 'Dap' .. type
--   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
--   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
-- end

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- Install golang specific config
-- require('dap-go').setup {
--   delve = {
--     -- On Windows delve must be run attached or it crashes.
--     -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
--     detached = vim.fn.has 'win32' == 0,
--   },
-- }


