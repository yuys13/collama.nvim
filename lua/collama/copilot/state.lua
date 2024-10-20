---@class CollamaState
---@field timer uv_timer_t
---@field job vim.SystemObj?
---@field bufnr number
---@field pos number[]?
---@field result string?
---@field extmark_id number?

local logger = require 'collama.logger'

vim.api.nvim_set_hl(0, 'CollamaSuggest', { link = 'Comment', default = true })

local ns_id = vim.api.nvim_create_namespace 'collama'

local M = {}

---@type CollamaState
local state = {
  timer = vim.uv.new_timer(),
  job = nil,
  bufnr = 0,
  pos = nil,
  result = nil,
  extmark_id = nil,
}

function M.clear()
  -- stop timer
  state.timer:stop()

  -- shutdown Job
  if state.job then
    logger.info 'Generation canceled'
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

---
---Start the timer. `timeout` and `repeat_n` are in milliseconds.
---
---If `timeout` is zero, the callback fires on the next event loop iteration. If
---`repeat_n` is non-zero, the callback fires first after `timeout` milliseconds and
---then repeatedly after `repeat_n` milliseconds.
---
---@param timeout integer
---@param repeat_n integer
---@param callback fun()
---@return 0|nil success, string? err_name, string? err_msg
function M.timer_start(timeout, repeat_n, callback)
  return state.timer:start(timeout, repeat_n, callback)
end

---Set requested position
function M.set_pos()
  state.bufnr = vim.fn.bufnr()
  state.pos = vim.api.nvim_win_get_cursor(0)
end

function M.get_pos()
  return state.bufnr, state.pos
end

---set job
---@param job vim.SystemObj
function M.set_job(job)
  state.job = job
end

---show extmark
---@param text string
local function show_extmark(text)
  local lines = vim.split(text, '\n')
  local virt_text = table.remove(lines, 1)
  local opts = {}
  opts.virt_text = { { virt_text, 'CollamaSuggest' } }
  opts.virt_text_pos = 'overlay'
  opts.virt_lines = {}
  for _, value in pairs(lines) do
    table.insert(opts.virt_lines, { { value, 'CollamaSuggest' } })
  end
  state.extmark_id = vim.api.nvim_buf_set_extmark(state.bufnr, ns_id, state.pos[1] - 1, state.pos[2], opts)
end

---Set result and show extmark
---@param result string
function M.complete_job(result)
  state.result = result
  show_extmark(result)
  if state.job then
    state.job = nil
  end
end

---get Fill-In-The-Middle result
---@return string?
function M.get_result()
  return state.result
end

function M.is_moved()
  if state.bufnr ~= vim.fn.bufnr() then
    return true
  end
  local now_pos = vim.api.nvim_win_get_cursor(0)
  return state.pos[1] ~= now_pos[1] or state.pos[2] ~= now_pos[2]
end

return M
