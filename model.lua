require("entity")

love.filesystem.load("lib/tiledmap.lua")()

local blocksLayer
local entitiesLayer

FIELD_EMPTY = 0
FIELD_BLOCK = 1
FIELD_LADDER = 2

function loadLevel(num)
    TiledMap_Load("map/map" .. tostring(num) .. ".tmx", FIELD_SIZE)

    local w = TiledMap_GetMapW()
    local h = TiledMap_GetMapH()

    entitiesLayer = TiledMap_GetLayerZByName("entities")
    blocksLayer = TiledMap_GetLayerZByName("blocks")

    entities = {}
    table.insert(entities, player)
    for x = 0,w - 1 do
        for y = 0, h - 1 do
            local tile = TiledMap_GetMapTile(x, y, entitiesLayer)
            local tileProps = TiledMap_GetTileProps(tile)
            if tileProps and tileProps.name == "player" then
                player.x = x + 0.5
                player.y = y
                player.type = "player"
                if tileProps.direction == "left" then
                    player.dx = -1
                else
                    player.dx = 1
                end
            elseif tileProps and tileProps.name == "monster" then
                local monster = Entity.create("monster")
                monster.x = x + 0.5
                monster.y = y
                monster.vx = 0
                monster.vy = 0
                monster.dy = 0
                monster.maxSpeed = 0.05
                if tileProps.direction == "left" then
                    monster.dx = -1
                else
                    monster.dx = 1
                end
                table.insert(entities, monster)
            end
        end
    end
    TiledMap_SetLayerInvisByName("entities")
end

function getMapRange(x1, y1, x2, y2)
    local fields = {}
    local z = TiledMap_GetLayerZByName("blocks")
    if x2 < x1 then
        aux = x1
        x1 = x2
        x2 = aux
    end
    if y2 < y1 then
        aux = y1
        y1 = y2
        y2 = aux
    end

    x1 = math.max(0, x1)
    y1 = math.max(0, y1)
    x2 = math.min(TiledMap_GetMapW(), x2)
    y2 = math.min(TiledMap_GetMapH(), y2)
    for x=x1,x2 do
        for y=y1,y2 do
            table.insert(fields, TiledMap_GetMapTile(x, y, blocksLayer))
        end
    end
    return fields
end
