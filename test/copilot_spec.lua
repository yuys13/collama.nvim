local copilot = require 'collama.copilot'
local stub = require 'luassert.stub'
local match = require 'luassert.match'

describe('create request', function()
  local mock
  local backup_ollama_host = vim.env.OLLAMA_HOST

  before_each(function()
    mock = stub.new(vim, 'system')
  end)

  after_each(function()
    mock:revert()
    vim.env.OLLAMA_HOST = backup_ollama_host
  end)

  it('request() default base_url', function()
    mock = stub.new(vim, 'system')
    ---@type CollamaConfig
    local test_config = { model = 'awesome_model' }
    vim.env.OLLAMA_HOST = nil

    copilot.request(test_config)

    vim.wait(1000, function()
      local ret, _ = mock:called()
      return ret
    end)

    local expected_request_body = { prompt = '', suffix = '', model = 'awesome_model', stream = false }

    assert.spy(mock).called(1)
    assert.spy(mock).was.called_with({
      'curl',
      '-sSL',
      '--compressed',
      '-d',
      vim.json.encode(expected_request_body),
      'http://127.0.0.1:11434/api/generate',
    }, { text = true }, match._)
  end)

  it('request() use OLLAMA_HOST', function()
    ---@type CollamaConfig
    local test_config = { model = 'awesome_model' }
    vim.env.OLLAMA_HOST = 'example.com'

    copilot.request(test_config)

    vim.wait(1000, function()
      local ret, _ = mock:called()
      return ret
    end)

    local expected_request_body = { prompt = '', suffix = '', model = 'awesome_model', stream = false }

    assert.spy(mock).called(1)
    assert.spy(mock).was.called_with({
      'curl',
      '-sSL',
      '--compressed',
      '-d',
      vim.json.encode(expected_request_body),
      'http://example.com/api/generate',
    }, { text = true }, match._)
  end)

  it('request() use base_url', function()
    ---@type CollamaConfig
    local test_config = { model = 'awesome_model', base_url = 'http://localhost:11434/api' }

    copilot.request(test_config)

    vim.wait(1000, function()
      local ret, _ = mock:called()
      return ret
    end)

    local expected_request_body = { prompt = '', suffix = '', model = 'awesome_model', stream = false }

    assert.spy(mock).called(1)
    assert.spy(mock).was.called_with({
      'curl',
      '-sSL',
      '--compressed',
      '-d',
      vim.json.encode(expected_request_body),
      'http://localhost:11434/api/generate',
    }, { text = true }, match._)
  end)
end)
