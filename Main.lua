-- zoom

function setup()
    displayMode(FULLSCREEN_NO_BUTTONS)
end

function draw()
    Draw.update()
end

function touched(touch)
    Touches.register(touch)
end
