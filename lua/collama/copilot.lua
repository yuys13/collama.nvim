---@class CollamaConfig
---@field base_url string
---@field model string

local state = require 'collama.copilot.state'
local logger = require 'collama.logger'

local M = {}

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

---request Fill-In-the-Middle
---@param config CollamaConfig
function M.request(config)
  state.set_pos()
  local prefix, suffix = get_buffer(state.get_pos())

  local job = require('collama.api').generate(config.base_url, {
    prompt = prefix,
    suffix = suffix,
    model = config.model,
    stream = false,
  }, function(res)
    local response = res.response
    state.complete_job(response)
  end)

  state.set_job(job)
end

---request Fill-In-the-Middle with debounce
---@param config CollamaConfig
function M.debounced_request(config, debounce_time)
  state.clear()
  -- request only normal buffer
  if vim.o.buftype ~= '' then
    return
  end
  state.timer_start(
    debounce_time,
    0,
    vim.schedule_wrap(function()
      M.request(config)
    end)
  )
end

function M.clear()
  state.clear()
end

---accept Fill-In-the-Middle result
function M.accept()
  local result = state.get_result()
  if not result then
    return
  end
  logger.info 'accept'

  if not state.is_moved() then
    -- insert text at cursor position, and place cursor at end of inserted text.
    vim.api.nvim_put(vim.split(result, '\n'), 'c', true, true)
  else
    local bufnr, pos = state.get_pos()
    -- just insert text.
    vim.api.nvim_buf_set_text(bufnr, pos[1] - 1, pos[2], pos[1] - 1, pos[2], vim.split(result, '\n'))
  end

  state.clear()
end

return M
