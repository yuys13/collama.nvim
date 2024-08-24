local M = {}

---
---@param config CollamaConfig
local function attach_global(config)
  local augroup = vim.api.nvim_create_augroup('collama_preset_example_group', { clear = true })

  -- auto execute debounced_request
  vim.api.nvim_create_autocmd({ 'InsertEnter', 'CursorMovedI', 'TextChangedI' }, {
    group = augroup,
    callback = function()
      require('collama.copilot').debounced_request(config, 1000)
    end,
  })
  -- auto cancel
  vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
    group = augroup,
    callback = function()
      require('collama.copilot').clear()
    end,
  })
  -- map accept key
  vim.keymap.set('i', '<M-j>', require('collama.copilot').accept)
end

---
---@param fim CollamaFimConfig
local function create_config(fim)
  local config = require('collama.copilot').get_default_config()
  config.fim = fim
  return config
end

function M.codellama()
  ---@type CollamaFimConfig
  local fim = {
    model = 'codellama:7b-code',
    tokens = require('collama.preset.tokens').codellama,
  }
  local config = create_config(fim)

  attach_global(config)
end

function M.codegemma()
  ---@type CollamaFimConfig
  local fim = {
    model = 'codegemma:7b-code',
    tokens = require('collama.preset.tokens').codegemma,
  }
  local config = create_config(fim)

  attach_global(config)
end

function M.starcoder2()
  ---@type CollamaFimConfig
  local fim = {
    model = 'starcoder2:latest',
    tokens = require('collama.preset.tokens').starcoder,
  }
  local config = create_config(fim)

  attach_global(config)
end

function M.stable_code()
  ---@type CollamaFimConfig
  local fim = {
    model = 'stable-code:latest',
    tokens = require('collama.preset.tokens').stable_code,
  }
  local config = create_config(fim)

  attach_global(config)
end

return M
