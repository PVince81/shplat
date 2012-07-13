require "model"

FIELD_SIZE = 20

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
      player.x = player.x + 1 * dt -- this would increment num by 100 per second
   end
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
end