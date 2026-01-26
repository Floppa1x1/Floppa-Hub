local id = game.PlaceId
print("Current PlaceId:", id)

if id == 111530421351096 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Floppa1x1/Floppa-Hub/refs/heads/main/yvsh.lua"))()
elseif id == 17625359962 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Floppa1x1/Floppa-Hub/refs/heads/main/Rivals.lua"))()
else
    warn("No script found for this game.")
end
