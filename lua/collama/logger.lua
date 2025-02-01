local M = {}

---@type fun(msg: string, level: integer|nil, opts: table|nil)|nil
local notify = nil

local minimum_level = vim.log.levels.INFO

---
--- setup logger
---
--- Can register functions compatible with vim.notify()
---@param func fun(msg: string, level: integer|nil, opts: table|nil)|nil
function M.setup(func)
  notify = func
end

---set minimum_level
---@param level integer see `:h vim.log.levels`
function M.set_minimum_level(level)
  minimum_level = level
end

---@param msg string Content of the notification to show to the user.
---@param level integer|nil One of the values from |vim.log.levels|.
---@param opts table|nil Optional parameters. Unused by default.
function M.log(msg, level, opts)
  if not notify then
    return
  end
  if level < minimum_level then
    return
  end
  notify(msg, level, opts)
end

function M.error(msg)
  M.log(msg, vim.log.levels.ERROR, { title = 'collama', annote = 'collama(ERROR)', group = 'collama' })
end

function M.warn(msg)
  M.log(msg, vim.log.levels.WARN, { title = 'collama', annote = 'collama(WARN)', group = 'collama' })
end

function M.info(msg)
  M.log(msg, vim.log.levels.INFO, { title = 'collama', annote = 'collama(INFO)', group = 'collama' })
end

function M.debug(msg)
  M.log(msg, vim.log.levels.DEBUG, { title = 'collama', annote = 'collama(DEBUG)', group = 'collama' })
end

return M
