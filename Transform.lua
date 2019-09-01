Transform = {}

Transform.modes = nil

do
    pinch = {}
    
    function pinch.enabled()
        return true
    end
    
    function pinch.condition()
        local count = Touches.count()

        if count ~= 2 then
            -- Save current transform when user releases two-finger pinch 
            for _, layer in ipairs(Layers) do
                if layer.current then
                    local point = Transform.point()
                        
                    point.pos = layer.current.anchor.pos
                        
                    if Transform.modes.rotate == true then
                        point.rotate = layer.current.rotate
                    end
                        
                    if Transform.modes.scale == true then
                        point.scale = layer.current.scale
                    end
                        
                    if Transform.modes.translate == true then
                        point.translate = layer.current.translate
                    end
                            
                    table.insert(layer.points, point)
                end
                
                layer.current = nil
            end
        end
        
        return count == 2
    end
    
    function pinch.notify()
        for _, layer in ipairs(Layers) do
            local touches = {}
            for _, touch in pairs(Touches.active) do
                table.insert(touches, Transform.screenToWorld(layer, vec2(touch.x, touch.y)))
            end
            
            local opposite = touches[2].y - touches[1].y
            local adjacent = touches[2].x - touches[1].x
            local dist = touches[1]:dist(touches[2])
            local angle = Transform.to360(math.deg(math.asin(opposite / dist)), adjacent)
            
            if not layer.current then
                layer.current = Transform.point()
                
                -- The first touch sets the anchor point from which all transforms are calculated:
                -- Rotate: difference between initial pinch angle
                -- Scale: initial pinch distance is set to scale == 1, subsequent changes in distance
                --     change the scale value
                -- Translate: The difference between the initial position of the first pinch touch
                --     and the updated position of that touch as it moves
                if not layer.current.anchor then
                    layer.current.anchor = Transform.point()
                    
                    layer.current.anchor.pos = touches[1]
                    layer.current.anchor.dist = dist        
                    layer.current.anchor.angle = angle
                end
            end
            
            if Transform.modes.rotate == true then
                layer.current.rotate = -(layer.current.anchor.angle - angle)
            end
            
            if Transform.modes.scale == true then
                layer.current.scale = layer.scale(dist / layer.current.anchor.dist)
            end
            
            if Transform.modes.translate == true then
                layer.current.translate = layer.translate(touches[1] - layer.current.anchor.pos)
            end
        end
    end
    
    table.insert(Touches.subscribers, pinch)
end

function Transform.point()
    return {pos = vec2(WIDTH / 2, HEIGHT / 2), rotate = 0, scale = 1, translate = vec2(0, 0)}
end

function Transform.draw(modes)
    Transform.modes = modes
    totalScale = 1

    for _, layer in ipairs(Layers) do
        for i, point in ipairs(layer.points) do
            if Transform.modes.translate == true then
                translate(point.translate.x, point.translate.y)
            end
                
            translate(point.pos.x, point.pos.y)
                if Transform.modes.rotate == true then
                    rotate(point.rotate)
                end
            
                if Transform.modes.scale == true then
                    scale(point.scale)
                    totalScale = totalScale * point.scale
                end
            translate(-point.pos.x, -point.pos.y)
        end
        
        if layer.current then
            if Transform.modes.translate == true then
                translate(layer.current.translate.x, layer.current.translate.y)
            end
            
            translate(layer.current.anchor.pos.x, layer.current.anchor.pos.y)
                if Transform.modes.rotate == true then
                    rotate(layer.current.rotate)
                end
            
                if Transform.modes.scale == true then
                    scale(layer.current.scale)
                    totalScale = totalScale * layer.current.scale
                end
            translate(-layer.current.anchor.pos.x, -layer.current.anchor.pos.y)
        end

        layer.draw(totalScale, layer.col)
    end
    
    -- Conditionally add/subtract layers
    Layers.addSubtract(totalScale)
end

function Transform.screenToWorld(layer, touch)   
    for _, point in ipairs(layer.points) do
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
