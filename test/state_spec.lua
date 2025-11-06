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

    -- Assert that methods are removed
    assert.is_nil(s.clear)
    assert.is_nil(s.get_job)
    assert.is_nil(s.timer_start)
    assert.is_nil(s.set_pos)
    assert.is_nil(s.get_pos)
    assert.is_nil(s.set_job)
    assert.is_nil(s.set_result)
    assert.is_nil(s.get_result)
    assert.is_nil(s.set_extmark_id)
    assert.is_nil(s.is_moved)
  end)
end)
