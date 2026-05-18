-- Spooky Stage Script (Week 2)
-- Lightning strikes with thunder sounds and screen flash

local lightningStrikeBeat = 0
local lightningOffset = 8

function onBeatHit()
    if getRandomBool(10) and curBeat > lightningStrikeBeat + lightningOffset then
        lightningStrikeShit()
    end
end

function lightningStrikeShit()
    playSound('thunder_' .. getRandomInt(1, 2))

    lightningStrikeBeat = curBeat
    lightningOffset = getRandomInt(8, 24)

    characterPlayAnim('boyfriend', 'scared', true)
    characterPlayAnim('dad', 'scared', true)
    characterPlayAnim('gf', 'scared', true)

    triggerEvent('Add Camera Zoom', '0.015', '0.03')
end
