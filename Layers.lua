Layers = {}

-- New layer constructor
function Layers.new(p)
    -- Default starting point, or pass in a custom point
    local point = p or Transform.point()
    
    return {points = {point}, current = nil, scale = function(v) return v end,
        translate = function(v) return v end, draw = dots, col = setColors()}
end

function Layers.addSubtract(totalScale)
    -- Add layer
    if totalScale > 2 and #Layers <= 2 then
        table.insert(Layers, 1, Layers.new())
    end
    
    -- Remove layer
    if totalScale > 10 and #Layers > 1 then
        table.remove(Layers, #Layers)
    end
end

function Layers.getAlpha(totalScale)        
    if totalScale < 1.05 then
        return 0
    elseif totalScale < 3 then        
        return 255 * ((1.95 - (3 - totalScale)) / 1.95)
    elseif totalScale < 7 then     
        return 255
    elseif totalScale < 10 then
        return 255 * ((3 - (totalScale - 7)) / 3)
    else
        return 0
    end
end