local envconfig = require 'collama.envconfig'

describe('get_host', function()
  local backup_ollama_host = vim.env.OLLAMA_HOST

  after_each(function()
    vim.env.OLLAMA_HOST = backup_ollama_host
  end)

  it('default', function()
    vim.env.OLLAMA_HOST = nil
    local expected = 'http://127.0.0.1:11434'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)

  it('OLLAMA_HOST', function()
    vim.env.OLLAMA_HOST = 'localhost:8080'
    local expected = 'http://localhost:8080'
    local actual = envconfig.get_host()
    assert.are_equal(expected, actual)
  end)
end)
