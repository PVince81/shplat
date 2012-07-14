love.filesystem.load("lib/tiledmap.lua")()

FIELD_EMPTY = 0
FIELD_BLOCK = 1
FIELD_LADDER = 2

function loadLevel(num)
    TiledMap_Load("map/map" .. tostring(num) .. ".tmx", FIELD_SIZE)

    local w = TiledMap_GetMapW()
    local h = TiledMap_GetMapH()

    local z = TiledMap_GetLayerZByName("entities")
    for x = 0,w - 1 do
        for y = 0, h - 1 do
            tile = TiledMap_GetMapTile(x, y, z)
            if tile ~= 0 then
                print(tile, x, y)
            end
            tileProps = TiledMap_GetTileProps(tile)
            if tileProps and tileProps.name == "player" then
                player.x = x
                player.y = y
                if tileProps.direction == "left" then
                    player.dx = -1
                else
                    player.dx = 1
                end
            end
        end
    end
    TiledMap_SetLayerInvisByName("entities")
    
end
