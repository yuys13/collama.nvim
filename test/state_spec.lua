local state = require 'collama.copilot.state'

describe('state', function()
  it('should be a simple data container', function()
    local s = state.new()

    assert.are.same('table', type(s))
    assert.is_not_nil(s.timer)
    assert.is_nil(s.job)
    assert.are.same(0, s.bufnr)
    assert.is_nil(s.pos)
    assert.is_nil(s.result)
    assert.is_nil(s.extmark_id)
  end)
end)
