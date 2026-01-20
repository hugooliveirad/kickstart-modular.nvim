-- annotate.nvim - Code review comments with virtual text display
-- See specs/annotate-nvim.md for full specification
--
-- COMPLETED:
-- 1. Core annotation functionality (add, edit, delete, undo, yank)
-- 2. Virtual text display + sign column indicators
-- 3. Drift detection for changed code
-- 4. Trouble.nvim custom source integration
-- 5. Buffer re-attachment on BufEnter (annotations persist across close/reopen)
-- 6. Delete from Trouble list (press 'd' to delete selected annotation)
-- 7. Edit from Trouble list (press 'e' to edit selected annotation)
-- 8. Navigation indicators in Trouble (severity icon for drifted, line range [L10-L15])
-- 9. Export to markdown file (<leader>rw with filename prompt)
-- 10. Jump to next/prev annotation (]r/[r, configurable keymaps)
-- 11. Import annotations from markdown file (<leader>ri)
-- 12. Filter cycling in Trouble ('f' key: all/current_buffer/drifted)
--
-- NEXT TWO MOVES (PRIORITY ORDER):
--
-- MOVE 1: Persist annotations to disk (optional, session-based by default)
--    Purpose: Allow saving/loading annotations across Neovim sessions
--    Implementation:
--    - Add config option: persist = false (default)
--    - When enabled, auto-save to .annotations.json on change
--    - Auto-load on BufEnter if file exists
--    - Respect .gitignore (don't track by default)
--    Test: Enable persist, add annotation, restart nvim, verify annotation restored
--
-- MOVE 2: Telescope integration
--    Purpose: Alternative to Trouble for annotation searching
--    Implementation:
--    - Add :Telescope annotate picker
--    - Show annotations with preview
--    - Support filtering by drifted/file
--    - Actions: jump, edit, delete
--    Test: Open telescope picker, search annotations, jump to selected

---@class Annotation
---@field id number Unique identifier
---@field bufnr number Buffer number
---@field file string Absolute file path
---@field start_line number 1-indexed start line
---@field end_line number 1-indexed end line
---@field original_content string[] Original lines (for drift detection)
---@field comment string The annotation text
---@field created_at number Timestamp
---@field extmark_id number|nil Extmark ID for tracking
---@field sign_ids number[] Sign IDs for the range
---@field drifted boolean Whether content has changed

local M = {}

-- State
local annotations = {} ---@type table<number, Annotation>
local next_id = 1
local undo_stack = {} ---@type Annotation[]
local max_undo = 10
local namespace = nil ---@type number|nil

-- Default configuration
local config = {
  keymaps = {
    add = '<leader>ra',
    list = '<leader>rl',
    yank = '<leader>ry',
    delete = '<leader>rd',
    edit = '<leader>re',
    delete_all = '<leader>rD',
    undo = '<leader>ru',
    write = '<leader>rw',
    import = '<leader>ri',
    next_annotation = ']r',
    prev_annotation = '[r',
  },
  float = {
    width = 40,
    height = 3,
    border = 'rounded',
  },
  virtual_text = {
    prefix = ' ',
    max_length = 60,
  },
  sign = {
    text = '',
    hl = 'DiagnosticSignInfo',
  },
  highlights = {
    virtual_text = 'Comment',
    virtual_text_drifted = 'DiagnosticWarn',
    sign = 'DiagnosticSignInfo',
    sign_drifted = 'DiagnosticSignWarn',
  },
}

-- Initialize namespace and signs
local function init()
  if namespace then
    return
  end
  namespace = vim.api.nvim_create_namespace 'annotate'

  -- Define signs
  vim.fn.sign_define('AnnotateSign', {
    text = config.sign.text,
    texthl = config.highlights.sign,
  })
  vim.fn.sign_define('AnnotateSignDrifted', {
    text = config.sign.text,
    texthl = config.highlights.sign_drifted,
  })
end

-- Get buffer lines
---@param bufnr number
---@param start_line number 1-indexed
---@param end_line number 1-indexed
---@return string[]
local function get_buffer_lines(bufnr, start_line, end_line)
  return vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
end

-- Truncate text for virtual text display
---@param text string
---@param max_len number
---@return string
local function truncate(text, max_len)
  if #text <= max_len then
    return text
  end
  return text:sub(1, max_len - 3) .. '...'
end

-- Check if annotation content has drifted
---@param annotation Annotation
---@return boolean
local function check_drift(annotation)
  if not vim.api.nvim_buf_is_valid(annotation.bufnr) then
    return annotation.drifted
  end

  local current = get_buffer_lines(annotation.bufnr, annotation.start_line, annotation.end_line)
  if #current ~= #annotation.original_content then
    return true
  end

  for i, line in ipairs(current) do
    if line ~= annotation.original_content[i] then
      return true
    end
  end

  return false
end

-- Update extmark position from buffer
---@param annotation Annotation
local function update_position_from_extmark(annotation)
  if not annotation.extmark_id or not vim.api.nvim_buf_is_valid(annotation.bufnr) then
    return
  end

  local mark = vim.api.nvim_buf_get_extmark_by_id(annotation.bufnr, namespace, annotation.extmark_id, {})
  if mark and #mark >= 2 then
    local new_start = mark[1] + 1 -- Convert 0-indexed to 1-indexed
    local line_diff = new_start - annotation.start_line
    annotation.start_line = new_start
    annotation.end_line = annotation.end_line + line_diff
  end
end

-- Render virtual text for an annotation
---@param annotation Annotation
local function render_virtual_text(annotation)
  if not vim.api.nvim_buf_is_valid(annotation.bufnr) then
    return
  end

  -- Remove existing extmark if any
  if annotation.extmark_id then
    pcall(vim.api.nvim_buf_del_extmark, annotation.bufnr, namespace, annotation.extmark_id)
  end

  local hl = annotation.drifted and config.highlights.virtual_text_drifted or config.highlights.virtual_text
  local prefix = config.virtual_text.prefix
  local text = truncate(annotation.comment, config.virtual_text.max_length)

  annotation.extmark_id = vim.api.nvim_buf_set_extmark(annotation.bufnr, namespace, annotation.start_line - 1, 0, {
    virt_lines = { { { prefix .. text, hl } } },
    virt_lines_above = true,
    right_gravity = false,
  })
end

-- Render signs for an annotation
---@param annotation Annotation
local function render_signs(annotation)
  if not vim.api.nvim_buf_is_valid(annotation.bufnr) then
    return
  end

  -- Remove existing signs
  for _, sign_id in ipairs(annotation.sign_ids or {}) do
    pcall(vim.fn.sign_unplace, 'annotate', { buffer = annotation.bufnr, id = sign_id })
  end
  annotation.sign_ids = {}

  local sign_name = annotation.drifted and 'AnnotateSignDrifted' or 'AnnotateSign'

  for line = annotation.start_line, annotation.end_line do
    local sign_id = vim.fn.sign_place(0, 'annotate', sign_name, annotation.bufnr, { lnum = line, priority = 10 })
    table.insert(annotation.sign_ids, sign_id)
  end
end

-- Render a single annotation
---@param annotation Annotation
local function render_annotation(annotation)
  annotation.drifted = check_drift(annotation)
  render_virtual_text(annotation)
  render_signs(annotation)
end

-- Render all annotations for a buffer
---@param bufnr number
local function render_buffer_annotations(bufnr)
  for _, annotation in pairs(annotations) do
    if annotation.bufnr == bufnr then
      update_position_from_extmark(annotation)
      render_annotation(annotation)
    end
  end
end

-- Re-attach annotations to a buffer by filepath
-- Called when a buffer is opened for a file that has existing annotations
---@param bufnr number The new buffer number
---@param filepath string The file path
local function reattach_annotations_to_buffer(bufnr, filepath)
  local reattached = 0
  for _, annotation in pairs(annotations) do
    if annotation.file == filepath and annotation.bufnr ~= bufnr then
      -- Update buffer reference
      annotation.bufnr = bufnr
      -- Clear old extmark/sign references (they're invalid now)
      annotation.extmark_id = nil
      annotation.sign_ids = {}
      -- Re-render on new buffer
      render_annotation(annotation)
      reattached = reattached + 1
    end
  end
  return reattached
end

-- Handle buffer being deleted/hidden - clear rendering references
-- Annotations stay in memory but extmarks/signs are buffer-specific
---@param bufnr number
local function on_buffer_delete(bufnr)
  for _, annotation in pairs(annotations) do
    if annotation.bufnr == bufnr then
      -- Clear rendering references (buffer is gone, so they're invalid)
      annotation.extmark_id = nil
      annotation.sign_ids = {}
    end
  end
end

-- Clear rendering for an annotation
---@param annotation Annotation
local function clear_annotation_rendering(annotation)
  if annotation.extmark_id and vim.api.nvim_buf_is_valid(annotation.bufnr) then
    pcall(vim.api.nvim_buf_del_extmark, annotation.bufnr, namespace, annotation.extmark_id)
  end

  for _, sign_id in ipairs(annotation.sign_ids or {}) do
    pcall(vim.fn.sign_unplace, 'annotate', { buffer = annotation.bufnr, id = sign_id })
  end
end

-- Create floating window for comment input
---@param callback fun(text: string|nil)
---@param initial_text string|nil
local function open_float_input(callback, initial_text)
  local width = config.float.width
  local height = config.float.height

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  if initial_text then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(initial_text, '\n'))
  end

  local win_opts = {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = width,
    height = height,
    style = 'minimal',
    border = config.float.border,
    title = ' Annotation ',
    title_pos = 'center',
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.api.nvim_win_set_option(win, 'wrap', true)

  -- Start in insert mode
  vim.cmd 'startinsert'

  -- Keymaps for the float
  local function close_and_submit()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local text = table.concat(lines, '\n')
    text = vim.trim(text)
    vim.api.nvim_win_close(win, true)
    callback(text ~= '' and text or nil)
  end

  local function close_and_cancel()
    vim.api.nvim_win_close(win, true)
    callback(nil)
  end

  vim.keymap.set({ 'n', 'i' }, '<C-s>', close_and_submit, { buffer = buf, desc = 'Submit annotation' })
  vim.keymap.set({ 'n', 'i' }, '<C-c>', close_and_cancel, { buffer = buf, desc = 'Cancel annotation' })
  vim.keymap.set('n', '<Esc>', close_and_cancel, { buffer = buf, desc = 'Cancel annotation' })
  vim.keymap.set('n', 'q', close_and_cancel, { buffer = buf, desc = 'Cancel annotation' })
end

-- Add a new annotation
---@param start_line number 1-indexed
---@param end_line number 1-indexed
function M.add(start_line, end_line)
  init()

  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  local original_content = get_buffer_lines(bufnr, start_line, end_line)

  open_float_input(function(comment)
    if not comment then
      return
    end

    ---@type Annotation
    local annotation = {
      id = next_id,
      bufnr = bufnr,
      file = file,
      start_line = start_line,
      end_line = end_line,
      original_content = original_content,
      comment = comment,
      created_at = os.time(),
      extmark_id = nil,
      sign_ids = {},
      drifted = false,
    }

    annotations[next_id] = annotation
    next_id = next_id + 1

    render_annotation(annotation)
  end)
end

-- Get annotation under cursor
---@return Annotation|nil
function M.get_under_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  for _, annotation in pairs(annotations) do
    if annotation.bufnr == bufnr then
      update_position_from_extmark(annotation)
      if cursor_line >= annotation.start_line and cursor_line <= annotation.end_line then
        return annotation
      end
    end
  end

  return nil
end

-- Delete an annotation
---@param annotation Annotation
function M.delete(annotation)
  -- Add to undo stack
  table.insert(undo_stack, annotation)
  if #undo_stack > max_undo then
    table.remove(undo_stack, 1)
  end

  clear_annotation_rendering(annotation)
  annotations[annotation.id] = nil
end

-- Delete annotation under cursor
function M.delete_under_cursor()
  local annotation = M.get_under_cursor()
  if annotation then
    M.delete(annotation)
    vim.notify('Annotation deleted', vim.log.levels.INFO)
  else
    vim.notify('No annotation under cursor', vim.log.levels.WARN)
  end
end

-- Edit annotation under cursor
function M.edit_under_cursor()
  local annotation = M.get_under_cursor()
  if not annotation then
    vim.notify('No annotation under cursor', vim.log.levels.WARN)
    return
  end

  open_float_input(function(comment)
    if not comment then
      return
    end

    annotation.comment = comment
    render_annotation(annotation)
  end, annotation.comment)
end

-- Delete all annotations
function M.delete_all()
  vim.ui.select({ 'Yes', 'No' }, { prompt = 'Delete all annotations?' }, function(choice)
    if choice == 'Yes' then
      for _, annotation in pairs(annotations) do
        clear_annotation_rendering(annotation)
      end
      annotations = {}
      vim.notify('All annotations deleted', vim.log.levels.INFO)
    end
  end)
end

-- Undo last delete
function M.undo_delete()
  if #undo_stack == 0 then
    vim.notify('Nothing to undo', vim.log.levels.WARN)
    return
  end

  local annotation = table.remove(undo_stack)
  annotations[annotation.id] = annotation
  render_annotation(annotation)
  vim.notify('Annotation restored', vim.log.levels.INFO)
end

-- Copy all annotations to clipboard
function M.yank_all()
  local grouped = {} ---@type table<string, Annotation[]>

  for _, annotation in pairs(annotations) do
    local file = annotation.file ~= '' and annotation.file or '[unsaved buffer]'
    grouped[file] = grouped[file] or {}
    table.insert(grouped[file], annotation)
  end

  if vim.tbl_isempty(grouped) then
    vim.notify('No annotations to copy', vim.log.levels.WARN)
    return
  end

  local lines = {}
  for file, file_annotations in pairs(grouped) do
    -- Sort by start line
    table.sort(file_annotations, function(a, b)
      return a.start_line < b.start_line
    end)

    for _, annotation in ipairs(file_annotations) do
      table.insert(lines, string.format('File: %sL%d:L%d', file, annotation.start_line, annotation.end_line))

      -- Get file extension for code fence
      local ext = file:match '%.([^%.]+)$' or ''
      table.insert(lines, '```' .. ext)
      for _, content_line in ipairs(annotation.original_content) do
        table.insert(lines, content_line)
      end
      table.insert(lines, '```')
      table.insert(lines, 'Comment: ' .. annotation.comment)
      table.insert(lines, '')
      table.insert(lines, '---')
      table.insert(lines, '')
    end
  end

  -- Remove trailing separator
  if #lines >= 2 then
    table.remove(lines)
    table.remove(lines)
  end

  local text = table.concat(lines, '\n')
  vim.fn.setreg('+', text)
  vim.notify(string.format('Copied %d annotations to clipboard', vim.tbl_count(annotations)), vim.log.levels.INFO)
end

-- Generate markdown content for annotations (shared by yank and write)
---@return string|nil content, number count
local function generate_markdown_content()
  local grouped = {} ---@type table<string, Annotation[]>

  for _, annotation in pairs(annotations) do
    local file = annotation.file ~= '' and annotation.file or '[unsaved buffer]'
    grouped[file] = grouped[file] or {}
    table.insert(grouped[file], annotation)
  end

  if vim.tbl_isempty(grouped) then
    return nil, 0
  end

  local lines = { '# Code Review Annotations', '' }
  local count = 0

  for file, file_annotations in pairs(grouped) do
    -- Sort by start line
    table.sort(file_annotations, function(a, b)
      return a.start_line < b.start_line
    end)

    for _, annotation in ipairs(file_annotations) do
      count = count + 1
      local drift_marker = annotation.drifted and ' ⚠️ DRIFTED' or ''
      table.insert(lines, string.format('## File: %sL%d:L%d%s', file, annotation.start_line, annotation.end_line, drift_marker))
      table.insert(lines, '')

      -- Get file extension for code fence
      local ext = file:match '%.([^%.]+)$' or ''
      table.insert(lines, '```' .. ext)
      for _, content_line in ipairs(annotation.original_content) do
        table.insert(lines, content_line)
      end
      table.insert(lines, '```')
      table.insert(lines, '')
      table.insert(lines, '**Comment:** ' .. annotation.comment)
      table.insert(lines, '')
      table.insert(lines, '---')
      table.insert(lines, '')
    end
  end

  -- Remove trailing separator
  if #lines >= 2 then
    table.remove(lines)
    table.remove(lines)
  end

  return table.concat(lines, '\n'), count
end

-- Write all annotations to a markdown file
function M.write_to_file()
  local content, count = generate_markdown_content()

  if not content then
    vim.notify('No annotations to export', vim.log.levels.WARN)
    return
  end

  -- Determine default filename based on first file with annotations
  local default_dir = vim.fn.getcwd()
  for _, annotation in pairs(annotations) do
    if annotation.file ~= '' then
      default_dir = vim.fn.fnamemodify(annotation.file, ':h')
      break
    end
  end
  local default_filename = default_dir .. '/annotations.md'

  -- Prompt for filename
  vim.ui.input({ prompt = 'Save annotations to: ', default = default_filename }, function(filename)
    if not filename or filename == '' then
      vim.notify('Export cancelled', vim.log.levels.INFO)
      return
    end

    -- Expand any ~ or environment variables
    filename = vim.fn.expand(filename)

    -- Write to file
    local file = io.open(filename, 'w')
    if not file then
      vim.notify('Failed to open file: ' .. filename, vim.log.levels.ERROR)
      return
    end

    file:write(content)
    file:close()

    vim.notify(string.format('Exported %d annotations to %s', count, filename), vim.log.levels.INFO)
  end)
end

-- Parse markdown file and extract annotations
---@param content string The markdown file content
---@return table[] parsed_annotations Array of {file, start_line, end_line, original_content, comment}
local function parse_markdown_annotations(content)
  local result = {}
  local lines = vim.split(content, '\n')

  local current = nil
  local in_code_block = false
  local code_lines = {}

  for _, line in ipairs(lines) do
    -- Check for file header: ## File: /path/to/file.luaL10:L15
    local file, start_l, end_l = line:match '^## File: (.+)L(%d+):L(%d+)'
    if file and start_l and end_l then
      -- Save previous annotation if exists
      if current then
        current.original_content = code_lines
        table.insert(result, current)
      end
      current = {
        file = file,
        start_line = tonumber(start_l),
        end_line = tonumber(end_l),
        original_content = {},
        comment = '',
      }
      code_lines = {}
      in_code_block = false
    elseif current then
      -- Check for code fence start/end
      if line:match '^```' then
        in_code_block = not in_code_block
      elseif in_code_block then
        table.insert(code_lines, line)
      elseif line:match '^%*%*Comment:%*%*' then
        current.comment = line:gsub('^%*%*Comment:%*%* ', '')
        current.original_content = code_lines
        table.insert(result, current)
        current = nil
        code_lines = {}
      end
    end
  end

  -- Handle last annotation if file ended without separator
  if current and current.comment ~= '' then
    current.original_content = code_lines
    table.insert(result, current)
  end

  return result
end

-- Import annotations from a markdown file
function M.import_from_file()
  -- Determine default filename
  local default_dir = vim.fn.getcwd()
  local default_filename = default_dir .. '/annotations.md'

  -- Prompt for filename
  vim.ui.input({ prompt = 'Import annotations from: ', default = default_filename, completion = 'file' }, function(filename)
    if not filename or filename == '' then
      vim.notify('Import cancelled', vim.log.levels.INFO)
      return
    end

    -- Expand any ~ or environment variables
    filename = vim.fn.expand(filename)

    -- Check if file exists
    if vim.fn.filereadable(filename) ~= 1 then
      vim.notify('File not found: ' .. filename, vim.log.levels.ERROR)
      return
    end

    -- Read file content
    local file = io.open(filename, 'r')
    if not file then
      vim.notify('Failed to open file: ' .. filename, vim.log.levels.ERROR)
      return
    end

    local content = file:read '*a'
    file:close()

    -- Parse annotations
    local parsed = parse_markdown_annotations(content)

    if #parsed == 0 then
      vim.notify('No annotations found in file', vim.log.levels.WARN)
      return
    end

    -- Import each annotation
    local imported = 0
    local skipped = 0

    for _, ann in ipairs(parsed) do
      -- Check if file exists
      if vim.fn.filereadable(ann.file) ~= 1 then
        skipped = skipped + 1
      else
        -- Open the file to get bufnr
        local bufnr = vim.fn.bufadd(ann.file)
        vim.fn.bufload(bufnr)

        -- Create annotation
        ---@type Annotation
        local annotation = {
          id = next_id,
          bufnr = bufnr,
          file = ann.file,
          start_line = ann.start_line,
          end_line = ann.end_line,
          original_content = ann.original_content,
          comment = ann.comment,
          created_at = os.time(),
          extmark_id = nil,
          sign_ids = {},
          drifted = false,
        }

        annotations[next_id] = annotation
        next_id = next_id + 1
        imported = imported + 1

        -- Check drift immediately
        annotation.drifted = check_drift(annotation)

        -- Render if buffer is currently displayed
        if vim.api.nvim_buf_is_valid(bufnr) then
          render_annotation(annotation)
        end
      end
    end

    local msg = string.format('Imported %d annotations', imported)
    if skipped > 0 then
      msg = msg .. string.format(' (%d skipped - files not found)', skipped)
    end
    vim.notify(msg, vim.log.levels.INFO)
  end)
end

-- Get all annotations (for Trouble integration)
---@return Annotation[]
function M.get_all()
  local result = {}
  for _, annotation in pairs(annotations) do
    update_position_from_extmark(annotation)
    table.insert(result, annotation)
  end
  return result
end

-- Get sorted annotations for current buffer
---@return Annotation[]
local function get_buffer_annotations_sorted()
  local bufnr = vim.api.nvim_get_current_buf()
  local result = {}

  for _, annotation in pairs(annotations) do
    if annotation.bufnr == bufnr then
      update_position_from_extmark(annotation)
      table.insert(result, annotation)
    end
  end

  -- Sort by start line
  table.sort(result, function(a, b)
    return a.start_line < b.start_line
  end)

  return result
end

-- Jump to next annotation in current buffer
function M.next_annotation()
  local buffer_annotations = get_buffer_annotations_sorted()

  if #buffer_annotations == 0 then
    vim.notify('No annotations in current buffer', vim.log.levels.INFO)
    return
  end

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  -- Find first annotation after cursor
  for _, annotation in ipairs(buffer_annotations) do
    if annotation.start_line > cursor_line then
      vim.api.nvim_win_set_cursor(0, { annotation.start_line, 0 })
      vim.notify(truncate(annotation.comment, 50), vim.log.levels.INFO)
      return
    end
  end

  -- Wrap around to first annotation
  local first = buffer_annotations[1]
  vim.api.nvim_win_set_cursor(0, { first.start_line, 0 })
  vim.notify('[wrap] ' .. truncate(first.comment, 45), vim.log.levels.INFO)
end

-- Jump to previous annotation in current buffer
function M.prev_annotation()
  local buffer_annotations = get_buffer_annotations_sorted()

  if #buffer_annotations == 0 then
    vim.notify('No annotations in current buffer', vim.log.levels.INFO)
    return
  end

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  -- Find last annotation before cursor (iterate in reverse)
  for i = #buffer_annotations, 1, -1 do
    local annotation = buffer_annotations[i]
    if annotation.start_line < cursor_line then
      vim.api.nvim_win_set_cursor(0, { annotation.start_line, 0 })
      vim.notify(truncate(annotation.comment, 50), vim.log.levels.INFO)
      return
    end
  end

  -- Wrap around to last annotation
  local last = buffer_annotations[#buffer_annotations]
  vim.api.nvim_win_set_cursor(0, { last.start_line, 0 })
  vim.notify('[wrap] ' .. truncate(last.comment, 45), vim.log.levels.INFO)
end

-- Trouble.nvim custom source
local trouble_source = {}

-- Filter state for Trouble list
-- Values: 'all', 'current_buffer', 'drifted'
local current_filter = 'all'
local filter_names = {
  all = 'All Annotations',
  current_buffer = 'Current Buffer',
  drifted = 'Drifted Only',
}
local filter_order = { 'all', 'current_buffer', 'drifted' }

-- Cycle to next filter
local function cycle_filter()
  for i, f in ipairs(filter_order) do
    if f == current_filter then
      current_filter = filter_order[(i % #filter_order) + 1]
      return
    end
  end
  current_filter = 'all'
end

-- Source configuration for Trouble
trouble_source.config = {
  annotate = {
    desc = 'Code Annotations',
    events = { 'BufEnter', 'TextChanged' },
    source = 'annotate',
    groups = { { 'filename', format = '{file_icon} {filename} {count}' } },
    sort = { 'filename', 'pos' },
    -- Show severity icon (warning for drifted), then text with line range
    format = '{severity_icon} {text}',
  },
}

-- Format line range string for Trouble display
---@param start_line number
---@param end_line number
---@return string
local function format_line_range(start_line, end_line)
  if start_line == end_line then
    return string.format('L%d', start_line)
  end
  return string.format('L%d-L%d', start_line, end_line)
end

-- Convert annotation to Trouble item
---@param annotation Annotation
---@return table
local function annotation_to_trouble_item(annotation)
  -- Format text with line range prefix
  local line_range = format_line_range(annotation.start_line, annotation.end_line)
  local display_text = string.format('[%s] %s', line_range, annotation.comment)

  -- Severity: WARN for drifted, INFO for normal
  -- Trouble uses vim.diagnostic.severity values: ERROR=1, WARN=2, INFO=3, HINT=4
  local severity = annotation.drifted and vim.diagnostic.severity.WARN or vim.diagnostic.severity.INFO

  local ok, Item = pcall(require, 'trouble.item')
  if not ok then
    -- Fallback format if trouble.item not available
    return {
      source = 'annotate',
      filename = annotation.file ~= '' and annotation.file or vim.api.nvim_buf_get_name(annotation.bufnr),
      buf = annotation.bufnr,
      pos = { annotation.start_line, 0 },
      end_pos = { annotation.end_line, 0 },
      item = annotation,
      text = display_text,
      severity = severity,
      id = tostring(annotation.id),
    }
  end

  return Item.new {
    source = 'annotate',
    filename = annotation.file ~= '' and annotation.file or vim.api.nvim_buf_get_name(annotation.bufnr),
    buf = annotation.bufnr,
    pos = { annotation.start_line, 0 },
    end_pos = { annotation.end_line, 0 },
    item = {
      id = annotation.id,
      comment = annotation.comment,
      drifted = annotation.drifted,
      original_content = annotation.original_content,
    },
    text = display_text,
    severity = severity,
    id = tostring(annotation.id),
  }
end

-- Trouble source get function
---@param cb function Callback to receive items
---@param ctx table Context with opts and main
function trouble_source.get(cb, ctx)
  local items = {}

  -- Get main buffer for 'current_buffer' filter
  local main_buf = ctx.main and ctx.main.buf or vim.api.nvim_get_current_buf()

  for _, annotation in pairs(annotations) do
    update_position_from_extmark(annotation)

    -- Apply current filter
    local include = false
    if current_filter == 'all' then
      include = true
    elseif current_filter == 'current_buffer' then
      include = annotation.bufnr == main_buf
    elseif current_filter == 'drifted' then
      include = annotation.drifted
    end

    if include then
      table.insert(items, annotation_to_trouble_item(annotation))
    end
  end

  cb(items)
end

-- Setup function for Trouble source
function trouble_source.setup()
  -- Nothing special needed on setup
end

-- Register the Trouble source
local function register_trouble_source()
  local ok, sources = pcall(require, 'trouble.sources')
  if ok and sources and sources.register then
    sources.register('annotate', trouble_source)
    return true
  end
  return false
end

-- Delete annotation by ID (for Trouble integration)
---@param id number Annotation ID
---@return boolean success
function M.delete_by_id(id)
  local annotation = annotations[id]
  if not annotation then
    return false
  end

  M.delete(annotation)
  return true
end

-- Edit annotation by ID (for Trouble integration)
-- Jumps to annotation location and opens float input
---@param id number Annotation ID
---@return boolean success
function M.edit_by_id(id)
  local annotation = annotations[id]
  if not annotation then
    return false
  end

  -- Jump to the annotation location
  if vim.api.nvim_buf_is_valid(annotation.bufnr) then
    -- Switch to the buffer containing the annotation
    vim.api.nvim_set_current_buf(annotation.bufnr)
    -- Move cursor to the annotation start line
    vim.api.nvim_win_set_cursor(0, { annotation.start_line, 0 })
  end

  -- Open float input with current text
  open_float_input(function(comment)
    if not comment then
      return
    end

    annotation.comment = comment
    render_annotation(annotation)
  end, annotation.comment)

  return true
end

-- Get annotation ID from Trouble item
---@param item table Trouble item
---@return number|nil
local function get_annotation_id_from_item(item)
  -- The item structure has the annotation data in item.item
  if item and item.item then
    -- Check if item.item has id directly (our format)
    if item.item.id then
      return item.item.id
    end
    -- Or check if it's the full annotation object
    if type(item.item) == 'table' and item.item.id then
      return item.item.id
    end
  end
  -- Try to get from the item's id field (string)
  if item and item.id then
    return tonumber(item.id)
  end
  return nil
end

-- Open Trouble list with custom source
function M.open_list()
  local ok, trouble = pcall(require, 'trouble')
  if not ok then
    vim.notify('Trouble.nvim not found', vim.log.levels.ERROR)
    return
  end

  -- Check if we have any annotations
  if vim.tbl_isempty(annotations) then
    vim.notify('No annotations', vim.log.levels.INFO)
    return
  end

  -- Try to use custom source first
  local source_registered = register_trouble_source()
  if source_registered then
    -- Open with custom configuration including delete and edit keymaps
    trouble.open {
      mode = 'annotate',
      keys = {
        d = {
          action = function(view)
            -- Get current item from view
            local item = view:current()
            if not item then
              vim.notify('No annotation selected', vim.log.levels.WARN)
              return
            end

            local id = get_annotation_id_from_item(item)
            if id and M.delete_by_id(id) then
              vim.notify('Annotation deleted', vim.log.levels.INFO)
              -- Refresh the Trouble list
              trouble.refresh()
              -- Close if no more annotations
              if vim.tbl_isempty(annotations) then
                trouble.close()
              end
            else
              vim.notify('Failed to delete annotation', vim.log.levels.ERROR)
            end
          end,
          desc = 'Delete annotation',
        },
        e = {
          action = function(view)
            -- Get current item from view
            local item = view:current()
            if not item then
              vim.notify('No annotation selected', vim.log.levels.WARN)
              return
            end

            local id = get_annotation_id_from_item(item)
            if id then
              -- Close Trouble first so the float appears in the correct window
              trouble.close()
              -- Small delay to let Trouble close, then edit
              vim.schedule(function()
                if M.edit_by_id(id) then
                  -- After edit completes, user can reopen list with <leader>rl
                else
                  vim.notify('Failed to edit annotation', vim.log.levels.ERROR)
                end
              end)
            else
              vim.notify('Failed to get annotation ID', vim.log.levels.ERROR)
            end
          end,
          desc = 'Edit annotation',
        },
        f = {
          action = function()
            -- Cycle to next filter
            cycle_filter()
            vim.notify('Filter: ' .. filter_names[current_filter], vim.log.levels.INFO)
            -- Refresh Trouble to apply new filter
            trouble.refresh()
          end,
          desc = 'Cycle filter (all/buffer/drifted)',
        },
      },
    }
  else
    -- Fallback to quickfix if custom source registration failed
    local items = {}
    for _, annotation in pairs(annotations) do
      update_position_from_extmark(annotation)
      table.insert(items, {
        bufnr = annotation.bufnr,
        lnum = annotation.start_line,
        col = 1,
        text = annotation.comment,
        type = annotation.drifted and 'W' or 'I',
      })
    end

    vim.fn.setqflist(items, 'r')
    vim.fn.setqflist({}, 'a', { title = 'Annotations' })
    trouble.toggle 'quickfix'
  end
end

-- Visual mode add annotation
function M.add_visual()
  local start_line = vim.fn.line 'v'
  local end_line = vim.fn.line '.'

  -- Ensure start < end
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  -- Exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)

  -- Delay to let visual mode exit
  vim.schedule(function()
    M.add(start_line, end_line)
  end)
end

-- Setup keymaps
local function setup_keymaps()
  local km = config.keymaps

  if km.add then
    vim.keymap.set('v', km.add, M.add_visual, { desc = '[R]eview: [A]dd annotation' })
  end

  if km.list then
    vim.keymap.set('n', km.list, M.open_list, { desc = '[R]eview: [L]ist annotations' })
  end

  if km.yank then
    vim.keymap.set('n', km.yank, M.yank_all, { desc = '[R]eview: [Y]ank all annotations' })
  end

  if km.delete then
    vim.keymap.set('n', km.delete, M.delete_under_cursor, { desc = '[R]eview: [D]elete annotation' })
  end

  if km.edit then
    vim.keymap.set('n', km.edit, M.edit_under_cursor, { desc = '[R]eview: [E]dit annotation' })
  end

  if km.delete_all then
    vim.keymap.set('n', km.delete_all, M.delete_all, { desc = '[R]eview: [D]elete all annotations' })
  end

  if km.undo then
    vim.keymap.set('n', km.undo, M.undo_delete, { desc = '[R]eview: [U]ndo delete' })
  end

  if km.write then
    vim.keymap.set('n', km.write, M.write_to_file, { desc = '[R]eview: [W]rite to file' })
  end

  if km.import then
    vim.keymap.set('n', km.import, M.import_from_file, { desc = '[R]eview: [I]mport from file' })
  end

  if km.next_annotation then
    vim.keymap.set('n', km.next_annotation, M.next_annotation, { desc = 'Next annotation' })
  end

  if km.prev_annotation then
    vim.keymap.set('n', km.prev_annotation, M.prev_annotation, { desc = 'Previous annotation' })
  end
end

-- Setup autocmds for drift detection and buffer re-attachment
local function setup_autocmds()
  local group = vim.api.nvim_create_augroup('Annotate', { clear = true })

  -- Handle text changes - update drift detection
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group,
    callback = function(args)
      render_buffer_annotations(args.buf)
    end,
  })

  -- Handle buffer enter - re-attach annotations if this file has any
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function(args)
      local bufnr = args.buf
      local filepath = vim.api.nvim_buf_get_name(bufnr)

      -- Skip empty filepaths (scratch buffers, etc.)
      if filepath == '' then
        return
      end

      -- Check if this file has annotations that need re-attachment
      local has_annotations_for_file = false
      for _, annotation in pairs(annotations) do
        if annotation.file == filepath then
          has_annotations_for_file = true
          -- Check if annotations need re-attachment (different bufnr or no extmark)
          if annotation.bufnr ~= bufnr or not annotation.extmark_id then
            reattach_annotations_to_buffer(bufnr, filepath)
            return
          end
        end
      end

      -- If annotations exist for this buffer, render them (drift detection)
      if has_annotations_for_file then
        render_buffer_annotations(bufnr)
      end
    end,
  })

  -- Handle buffer delete/wipe - clear rendering references
  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    group = group,
    callback = function(args)
      on_buffer_delete(args.buf)
    end,
  })
end

-- Setup function
---@param opts table|nil
function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
  init()
  setup_keymaps()
  setup_autocmds()
end

-- Expose module for direct require
_G.Annotate = M

-- Auto-setup when loaded by lazy.nvim's import
-- This runs once when the file is required
vim.schedule(function()
  M.setup()
end)

-- Return empty spec (plugin is self-contained, no external deps needed)
return {}
