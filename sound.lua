function playSound(sound)
    channel = love.audio.newSource(sound)
    channel:play()
end

function playMusic(sound)
    channel = love.audio.newSource(sound, "stream")
    channel:setLooping(true)
    channel:play()
    return channel
end

function loadMusic()
    local path = "mus/"
    musics = {}
    musics.main = love.sound.newSoundData(path .. "shplat.ogg")
end

function loadSounds()
    local path = "snd/"
    sounds = {}
    sounds.jump = love.sound.newSoundData(path .. "jump.wav")
    sounds.dead = love.sound.newSoundData(path .. "dead.wav")
    sounds.collect = love.sound.newSoundData(path .. "collect.wav")
    sounds.floor = love.sound.newSoundData(path .. "floor.wav")
    sounds.doorOpen = love.sound.newSoundData(path .. "dooropen.wav")
    sounds.exit = love.sound.newSoundData(path .. "exit.wav")
end