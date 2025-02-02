local assert = require 'luassert'
local spy = require 'luassert.spy'

describe('default', function()
  local logger

  before_each(function()
    package.loaded['collama.logger'] = nil
    logger = require 'collama.logger'
  end)

  it('notify is nil', function()
    assert.is_nil(logger.notify)
  end)

  it('level is INFO', function()
    assert.equal(vim.log.levels.INFO, logger.level)
  end)
end)

describe('error()', function()
  local logger = require 'collama.logger'
  local notify = spy.on(logger, 'notify')

  before_each(function()
    notify:clear()
  end)

  after_each(function()
    logger.level = vim.log.levels.INFO
  end)

  it('do not call notify when error level is OFF', function()
    logger.level = vim.log.levels.OFF

    logger.error 'error message'
    assert.spy(notify).was.called(0)
  end)

  it('call notify when error level is ERROR', function()
    logger.level = vim.log.levels.ERROR

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
  local notify = spy.on(logger, 'notify')

  before_each(function()
    notify:clear()
  end)

  after_each(function()
    logger.level = vim.log.levels.INFO
  end)

  it('do not call notify when error level is ERROR', function()
    logger.level = vim.log.levels.ERROR

    logger.warn 'warn message'
    assert.spy(notify).was.called(0)
  end)

  it('call notify when error level is WARN', function()
    logger.level = vim.log.levels.WARN

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
  local notify = spy.on(logger, 'notify')

  before_each(function()
    notify:clear()
  end)

  after_each(function()
    logger.level = vim.log.levels.INFO
  end)

  it('do not call notify when error level is WARN', function()
    logger.level = vim.log.levels.WARN

    logger.info 'info message'
    assert.spy(notify).was.called(0)
  end)

  it('call notify when error level is INFO', function()
    logger.level = vim.log.levels.INFO

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
  local notify = spy.on(logger, 'notify')

  before_each(function()
    notify:clear()
  end)

  after_each(function()
    logger.level = vim.log.levels.INFO
  end)

  it('do not call notify when error level is INFO', function()
    logger.level = vim.log.levels.INFO

    logger.debug 'debug message'
    assert.spy(notify).was.called(0)
  end)

  it('call notify when error level is DEBUG', function()
    logger.level = vim.log.levels.DEBUG

    logger.debug 'debug message'
    assert.spy(notify).was.called(1)
  end)

  it('call notify with error level', function()
    logger.level = vim.log.levels.DEBUG

    logger.debug 'debug message'
    assert.spy(notify).was.called_with('debug message', vim.log.levels.DEBUG, {
      title = 'collama',
      annote = 'collama(DEBUG)',
      group = 'collama',
    })
  end)
end)
