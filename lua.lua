local placeId = game.PlaceId
print("Current PlaceId:", placeId)

local scripts = {
    [111530421351096] = "https://raw.githubusercontent.com/Floppa1x1/Floppa-Hub/main/lua.lua",
    [17625359962] = "https://raw.githubusercontent.com/Floppa1x1/Floppa-Hub/main/Rivals.lua",
}

local scriptUrl = scripts[placeId]

if scriptUrl then
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
    if not success then
        warn("Failed to execute script:", err)
    end
else
    warn("No script available for this game (PlaceId: " .. placeId .. ")")
end
