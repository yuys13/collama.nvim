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
  local obj = {}
  obj.timer = vim.uv.new_timer()
  obj.job = nil
  obj.bufnr = 0
  obj.pos = nil
  obj.result = nil
  obj.extmark_id = nil
  return obj
end

return CollamaState
