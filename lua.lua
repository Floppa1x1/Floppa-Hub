
local placeId = game.PlaceId

local scripts = {
    [111530421351096] = "https://raw.githubusercontent.com/Floppa1x1/Floppa-Hub/refs/heads/main/yvsh.lua", -- You VS Homer
    [17625359962] = "https://raw.githubusercontent.com/Floppa1x1/Floppa-Hub/refs/heads/main/Rivals.lua", -- Rivals
}

local scriptUrl = scripts[placeId]

if scriptUrl then
    loadstring(game:HttpGet(scriptUrl))()
else
    warn("No script available for this game (PlaceId: " .. placeId .. ")")
end
