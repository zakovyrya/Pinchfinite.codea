Draw = {}

Draw.queue = {}

local DISTANCE_DELTA = 5
local MAX_SCALE = 4
local MIN_SCALE = 0.2
local PERCENT_OF_PINCH_DELTA = 0.005
local ROTATION_INCREMENT = 1
local ROTATION_THRESHOLD = 0.5
local SCREEN_CENTER = vec2(WIDTH / 2, HEIGHT / 2)

-- Translate
do
    local translate = {}
    
    function translate.condition()
        return Touches.count() == 1
    end
    
    function translate.notify()
        Zoom.translation = Zoom.translation + vec2(Touches.current.deltaX, Touches.current.deltaY)
    end
    
    table.insert(Touches.subscribers, translate)
end

-- Zoom
do
    local zoom = {}
    
    function zoom.condition()
        local states = Touches.activeStates()
        local allMoving = true
        
        for _, state in pairs(states) do
            if state ~= MOVING then
                allMoving = false
            end
        end
        
        local count = Touches.count()
        
        -- If not zooming, then reset prevPinchDistance
        if count == 1 then
            Zoom.prevPinchDistance = nil
            Zoom.pinchDistance = nil
        end
        
        return count == 2 and allMoving == true
    end
    
    function zoom.notify()
        Draw.zoom()
    end
    
    table.insert(Touches.subscribers, zoom)
end

-- Zoom end
do
    local zoomEnd = {}
    
    function zoomEnd.condition()
        return Zoom.currentTransform ~= nil and Touches.count() == 0
    end
    
    function zoomEnd.notify()
        table.insert(Zoom.transformPoints, TransformPoint(
            Zoom.currentTransform.rotate,
            Zoom.currentTransform.scale,
            Zoom.currentTransform.world
        ))
        
        Zoom.currentTransform = nil
    end
    
    table.insert(Touches.subscribers, zoomEnd)
end

-- Rotate
do
    local rotation = {}
    local direction
    
    function rotation.condition()
        local count = Touches.count()
        local active = Touches.active
        
        if count == 3 then
            for _, touch in pairs(active) do
                if touch.deltaY > ROTATION_THRESHOLD then
                    direction = "clockwise"
                    
                    return true
                elseif touch.deltaY < -ROTATION_THRESHOLD then
                    direction = "counterClockwise"
                    
                    return true
                end
            end
            
            return false
        end
    end
    
    function rotation.notify()
        if not Zoom.currentTransform then
            if Zoom.rotatePoint then
                Zoom.currentTransform = TransformPoint(0, 1, Zoom.rotatePoint)
                Zoom.rotatePoint = nil
            else
                Zoom.currentTransform = TransformPoint(0, 1, SCREEN_CENTER)
            end
        end
        
        if direction == "clockwise" then
            Zoom.currentTransform.rotate = Zoom.currentTransform.rotate + ROTATION_INCREMENT
        elseif direction == "counterClockwise" then
            Zoom.currentTransform.rotate = Zoom.currentTransform.rotate - ROTATION_INCREMENT
        end
    end
    
    table.insert(Touches.subscribers, rotation)
end

-- Rotate point
do
    local rotatePoint = {}
    
    function rotatePoint.condition()
        return Touches.current.state == BEGAN and Touches.count() == 1
    end
    
    function rotatePoint.notify()
        local t = Zoom.screenToWorld(vec2(Touches.current.x, Touches.current.y))
        Zoom.rotatePoint = t
    end
    
    table.insert(Touches.subscribers, rotatePoint)
end

function Draw.update()
    background(47, 47, 47, 255)
    
    Zoom.draw()
    
    for _, queued in ipairs(Draw.queue) do
        queued()
    end
end

function Draw.zoom()
    local pinchCenter = nil
    local zoomTouches = {}
    
    for _, touch in pairs(Touches.active) do
        local t = Zoom.screenToWorld(vec2(touch.x, touch.y))
        zoomTouches[#zoomTouches+ 1] = vec2(t.x, t.y)
    end

    Zoom.prevPinchDistance = Zoom.pinchDistance
    Zoom.pinchDistance = zoomTouches[1]:dist(zoomTouches[2])
    
    pinchCenter = vec2(((zoomTouches[2].x + zoomTouches[1].x) / 2),
        ((zoomTouches[2].y + zoomTouches[1].y) / 2))
    
    if Zoom.currentTransform == nil then
        Zoom.currentTransform = TransformPoint(0, 1, pinchCenter)
    end

    if Zoom.prevPinchDistance then
        Zoom.pinchDelta = math.floor(Zoom.pinchDistance - Zoom.prevPinchDistance)
        
        local minScale = MIN_SCALE / Zoom.currentScale()
        local maxScale = MAX_SCALE / Zoom.currentScale()
        
        Zoom.currentTransform.scale = math.min(maxScale, math.max((Zoom.currentTransform.scale +
            (Zoom.pinchDelta * PERCENT_OF_PINCH_DELTA)), minScale))
    end
end
