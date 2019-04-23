-- zoom

function setup()
    displayMode(OVERLAY)
    parameter.number("s", 0, 2, 0.8)
    parameter.integer("x", -500, 500, 0)
    parameter.integer("y", -500, 500, 0)
    parameter.watch("totalScale")
    parameter.watch("totalTrans")
    
    scales = {}
    touches = {}
    col = nil
end

function draw()
    background(40, 40, 50)
    totalScale = 1
    totalTrans = vec2(0, 0)
    
    translate(x, y)
    
    for i, touch in ipairs(touches) do
        translate(touch[2].x, touch[2].y)
        scale(scales[i])
        translate(-touch[2].x, -touch[2].y)
        
        totalScale = totalScale * scales[i]
        totalTrans.x = totalTrans.x + touch[2].x
        totalTrans.y = totalTrans.y + touch[2].y
    end
    
    if #touches > 0 then
        totalTrans.x = totalTrans.x / #touches
        totalTrans.y = totalTrans.y / #touches
    end
    
    for i, touch in ipairs(touches) do
        fill(touch[1] or 255)
        ellipse(touch[2].x, touch[2].y, 50)
    end
    
    fill(107, 59, 134, 255)
    ellipse(WIDTH / 2, HEIGHT / 2, 50)
    
    if moving then
        fill(col)
        ellipse(moving.x, moving.y, 50)
    end
end

function touched(touch)
    local t = vec2(touch.x, touch.y)       
    for i, touch in ipairs(touches) do
        t.x = (touch[2].x) + ((t.x - touch[2].x) / scales[i])
        t.y = (touch[2].y) + ((t.y - touch[2].y) / scales[i])
    end
    
    t.x = t.x - (x / totalScale)
    t.y = t.y - (y / totalScale)
    
    if touch.state == MOVING then        
        moving = vec2(t.x, t.y)
        
        if col == nil then
            col = color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        end
    elseif touch.state == ENDED then
        table.insert(touches, {col, vec2(t.x, t.y)})        
        table.insert(scales, s)
        
        moving = nil
        col = nil
    end
end
