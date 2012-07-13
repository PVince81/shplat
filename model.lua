FIELD_EMPTY = 0
FIELD_BLOCK = 1
FIELD_LADDER = 2


function loadLevel(num)
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