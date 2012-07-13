FIELD_EMPTY = 0
FIELD_BLOCK = 1
FIELD_LADDER = 2


function loadLevel(num)
    level = {}

    width = 50
    height = 50

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
        fields[height-3][x] = FIELD_BLOCK
    end

    fields[height-1][width - 1] = FIELD_LADDER
    fields[height-2][width - 1] = FIELD_LADDER
    fields[height-3][width - 1] = FIELD_LADDER

    
    level["width"] = width
    level["height"] = height
    level["fields"] = fields
    return level
end
