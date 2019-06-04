Transform = {}

function Transform.point()
    return {pos = vec2(0, 0), rotate = 0, scale = 1, translate = vec2(0, 0)}
end

Transform.current = nil
Transform.points = {}

do
    pinch = {}
    
    function pinch.condition()
        local count = Touches.count()

        if count ~= 2 then      
            if Transform.current then
                local point = Transform.point()
                
                point.pos = Transform.current.anchor.pos
                point.rotate = Transform.current.rotate
                point.scale = Transform.current.scale
                point.translate = Transform.current.translate
                
                table.insert(Transform.points, point)
            end

            Transform.current = nil
        end
        
        return count == 2
    end
    
    function pinch.notify()
        local touches = {}
        for _, touch in pairs(Touches.active) do
            table.insert(touches, Transform.screenToWorld(vec2(touch.x, touch.y)))
        end

        local opposite = touches[2].y - touches[1].y
        local adjacent = touches[2].x - touches[1].x
        local dist = touches[1]:dist(touches[2])
        local angle = Transform.to360(math.deg(math.asin(opposite / dist)), adjacent)

        if not Transform.current then
            Transform.current = Transform.point()
            
            if not Transform.current.anchor then
                Transform.current.anchor = Transform.point()
                
                Transform.current.anchor.pos = touches[1]
                Transform.current.anchor.dist = dist        
                Transform.current.anchor.angle = angle
            end
        end
        
        Transform.current.rotate = -(Transform.current.anchor.angle - angle)
        Transform.current.scale = dist / Transform.current.anchor.dist
        Transform.current.translate = touches[1] - Transform.current.anchor.pos
    end
    
    table.insert(Touches.subscribers, pinch)
end

function Transform.draw()         
    for _, point in ipairs(Transform.points) do
        translate(point.translate.x, point.translate.y)
            
        translate(point.pos.x, point.pos.y)
            rotate(point.rotate)
            scale(point.scale)
        translate(-point.pos.x, -point.pos.y)
    end

    if Transform.current then
        translate(Transform.current.translate.x, Transform.current.translate.y)

        translate(Transform.current.anchor.pos.x, Transform.current.anchor.pos.y)
            rotate(Transform.current.rotate)
            scale(Transform.current.scale)
        translate(-Transform.current.anchor.pos.x, -Transform.current.anchor.pos.y)
    end
end

function Transform.screenToWorld(touch)   
    for _, point in ipairs(Transform.points) do
        touch = touch - point.translate
        
        -- Remove rotations around all previous transform points
        local radius = vec2(point.pos.x - touch.x, point.pos.y - touch.y)
        
        touch.x = point.pos.x - ((math.cos(math.rad(point.rotate)) * radius.x) +
            (math.sin(math.rad(point.rotate)) * radius.y))
        touch.y = point.pos.y - ((math.cos(math.rad(point.rotate)) * radius.y) -
            (math.sin(math.rad(point.rotate)) * radius.x))
        
        -- Remove all previous scales   
        touch = point.pos + ((touch - point.pos) / point.scale)
    end
    
    return touch
end

-- angle is positive if secondTouch.y > firstTouch.ys
-- xDelta is positive if secondTouch.x > firstTouch.x
function Transform.to360(angle, xDelta)
    -- Quadrant 1 if angle and xDelta are positive, else: 
    if xDelta < 0 then
        -- Quadrant 2, 3
        angle = 180 - angle
    elseif angle < 0 then
        -- Quadrant 4
        angle = 360 + angle
    end
    
    return angle
end
