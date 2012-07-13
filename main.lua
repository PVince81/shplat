require "model"

FIELD_SIZE = 20
MOMENTUM = 1

function love.conf(t)
    t.screen.width = 800
    t.screen.height = 600
end

function love.load()
    level = loadLevel(0)
    player = createPlayer()

    player.x = level.playerStartX
    player.y = level.playerStartY
end

function love.update(dt)
   if love.keyboard.isDown("right") then
      MOMENTUM = MOMENTUM + 0.5 * dt
	  player.x = player.x + MOMENTUM * dt
   end
end

function love.keyreleased( key, unicode )
   MOMENTUM = 1
end

function love.draw()
    love.graphics.setColor(255, 255, 255, 255)

    -- render map
    offsetY = 0
    for y=0,level.height do
        row = level.fields[y]
        offsetX = 0
        for x=0,level.width do
            field = row[x]
            if field == FIELD_BLOCK then
                love.graphics.rectangle("fill", offsetX, offsetY, FIELD_SIZE, FIELD_SIZE)
            end
            offsetX = offsetX + FIELD_SIZE
        end
        offsetY = offsetY + FIELD_SIZE
    end

    love.graphics.setColor(128, 0, 0, 255)
    -- render player
    love.graphics.circle("fill", (player.x  - 0.5) * FIELD_SIZE, (player.y - 0.5) * FIELD_SIZE, FIELD_SIZE / 2.0)
	
	-- debug
	love.graphics.print(MOMENTUM, 20, 20)
end