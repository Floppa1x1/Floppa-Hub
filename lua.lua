
local games = {
    ["Ride a Pet"] = {124216119978534, "rideapet.lua"},
    ["Huss Valley"] = {107535308163741, "hussvalley.lua"},
    ["Steal an Egg"] = {107778070777162, "stealanegg.lua"},
    ["Slayers"] = {16205713724, "slayers.lua"}
}

local function load(file)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Floppa1x1/Floppa-Hub/refs/heads/main/" .. file))()
end

local matched = false
for _, data in pairs(games) do
    if game.PlaceId == data[1] then
        matched = true
        load(data[2])
        break
    end
end

if not matched then
    local gui = Instance.new("ScreenGui")
    gui.Name = "GameSelector"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromOffset(170, 145)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)

    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center

    for name, data in pairs(games) do
        local button = Instance.new("TextButton", frame)
        button.Size = UDim2.fromOffset(155, 28)
        button.Text = name
        button.MouseButton1Click:Connect(function()
            gui:Destroy()
            load(data[2])
        end)
    end
end
