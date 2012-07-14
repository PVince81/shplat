require "model"
require("donut")

FIELD_SIZE = 25

gravity = {
    x= 0,
    y= 0.004
}
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
entities = {}
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
    sprites.monsterRight = love.graphics.newQuad(0, FIELD_SIZE, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())
    sprites.monsterLeft = love.graphics.newQuad(FIELD_SIZE, FIELD_SIZE, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())
end

function love.load()
    debug = Donut.init(10, 10)
    fps = debug.add("FPS")
    --random = debug.add("Random")
    
    debug_currentTile = debug.add("Current tile")
    

    loadSprites()

    loadLevel(1)
    
    z = TiledMap_GetLayerZByName("blocks")
	debug_player_x = debug.add("Player.x")
	debug_player_y = debug.add("Player.y")
	debug_player_vx = debug.add("Player.vx")
	debug_player_vy = debug.add("Player.vy")
	debug_player_state = debug.add("Player.state")
	debug_keypressed = debug.add("keypressed")
	debug_sometext = debug.add("debugsometext")
end

function updateEntity(entity, dt)

    -- gravity
    if entity.state ~= "climb" then
        entity.vy = entity.vy + gravity.y
    end

   
    local dirX = entity.vx / math.abs(entity.vx)
    local dirY = entity.vy / math.abs(entity.vy)
    if math.abs(entity.vx) > entity.maxSpeed then
        entity.vx = entity.maxSpeed * dirX
    end

    target = {
        x = entity.x + entity.vx,
        y = entity.y + entity.vy
    }

    -- TODO: add collision detection
    targetTileX = TiledMap_GetMapTile(math.floor(target.x + dirX * 0.5), math.floor(target.y), z)
    targetTileY = TiledMap_GetMapTile(math.floor(target.x), math.floor(target.y + dirY), z)
    targetTilePropsX = TiledMap_GetTileProps(targetTileX) or {};
    targetTilePropsY = TiledMap_GetTileProps(targetTileY) or {};
    if targetTilePropsX.type == "wall" then
        target.x = entity.x
        entity.vx = 0
    end
    if targetTilePropsY.type == "wall" then
        target.y = entity.y
        entity.vy = 0
    end

    entity.x = target.x
    entity.y = target.y
end

function updateMonster(entity, dt)
    local dirX = entity.dx
    entity.vx = dirX * entity.maxSpeed
    updateEntity(entity, dt)
    -- couldn't move ?
    if ( entity.vx == 0 ) then
        -- change direction
        entity.dx = -entity.dx
    end
end

function love.update(dt)
    if dt < 1/60 then
      love.timer.sleep((1/60 - dt))
    end
    
    local moveX = 0
    local dirX = 0
    local dirY = 0
    if love.keyboard.isDown("right") then
        moveX = 1
        player.dx = 1
    elseif love.keyboard.isDown("left") then
        moveX = -1
        player.dx = -1
    end

	
	if love.keyboard.isDown("up") then
        --debug.update(debug_sometext, "step1")
		currentTile = TiledMap_GetMapTile(math.floor(player.x), math.floor(player.y), z)
        currentTileProps = TiledMap_GetTileProps(currentTile) or {};
		currentTileType = currentTileProps.type or currentTile
		debug.update(debug_sometext, currentTileType)
        if currentTileType == "ladder" then
            --debug.update(debug_sometext, "step2")
			player.vy = -0.07
            player.state = "climb"
--        else
            --player.vy = 0
     --       player.state = "stand"
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

    for i, entity in ipairs(entities) do
        if entity.type == "player" then
            updateEntity(entity, dt)
        end
        if entity.type == "monster" then
            updateMonster(entity, dt)
        end
    end

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
	debug.update(debug_player_state,player.state)
end

function love.keypressed(key, unicode)
	if key == "s" then -- show/hide with "s"
		debug.toggle()
	end
	debug.update(debug_keypressed, key)

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
    local mapOffsetX = love.graphics.getWidth() / 2 - cam.x
    local mapOffsetY = love.graphics.getHeight() / 2 - cam.y

    for i, entity in ipairs(entities) do
        local offsetX = mapOffsetX + (entity.x - 0.5) * FIELD_SIZE
        local offsetY = mapOffsetY + entity.y  * FIELD_SIZE
        local sprite = nil
        if entity.type == "player" then
            if player.dx < 0 then
                sprite = sprites.playerLeft
            else
                sprite = sprites.playerRight
            end
        elseif entity.type == "monster" then
            if entity.dx < 0 then
                sprite = sprites.monsterLeft
            else
                sprite = sprites.monsterRight
            end
        end
        love.graphics.drawq(spritesImage, sprite, offsetX, offsetY)
    end

    -- debug
	debug.draw()
end
