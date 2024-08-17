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
---@field accept_key string

local ns_id = vim.api.nvim_create_namespace 'collama'

local M = {}

function M.get_default_config()
  ---@type CollamaConfig
  local config = {
    base_url = 'http://localhost:11434/api/',
    fim = {
      model = 'codellama:7b-code',
      tokens = require('collama.preset.tokens').codellama,
    },
    accept_key = '<M-j>',
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

---show extmark
---@param bufnr number number of a buffer
---@param pos number[] cursor position
---@param text string String you want to display
---@return number extmark_id
local function show_extmark(bufnr, pos, text)
  local lines = vim.split(text, '\n')
  local virt_text = table.remove(lines, 1)
  local opts = {}
  opts.virt_text = { { virt_text, 'Comment' } }
  opts.virt_text_pos = 'overlay'
  opts.virt_lines = {}
  for _, value in pairs(lines) do
    table.insert(opts.virt_lines, { { value, 'Comment' } })
  end
  return vim.api.nvim_buf_set_extmark(bufnr, ns_id, pos[1] - 1, pos[2], opts)
end

---
---@param bufnr number number of a buffer
---@param pos number[] cursor position
---@param tokens CollamaFimTokens special tokens for FIM
---@param accept_key string
---@return fun(res:CollamaGenerateResponse)
local function create_callback(bufnr, pos, tokens, accept_key)
  ---
  ---@param res CollamaGenerateResponse
  local function callback(res)
    local response = res.response
    if tokens.end_of_middle then
      response = response:gsub(tokens.end_of_middle .. '$', '')
    end
    local extmark_id = show_extmark(bufnr, pos, response)

    vim.keymap.set('i', accept_key, function()
      vim.notify('[collama]: accept', vim.log.levels.INFO)
      vim.api.nvim_buf_set_text(bufnr, pos[1] - 1, pos[2], pos[1] - 1, pos[2], vim.split(response, '\n'))
      vim.api.nvim_buf_del_extmark(bufnr, ns_id, extmark_id)
      vim.keymap.del('i', accept_key)
    end)
    vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChangedI', 'CursorMovedI' }, {
      once = true,
      pattern = '*',
      callback = function()
        vim.api.nvim_buf_del_extmark(bufnr, ns_id, extmark_id)
      end,
    })
  end

  return callback
end

---request Fill-In-the-Middle
---@param config CollamaConfig
function M.request(config)
  local buffer = vim.fn.bufnr()
  local cur_pos = vim.api.nvim_win_get_cursor(0)
  local prefix, suffix = get_buffer(buffer, cur_pos)
  local prompt = create_prompt(prefix, suffix, config.fim.tokens)

  local job = require('collama.api').generate(config.base_url, {
    prompt = prompt,
    model = config.fim.model,
    stream = false,
  }, create_callback(buffer, cur_pos, config.fim.tokens, config.accept_key))

  return job
end

local timer = vim.uv.new_timer()

---request Fill-In-the-Middle with debounce
---@param config CollamaConfig
function M.debounced_request(config, debounce_time)
  -- request only nomal buffer
  if vim.o.buftype ~= '' then
    timer:stop()
    return
  end
  timer:start(
    debounce_time,
    0,
    vim.schedule_wrap(function()
      local job = M.request(config)
      vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChangedI', 'CursorMovedI' }, {
        once = true,
        callback = function()
          vim.notify('[collama]: job:shutdown()', vim.log.levels.DEBUG)
          -- job.shutdown() does not stop the curl process.
          -- job.pid is correct for integer because the return value of uv.spawn is an integer.
          vim.uv.kill(job.pid --[[@as integer]])
          -- If exit_code is non-zero, plenary.curl outputs an error, so set it to 0.
          job:shutdown(0)
        end,
      })
    end)
  )
  vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
    once = true,
    callback = function()
      -- vim.notify('[collama]: timer:stop()', vim.log.levelsire.DEBUG)
      timer:stop()
    end,
  })
end

return M
