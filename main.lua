require "model"

FIELD_SIZE = 25

level = nil
player = {x=0, y=0}
cam = {x=0, y=0}
sprites = nil
MOMENTUM = 0

function love.conf(t)
    t.screen.width = 800
    t.screen.height = 600
end

function loadSprites()
    sprites = {}
    spritesImage = love.graphics.newImage("sprites.png")
    sprites.block = love.graphics.newQuad(0, 0, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())
    sprites.ladder = love.graphics.newQuad(FIELD_SIZE, 0, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())

    sprites.playerRight = love.graphics.newQuad(0, FIELD_SIZE, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())
    sprites.playerLeft = love.graphics.newQuad(FIELD_SIZE, FIELD_SIZE, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())
end

function love.load()

    TiledMap_Load("map/map1.tmx", FIELD_SIZE)
    player.x = 1
    player.y = 12
    cam.x = player.x * FIELD_SIZE
    cam.y = player.y * FIELD_SIZE
    -- TODO: use sprites from tiled map?
    loadSprites()

--    level = loadLevel(1)
    --saveLevel(1, level)
    
    --level = loadLevelOld(1)
--    player = createPlayer()

    --player.x = level.playerStartX
    --player.y = level.playerStartY
end

function love.update(dt)
   if love.keyboard.isDown("right") then
      MOMENTUM = MOMENTUM + 0.5 * dt
      player.x = player.x + MOMENTUM * dt
      cam.x = cam.x + MOMENTUM * dt * FIELD_SIZE
   end
end

function love.keyreleased( key, unicode )
   MOMENTUM = 1
end

function love.draw()
    love.graphics.setColor(255, 255, 255, 255)

    TiledMap_DrawNearCam(cam.x,cam.y)

    -- render map
--     offsetY = 0
--     for y=0,level.height do
--         row = level.fields[y]
--         offsetX = 0
--         for x=0,level.width do
--             field = row[x]
--             if field == FIELD_BLOCK then
--                 love.graphics.drawq(spritesImage, sprites.block, offsetX, offsetY)
--             elseif field == FIELD_LADDER then
--                 love.graphics.drawq(spritesImage, sprites.ladder, offsetX, offsetY)
--             end
--             offsetX = offsetX + FIELD_SIZE
--         end
--         offsetY = offsetY + FIELD_SIZE
--     end
-- 
    -- render player    
    mapOffsetX = love.graphics.getWidth() / 2 - cam.x
    mapOffsetY = love.graphics.getHeight() / 2 - cam.y
    
    if MOMENTUM < 0 then
        playerSprite = sprites.playerLeft
    else
        playerSprite = sprites.playerRight
    end

    offsetX = mapOffsetX + (player.x  - 0.5) * FIELD_SIZE
    offsetY = mapOffsetY + player.y  * FIELD_SIZE - FIELD_SIZE
    love.graphics.drawq(spritesImage, playerSprite, offsetX, offsetY)
end
