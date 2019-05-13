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
    
    dotText()
end

function dotText()
    local rotations = {0, 90, 180, 270}
    local wordTable = {"Rotate", "Scale", "Translate", "Oh my!", "How to\nImplement", "Zoom"}
    textAlign(CENTER)
    font("AmericanTypewriter-Bold")
    fontSize(16)

    if #words == 0 then
        for n = 1, #wordTable do
            local rotation = math.random(1, 4)
            
            local i, j = math.random(1, 5), math.random(1, 5)
            local x = (WIDTH / 2) - ((3 - i) * 200)
            local y = (HEIGHT / 2) - ((3 - j) * 200)

            table.insert(words, {rotations[rotation], x, y})
        end
    end
  
    for n = 1, #wordTable do
        local rotation = words[n][1]
        local x = words[n][2]
        local y = words[n][3]

        translate(x, y)
        rotate(rotation)         
        fill(0, 0, 0, 255)
        text(wordTable[n], 0, 0)
        rotate(-rotation)
        translate(-x, -y)
    end
end

table.insert(Draw.queue, dots)