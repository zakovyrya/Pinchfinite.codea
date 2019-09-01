-- Test layer
    
function setColors()
    colors = {}
    for i = 1, 121 do
        colors[i] = color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 127)
    end
    
    return colors
end

function dots(totalScale, colors)
    alpha = Layers.getAlpha(totalScale)
    
    col = 1
    for i = 1, 11 do
        for j = 1, 11 do                   
            local x = (WIDTH / 2) - ((6 - i) * 100)
            local y = (HEIGHT / 2) - ((6 - j) * 100)
                
            fill(colors[col].r, colors[col].g, colors[col].b, alpha)
            ellipse(x, y, 50)
                
            col = col + 1
        end
    end
    
    if totalScale > 10 then
        dotLayer = nil
    end
end