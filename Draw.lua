Draw = {}

Draw.queue = {}

function Draw.update()
    background(47, 47, 47, 255)
    
    Transform.draw()
    
    for _, queued in ipairs(Draw.queue) do
        queued()
    end
end
