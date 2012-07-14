require("model")
require("donut")
require("state")
require("entity")

FIELD_SIZE = 25

currentLevel = 1
paused = false
gravity = {
    x= 0,
    y= 0.4
}
level = nil
player = Entity.create("player")
player.dx=1
player.speed=0.4
player.maxSpeed=0.1
game = {
    state = State.create("running")
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
    sprites.playerDead = love.graphics.newQuad(FIELD_SIZE * 3, 0, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())
    sprites.monsterRight = love.graphics.newQuad(0, FIELD_SIZE, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())
    sprites.monsterLeft = love.graphics.newQuad(FIELD_SIZE, FIELD_SIZE, FIELD_SIZE, FIELD_SIZE, spritesImage:getWidth(), spritesImage:getHeight())
end

function love.load()
    currentLevel = 1
    debug = Donut.init(10, 10)
    fps = debug.add("FPS")
    --random = debug.add("Random")
    
    debug_currentTile = debug.add("Current tile")
    

    loadSprites()

	debug_player_x = debug.add("Player.x")
	debug_player_y = debug.add("Player.y")
	debug_player_vx = debug.add("Player.vx")
	debug_player_vy = debug.add("Player.vy")
	debug_player_state = debug.add("Player.state")
    debug_game_state = debug.add("Game.state")
	debug_keypressed = debug.add("keypressed")
	debug_sometext = debug.add("debugsometext")
    start()
end

function start()
    loadLevel(currentLevel)
    z = TiledMap_GetLayerZByName("blocks")
    game.state:setState("running")
end

function getBoundingBox(entity)
    -- entity coords always based on feet
    return {
        x1 = entity.x - 0.4,
        y1 = entity.y + 0.1,
        x2 = entity.x + 0.4,
        y2 = entity.y + 1.0
    }
end

function checkRectCollision(rect1, rect2)
    left1 = rect1.x1
    left2 = rect2.x1
    top1 = rect1.y1
    top2 = rect2.y1
    right1 = rect1.x2
    right2 = rect2.x2
    bottom1 = rect1.y2
    bottom2 = rect2.y2
    if bottom1 <= top2 then
        return false
    end
    if top1 >= bottom2 then
        return false
    end
    if right1 <= left2 then
        return false
    end
    if left1 >= right2 then
        return false
    end
    return true
end

function updateEntity(entity, dt)
    local dirX = 0
    local dirY = 0

    entity.state:step(dt)

    if entity.state.name == "dead" then
        return
    end
    
    -- gravity
    if entity.state.name ~= "climb" then
        entity.vy = entity.vy + gravity.y * dt
    end

    if entity.vx ~= 0 then
        dirX = entity.vx / math.abs(entity.vx)
    end
    if entity.vy ~= 0 then
        dirY = entity.vy / math.abs(entity.vy)
    end
    if math.abs(entity.vx) > entity.maxSpeed then
        entity.vx = entity.maxSpeed * dirX
    end

    target = {
        x = entity.x + entity.vx,
        y = entity.y + entity.vy
    }

    -- collision detection
    if dirX ~= 0 then
        local bb = getBoundingBox(entity)
        local mapX = math.floor(target.x) + dirX
        bb.x1 = bb.x1 + entity.vx
        bb.x2 = bb.x2 + entity.vx

        local mapY1 = math.floor(bb.y1) - 1
        local mapY2 = math.floor(bb.y2) + 1
        
        local tiles = getMapRange(mapX, mapY1, mapX, mapY2)
        local hasCollision = false
        for i,tile in ipairs(tiles) do
            local tileProps = TiledMap_GetTileProps(tile)
            if tileProps and tileProps.type == "wall" then
                local wallBB = {
                    x1 = mapX,
                    y1 = mapY1 + i - 1,
                    x2 = mapX + 1,
                    y2 = mapY1 + i
                }
                if checkRectCollision(bb, wallBB) then
                    hasCollision = true
                    break
                end
            end
        end

        if hasCollision then
            --target.x = entity.x
            if dirX > 0 then
                target.x = math.floor(mapX) - 0.5
            else
                target.x = math.floor(mapX) + 1.5
            end
            entity.vx = 0
        end
    end

    if dirY ~= 0 then
        local bb = getBoundingBox(entity)
        local mapY = math.floor(target.y) + dirY
        bb.y1 = bb.y1 + entity.vy
        bb.y2 = bb.y2 + entity.vy

        local mapX1 = math.floor(bb.x1) - 1
        local mapX2 = math.floor(bb.x2) + 1

        local tiles = getMapRange(mapX1, mapY, mapX2, mapY)
        local hasCollision = false
        for i,tile in ipairs(tiles) do
            local tileProps = TiledMap_GetTileProps(tile)
            if tileProps and tileProps.type == "wall" then
                local wallBB = {
                    x1 = mapX1 + i - 1,
                    y1 = mapY,
                    x2 = mapX1 + i,
                    y2 = mapY
                }
                if checkRectCollision(bb, wallBB) then
                    hasCollision = true
                    break
                end
            end
        end

        if hasCollision then
            target.y = entity.y
             --if dirY > 0 then
--                 target.y = math.floor(mapY) - 0.5
--             else
--                 target.y = math.floor(mapY) + 1.5
--             end
            entity.vy = 0
        end
    end

    entity.x = target.x
    entity.y = target.y
end

function updatePlayer(player, dt)
    updateEntity(player, dt)
    if player.state.name ~= "dead" then
        local bb = getBoundingBox(player)
        -- check collision with monsters
        for i, entity in ipairs(entities) do
            if entity.type == "monster" then
                local bb2 = getBoundingBox(entity)
                if checkRectCollision(bb, bb2) then
                    player.state:setState("dead", 2, "stand")
                    game.state:setState("dead", 2, "restart")
                    break
                end
            end
        end
    end
    
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
    if paused then
        return
    end

    if game.state.name == "restart" then
        start()
    end
    game.state:step(dt)
    
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


    if player.state.name ~= "dead" then
        if love.keyboard.isDown("up") then
            --debug.update(debug_sometext, "step1")
            currentTile = TiledMap_GetMapTile(math.floor(player.x), math.floor(player.y), z)
            currentTileProps = TiledMap_GetTileProps(currentTile) or {};
            currentTileType = currentTileProps.type or currentTile
            debug.update(debug_sometext, currentTileType)
            if currentTileType == "ladder" then
                --debug.update(debug_sometext, "step2")
                player.vy = -0.07
                player.state:setState("climb")
    --        else
                --player.vy = 0
        --       player.state = "stand"
            end
        end
    else
        moveX = 0
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
            updatePlayer(entity, dt)
        end
        if entity.type == "monster" then
            updateMonster(entity, dt)
        end
    end

    if player.state.name ~= "dead" then
        cam.x = player.x * FIELD_SIZE
        cam.y = player.y * FIELD_SIZE
    end

    
	debug.update(fps, love.timer.getFPS())

    tile = TiledMap_GetMapTile(math.floor(player.x), math.floor(player.y), z)
    tileProps = TiledMap_GetTileProps(tile) or {};
    tileType = tileProps.type or tile
    debug.update(debug_currentTile, tileType)
	debug.update(debug_player_x, player.x)
	debug.update(debug_player_y, player.y)
	debug.update(debug_player_vx, player.vx)
	debug.update(debug_player_vy, player.vy)
    debug.update(debug_player_state,player.state.name .. " (" .. player.state:getProgress() .. " )")
    debug.update(debug_game_state,game.state.name .. " (" .. game.state:getProgress() .. " )")
end

function love.keypressed(key, unicode)
	if key == "s" then -- show/hide with "s"
		debug.toggle()
	end
	debug.update(debug_keypressed, key)
    if key == "p" then -- show/hide with "s"
        paused = not paused
    end

end

function love.keyreleased( key, unicode )
	if key == "up" and player.state ~= "dead" then
		player.vy = 0
		player.state:setState("stand")
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
        local offsetX = mapOffsetX + entity.x * FIELD_SIZE
        local offsetY = mapOffsetY + (entity.y + 0.5) * FIELD_SIZE
        local sprite = nil
        local angle = nil
        local scale = nil
        if entity.type == "player" then
            if player.state.name == "climb" then
                sprite = sprites.playerUp
            elseif player.state.name == "dead" then
                sprite = sprites.playerDead
                angle = math.pi * 4.0 * entity.state:getProgress()
                scale = 1.0 + math.sin(angle * 2.0)
            elseif player.dx < 0 then
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
        love.graphics.drawq(spritesImage, sprite, offsetX, offsetY, angle, scale, scale, 12.5, 12.5)
    end

    -- debug
	debug.draw()
end
