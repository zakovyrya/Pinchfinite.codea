-- zoom

function setup()
    displayMode(OVERLAY)
    parameter.number("s", 0, 2, 1)
    parameter.number("r", -360, 360, 90)
    parameter.integer("x", -500, 500, 0)
    parameter.integer("y", -500, 500, 0)
    
    scales = {}
    rotations = {}
    touches = {}
    col = nil
end

function draw()
    background(40, 40, 50)
    totalScale = 1
    totalTrans = vec2(0, 0)
    totalRotation = 0
    
    -- Current translation
    translate(x, y)
    
    for i, touch in ipairs(touches) do
        -- Apply all zooms
        translate(touch[2].x, touch[2].y)
        scale(scales[i])
        rotate(rotations[i])
        translate(-touch[2].x, -touch[2].y)
        
        -- Calculate total scaling and translation
        totalScale = totalScale * scales[i]
        totalTrans.x = totalTrans.x + touch[2].x
        totalTrans.y = totalTrans.y + touch[2].y
        totalRotation = totalRotation + rotations[i]
    end
    
    -- Calculate average translation
    if #touches > 0 then
        totalTrans.x = totalTrans.x / #touches
        totalTrans.y = totalTrans.y / #touches
    end
    
    -- Draw touch 
    for i, touch in ipairs(touches) do
        fill(touch[1] or 255)
        ellipse(touch[2].x, touch[2].y, 50)
    end
    
    -- Moving touch (already transformed from screen to world), before being stored
    if moving then
        fill(col)
        ellipse(moving.x, moving.y, 50)
    end
end

function touched(touch)
    local t = vec2(touch.x, touch.y)
    
    -- Reposition new touch based on current translate values (...that have been scaled)
    t.x = t.x - x
    t.y = t.y - y

    for i, touch in ipairs(touches) do
        -- Reposition new touch based on all previous rotations
        local radius = vec2(touch[2].x - t.x, touch[2].y - t.y)

        t.x = touch[2].x - ((math.cos(math.rad(rotations[i])) * radius.x) + (math.sin(math.rad(rotations[i])) * radius.y))
        t.y = touch[2].y - ((math.cos(math.rad(rotations[i])) * radius.y) - (math.sin(math.rad(rotations[i])) * radius.x))
        
        -- Reposition new touch based on all previous zooms (+translate, scale -translate)    
        t.x = (touch[2].x) + ((t.x - touch[2].x) / scales[i])
        t.y = (touch[2].y) + ((t.y - touch[2].y) / scales[i])
    end
    
    if touch.state == BEGAN or touch.state == MOVING then        
        moving = vec2(t.x, t.y)
        
        if col == nil then
            col = color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        end
    elseif touch.state == ENDED then
        table.insert(touches, {col, vec2(t.x, t.y)})        
        table.insert(scales, s)
        table.insert(rotations, r)
        
        moving = nil
        col = nil
    end
end
