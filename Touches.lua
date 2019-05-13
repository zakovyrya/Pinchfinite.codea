Touches = {}

Touches.active = {}
Touches.current = nil

-- Each subscriber requires condition() and notify() functions
Touches.subscribers = {}

-- Register touches, then notify subscribers
function Touches.register(touch)
    if touch.state == BEGAN or touch.state == MOVING then
        Touches.active[touch.id] = touch
    elseif touch.state == ENDED or touch.state == CANCELLED then
        Touches.active[touch.id] = nil
    end
    
    Touches.current = touch

    Touches.notify()
end

function Touches.count()
    local count = 0
    
    for _, _ in pairs(Touches.active) do
        count = count + 1
    end

    return count
end

function Touches.activeStates()
    local states = {}
    
    for _, touch in pairs(Touches.active) do
        table.insert(states, touch.state)
    end

    return states
end

function Touches.notify()
    for _, subscriber in ipairs(Touches.subscribers) do
        if subscriber.condition() == true then
            subscriber.notify()
        end
    end
end
