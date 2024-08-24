---@class CollamaFimTokens
---@field prefix string special token for FIM such as `<PRE>`
---@field suffix string special token for FIM such as `<SUF>`
---@field middle string special token for FIM such as `<MID>`
---@field end_of_middle string? special token for FIM such as `<EOM>`

---@class CollamaFimConfig
---@field model string
---@field tokens CollamaFimTokens

---@class CollamaConfig
---@field base_url string
---@field fim CollamaFimConfig

local state = require 'collama.copilot.state'

local M = {}

function M.get_default_config()
  ---@type CollamaConfig
  local config = {
    base_url = 'http://localhost:11434/api/',
    fim = {
      model = 'codellama:7b-code',
      tokens = require('collama.preset.tokens').codellama,
    },
  }
  return config
end

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

---create prompt
---@param prefix string string before cursor
---@param suffix string string after cursor
---@param tokens CollamaFimTokens special tokens for FIM
---@return string prompt
local function create_prompt(prefix, suffix, tokens)
  return tokens.prefix .. prefix .. tokens.suffix .. suffix .. tokens.middle
end

---request Fill-In-the-Middle
---@param config CollamaConfig
function M.request(config)
  state.set_pos()
  local prefix, suffix = get_buffer(state.get_pos())
  local prompt = create_prompt(prefix, suffix, config.fim.tokens)

  local job = require('collama.api').generate(config.base_url, {
    prompt = prompt,
    model = config.fim.model,
    stream = false,
  }, function(res)
    local response = res.response
    if config.fim.tokens.end_of_middle then
      response = response:gsub(config.fim.tokens.end_of_middle .. '$', '')
    end
    state.set_result(response)
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

function M.accept()
  state.accept_result()
end

return M
