local M = {}

---Get host
---@return string
function M.get_host()
  if vim.env.OLLAMA_HOST then
    return string.format('http://%s', vim.env.OLLAMA_HOST)
  end
  return 'http://127.0.0.1:11434'
end

return M
