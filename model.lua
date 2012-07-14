love.filesystem.load("lib/tiledmap.lua")()

FIELD_EMPTY = 0
FIELD_BLOCK = 1
FIELD_LADDER = 2


function loadLevel(num)
    local filename = "level" .. num .. ".dat"
    local data = love.filesystem.lines( filename )
    print(data[0])
    for line in data do
        print(line)
    end
    --width = result[0]
    --height = result[1]
    --for i=2, # result do
        --row = result[i]
    --end
    --print(width, height)
    
end

function saveLevel(num, level)
    local filename = "level" .. tostring(num) .. ".dat"

    str = ""

    str = str .. tostring(level.width) .. "\n"
    str = str .. tostring(level.height) .. "\n"
    
    for y=0,height do
        row = level.fields[y]
        for x=0,width do
            field = row[x]
            c = "_"
            if field == FIELD_BLOCK then
                c = "X"
            elseif field == FIELD_LADDER then
                c = "#"
            end
            str = str .. c
        end
        str = str .. "\n"
    end
        
    --love.filesystem.save( filename )
    print(str)
end

function loadLevelOld(num)
    level = {}

    width = 20
    height = 20

    fields = {}
    for y=0,height do
        row = {}
        for x=0,width do
            row[x] = FIELD_EMPTY
        end
        fields[y] = row
    end

    for x=0,width do
        fields[height-1][x] = FIELD_BLOCK
        fields[height-4][x] = FIELD_BLOCK
    end

    fields[height-2][width - 1] = FIELD_LADDER
    fields[height-3][width - 1] = FIELD_LADDER
    fields[height-4][width - 1] = FIELD_LADDER
    fields[height-5][width - 1] = FIELD_LADDER

    
    level.width = width
    level.height = height
    level.fields = fields
    level.playerStartX = 1
    level.playerStartY = height - 1
    return level
end

function createPlayer()
    player = {}
    player.x = 0
    player.y = 0
    return player
end
