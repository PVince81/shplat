love.filesystem.load("lib/tiledmap.lua")()

FIELD_EMPTY = 0
FIELD_BLOCK = 1
FIELD_LADDER = 2

function loadLevel(num)
    TiledMap_Load("map/map" .. tostring(num) .. ".tmx", FIELD_SIZE)

    local w = TiledMap_GetMapW()
    local h = TiledMap_GetMapH()

    local z = TiledMap_GetLayerZByName("entities")


    entities = {}
    table.insert(entities, player)
    for x = 0,w - 1 do
        for y = 0, h - 1 do
            tile = TiledMap_GetMapTile(x, y, z)
            tileProps = TiledMap_GetTileProps(tile)
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
                monster = {
                    x = x + 0.5,
                    y = y,
                    type = "monster"
                }
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
