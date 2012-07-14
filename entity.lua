require("state")

Entity = {}
Entity.__index = Entity

function Entity.create(type)
    local entity = {}
    setmetatable(entity, Entity)

    entity.x = 0
    entity.y = 0
    entity.vx = 0
    entity.vy = 0
    entity.dx = 1
    entity.dy = 0    
    entity.type = type
    entity.state = State.create("stand")
    return entity
end
