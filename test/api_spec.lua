local api = require 'collama.api'
local stub = require 'luassert.stub'
local spy = require 'luassert.spy'
local match = require 'luassert.match'

describe('base_url', function()
  local backup_ollama_host = vim.env.OLLAMA_HOST

  after_each(function()
    vim.env.OLLAMA_HOST = backup_ollama_host
  end)

  it('default', function()
    vim.env.OLLAMA_HOST = nil
    local expected = 'http://127.0.0.1:11434/api/'
    local actual = api.get_base_url()
    assert.are_equal(expected, actual)
  end)

  it('OLLAMA_HOST', function()
    vim.env.OLLAMA_HOST = 'localhost:8080'
    local expected = 'http://localhost:8080/api/'
    local actual = api.get_base_url()
    assert.are_equal(expected, actual)
  end)
end)

describe('generate', function()
  it('request with curl', function()
    local mock = stub.new(vim, 'system')

    ---@type CollamaGenerateRequest
    local request_body = { model = 'awesome_model', prompt = 'The quick brown fox', suffix = 'lazy dog.' }
    api.generate('url', request_body, function(_) end)
    vim.wait(1000, function()
      local ret, _ = mock:called()
      return ret
    end)

    request_body.stream = false
    assert.spy(mock).was.called_with({
      'curl',
      '-sSL',
      '--compressed',
      '-d',
      vim.json.encode(request_body),
      'url/generate',
    }, { text = true }, match._)

    mock:revert()
  end)

  it('request stream false, even if specified true', function()
    local mock = stub.new(vim, 'system')

    ---@type CollamaGenerateRequest
    local request_body =
      { model = 'awesome_model', prompt = 'The quick brown fox', suffix = 'lazy dog.', stream = true }
    api.generate('url', request_body, function(_) end)
    vim.wait(1000, function()
      local ret, _ = mock:called()
      return ret
    end)

    request_body.stream = false
    assert.spy(mock).was.called_with({
      'curl',
      '-sSL',
      '--compressed',
      '-d',
      vim.json.encode(request_body),
      'url/generate',
    }, { text = true }, match._)

    mock:revert()
  end)

  it('call callback', function()
    local mock = stub.new(vim, 'system')
    mock.invokes(function(_, _, on_exit)
      on_exit {
        signal = 0,
        code = 0,
        stdout = vim.json.encode {
          done = true,
          model = 'awesome_model',
          response = 'jumps over',
        },
      }
    end)

    local callback = spy.new()
    api.generate('', { model = '', prompt = '' }, function(res)
      callback(res)
    end)

    vim.wait(1000, function()
      local ret, _ = callback:called()
      return ret
    end)

    assert.spy(callback).was.called_with { done = true, model = 'awesome_model', response = 'jumps over' }

    mock:revert()
  end)

  it('output debug message when curl receive signal', function()
    local log = spy.on(require 'collama.logger', 'debug')
    local mock = stub.new(vim, 'system')
    mock.invokes(function(_, _, on_exit)
      on_exit {
        signal = 1234,
        code = 0,
        stdout = vim.json.encode {
          done = true,
          model = 'awesome_model',
          response = 'jumps over',
        },
      }
    end)

    local callback = spy.new()
    api.generate('', { model = '', prompt = '' }, function(res)
      callback(res)
    end)

    vim.wait(1000, function()
      local ret, _ = log:called(3)
      return ret
    end)

    assert.spy(callback).was.called(0)
    assert.spy(log).was.called_with 'cancelled with signal:1234'

    mock:revert()
    log:revert()
  end)

  it('output error message when curl return error code', function()
    local log = spy.on(require 'collama.logger', 'error')
    local mock = stub.new(vim, 'system')
    mock.invokes(function(_, _, on_exit)
      on_exit {
        signal = 0,
        code = 1,
        stdout = vim.json.encode {
          done = true,
          model = 'awesome_model',
          response = 'jumps over',
        },
      }
    end)

    local callback = spy.new()
    api.generate('', { model = '', prompt = '' }, function(res)
      callback(res)
    end)

    vim.wait(1000, function()
      local ret, _ = log:called(1)
      return ret
    end)

    assert.spy(callback).was.called(0)
    assert.spy(log).was.called_with 'Generation error'

    mock:revert()
    log:revert()
  end)

  it('output error message when response is malformed', function()
    local log = spy.on(require 'collama.logger', 'error')
    local mock = stub.new(vim, 'system')
    mock.invokes(function(_, _, on_exit)
      on_exit {
        signal = 0,
        code = 0,
        stdout = 'this is not json',
      }
    end)

    local callback = spy.new()
    api.generate('', { model = '', prompt = '' }, function(res)
      callback(res)
    end)

    vim.wait(1000, function()
      local ret, _ = log:called(1)
      return ret
    end)

    assert.spy(callback).was.called(0)
    assert.spy(log).was.called_with 'Generation error'

    mock:revert()
    log:revert()
  end)
end)
