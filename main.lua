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
            dy=0,
            -- speed
            speed=0.4,
            -- max speed
            maxSpeed=0.1,
			-- state
			state="stand"
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
    spritesImage = love.graphics.newImage("entities.png")
    sprites.playerRight = love.graphics.newQuad(0, 0, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())
    sprites.playerLeft = love.graphics.newQuad(FIELD_SIZE, 0, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())
    sprites.playerUp = love.graphics.newQuad(FIELD_SIZE * 2, 0, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())
end

function love.load()
    debug = Donut.init(10, 10)
    fps = debug.add("FPS")
    --random = debug.add("Random")
    debug_playerPos = debug.add("Player pos")
    debug_currentTile = debug.add("Current tile")
    

    loadSprites()

    loadLevel(1)
    z = TiledMap_GetLayerZByName("blocks")
	debug_player_x = debug.add("Player.x")
	debug_player_y = debug.add("Player.y")
	debug_player_vx = debug.add("Player.vx")
	debug_player_vy = debug.add("Player.vy")
	
	
end

function love.update(dt)
    if dt < 1/60 then
      love.timer.sleep((1/60 - dt))
    end
    
    moveX = 0
    dirX = 0
    dirY = 0
    if love.keyboard.isDown("right") then
        moveX = 1
        player.dx = 1
    elseif love.keyboard.isDown("left") then
        moveX = -1
        player.dx = -1
    end

	if love.keyboard.isDown("up") then

    currentTile = TiledMap_GetMapTile(math.floor(player.x + 0.5), math.floor(player.y + 0.5), z)
    targetTileProps = TiledMap_GetTileProps(targetTile) or {};
    if targetTileProps.type == "ladder" then
        player.vy = -0.07
		player.state = "climbe"
    else
		player.vy = 0
		player.state = "stand"
	end	
	
	
	
	end
	
    if moveX ~= 0 then
        player.vx = player.vx + moveX * player.speed * dt
    else
        -- deccelerate
        player.vx = player.vx * 0.9
    end
    if math.abs(player.vx) < 0.001 then
        player.vx = 0
    end

    dirX = player.vx / math.abs(player.vx)
    if math.abs(player.vx) > player.maxSpeed then
        player.vx = player.maxSpeed * dirX
    end
    
    target = {
        x = player.x + player.vx,
        y = player.y + player.vy
    }

    -- TODO: add collision detection
    targetTile = TiledMap_GetMapTile(math.floor(target.x + dirX * 0.5), math.floor(target.y + dirY * 0.5), z)
    targetTileProps = TiledMap_GetTileProps(targetTile) or {};
    if targetTileProps.type == "wall" then
        target.x = player.x
        target.y = player.y
    end

    player.x = target.x
    player.y = target.y

    debug.update(debug_playerPos, player.x .. " " .. player.y)
    
    cam.x = player.x * FIELD_SIZE
    cam.y = player.y * FIELD_SIZE  

	debug.update(fps, love.timer.getFPS())

    tile = TiledMap_GetMapTile(math.floor(player.x), math.floor(player.y), z)
    tileProps = TiledMap_GetTileProps(tile) or {};
    tileType = tileProps.type or tile
    debug.update(debug_currentTile, tileType)
	debug.update(debug_player_x, player.x)
	debug.update(debug_player_y, player.y)
	debug.update(debug_player_vx, player.vx)
	debug.update(debug_player_vy, player.vy)
end

function love.keypressed(key, unicode)
	if key == "s" then -- show/hide with "s"
		debug.toggle()
	end

end

function love.keyreleased( key, unicode )
	if key == "up" then
		player.vy = 0
		player.state="stand"
	end
end

function love.draw()
    love.graphics.setColor(255, 255, 255, 255)

    -- render map
    TiledMap_DrawNearCam(cam.x,cam.y)

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
	debug.draw()
end
