
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local speed = 80
local running = false
local movement = nil

local visitedCoins = setmetatable({}, {__mode = "k"})

local oldGui = playerGui:FindFirstChild("CoinFarmUI")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "CoinFarmUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(220, 145)
main.Position = UDim2.new(0.5, -110, 0.5, -72)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(55, 55, 65)
stroke.Thickness = 1
stroke.Parent = main

local function createLabel(text, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.fromOffset(10, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = main
    return label
end

local title = createLabel("COIN FARM", 10)
title.TextSize = 14

local statusLabel = createLabel("Status: Stopped", 37)
createLabel("Move Speed", 65)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.fromOffset(90, 27)
speedBox.Position = UDim2.fromOffset(120, 62)
speedBox.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Text = tostring(speed)
speedBox.ClearTextOnFocus = false
speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 12
speedBox.Parent = main

Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 32)
toggle.Position = UDim2.fromOffset(10, 101)
toggle.BackgroundColor3 = Color3.fromRGB(40, 155, 95)
toggle.Text = "START"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 12
toggle.Parent = main

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 7)

local function setStatus(text)
    statusLabel.Text = "Status: " .. text
end

local function isAlive()
    return player:GetAttribute("Alive") == true
end

local function getCharacter()
    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid or humanoid.Health <= 0 then
        return
    end

    return root, humanoid
end

local function isInCoinContainer(coin)
    local parent = coin.Parent

    while parent and parent ~= workspace do
        if parent.Name == "CoinContainer" then
            return true
        end

        parent = parent.Parent
    end

    return false
end

local function isPartVisible(part)
    if not part:IsA("BasePart") then
        return false
    end

    local opacity = (1 - part.Transparency)
        * (1 - part.LocalTransparencyModifier)

    return opacity > 0.05
end

local function isCoinVisible(coin)
    if isPartVisible(coin) then
        return true
    end

    for _, child in ipairs(coin:GetDescendants()) do
        if isPartVisible(child) then
            return true
        end
    end

    -- Supports transparent hitboxes inside visible coin models.
    local parent = coin.Parent

    if parent
        and parent:IsA("Model")
        and parent.Name ~= "CoinContainer" then

        for _, child in ipairs(parent:GetDescendants()) do
            if child ~= coin and isPartVisible(child) then
                return true
            end
        end
    end

    return false
end

local function isValidCoin(coin)
    return coin
        and coin:IsA("BasePart")
        and coin.Name == "Coin_Server"
        and coin:IsDescendantOf(workspace)
        and isInCoinContainer(coin)
        and isCoinVisible(coin)
end

local function getNearestCoin(root)
    local nearest = nil
    local shortest = math.huge

    for _, coin in ipairs(workspace:GetDescendants()) do
        if isValidCoin(coin) and not visitedCoins[coin] then
            local distance = (root.Position - coin.Position).Magnitude

            if distance < shortest then
                shortest = distance
                nearest = coin
            end
        end
    end

    return nearest, shortest
end

local function stopMovement()
    local active = movement
    if not active then return end

    movement = nil

    if active.align then
        active.align:Destroy()
    end

    if active.orientation then
        active.orientation:Destroy()
    end

    if active.attachment then
        active.attachment:Destroy()
    end

    for part, original in pairs(active.collisions) do
        if part.Parent then
            part.CanCollide = original
        end
    end

    if active.root and active.root.Parent then
        active.root.CanTouch = active.originalTouch
        active.root.Anchored = false
        active.root.AssemblyLinearVelocity = Vector3.zero
        active.root.AssemblyAngularVelocity = Vector3.zero
    end

    if active.humanoid and active.humanoid.Parent then
        active.humanoid.PlatformStand = active.originalPlatform
        active.humanoid.AutoRotate = active.originalRotate
    end
end

local function startMovement(root, humanoid)
    stopMovement()

    local attachment = Instance.new("Attachment")
    attachment.Name = "CoinFarmAttachment"
    attachment.Parent = root

    local align = Instance.new("AlignPosition")
    align.Name = "CoinFarmPosition"
    align.Mode = Enum.PositionAlignmentMode.OneAttachment
    align.Attachment0 = attachment
    align.ApplyAtCenterOfMass = true
    align.RigidityEnabled = false
    align.MaxForce = 1e9
    align.MaxVelocity = speed
    align.Responsiveness = 100
    align.Position = root.Position
    align.Parent = root

    local orientation = Instance.new("AlignOrientation")
    orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    orientation.Attachment0 = attachment
    orientation.MaxTorque = 1e9
    orientation.Responsiveness = 50
    orientation.CFrame = root.CFrame.Rotation
    orientation.Parent = root

    local active = {
        root = root,
        humanoid = humanoid,
        attachment = attachment,
        align = align,
        orientation = orientation,
        collisions = {},
        originalTouch = root.CanTouch,
        originalPlatform = humanoid.PlatformStand,
        originalRotate = humanoid.AutoRotate
    }

    movement = active

    root.Anchored = false
    root.CanTouch = true
    root.AssemblyLinearVelocity = Vector3.zero

    humanoid.AutoRotate = false
    humanoid.PlatformStand = true

    return active
end

local noclipConnection = RunService.Stepped:Connect(function()
    local active = movement

    if not active or not running or not isAlive() then
        return
    end

    local character = active.root.Parent
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if active.collisions[part] == nil then
                active.collisions[part] = part.CanCollide
            end

            part.CanCollide = false
        end
    end
end)

local function tryTouch(root, coin)
    if not running or not isAlive() or not isValidCoin(coin) then
        return
    end

    if typeof(firetouchinterest) ~= "function" then
        return
    end

    task.spawn(function()
        pcall(function()
            firetouchinterest(root, coin, 0)
            task.wait(0.04)

            if running and isAlive() and isValidCoin(coin) then
                firetouchinterest(root, coin, 1)
            end
        end)
    end)
end

local function moveToCoin(coin, initialDistance)
    if not running or not isAlive() or not isValidCoin(coin) then
        return
    end

    local root, humanoid = getCharacter()
    if not root then return end

    local active = startMovement(root, humanoid)

    local started = os.clock()
    local arrivedAt = nil
    local lastTouchTry = 0

    local maxTime = math.clamp(
        initialDistance / math.max(speed, 1) * 2.5 + 2,
        2,
        40
    )

    while running
        and isAlive()
        and movement == active
        and gui.Parent do

        if not root.Parent or humanoid.Health <= 0 then
            break
        end

        -- Stop chasing if the coin disappears or turns invisible.
        if not isValidCoin(coin) then
            break
        end

        local now = os.clock()
        local distance = (root.Position - coin.Position).Magnitude

        if now - started > maxTime then
            break
        end

        local reach = math.clamp(
            math.max(coin.Size.X, coin.Size.Y, coin.Size.Z) / 2 + 1,
            2.5,
            5
        )

        active.align.Position = coin.Position
        active.align.MaxVelocity = speed

        if distance <= reach then
            if not arrivedAt then
                arrivedAt = now
                setStatus("Collecting")
            end

            if now - lastTouchTry >= 0.15 then
                lastTouchTry = now
                tryTouch(root, coin)
            end

            if now - arrivedAt >= 0.35 then
                break
            end
        else
            arrivedAt = nil
            setStatus("Moving")
        end

        RunService.Heartbeat:Wait()
    end

    stopMovement()
end

speedBox.FocusLost:Connect(function()
    local value = tonumber(speedBox.Text)

    if value and value >= 1 and value <= 500 then
        speed = value

        if movement and movement.align then
            movement.align.MaxVelocity = speed
        end
    end

    speedBox.Text = tostring(speed)
end)

toggle.MouseButton1Click:Connect(function()
    running = not running

    toggle.Text = running and "STOP" or "START"

    toggle.BackgroundColor3 = running
        and Color3.fromRGB(185, 65, 65)
        or Color3.fromRGB(40, 155, 95)

    if not running then
        stopMovement()
        setStatus("Stopped")
    end
end)

local aliveConnection = player:GetAttributeChangedSignal("Alive"):Connect(function()
    if not isAlive() then
        stopMovement()

        if running then
            setStatus("Not Alive")
        end
    end
end)

local characterAddedConnection = player.CharacterAdded:Connect(function()
    stopMovement()
end)

local characterRemovingConnection = player.CharacterRemoving:Connect(function()
    stopMovement()
end)

gui.Destroying:Connect(function()
    running = false
    stopMovement()
    noclipConnection:Disconnect()
    aliveConnection:Disconnect()
    characterAddedConnection:Disconnect()
    characterRemovingConnection:Disconnect()
end)

task.spawn(function()
    while gui.Parent do
        if not running then
            task.wait(0.1)
            continue
        end

        if not isAlive() then
            stopMovement()
            setStatus("Not Alive")
            task.wait(0.15)
            continue
        end

        local root = getCharacter()

        if not root then
            setStatus("Waiting for character")
            task.wait(0.2)
            continue
        end

        local coin, distance = getNearestCoin(root)

        if not coin then
            setStatus("Waiting for new coins")
            task.wait(0.2)
            continue
        end

        -- Mark this instance immediately so it is never targeted twice.
        visitedCoins[coin] = true

        moveToCoin(coin, distance)

        if running and isAlive() then
            setStatus("Searching")
        end

        task.wait(0.03)
    end

    running = false
    stopMovement()
end)
