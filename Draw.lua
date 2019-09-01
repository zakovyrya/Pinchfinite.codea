Draw = {}

Draw.background = color(47, 47, 47, 255)
Draw.queue = {}

function Draw.update()
    background(Draw.background)
    
    Transform.draw({rotate = true, scale = true, translate = true})
end
