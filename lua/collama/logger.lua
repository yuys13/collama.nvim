local M = {}

local enable = false

function M.enable()
  enable = true
end

function M.disable()
  enable = false
end

function M.toggle()
  enable = not enable
end

---@param msg string Content of the notification to show to the user.
---@param level integer|nil One of the values from |vim.log.levels|.
---@param opts table|nil Optional parameters. Unused by default.
function M.log(msg, level, opts)
  if not enable then
    return
  end
  vim.notify('[collama]: ' .. msg, level, opts)
end

function M.info(msg)
  M.log(msg, vim.log.levels.INFO)
end

function M.debug(msg)
  M.log(msg, vim.log.levels.DEBUG)
end

return M
