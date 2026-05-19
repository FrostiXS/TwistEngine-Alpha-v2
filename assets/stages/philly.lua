-- Philly Stage Script (Week 3)
-- City window lights change color every 4 beats

local phillyLightsColors = {'31A2FD', '31FD8C', 'FB33F5', 'FD4531', 'FBA633'}
local curLight = -1

function onBeatHit()
    if curBeat % 4 == 0 then
        curLight = getRandomInt(0, #phillyLightsColors - 1)
        -- Window light color change effect
    end
end
