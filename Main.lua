-- zoom

function setup()
    displayMode(STANDARD)
end

function draw()
    Draw.update()
end

function touched(touch)   
    Touches.register(touch)
end
