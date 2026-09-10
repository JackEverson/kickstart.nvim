vim.pack.add { gh 'jake-stewart/multicursor.nvim' }

local mc = require 'multicursor-nvim'
mc.setup()

local set = vim.keymap.set

-- [[ Building a set of cursors ]]

-- Add or skip a cursor on the line above/below.
set({ 'n', 'x' }, '<up>', function() mc.lineAddCursor(-1) end, { desc = 'Multicursor: add above' })
set({ 'n', 'x' }, '<down>', function() mc.lineAddCursor(1) end, { desc = 'Multicursor: add below' })
set({ 'n', 'x' }, '<leader><up>', function() mc.lineSkipCursor(-1) end, { desc = 'Multicursor: skip above' })
set({ 'n', 'x' }, '<leader><down>', function() mc.lineSkipCursor(1) end, { desc = 'Multicursor: skip below' })

-- Add a cursor at the next match of the word (or visual selection) under the cursor.
set({ 'n', 'x' }, '<C-n>', function() mc.matchAddCursor(1) end, { desc = 'Multicursor: add at next match' })

-- NOTE: <leader>s is the [S]earch group, so the rest live under <leader>m.
set({ 'n', 'x' }, '<leader>mp', function() mc.matchAddCursor(-1) end, { desc = '[M]ulticursor add at [P]rev match' })
set({ 'n', 'x' }, '<leader>ms', function() mc.matchSkipCursor(1) end, { desc = '[M]ulticursor [S]kip next match' })
set({ 'n', 'x' }, '<leader>ma', mc.matchAllAddCursors, { desc = '[M]ulticursor add to [A]ll matches' })
set('n', '<leader>mr', mc.restoreCursors, { desc = '[M]ulticursor [R]estore cleared cursors' })

-- `gaip` puts a cursor on every line of a paragraph. Works with any text object.
set({ 'n', 'x' }, 'ga', mc.addCursorOperator, { desc = 'Multicursor: add over text object' })

-- [[ Visual selection -> a cursor per line ]]
-- This is the live-preview replacement for <C-v>I and <C-v>A.
set('x', 'I', mc.insertVisual, { desc = 'Multicursor: insert on every selected line' })
set('x', 'A', mc.appendVisual, { desc = 'Multicursor: append on every selected line' })

-- [[ Managing cursors ]]
set({ 'n', 'x' }, '<C-q>', mc.toggleCursor, { desc = 'Multicursor: toggle cursor here' })

-- These only bind while multiple cursors exist, so they can overlap normal maps.
mc.addKeymapLayer(function(layerSet)
  layerSet({ 'n', 'x' }, '<left>', mc.prevCursor, { desc = 'Multicursor: previous' })
  layerSet({ 'n', 'x' }, '<right>', mc.nextCursor, { desc = 'Multicursor: next' })
  layerSet({ 'n', 'x' }, '<leader>mx', mc.deleteCursor, { desc = '[M]ulticursor delete this cursor' })
  layerSet('n', '<esc>', function()
    if not mc.cursorsEnabled() then
      mc.enableCursors()
    else
      mc.clearCursors()
    end
  end, { desc = 'Multicursor: enable or clear' })
end)

-- [[ Mouse ]]
-- Ctrl+Alt+click to add a cursor, again on an existing one to remove it.
-- Ctrl+Alt+drag to add a cursor with a visual selection.
-- Plain Ctrl+click is left alone, so it stays as CTRL-] (goto definition via LSP tagfunc).
set('n', '<C-M-LeftMouse>', mc.handleMouse, { desc = 'Multicursor: add/remove cursor at click' })
set('n', '<C-M-LeftDrag>', mc.handleMouseDrag, { desc = 'Multicursor: drag selection' })
set('n', '<C-M-LeftRelease>', mc.handleMouseRelease, { desc = 'Multicursor: end drag' })
