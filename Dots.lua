local colors = {}
for i = 1, 25 do
    colors[i] = color(math.random(0, 255), math.random(0, 255), math.random(0, 255))
end

local words = {}

function dots()
    col = 1
    for i = 1, 5 do
        for j = 1, 5 do                   
            local x = (WIDTH / 2) - ((3 - i) * 200)
            local y = (HEIGHT / 2) - ((3 - j) * 200)
                
            fill(colors[col])
            ellipse(x, y, 100)
                
            col = col + 1
        end
    end
end

table.insert(Draw.queue, dots)