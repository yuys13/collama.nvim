---@class FimTokens
---@field prefix string special token for FIM such as `\<PRE\>`
---@field suffix string special token for FIM such as `\<SUF\>`
---@field middle string special token for FIM such as `\<MID\>`
---@field end_of_middle string special token for FIM such as `<EOM>`

---@class FimConfig
---@field model string
---@field tokens FimTokens

local ns_id = vim.api.nvim_create_namespace 'collama'

local M = {}

---get prefix and suffix from buffer
---@param bufnr number number of a buffer
---@param pos number[] cursor position
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
---@param tokens FimTokens special tokens for FIM
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
---@param tokens FimTokens special tokens for FIM
---@return fun(res:CollamaGenerateResponse)
local function create_callback(bufnr, pos, tokens)
  ---
  ---@param res CollamaGenerateResponse
  local function callback(res)
    local response = res.response:gsub(tokens.end_of_middle .. '$', '')
    local extmark_id = show_extmark(bufnr, pos, response)

    vim.keymap.set('i', '<C-f>', function()
      vim.notify('[collama]: accept', vim.log.levels.INFO)
      vim.api.nvim_buf_set_text(bufnr, pos[1] - 1, pos[2], pos[1] - 1, pos[2], vim.split(response, '\n'))
      vim.api.nvim_buf_del_extmark(bufnr, ns_id, extmark_id)
      vim.keymap.del('i', '<C-f>')
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
---@param config FimConfig
function M.request(config)
  local buffer = vim.fn.bufnr()
  local cur_pos = vim.api.nvim_win_get_cursor(0)
  local prefix, suffix = get_buffer(buffer, cur_pos)
  local prompt = create_prompt(prefix, suffix, config.tokens)

  require('collama.api').generate('http://localhost:11434/api/', {
    prompt = prompt,
    model = config.model,
    stream = false,
  }, create_callback(buffer, cur_pos, config.tokens))
end

return M
