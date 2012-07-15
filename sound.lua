function playSound(sound)
    channel = love.audio.newSource(sound)
    channel:play()
    
end

function loadSounds()
    local path = "snd/"
    sounds = {}
    sounds.jump = love.sound.newSoundData(path .. "jump.wav")
    sounds.dead = love.sound.newSoundData(path .. "dead.wav")
    sounds.collect = love.sound.newSoundData(path .. "collect.wav")
    sounds.floor = love.sound.newSoundData(path .. "floor.wav")
end