require "model"
require("donut")

FIELD_SIZE = 25

level = nil
player = {
            -- position
            x=0,
            y=0,
            -- movement vector
            vx=0,
            vy=0,
            -- direction
            dx=1,
            -- speed
            speed=0.2,
            -- max speed
            maxSpeed=0.1
        }
cam = {x=0, y=0}
sprites = nil

function love.conf(t)
    t.screen.width = 800
    t.screen.height = 600
    t.screen.vsync = true
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
    player.x = 2
    player.y = 11.5
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
	
	debug = Donut.init(10, 10)
	fps = debug.add("FPS")
	random = debug.add("Random")
end

function love.update(dt)
    moveX = 0
    if love.keyboard.isDown("right") then
        moveX = 1
        player.dx = 1
    elseif love.keyboard.isDown("left") then
        moveX = -1
        player.dx = -1
    end

    if moveX ~= 0 then
        player.vx = player.vx + moveX * player.speed * dt
        if math.abs(player.vx) > player.maxSpeed then
            player.vx = player.maxSpeed * player.vx / math.abs(player.vx)
        end
    else
        -- deccelerate
        player.vx = player.vx * 0.9
    end
    if math.abs(player.vx) < 0.001 then
        player.vx = 0
    end

    target = {
        x = player.x + player.vx,
        y = player.y + player.vy
    }

    -- TODO: add collision detection    
    targetTile = TiledMap_GetMapTile(math.floor(target.x), math.floor(target.y), 1)
    if targetTile == 1 then
        target.x = player.x
        target.y = player.y
    end
    
    
    player.x = target.x
    player.y = target.y

    cam.x = player.x * FIELD_SIZE
    cam.y = player.y * FIELD_SIZE  

	debug.update(fps, love.timer.getFPS())
	debug.update(random, math.random(0, 100))	
end

function love.keypressed(key, unicode)
	if key == "s" then -- show/hide with "s"
		debug.toggle()
	end
end

function love.keyreleased( key, unicode )
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
    
    if player.dx < 0 then
        playerSprite = sprites.playerLeft
    else
        playerSprite = sprites.playerRight
    end

    offsetX = mapOffsetX + (player.x - 0.5) * FIELD_SIZE
    offsetY = mapOffsetY + player.y  * FIELD_SIZE -- - FIELD_SIZE
    love.graphics.drawq(spritesImage, playerSprite, offsetX, offsetY)

    -- debug
    tile = TiledMap_GetMapTile(math.floor(player.x), math.floor(player.y), 1)
    
    love.graphics.print(tile, 0, love.graphics.getHeight() - 20)
	debug.draw()
end
