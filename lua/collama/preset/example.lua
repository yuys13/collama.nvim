---@class CollamaExampleSetupConfig
---@field base_url string? base_url like `http://localhost:11434/api/`. If nil is specified, fall back to `http://${OLLAMA_HOST}/api/`
---@field model string the model name. ex) `qwen2.5-coder:7b`
---@field debounce_time integer? default: 1000

local M = {}

---
---@param config CollamaExampleSetupConfig
function M.setup(config)
  ---@type CollamaConfig
  local cc = {
    base_url = config.base_url,
    model = config.model,
  }
  local debounce_time = config.debounce_time or 1000

  local augroup = vim.api.nvim_create_augroup('collama_preset_example_group', { clear = true })

  -- auto execute debounced_request
  vim.api.nvim_create_autocmd({ 'InsertEnter', 'CursorMovedI', 'TextChangedI' }, {
    group = augroup,
    callback = function()
      require('collama.copilot').debounced_request(cc, debounce_time)
    end,
  })
  -- auto cancel
  vim.api.nvim_create_autocmd({ 'InsertLeave', 'VimLeavePre' }, {
    group = augroup,
    callback = function()
      require('collama.copilot').clear()
    end,
  })
end

return M
