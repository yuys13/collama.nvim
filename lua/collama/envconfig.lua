local M = {}

---Trim spaces and quotes
---@param s string
---@return string
local function trim(s)
  return (s:gsub('^[%s"\']+', ''):gsub('[%s"\']+$', ''))
end

---Get host
---@return string
function M.get_host()
  local env_host = vim.env.OLLAMA_HOST or ''
  env_host = trim(env_host)

  if env_host == '' then
    return 'http://127.0.0.1:11434'
  end

  if env_host == 'ollama.com' then
    return 'https://ollama.com:443'
  end

  local scheme = 'http'
  local rest = env_host
  if env_host:match '^https?://' then
    scheme, rest = env_host:match '^(https?)://(.*)$'
  end

  -- Separate path
  local host_port, path = rest:match '^([^/]+)(/.*)$'
  if not host_port then
    host_port = rest
    path = ''
  end

  -- Separate host and port
  local host, port_str
  if host_port:match '^%[.*%]' then
    -- IPv6 with brackets
    host, port_str = host_port:match '^(%[.-%]):?(.*)$'
  elseif host_port:gsub('[^:]', ''):len() > 1 then
    -- raw IPv6 (multiple colons, no brackets)
    host = '[' .. host_port .. ']'
    port_str = ''
  elseif host_port:match '^:' then
    -- only port case like ":1234"
    host = ''
    port_str = host_port:match '^:(.*)$'
  else
    -- IPv4 or hostname
    host, port_str = host_port:match '^([^:]*):?(.*)$'
  end

  local port = tonumber(port_str)
  if port_str == '' or not port then
    -- Default ports
    if env_host:match '^https?://' then
      if scheme == 'https' then
        port = 443
      else
        port = 80
      end
    else
      port = 11434
    end
  end

  -- Port validation
  if port and (port < 0 or port > 65535) then
    port = 11434
  end

  local result = string.format('%s://%s', scheme, host)
  if port then
    result = result .. ':' .. port
  end
  result = result .. path

  return result
end

return M
