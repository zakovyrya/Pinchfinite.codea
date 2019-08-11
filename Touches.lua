Touches = {}

Touches.active = {}

-- Each subscriber requires condition() and notify() functions
Touches.subscribers = {}

-- Register touches, then notify subscribers
function Touches.register(touch)
    if touch.state == BEGAN or touch.state == MOVING then
        Touches.active[touch.id] = touch
    elseif touch.state == ENDED or touch.state == CANCELLED then
        Touches.active[touch.id] = nil
    end

    Touches.notify()
end

-- Return the number of active touces
function Touches.count()
    local count = 0
        
    for _, _ in pairs(Touches.active) do
        count = count + 1
    end

    return count
end

function Touches.notify()
    for _, subscriber in ipairs(Touches.subscribers) do
        if subscriber.enabled() == true and subscriber.condition() == true then
            subscriber.notify()
        end
    end
end
