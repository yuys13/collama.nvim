local envconfig = require 'collama.envconfig'

describe('get_host', function()
  local backup_ollama_host = vim.env.OLLAMA_HOST

  after_each(function()
    vim.env.OLLAMA_HOST = backup_ollama_host
  end)

  it('empty', function()
    vim.env.OLLAMA_HOST = ''
    local expected = 'http://127.0.0.1:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('only address', function()
    vim.env.OLLAMA_HOST = '1.2.3.4'
    local expected = 'http://1.2.3.4:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('only port', function()
    vim.env.OLLAMA_HOST = ':1234'
    local expected = 'http://:1234'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('address and port', function()
    vim.env.OLLAMA_HOST = '1.2.3.4:1234'
    local expected = 'http://1.2.3.4:1234'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('hostname', function()
    vim.env.OLLAMA_HOST = 'example.com'
    local expected = 'http://example.com:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('hostname and port', function()
    vim.env.OLLAMA_HOST = 'example.com:1234'
    local expected = 'http://example.com:1234'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('zero port', function()
    vim.env.OLLAMA_HOST = ':0'
    local expected = 'http://:0'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('too large port', function()
    vim.env.OLLAMA_HOST = ':66000'
    local expected = 'http://:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('too small port', function()
    vim.env.OLLAMA_HOST = ':-1'
    local expected = 'http://:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('ipv6 localhost', function()
    vim.env.OLLAMA_HOST = '[::1]'
    local expected = 'http://[::1]:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('ipv6 world open', function()
    vim.env.OLLAMA_HOST = '[::]'
    local expected = 'http://[::]:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('ipv6 no brackets', function()
    vim.env.OLLAMA_HOST = '::1'
    local expected = 'http://[::1]:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('ipv6 + port', function()
    vim.env.OLLAMA_HOST = '[::1]:1337'
    local expected = 'http://[::1]:1337'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('extra space', function()
    vim.env.OLLAMA_HOST = ' 1.2.3.4 '
    local expected = 'http://1.2.3.4:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('extra quotes', function()
    vim.env.OLLAMA_HOST = '"1.2.3.4"'
    local expected = 'http://1.2.3.4:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('extra space+quotes', function()
    vim.env.OLLAMA_HOST = ' " 1.2.3.4 " '
    local expected = 'http://1.2.3.4:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('extra single quotes', function()
    vim.env.OLLAMA_HOST = "'1.2.3.4'"
    local expected = 'http://1.2.3.4:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('http', function()
    vim.env.OLLAMA_HOST = 'http://1.2.3.4'
    local expected = 'http://1.2.3.4:80'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('http port', function()
    vim.env.OLLAMA_HOST = 'http://1.2.3.4:4321'
    local expected = 'http://1.2.3.4:4321'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('https', function()
    vim.env.OLLAMA_HOST = 'https://1.2.3.4'
    local expected = 'https://1.2.3.4:443'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('https port', function()
    vim.env.OLLAMA_HOST = 'https://1.2.3.4:4321'
    local expected = 'https://1.2.3.4:4321'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('proxy path', function()
    vim.env.OLLAMA_HOST = 'https://example.com/ollama'
    local expected = 'https://example.com:443/ollama'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('ollama.com', function()
    vim.env.OLLAMA_HOST = 'ollama.com'
    local expected = 'https://ollama.com:443'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)
end)
