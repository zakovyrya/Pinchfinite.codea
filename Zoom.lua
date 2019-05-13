Zoom = {}

Zoom.currentTransform = nil
Zoom.prevPinchDistance = nil
Zoom.pinchDelta = 0
Zoom.pinchDistance = nil
Zoom.rotatePoint = nil
Zoom.transformPoints = {}
Zoom.translation = vec2(0, 0)


-- Returns a table representing one point of view transformation
function TransformPoint(r, s, w)
    return {
        rotate = r,
        scale = s,
        world = w
    }
end

function Zoom.currentRotation()
    local totalRotation = 0
    
    for i, point in ipairs(Zoom.transformPoints) do
        totalRotation = totalRotation + point.rotate
    end
    
    return totalRotation
end

function Zoom.currentScale()
    local totalScale = 1
    
    for i, point in ipairs(Zoom.transformPoints) do
        totalScale = totalScale * point.scale
    end
    
    return totalScale
end

-- Transform view, given all transform points
function Zoom.draw(current)
    translate(Zoom.translation.x or 0, Zoom.translation.y or 0)
    
    for i, point in ipairs(Zoom.transformPoints) do
        translate(point.world.x, point.world.y)
        
        scale(point.scale)
        rotate(point.rotate)
        
        translate(-point.world.x, -point.world.y)
    end
    
    if Zoom.currentTransform then
        translate(Zoom.currentTransform.world.x, Zoom.currentTransform.world.y)
        
        scale(Zoom.currentTransform.scale)
        rotate(Zoom.currentTransform.rotate)
        
        translate(-Zoom.currentTransform.world.x, -Zoom.currentTransform.world.y)
    end
end

-- Transform screen coordinate of touch to world coordinate. This involves a reversal
-- of all session transform points, to "unwind" the current world view transform back
-- to the intial view where screen coordinates match world coordinates
--
-- touch vec2 screen coordinate
function Zoom.screenToWorld(touch)
    -- Remove current translation
    touch.x = touch.x - Zoom.translation.x
    touch.y = touch.y - Zoom.translation.y

    for i, point in ipairs(Zoom.transformPoints) do
        -- Remove rotations around all previous transform points
        local radius = vec2(point.world.x - touch.x, point.world.y - touch.y)

        touch.x = point.world.x - ((math.cos(math.rad(point.rotate)) * radius.x) +
            (math.sin(math.rad(point.rotate)) * radius.y))
        touch.y = point.world.y - ((math.cos(math.rad(point.rotate)) * radius.y) -
            (math.sin(math.rad(point.rotate)) * radius.x))
        
        -- Remove all previous scales   
        touch.x = point.world.x + ((touch.x - point.world.x) / point.scale)
        touch.y = point.world.y + ((touch.y - point.world.y) / point.scale)
    end
    
    return touch
end
