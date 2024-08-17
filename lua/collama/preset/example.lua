local M = {}

---
---@param config CollamaFimConfig
local function attach_global(config)
  local augroup = vim.api.nvim_create_augroup('collama_preset_example_group', { clear = true })

  vim.api.nvim_create_autocmd({ 'InsertEnter', 'CursorMovedI', 'TextChangedI' }, {
    group = augroup,
    callback = function()
      require('collama.copilot').debounced_request(config)
    end,
  })
end

function M.codellama()
  ---@type CollamaFimConfig
  local config = {
    model = 'codellama:7b-code',
    tokens = require('collama.preset.tokens').codellama,
  }

  attach_global(config)
end

function M.codegemma()
  ---@type CollamaFimConfig
  local config = {
    model = 'codegemma:7b-code',
    tokens = require('collama.preset.tokens').codegemma,
  }

  attach_global(config)
end

function M.starcoder2()
  ---@type CollamaFimConfig
  local config = {
    model = 'starcoder2:latest',
    tokens = require('collama.preset.tokens').starcoder,
  }

  attach_global(config)
end

function M.stable_code()
  ---@type CollamaFimConfig
  local config = {
    model = 'stable-code:latest',
    tokens = require('collama.preset.tokens').stable_code,
  }

  attach_global(config)
end

return M
