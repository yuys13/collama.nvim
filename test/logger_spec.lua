---@diagnostic disable: param-type-mismatch, undefined-field
local logger = require 'collama.logger'

local spy = require 'luassert.spy'

describe('default error level is INFO so', function()
  after_each(function()
    logger.setup(nil)
  end)

  it('error call notify', function()
    local notify = spy.new(function() end)
    logger.setup(notify)

    logger.error 'message'
    assert.spy(notify).was.called()
  end)

  it('warn call notify', function()
    local notify = spy.new(function() end)
    logger.setup(notify)

    logger.warn 'message'
    assert.spy(notify).was.called()
  end)

  it('info call notify', function()
    local notify = spy.new(function() end)
    logger.setup(notify)

    logger.info 'message'
    assert.spy(notify).was.called()
  end)

  it('debug do not call notify', function()
    local notify = spy.new(function() end)
    logger.setup(notify)

    logger.debug 'message'
    assert.spy(notify).was_not_called()
  end)
end)

describe('error function', function()
  after_each(function()
    logger.set_minimum_level(vim.log.levels.INFO)
  end)

  it('do not call notify when error level is OFF', function()
    local notify = spy.new(function() end)
    logger.setup(notify)
    logger.set_minimum_level(vim.log.levels.OFF)

    logger.error 'error message'
    assert.spy(notify).was_not_called()
  end)

  it('call notify when error level is ERROR', function()
    local notify = spy.new(function() end)
    logger.setup(notify)
    logger.set_minimum_level(vim.log.levels.ERROR)

    logger.error 'error message'
    assert.spy(notify).was.called()
  end)

  it('call notify with error level', function()
    local notify = spy.new(function() end)
    logger.setup(notify)

    logger.error 'error message'
    assert.spy(notify).was.called_with('error message', vim.log.levels.ERROR, {
      title = 'collama',
      annote = 'collama(ERROR)',
      group = 'collama',
    })
  end)
end)

describe('warn function', function()
  after_each(function()
    logger.set_minimum_level(vim.log.levels.INFO)
  end)

  it('do not call notify when error level is ERROR', function()
    local notify = spy.new(function() end)
    logger.setup(notify)
    logger.set_minimum_level(vim.log.levels.ERROR)

    logger.warn 'warn message'
    assert.spy(notify).was_not_called()
  end)

  it('call notify when error level is WARN', function()
    local notify = spy.new(function() end)
    logger.setup(notify)
    logger.set_minimum_level(vim.log.levels.WARN)

    logger.warn 'warn message'
    assert.spy(notify).was.called()
  end)

  it('call notify with error level', function()
    local notify = spy.new(function() end)
    logger.setup(notify)

    logger.warn 'warn message'
    assert.spy(notify).was.called_with('warn message', vim.log.levels.WARN, {
      title = 'collama',
      annote = 'collama(WARN)',
      group = 'collama',
    })
  end)
end)

describe('info function', function()
  after_each(function()
    logger.set_minimum_level(vim.log.levels.INFO)
  end)

  it('do not call notify when error level is WARN', function()
    local notify = spy.new(function() end)
    logger.setup(notify)
    logger.set_minimum_level(vim.log.levels.WARN)

    logger.info 'info message'
    assert.spy(notify).was_not_called()
  end)

  it('call notify when error level is INFO', function()
    local notify = spy.new(function() end)
    logger.setup(notify)
    logger.set_minimum_level(vim.log.levels.INFO)

    logger.info 'info message'
    assert.spy(notify).was.called()
  end)

  it('call notify with error level', function()
    local notify = spy.new(function() end)
    logger.setup(notify)

    logger.info 'info message'
    assert.spy(notify).was.called_with('info message', vim.log.levels.INFO, {
      title = 'collama',
      annote = 'collama(INFO)',
      group = 'collama',
    })
  end)
end)

describe('debug function', function()
  after_each(function()
    logger.set_minimum_level(vim.log.levels.INFO)
  end)

  it('do not call notify when error level is INFO', function()
    local notify = spy.new(function() end)
    logger.setup(notify)
    logger.set_minimum_level(vim.log.levels.INFO)

    logger.debug 'debug message'
    assert.spy(notify).was_not_called()
  end)

  it('call notify when error level is DEBUG', function()
    local notify = spy.new(function() end)
    logger.setup(notify)
    logger.set_minimum_level(vim.log.levels.DEBUG)

    logger.debug 'debug message'
    assert.spy(notify).was.called()
  end)

  it('call notify with error level', function()
    local notify = spy.new(function() end)
    logger.setup(notify)
    logger.set_minimum_level(vim.log.levels.DEBUG)

    logger.debug 'debug message'
    assert.spy(notify).was.called_with('debug message', vim.log.levels.DEBUG, {
      title = 'collama',
      annote = 'collama(DEBUG)',
      group = 'collama',
    })
  end)
end)
