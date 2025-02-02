local M = {}

---@type fun(msg: string, level: integer|nil, opts: table|nil)|nil
--- Can register functions compatible with vim.notify()
M.notify = nil

---@type integer Minimum level of messages to log. Logs below this level will be ignored.
---Default is vim.log.levels.INFO.
---See `:h vim.log.levels`
M.level = vim.log.levels.INFO

---
--- setup logger
---
--- Can register functions compatible with vim.notify()
---@param func fun(msg: string, level: integer|nil, opts: table|nil)|nil
---@deprecated Use require('collama.logger').notify directly.
function M.setup(func)
  M.notify = func
end

---set minimum_level
---@param level integer see `:h vim.log.levels`
---@deprecated Use require('collama.logger').level directly.
function M.set_level(level)
  M.level = level
end

---@param msg string Content of the notification to show to the user.
---@param level integer|nil One of the values from |vim.log.levels|.
---@param opts table|nil Optional parameters. Unused by default.
function M.log(msg, level, opts)
  if not M.notify then
    return
  end
  if level < M.level then
    return
  end
  M.notify(msg, level, opts)
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
