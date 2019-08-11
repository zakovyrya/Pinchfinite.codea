Transform = {}

Transform.current = nil
Transform.modes = nil
Transform.points = {}

do
    pinch = {}
    
    function pinch.enabled()
        return true
    end
    
    function pinch.condition()
        local count = Touches.count()

        if count ~= 2 then
            -- Save current transform when user releases two-finger pinch 
            if Transform.current then
                local point = Transform.point()
                
                point.pos = Transform.current.anchor.pos
                
                if Transform.modes.rotate == true then
                    point.rotate = Transform.current.rotate
                end
                
                if Transform.modes.scale == true then
                    point.scale = Transform.current.scale
                end
                
                if Transform.modes.translate == true then
                    point.translate = Transform.current.translate
                end
                    
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
            
            -- The first touch sets the anchor point from which all transforms are calculated:
            -- Rotate: difference between initial pinch angle
            -- Scale: initial pinch distance is set to scale == 1, subsequent changes in distance
            --     change the scale value
            -- Translate: The difference between the initial position of the first pinch touch
            --     and the updated position of that touch as it moves
            if not Transform.current.anchor then
                Transform.current.anchor = Transform.point()
                
                
                Transform.current.anchor.pos = touches[1]
                Transform.current.anchor.dist = dist        
                Transform.current.anchor.angle = angle
            end
        end
        
        if Transform.modes.rotate == true then
            Transform.current.rotate = -(Transform.current.anchor.angle - angle)
        end
        
        if Transform.modes.scale == true then
            Transform.current.scale = dist / Transform.current.anchor.dist
        end
        
        if Transform.modes.translate == true then
            Transform.current.translate = touches[1] - Transform.current.anchor.pos
        end
    end
    
    table.insert(Touches.subscribers, pinch)
end

function Transform.point()
    return {pos = vec2(0, 0), rotate = 0, scale = 1, translate = vec2(0, 0)}
end

function Transform.draw(modes)
    Transform.modes = modes
          
    for _, point in ipairs(Transform.points) do
        if Transform.modes.translate == true then
            translate(point.translate.x, point.translate.y)
        end
            
        translate(point.pos.x, point.pos.y)
            if Transform.modes.rotate == true then
                rotate(point.rotate)
            end
        
            if Transform.modes.scale == true then
                scale(point.scale)
            end
        translate(-point.pos.x, -point.pos.y)
    end

    if Transform.current then
        if Transform.modes.translate == true then
            translate(Transform.current.translate.x, Transform.current.translate.y)
        end

        translate(Transform.current.anchor.pos.x, Transform.current.anchor.pos.y)
            if Transform.modes.rotate == true then
                rotate(Transform.current.rotate)
            end
        
            if Transform.modes.scale == true then
                scale(Transform.current.scale)
            end
        translate(-Transform.current.anchor.pos.x, -Transform.current.anchor.pos.y)
    end
end

function Transform.screenToWorld(touch)   
    for _, point in ipairs(Transform.points) do
        -- Remove previous translations
        if Transform.modes.translate == true then
            touch = touch - point.translate
        end
        
        -- Remove previous rotations
        if Transform.modes.rotate == true then
            local radius = vec2(point.pos.x - touch.x, point.pos.y - touch.y)
            
            touch.x = point.pos.x - ((math.cos(math.rad(point.rotate)) * radius.x) +
                (math.sin(math.rad(point.rotate)) * radius.y))
            touch.y = point.pos.y - ((math.cos(math.rad(point.rotate)) * radius.y) -
                (math.sin(math.rad(point.rotate)) * radius.x))
        end
        
        -- Remove previous scales
        if Transform.modes.scale == true then
            touch = point.pos + ((touch - point.pos) / point.scale)
        end
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
