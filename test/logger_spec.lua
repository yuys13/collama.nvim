local assert = require 'luassert'
local spy = require 'luassert.spy'

local notify = spy.new(function() end)

describe('default error level is INFO so', function()
  package.loaded['collama.logger'] = nil
  local logger = require 'collama.logger'
  ---@diagnostic disable-next-line: param-type-mismatch
  logger.setup(notify)

  before_each(function()
    notify:clear()
  end)

  it('error call notify', function()
    logger.error 'message'
    assert.spy(notify).was.called(1)
  end)

  it('warn call notify', function()
    logger.warn 'message'
    assert.spy(notify).was.called(1)
  end)

  it('info call notify', function()
    logger.info 'message'
    assert.spy(notify).was.called(1)
  end)

  it('debug do not call notify', function()
    logger.debug 'message'
    assert.spy(notify).was.called(0)
  end)
end)

describe('error()', function()
  local logger = require 'collama.logger'
  ---@diagnostic disable-next-line: param-type-mismatch
  logger.setup(notify)

  before_each(function()
    notify:clear()
  end)

  after_each(function()
    logger.set_minimum_level(vim.log.levels.INFO)
  end)

  it('do not call notify when error level is OFF', function()
    logger.set_minimum_level(vim.log.levels.OFF)

    logger.error 'error message'
    assert.spy(notify).was.called(0)
  end)

  it('call notify when error level is ERROR', function()
    logger.set_minimum_level(vim.log.levels.ERROR)

    logger.error 'error message'
    assert.spy(notify).was.called(1)
  end)

  it('call notify with error level', function()
    logger.error 'error message'
    assert.spy(notify).was.called_with('error message', vim.log.levels.ERROR, {
      title = 'collama',
      annote = 'collama(ERROR)',
      group = 'collama',
    })
  end)
end)

describe('warn()', function()
  local logger = require 'collama.logger'
  ---@diagnostic disable-next-line: param-type-mismatch
  logger.setup(notify)

  before_each(function()
    notify:clear()
  end)

  after_each(function()
    logger.set_minimum_level(vim.log.levels.INFO)
  end)

  it('do not call notify when error level is ERROR', function()
    logger.set_minimum_level(vim.log.levels.ERROR)

    logger.warn 'warn message'
    assert.spy(notify).was.called(0)
  end)

  it('call notify when error level is WARN', function()
    logger.set_minimum_level(vim.log.levels.WARN)

    logger.warn 'warn message'
    assert.spy(notify).was.called(1)
  end)

  it('call notify with error level', function()
    logger.warn 'warn message'
    assert.spy(notify).was.called_with('warn message', vim.log.levels.WARN, {
      title = 'collama',
      annote = 'collama(WARN)',
      group = 'collama',
    })
  end)
end)

describe('info()', function()
  local logger = require 'collama.logger'
  ---@diagnostic disable-next-line: param-type-mismatch
  logger.setup(notify)

  before_each(function()
    notify:clear()
  end)

  after_each(function()
    logger.set_minimum_level(vim.log.levels.INFO)
  end)

  it('do not call notify when error level is WARN', function()
    logger.set_minimum_level(vim.log.levels.WARN)

    logger.info 'info message'
    assert.spy(notify).was.called(0)
  end)

  it('call notify when error level is INFO', function()
    logger.set_minimum_level(vim.log.levels.INFO)

    logger.info 'info message'
    assert.spy(notify).was.called(1)
  end)

  it('call notify with error level', function()
    logger.info 'info message'
    assert.spy(notify).was.called_with('info message', vim.log.levels.INFO, {
      title = 'collama',
      annote = 'collama(INFO)',
      group = 'collama',
    })
  end)
end)

describe('debug()', function()
  local logger = require 'collama.logger'
  ---@diagnostic disable-next-line: param-type-mismatch
  logger.setup(notify)

  before_each(function()
    notify:clear()
  end)

  after_each(function()
    logger.set_minimum_level(vim.log.levels.INFO)
  end)

  it('do not call notify when error level is INFO', function()
    logger.set_minimum_level(vim.log.levels.INFO)

    logger.debug 'debug message'
    assert.spy(notify).was.called(0)
  end)

  it('call notify when error level is DEBUG', function()
    logger.set_minimum_level(vim.log.levels.DEBUG)

    logger.debug 'debug message'
    assert.spy(notify).was.called(1)
  end)

  it('call notify with error level', function()
    logger.set_minimum_level(vim.log.levels.DEBUG)

    logger.debug 'debug message'
    assert.spy(notify).was.called_with('debug message', vim.log.levels.DEBUG, {
      title = 'collama',
      annote = 'collama(DEBUG)',
      group = 'collama',
    })
  end)
end)
