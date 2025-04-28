local logger = require 'collama.logger'

local ns_id = vim.api.nvim_create_namespace 'collama'

---@class CollamaState
---@field timer uv_timer_t
---@field job vim.SystemObj?
---@field bufnr number
---@field pos number[]?
---@field result string?
---@field extmark_id number?
local CollamaState = {}

---@return CollamaState
function CollamaState.new()
  local obj = setmetatable({}, { __index = CollamaState })
  obj.timer = vim.uv.new_timer()
  obj.job = nil
  obj.bufnr = 0
  obj.pos = nil
  obj.result = nil
  obj.extmark_id = nil
  return obj
end

function CollamaState:clear()
  -- stop timer
  self.timer:stop()

  -- shutdown Job
  if self.job then
    logger.info(string.format('Generation canceled [%d]', self.job.pid))
    self.job:kill(9)
    self.job = nil
  end

  -- clear extmark
  if self.extmark_id then
    vim.api.nvim_buf_del_extmark(self.bufnr, ns_id, self.extmark_id)
    self.extmark_id = nil
  end

  -- clear other state
  self.bufnr = 0
  self.pos = nil
  self.result = nil
end

function CollamaState:get_job()
  return self.job
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
function CollamaState:timer_start(timeout, repeat_n, callback)
  return self.timer:start(timeout, repeat_n, callback)
end

---Set requested position
function CollamaState:set_pos()
  self.bufnr = vim.fn.bufnr()
  self.pos = vim.api.nvim_win_get_cursor(0)
end

function CollamaState:get_pos()
  return self.bufnr, self.pos
end

---Set job
---@param job vim.SystemObj?
function CollamaState:set_job(job)
  self.job = job
end

---Set Fill-In-The-Middle result
---@param result string
function CollamaState:set_result(result)
  self.result = result
end

---Get Fill-In-The-Middle result
---@return string?
function CollamaState:get_result()
  return self.result
end

---Set extmark_id
---@param extmark_id number
function CollamaState:set_extmark_id(extmark_id)
  self.extmark_id = extmark_id
end

function CollamaState:is_moved()
  if self.bufnr ~= vim.fn.bufnr() then
    return true
  end
  local now_pos = vim.api.nvim_win_get_cursor(0)
  return self.pos[1] ~= now_pos[1] or self.pos[2] ~= now_pos[2]
end

return CollamaState
