-- Pinchfinite
displayMode(STANDARD)

function setup()
    --Initial layer
    local point = Transform.point()
    point.scale = 1.75
    table.insert(Layers, Layers.new(point))
end

function draw()
    Draw.update()
end

function touched(touch)
    Touches.register(touch)
end
