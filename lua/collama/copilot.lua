---@class CollamaConfig
---@field base_url string?
---@field model string

local state = require('collama.copilot.state').new()
local logger = require 'collama.logger'

vim.api.nvim_set_hl(0, 'CollamaSuggest', { link = 'Comment', default = true })

local ns_id = vim.api.nvim_create_namespace 'collama'

local M = {}

local function clear_state()
  -- stop timer
  state.timer:stop()

  -- shutdown Job
  if state.job then
    logger.info(string.format('Generation canceled [%d]', state.job.pid))
    state.job:kill(9)
    state.job = nil
  end

  -- clear extmark
  if state.extmark_id then
    vim.api.nvim_buf_del_extmark(state.bufnr, ns_id, state.extmark_id)
    state.extmark_id = nil
  end

  -- clear other state
  state.bufnr = 0
  state.pos = nil
  state.result = nil
end

local function is_moved()
  if state.bufnr ~= vim.fn.bufnr() then
    return true
  end
  local now_pos = vim.api.nvim_win_get_cursor(0)
  return state.pos[1] ~= now_pos[1] or state.pos[2] ~= now_pos[2]
end

---get prefix and suffix from buffer
---@param bufnr number number of a buffer
---@param pos number[] cursor position
---@return string prefix, string suffix
local function get_buffer(bufnr, pos)
  local lines
  lines = vim.api.nvim_buf_get_text(bufnr, 0, 0, pos[1] - 1, pos[2], {})
  local prefix = table.concat(lines, '\n')
  lines = vim.api.nvim_buf_get_text(bufnr, pos[1] - 1, pos[2], -1, -1, {})
  local suffix = table.concat(lines, '\n')

  return prefix, suffix
end

---show extmark
---@param text string
local function show_extmark(text)
  if text == nil then
    logger.debug 'show_extmark end (text is nil)'
    return
  end

  local bufnr, pos = state.bufnr, state.pos
  ---@type vim.api.keyset.set_extmark
  local opts = {}

  local lines = vim.split(text, '\n')
  local virt_text = table.remove(lines, 1)
  opts.virt_text = { { virt_text, 'CollamaSuggest' } }

  if #lines == 0 then
    -- if generated result is a single line, display 'inline'
    opts.virt_text_pos = 'inline'
    state.extmark_id = vim.api.nvim_buf_set_extmark(bufnr, ns_id, pos[1] - 1, pos[2], opts)
    logger.debug 'show_extmark end (single line)'
    return
  end

  opts.virt_text_pos = 'overlay'

  opts.virt_lines = {}
  for _, value in pairs(lines) do
    table.insert(opts.virt_lines, { { value, 'CollamaSuggest' } })
  end

  state.extmark_id = vim.api.nvim_buf_set_extmark(bufnr, ns_id, pos[1] - 1, pos[2], opts)
  logger.debug 'show_extmark end (multi line)'
end

---Set result and show extmark
---@param result string
local function complete_job(result)
  if state.job == nil then
    logger.info 'job is already canceled'
    return
  end
  logger.info(string.format('Generation completed [%d]', state.job.pid))
  state.result = result
  show_extmark(result)
  state.job = nil
end

---request Fill-In-the-Middle
---@param config CollamaConfig
function M.request(config)
  state.bufnr = vim.fn.bufnr()
  state.pos = vim.api.nvim_win_get_cursor(0)
  local prefix, suffix = get_buffer(state.bufnr, state.pos)

  local api = require 'collama.api'
  local base_url = config.base_url or api.get_base_url()

  local job = api.generate(base_url, {
    prompt = prefix,
    suffix = suffix,
    model = config.model,
  }, function(res)
    local response = res.response
    complete_job(response)
  end)

  logger.info(string.format('Generating...[%d]', job.pid))

  state.job = job
end

---request Fill-In-the-Middle with debounce
---@param config CollamaConfig
---@param debounce_time integer
function M.debounced_request(config, debounce_time)
  clear_state()
  -- request only normal buffer
  if vim.o.buftype ~= '' then
    return
  end
  state.timer:start(
    debounce_time,
    0,
    vim.schedule_wrap(function()
      M.request(config)
    end)
  )
end

function M.clear()
  clear_state()
end

---accept Fill-In-the-Middle result
function M.accept()
  local result = state.result
  if not result then
    return
  end
  logger.info 'accept'

  if not is_moved() then
    -- insert text at cursor position, and place cursor at end of inserted text.
    vim.api.nvim_put(vim.split(result, '\n'), 'c', false, true)
  else
    local bufnr, pos = state.bufnr, state.pos
    -- just insert text.
    vim.api.nvim_buf_set_text(bufnr, pos[1] - 1, pos[2], pos[1] - 1, pos[2], vim.split(result, '\n'))
  end

  clear_state()
end

return M