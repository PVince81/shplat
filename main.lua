require "model"

FIELD_SIZE = 25

level = nil
player = nil
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
end

function love.load()
    loadSprites()
    
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
                love.graphics.drawq(spritesImage, sprites.block, offsetX, offsetY)
            elseif field == FIELD_LADDER then
                love.graphics.drawq(spritesImage, sprites.ladder, offsetX, offsetY)
            end
            offsetX = offsetX + FIELD_SIZE
        end
        offsetY = offsetY + FIELD_SIZE
    end

    -- render player
    love.graphics.setColor(128, 0, 0, 255)
    love.graphics.circle("fill", (player.x  - 0.5) * FIELD_SIZE, (player.y - 0.5) * FIELD_SIZE,
            FIELD_SIZE / 2.0)
    love.graphics.setColor(96, 0, 0, 255)
    love.graphics.circle("line", (player.x  - 0.5) * FIELD_SIZE, (player.y - 0.5) * FIELD_SIZE,
            FIELD_SIZE / 2.0)
end
