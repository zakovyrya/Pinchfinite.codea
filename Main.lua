-- zoom

function setup()
    displayMode(OVERLAY)
    parameter.number("s", 0, 2, 1)
    parameter.number("r", -360, 360, 0)
    parameter.integer("x", -500, 500, 0, function() Zoom.translation = vec2(x, Zoom.translation.y) end)
    parameter.integer("y", -500, 500, 0, function() Zoom.translation = vec2(Zoom.translation.x, y) end)
    
    colors = {}
end

function draw()
    background(40, 40, 50)
    
    Zoom.draw()
    
    -- Draw touch 
    for i, point in ipairs(Zoom.transformPoints) do
        fill(colors[i])
        ellipse(point.world.x, point.world.y, 50)
    end
    
    -- Moving touch (already transformed from screen to world), before being stored
    if moving then
        fill(colors[#colors])
        ellipse(moving.x, moving.y, 50)
    end
end

function touched(touch)
    local t = vec2(touch.x, touch.y)
    
    t = Zoom.screenToWorld(t)
    
    if touch.state == BEGAN or touch.state == MOVING then        
        moving = t
        if col == nil then
            table.insert(colors, color(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
            col = true
        end
    elseif touch.state == ENDED then
        TransformPoint(r, s, t)
        
        moving = nil
        col = nil
    end
end
