local Games = {
    [111530421351096] = "https://raw.githubusercontent.com/Floppa1x1/Floppa-Hub/refs/heads/main/yvsh.lua", -- You VS Homer
    [17625359962] = "https://raw.githubusercontent.com/Floppa1x1/Floppa-Hub/refs/heads/main/Rivals.lua", -- Rivals
}

local url = Games[game.PlaceId]

if url then
    loadstring(game:HttpGet(url))()
else
    warn("This game is not supported.")
end
