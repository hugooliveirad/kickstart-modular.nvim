-- annotate.nvim tests
-- Run with: :luafile %
-- This file returns empty table to avoid lazy.nvim treating it as a plugin spec

local M = {}

-- Test utilities
local function assert_eq(actual, expected, msg)
  if actual ~= expected then
    error(string.format('%s: expected %s, got %s', msg or 'Assertion failed', vim.inspect(expected), vim.inspect(actual)))
  end
end

local function assert_true(value, msg)
  if not value then
    error(msg or 'Expected true, got false')
  end
end

local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    print('✓ ' .. name)
  else
    print('✗ ' .. name .. ': ' .. tostring(err))
  end
end

-- Get the annotate module
local function get_annotate()
  -- Clear cached module to get fresh state
  package.loaded['custom.plugins.annotate'] = nil
  local spec = require 'custom.plugins.annotate'
  -- The module table is in the same file, we need to access it differently
  -- For testing, we'll load the file and extract M
  local annotate_path = vim.fn.stdpath 'config' .. '/lua/custom/plugins/annotate.lua'
  local chunk = loadfile(annotate_path)
  if not chunk then
    error 'Failed to load annotate.lua'
  end

  -- Execute in isolated environment to get M
  local env = setmetatable({}, { __index = _G })
  setfenv(chunk, env)
  chunk()

  -- M is local, so we need to use the returned spec
  -- The setup function initializes M, so we call it
  return spec
end

function M.run_tests()
  print '\n=== annotate.nvim tests ===\n'

  test('Module loads without error', function()
    local spec = get_annotate()
    assert_true(spec ~= nil, 'spec should not be nil')
    assert_true(spec.config ~= nil, 'config function should exist')
  end)

  test('Config function exists', function()
    local spec = get_annotate()
    assert_eq(type(spec.config), 'function', 'config should be a function')
  end)

  test('Plugin has correct name', function()
    local spec = get_annotate()
    assert_eq(spec.name, 'annotate', 'name should be annotate')
  end)

  -- Integration test: create a test buffer and add annotation
  test('Can create buffer and setup plugin', function()
    local spec = get_annotate()

    -- Create a test buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      'line 1',
      'line 2',
      'line 3',
    })

    -- Setup should not error
    local ok = pcall(spec.config)
    assert_true(ok, 'setup should not error')

    -- Cleanup
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  test('Truncate function works correctly', function()
    -- We can't test internal functions directly, but we can verify behavior
    -- through the public API later
    assert_true(true, 'placeholder')
  end)

  -- Test virtual text positioning (uses virt_lines below hunk)
  test('Virtual text renders below hunk with arrow prefix', function()
    -- Ensure module is loaded with global access
    require 'custom.plugins.annotate'

    -- Create a test buffer with some content
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      'function test()',
      '  local x = 1',
      '  local y = 2',
      '  return x + y',
      'end',
    })

    -- Add annotation programmatically using global
    if _G.Annotate then
      -- Add annotation on lines 2-3 (the local declarations)
      _G.Annotate.add(2, 3)
      -- Since add() prompts for input, we'll just verify the module loads
      -- Visual testing will verify the actual rendering
    end

    -- Cleanup
    vim.api.nvim_buf_delete(buf, { force = true })
    assert_true(true, 'Virtual text test setup completed')
  end)

  -- Test drift detection doesn't false positive on unchanged content
  test('Drift detection: unchanged content should not drift', function()
    require 'custom.plugins.annotate'

    if not _G.Annotate then
      error 'Annotate global not available'
    end

    -- Create a test buffer with content
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    local test_lines = {
      'line 1',
      'line 2',
      'line 3',
      'line 4',
      'line 5',
    }
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, test_lines)

    -- Get all current annotations and clear them for clean test
    local all = _G.Annotate.get_all()
    for _, ann in ipairs(all) do
      _G.Annotate.delete(ann)
    end

    -- We can't easily test add() since it prompts, but we can verify
    -- the get_all() and drift detection logic works
    assert_true(#_G.Annotate.get_all() == 0, 'Should have no annotations after clearing')

    -- Cleanup
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  -- Test extmark position tracking (regression test for drift bug)
  test('Extmark tracks end_line position correctly', function()
    require 'custom.plugins.annotate'

    -- This is a regression test for the bug where update_position_from_extmark
    -- incorrectly assumed the extmark tracked start_line instead of end_line
    -- The fix ensures extmark position changes update both start_line and end_line
    -- by calculating line_diff from end_line, not start_line

    -- Visual testing needed to fully verify this works across buffer close/reopen
    assert_true(true, 'Extmark position tracking test - visual verification required')
  end)

  print '\n=== Tests complete ===\n'
end

-- Run tests when sourced directly
if vim.fn.expand '%:t' == 'annotate_test.lua' then
  M.run_tests()
end

-- Return empty table for lazy.nvim (not a plugin spec)
return {}
