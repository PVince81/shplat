State = {}
State.__index = State

function State.create(name)
    local state = {}
    setmetatable(state, State)

    state.name = name
    state.nextState = nil
    state.time = 0
    state.maxTime = 0
    return state
end

function State:step(delta)
    if self.maxTime > 0 then
        self.time = self.time + delta
        if self.time > self.maxTime then
            self:setState(self.nextState)
            return true
        end
    end
    return false
end

function State:setState(stateName, maxTime, nextState)
    self.name = stateName
    self.time = 0
    self.maxTime = maxTime or 0
    self.nextState = nextState or nil
end

-- Returns progress, 0 is at start, 1 is finished
function State:getProgress()
    if self.maxTime > 0 then
        return self.time / self.maxTime
    else
        return 1
    end
end