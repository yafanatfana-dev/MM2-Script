-- LR Script for Murder Mystery 2
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Draggable GUI
local MainGUI = Instance.new("ScreenGui")
local DragFrame = Instance.new("Frame")
local OpenButton = Instance.new("TextButton")

MainGUI.Name = "LRGUI"
MainGUI.Parent = game.CoreGui
MainGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

DragFrame.Name = "DragFrame"
DragFrame.Parent = MainGUI
DragFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DragFrame.BorderSizePixel = 2
DragFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
DragFrame.Size = UDim2.new(0, 25, 0, 25)
DragFrame.Position = UDim2.new(0, 10, 0, 10)
DragFrame.Active = true
DragFrame.Draggable = true

OpenButton.Name = "OpenButton"
OpenButton.Parent = DragFrame
OpenButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
OpenButton.Size = UDim2.new(1, 0, 1, 0)
OpenButton.Text = "LR"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 12
OpenButton.TextScaled = true

-- Main Menu
local MainFrame = Instance.new("Frame")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local CloseButton = Instance.new("TextButton")

MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGUI
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
MainFrame.Visible = false

CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.ZIndex = 2

ScrollFrame.Parent = MainFrame
ScrollFrame.Size = UDim2.new(1, -10, 1, -30)
ScrollFrame.Position = UDim2.new(0, 5, 0, 25)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 3, 0)
ScrollFrame.ScrollBarThickness = 5

UIListLayout.Parent = ScrollFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- ESP (ВЫСОКИЙ ПРИОРИТЕТ)
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(0.9, 0, 0, 40)
ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ESPToggle.Text = "ESP: OFF"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 16
ESPToggle.TextStrokeColor3 = Color3.fromRGB(0, 255, 0)
ESPToggle.TextStrokeTransparency = 0.8
ESPToggle.Parent = ScrollFrame

local espEnabled = false
local espBoxes = {}
local espConnections = {}

local function getPlayerRole(player)
    if not player or not player.Character then return "Innocent" end
    
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    -- Проверяем инструменты в инвентаре
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = string.lower(tool.Name)
                if toolName:find("knife") or toolName:find("murder") then
                    return "Murderer"
                elseif toolName:find("gun") or toolName:find("pistol") or toolName:find("sheriff") then
                    return "Sheriff"
                end
            end
        end
    end
    
    -- Проверяем инструменты в руках
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        local toolName = string.lower(tool.Name)
        if toolName:find("knife") or toolName:find("murder") then
            return "Murderer"
        elseif toolName:find("gun") or toolName:find("pistol") or toolName:find("sheriff") then
            return "Sheriff"
        end
    end
    
    return "Innocent"
end

local function updateESPColor(espBox, role)
    if role == "Murderer" then
        espBox.FillColor = Color3.fromRGB(255, 0, 0)
        espBox.OutlineColor = Color3.fromRGB(255, 0, 0)
    elseif role == "Sheriff" then
        espBox.FillColor = Color3.fromRGB(0, 0, 255)
        espBox.OutlineColor = Color3.fromRGB(0, 0, 255)
    else
        espBox.FillColor = Color3.fromRGB(0, 255, 0)
        espBox.OutlineColor = Color3.fromRGB(0, 255, 0)
    end
end

local function createESP(player)
    if player == LocalPlayer then return end
    
    local espBox = Instance.new("Highlight")
    espBox.Name = player.Name .. "ESP"
    espBox.Adornee = nil
    espBox.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    espBox.Enabled = false
    espBox.Parent = game.CoreGui
    
    espBoxes[player] = espBox
    
    local function updateESP()
        if espEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            espBox.Adornee = player.Character
            espBox.Enabled = true
            
            local role = getPlayerRole(player)
            updateESPColor(espBox, role)
        else
            espBox.Enabled = false
        end
    end
    
    -- Создаем соединения для отслеживания изменений
    local connections = {}
    
    table.insert(connections, player.CharacterAdded:Connect(function(character)
        wait(1)
        updateESP()
        
        -- Отслеживаем изменения в инвентаре
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            table.insert(connections, backpack.ChildAdded:Connect(updateESP))
            table.insert(connections, backpack.ChildRemoved:Connect(updateESP))
        end
    end))
    
    table.insert(connections, player.CharacterRemoving:Connect(function()
        espBox.Enabled = false
    end))
    
    -- Отслеживаем изменения инструментов
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        table.insert(connections, backpack.ChildAdded:Connect(updateESP))
        table.insert(connections, backpack.ChildRemoved:Connect(updateESP))
    end
    
    espConnections[player] = connections
    updateESP()
end

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPToggle.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    ESPToggle.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(60, 60, 60)
    
    if espEnabled then
        -- Создаем ESP для всех существующих игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
    else
        -- Удаляем все ESP
        for player, espBox in pairs(espBoxes) do
            espBox:Destroy()
        end
        for player, connections in pairs(espConnections) do
            for _, connection in pairs(connections) do
                connection:Disconnect()
            end
        end
        espBoxes = {}
        espConnections = {}
    end
end)

-- SilentAim (ВЫСОКИЙ ПРИОРИТЕТ)
local SilentAimToggle = Instance.new("TextButton")
SilentAimToggle.Size = UDim2.new(0.9, 0, 0, 40)
SilentAimToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SilentAimToggle.Text = "SilentAim: OFF"
SilentAimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SilentAimToggle.TextSize = 16
SilentAimToggle.Parent = ScrollFrame

local silentAimEnabled = false
local silentAimCircle

-- Создаем круг для SilentAim
local function createSilentAimCircle()
    silentAimCircle = Instance.new("Frame")
    silentAimCircle.Name = "SilentAimCircle"
    silentAimCircle.Parent = MainGUI
    silentAimCircle.BackgroundTransparency = 1
    silentAimCircle.BorderSizePixel = 2
    silentAimCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
    silentAimCircle.Size = UDim2.new(0, 100, 0, 100)
    silentAimCircle.Position = UDim2.new(0.5, -50, 0.5, -50)
    silentAimCircle.Visible = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = silentAimCircle
end

createSilentAimCircle()

local function findTargetInCircle()
    if not silentAimEnabled then return nil end
    
    local camera = workspace.CurrentCamera
    local viewportSize = camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local circleRadius = 50
    
    local closestTarget = nil
    local closestDistance = circleRadius
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local screenPoint, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                
                if onScreen then
                    local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distance = (screenPos - center).Magnitude
                    
                    -- Проверяем, находится ли цель в круге и не за стеной
                    if distance <= circleRadius then
                        -- Проверка на стену (raycast)
                        local origin = camera.CFrame.Position
                        local direction = (humanoidRootPart.Position - origin).Unit
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        
                        local raycastResult = workspace:Raycast(origin, direction * 1000, raycastParams)
                        
                        if raycastResult then
                            local hitPart = raycastResult.Instance
                            local hitPlayer = Players:GetPlayerFromCharacter(hitPart:FindFirstAncestorOfClass("Model"))
                            
                            if hitPlayer == player then
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestTarget = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestTarget
end

-- Перехват выстрелов
local oldNamecall
SilentAimToggle.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    SilentAimToggle.Text = "SilentAim: " .. (silentAimEnabled and "ON" or "OFF")
    SilentAimToggle.BackgroundColor3 = silentAimEnabled and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(60, 60, 60)
    silentAimCircle.Visible = silentAimEnabled
    
    if silentAimEnabled then
        -- Перехватываем вызовы методов
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "FireServer" and tostring(self) == "Gun" then
                local target = findTargetInCircle()
                if target and target.Character then
                    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        -- Изменяем аргументы для попадания в цель
                        args[1] = humanoidRootPart.Position
                    end
                end
            end
            
            return oldNamecall(self, unpack(args))
        end)
    else
        if oldNamecall then
            hookmetamethod(game, "__namecall", oldNamecall)
        end
    end
end)

-- NoClip
local NoClipToggle = Instance.new("TextButton")
NoClipToggle.Size = UDim2.new(0.9, 0, 0, 30)
NoClipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
NoClipToggle.Text = "NoClip: OFF"
NoClipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
NoClipToggle.TextSize = 14
NoClipToggle.Parent = ScrollFrame

local noclip = false
local noclipConnection
NoClipToggle.MouseButton1Click:Connect(function()
    noclip = not noclip
    NoClipToggle.Text = "NoClip: " .. (noclip and "ON" or "OFF")
    
    if noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end)

-- Infinite Jump
local InfJumpToggle = Instance.new("TextButton")
InfJumpToggle.Size = UDim2.new(0.9, 0, 0, 30)
InfJumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
InfJumpToggle.Text = "Infinity Jump: OFF"
InfJumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
InfJumpToggle.TextSize = 14
InfJumpToggle.Parent = ScrollFrame

local infiniteJump = false
InfJumpToggle.MouseButton1Click:Connect(function()
    infiniteJump = not infiniteJump
    InfJumpToggle.Text = "Infinity Jump: " .. (infiniteJump and "ON" or "OFF")
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Fly
local FlyToggle = Instance.new("TextButton")
FlyToggle.Size = UDim2.new(0.9, 0, 0, 30)
FlyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FlyToggle.Text = "Fly: OFF"
FlyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyToggle.TextSize = 14
FlyToggle.Parent = ScrollFrame

local flying = false
local flyConnection
local flyBV

FlyToggle.MouseButton1Click:Connect(function()
    flying = not flying
    FlyToggle.Text = "Fly: " .. (flying and "ON" or "OFF")
    
    if flying then
        -- Автоматически включаем NoClip
        if not noclip then
            noclip = true
            NoClipToggle.Text = "NoClip: ON"
            noclipConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                humanoid.PlatformStand = true
                
                flyBV = Instance.new("BodyVelocity")
                flyBV.Velocity = Vector3.new(0, 0, 0)
                flyBV.MaxForce = Vector3.new(40000, 40000, 40000)
                flyBV.Parent = rootPart
                
                flyConnection = RunService.Heartbeat:Connect(function()
                    if character and rootPart then
                        local cam = workspace.CurrentCamera
                        local lookVector = cam.CFrame.LookVector
                        
                        local moveDirection = Vector3.new()
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            moveDirection = moveDirection + lookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            moveDirection = moveDirection - lookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            moveDirection = moveDirection - cam.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            moveDirection = moveDirection + cam.CFrame.RightVector
                        end
                        
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            moveDirection = moveDirection + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            moveDirection = moveDirection - Vector3.new(0, 1, 0)
                        end
                        
                        if moveDirection.Magnitude > 0 then
                            flyBV.Velocity = lookVector * 50
                        else
                            flyBV.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end)
            end
        end
    else
        if flyConnection then
            flyConnection:Disconnect()
        end
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid then
                humanoid.PlatformStand = false
            end
            
            if rootPart and flyBV then
                flyBV:Destroy()
            end
        end
    end
end)

-- Speed
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(0.9, 0, 0, 50)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedFrame.Parent = ScrollFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 30"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14
SpeedLabel.Parent = SpeedFrame

local SpeedMinus = Instance.new("TextButton")
SpeedMinus.Size = UDim2.new(0.1, 0, 0.5, 0)
SpeedMinus.Position = UDim2.new(0.7, 0, 0, 0)
SpeedMinus.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedMinus.Text = "–"
SpeedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedMinus.TextSize = 16
SpeedMinus.Parent = SpeedFrame

local currentSpeed = 30
local speedConnection

local function updateSpeed(newSpeed)
    currentSpeed = math.clamp(newSpeed, 30, 300)
    SpeedLabel.Text = "Speed: " .. currentSpeed
    
    if speedConnection then
        speedConnection:Disconnect()
    end
    
    speedConnection = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = currentSpeed
            end
        end
    end)
end

SpeedMinus.MouseButton1Click:Connect(function()
    local SpeedConfig = Instance.new("Frame")
    SpeedConfig.Name = "SpeedConfig"
    SpeedConfig.Parent = MainGUI
    SpeedConfig.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SpeedConfig.BorderSizePixel = 2
    SpeedConfig.BorderColor3 = Color3.fromRGB(255, 255, 255)
    SpeedConfig.Size = UDim2.new(0, 200, 0, 150)
    SpeedConfig.Position = UDim2.new(0.5, -100, 0.5, -75)
    
    local SpeedSlider = Instance.new("TextButton")
    SpeedSlider.Size = UDim2.new(0.8, 0, 0, 30)
    SpeedSlider.Position = UDim2.new(0.1, 0, 0.3, 0)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SpeedSlider.Text = "Set Speed: " .. currentSpeed
    SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedSlider.TextSize = 14
    SpeedSlider.Parent = SpeedConfig
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0.3, 0, 0, 25)
    CloseButton.Position = UDim2.new(0.35, 0, 0.7, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    CloseButton.Text = "Close"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Parent = SpeedConfig
    
    SpeedSlider.MouseButton1Click:Connect(function()
        currentSpeed = currentSpeed < 300 and currentSpeed + 30 or 30
        SpeedSlider.Text = "Set Speed: " .. currentSpeed
        updateSpeed(currentSpeed)
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        SpeedConfig:Destroy()
    end)
end)

updateSpeed(30)

-- Open/Close Menu
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    DragFrame.Visible = false
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    DragFrame.Visible = true
end)

-- Player added ESP
Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
    if espConnections[player] then
        for _, connection in pairs(espConnections[player]) do
            connection:Disconnect()
        end
        espConnections[player] = nil
    end
end)

-- Initial ESP setup
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and espEnabled then
        createESP(player)
    end
endScrollFrame.Size = UDim2.new(1, -10, 1, -30)
ScrollFrame.Position = UDim2.new(0, 5, 0, 25)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollFrame.ScrollBarThickness = 5

UIListLayout.Parent = ScrollFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- NoClip
local NoClipToggle = Instance.new("TextButton")
NoClipToggle.Size = UDim2.new(0.9, 0, 0, 30)
NoClipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
NoClipToggle.Text = "NoClip: OFF"
NoClipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
NoClipToggle.TextSize = 14
NoClipToggle.Parent = ScrollFrame

local noclip = false
local noclipConnection
NoClipToggle.MouseButton1Click:Connect(function()
    noclip = not noclip
    NoClipToggle.Text = "NoClip: " .. (noclip and "ON" or "OFF")
    
    if noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end)

-- Infinite Jump
local InfJumpToggle = Instance.new("TextButton")
InfJumpToggle.Size = UDim2.new(0.9, 0, 0, 30)
InfJumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
InfJumpToggle.Text = "Infinity Jump: OFF"
InfJumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
InfJumpToggle.TextSize = 14
InfJumpToggle.Parent = ScrollFrame

local infiniteJump = false
InfJumpToggle.MouseButton1Click:Connect(function()
    infiniteJump = not infiniteJump
    InfJumpToggle.Text = "Infinity Jump: " .. (infiniteJump and "ON" or "OFF")
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- ESP
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(0.9, 0, 0, 30)
ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ESPToggle.Text = "ESP: OFF"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 14
ESPToggle.Parent = ScrollFrame

local espEnabled = false
local espBoxes = {}

local function getPlayerRole(player)
    local character = player.Character
    if character then
        -- Проверяем инструменты в инвентаре
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    if string.lower(tool.Name) == "knife" then
                        return "Murderer"
                    elseif string.lower(tool.Name) == "gun" then
                        return "Sheriff"
                    end
                end
            end
        end
        
        -- Проверяем инструменты в руках
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            if string.lower(tool.Name) == "knife" then
                return "Murderer"
            elseif string.lower(tool.Name) == "gun" then
                return "Sheriff"
            end
        end
    end
    return "Innocent"
end

local function createESP(player)
    local espBox = Instance.new("Highlight")
    espBox.Name = player.Name .. "ESP"
    espBox.Adornee = nil
    espBox.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    espBox.Enabled = false
    espBox.Parent = game.CoreGui
    
    espBoxes[player] = espBox
    
    local function updateESP()
        if espEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            espBox.Adornee = player.Character
            espBox.Enabled = true
            
            local role = getPlayerRole(player)
            if role == "Murderer" then
                espBox.FillColor = Color3.fromRGB(255, 0, 0)
                espBox.OutlineColor = Color3.fromRGB(255, 0, 0)
            elseif role == "Sheriff" then
                espBox.FillColor = Color3.fromRGB(0, 0, 255)
                espBox.OutlineColor = Color3.fromRGB(0, 0, 255)
            else
                espBox.FillColor = Color3.fromRGB(0, 255, 0)
                espBox.OutlineColor = Color3.fromRGB(0, 255, 0)
            end
        else
            espBox.Enabled = false
        end
    end
    
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Ждем загрузки персонажа
        updateESP()
    end)
    
    -- Обновляем при изменении инвентаря
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        backpack.ChildAdded:Connect(updateESP)
        backpack.ChildRemoved:Connect(updateESP)
    end
    
    updateESP()
end

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPToggle.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
    else
        for player, espBox in pairs(espBoxes) do
            espBox:Destroy()
        end
        espBoxes = {}
    end
end)

-- Fly
local FlyToggle = Instance.new("TextButton")
FlyToggle.Size = UDim2.new(0.9, 0, 0, 30)
FlyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FlyToggle.Text = "Fly: OFF"
FlyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyToggle.TextSize = 14
FlyToggle.Parent = ScrollFrame

local flying = false
local flyConnection
local flyBV

FlyToggle.MouseButton1Click:Connect(function()
    flying = not flying
    FlyToggle.Text = "Fly: " .. (flying and "ON" or "OFF")
    
    if flying then
        -- Автоматически включаем NoClip
        if not noclip then
            noclip = true
            NoClipToggle.Text = "NoClip: ON"
            noclipConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                humanoid.PlatformStand = true
                
                flyBV = Instance.new("BodyVelocity")
                flyBV.Velocity = Vector3.new(0, 0, 0)
                flyBV.MaxForce = Vector3.new(40000, 40000, 40000)
                flyBV.Parent = rootPart
                
                flyConnection = RunService.Heartbeat:Connect(function()
                    if character and rootPart then
                        local cam = workspace.CurrentCamera
                        local lookVector = cam.CFrame.LookVector
                        
                        -- Определяем направление по джойстику
                        local moveDirection = Vector3.new()
                        if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
                            local touchInputs = UserInputService:GetConnectedGamepads()
                            if #touchInputs > 0 then
                                local thumbstick = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
                                -- Симуляция джойстика для мобильного управления
                                moveDirection = lookVector
                            end
                        else
                            -- Клавиатура
                            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                                moveDirection = moveDirection + lookVector
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                                moveDirection = moveDirection - lookVector
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                                moveDirection = moveDirection - cam.CFrame.RightVector
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                                moveDirection = moveDirection + cam.CFrame.RightVector
                            end
                        end
                        
                        -- Вертикальное движение
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            moveDirection = moveDirection + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            moveDirection = moveDirection - Vector3.new(0, 1, 0)
                        end
                        
                        -- Если есть направление движения, летим вперед по взгляду
                        if moveDirection.Magnitude > 0 then
                            flyBV.Velocity = lookVector * 50
                        else
                            flyBV.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end)
            end
        end
    else
        if flyConnection then
            flyConnection:Disconnect()
        end
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid then
                humanoid.PlatformStand = false
            end
            
            if rootPart and flyBV then
                flyBV:Destroy()
            end
        end
    end
end)

-- Speed
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(0.9, 0, 0, 50)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedFrame.Parent = ScrollFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 30"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14
SpeedLabel.Parent = SpeedFrame

local SpeedMinus = Instance.new("TextButton")
SpeedMinus.Size = UDim2.new(0.1, 0, 0.5, 0)
SpeedMinus.Position = UDim2.new(0.7, 0, 0, 0)
SpeedMinus.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedMinus.Text = "–"
SpeedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedMinus.TextSize = 16
SpeedMinus.Parent = SpeedFrame

local currentSpeed = 30
local speedConnection

local function updateSpeed(newSpeed)
    currentSpeed = math.clamp(newSpeed, 30, 300)
    SpeedLabel.Text = "Speed: " .. currentSpeed
    
    if speedConnection then
        speedConnection:Disconnect()
    end
    
    speedConnection = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = currentSpeed
            end
        end
    end)
end

SpeedMinus.MouseButton1Click:Connect(function()
    local SpeedConfig = Instance.new("Frame")
    SpeedConfig.Name = "SpeedConfig"
    SpeedConfig.Parent = MainGUI
    SpeedConfig.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SpeedConfig.BorderSizePixel = 2
    SpeedConfig.BorderColor3 = Color3.fromRGB(255, 255, 255)
    SpeedConfig.Size = UDim2.new(0, 200, 0, 150)
    SpeedConfig.Position = UDim2.new(0.5, -100, 0.5, -75)
    
    local SpeedSlider = Instance.new("TextButton")
    SpeedSlider.Size = UDim2.new(0.8, 0, 0, 30)
    SpeedSlider.Position = UDim2.new(0.1, 0, 0.3, 0)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SpeedSlider.Text = "Set Speed: " .. currentSpeed
    SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedSlider.TextSize = 14
    SpeedSlider.Parent = SpeedConfig
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0.3, 0, 0, 25)
    CloseButton.Position = UDim2.new(0.35, 0, 0.7, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    CloseButton.Text = "Close"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Parent = SpeedConfig
    
    SpeedSlider.MouseButton1Click:Connect(function()
        currentSpeed = currentSpeed < 300 and currentSpeed + 30 or 30
        SpeedSlider.Text = "Set Speed: " .. currentSpeed
        updateSpeed(currentSpeed)
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        SpeedConfig:Destroy()
    end)
end)

updateSpeed(30)

-- Open/Close Menu
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    DragFrame.Visible = false
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    DragFrame.Visible = true
end)

-- Player added ESP
Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        createESP(player)
    end
end)

-- Initial ESP setup
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and espEnabled then
        createESP(player)
    end
endScrollFrame.Size = UDim2.new(1, -10, 1, -30)
ScrollFrame.Position = UDim2.new(0, 5, 0, 25)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollFrame.ScrollBarThickness = 5

UIListLayout.Parent = ScrollFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- NoClip
local NoClipToggle = Instance.new("TextButton")
NoClipToggle.Size = UDim2.new(0.9, 0, 0, 30)
NoClipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
NoClipToggle.Text = "NoClip: OFF"
NoClipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
NoClipToggle.TextSize = 14
NoClipToggle.Parent = ScrollFrame

local noclip = false
local noclipConnection
NoClipToggle.MouseButton1Click:Connect(function()
    noclip = not noclip
    NoClipToggle.Text = "NoClip: " .. (noclip and "ON" or "OFF")
    
    if noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end)

-- Infinite Jump
local InfJumpToggle = Instance.new("TextButton")
InfJumpToggle.Size = UDim2.new(0.9, 0, 0, 30)
InfJumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
InfJumpToggle.Text = "Infinity Jump: OFF"
InfJumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
InfJumpToggle.TextSize = 14
InfJumpToggle.Parent = ScrollFrame

local infiniteJump = false
InfJumpToggle.MouseButton1Click:Connect(function()
    infiniteJump = not infiniteJump
    InfJumpToggle.Text = "Infinity Jump: " .. (infiniteJump and "ON" or "OFF")
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- ESP
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(0.9, 0, 0, 30)
ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ESPToggle.Text = "ESP: OFF"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 14
ESPToggle.Parent = ScrollFrame

local espEnabled = false
local espBoxes = {}

local function getPlayerRole(player)
    local character = player.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            if string.lower(tool.Name) == "knife" then
                return "Murderer"
            elseif string.lower(tool.Name) == "gun" then
                return "Sheriff"
            end
        end
        return "Innocent"
    end
    return "Innocent"
end

local function createESP(player)
    local espBox = Instance.new("Highlight")
    espBox.Name = player.Name .. "ESP"
    espBox.Adornee = nil
    espBox.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    espBox.Enabled = false
    espBox.Parent = game.CoreGui
    
    espBoxes[player] = espBox
    
    local function updateESP()
        if espEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            espBox.Adornee = player.Character
            espBox.Enabled = true
            
            local role = getPlayerRole(player)
            if role == "Murderer" then
                espBox.FillColor = Color3.fromRGB(255, 0, 0)
                espBox.OutlineColor = Color3.fromRGB(255, 0, 0)
            elseif role == "Sheriff" then
                espBox.FillColor = Color3.fromRGB(0, 0, 255)
                espBox.OutlineColor = Color3.fromRGB(0, 0, 255)
            else
                espBox.FillColor = Color3.fromRGB(0, 255, 0)
                espBox.OutlineColor = Color3.fromRGB(0, 255, 0)
            end
        else
            espBox.Enabled = false
        end
    end
    
    player.CharacterAdded:Connect(updateESP)
    updateESP()
end

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPToggle.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
    else
        for player, espBox in pairs(espBoxes) do
            espBox:Destroy()
        end
        espBoxes = {}
    end
end)

-- Fly
local FlyToggle = Instance.new("TextButton")
FlyToggle.Size = UDim2.new(0.9, 0, 0, 30)
FlyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FlyToggle.Text = "Fly: OFF"
FlyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyToggle.TextSize = 14
FlyToggle.Parent = ScrollFrame

local flying = false
local flyConnection
FlyToggle.MouseButton1Click:Connect(function()
    flying = not flying
    FlyToggle.Text = "Fly: " .. (flying and "ON" or "OFF")
    
    if flying then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                humanoid.PlatformStand = true
                
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                bodyVelocity.Parent = rootPart
                
                flyConnection = RunService.Heartbeat:Connect(function()
                    if character and rootPart then
                        local cam = workspace.CurrentCamera
                        local direction = Vector3.new()
                        
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            direction = direction + cam.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            direction = direction - cam.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            direction = direction - cam.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            direction = direction + cam.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            direction = direction + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            direction = direction - Vector3.new(0, 1, 0)
                        end
                        
                        bodyVelocity.Velocity = direction * 50
                    end
                end)
            end
        end
    else
        if flyConnection then
            flyConnection:Disconnect()
        end
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid then
                humanoid.PlatformStand = false
            end
            
            if rootPart then
                local bodyVelocity = rootPart:FindFirstChildOfClass("BodyVelocity")
                if bodyVelocity then
                    bodyVelocity:Destroy()
                end
            end
        end
    end
end)

-- Speed
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(0.9, 0, 0, 50)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedFrame.Parent = ScrollFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 30"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14
SpeedLabel.Parent = SpeedFrame

local SpeedMinus = Instance.new("TextButton")
SpeedMinus.Size = UDim2.new(0.1, 0, 0.5, 0)
SpeedMinus.Position = UDim2.new(0.7, 0, 0, 0)
SpeedMinus.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedMinus.Text = "–"
SpeedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedMinus.TextSize = 16
SpeedMinus.Parent = SpeedFrame

local currentSpeed = 30
local speedConnection

local function updateSpeed(newSpeed)
    currentSpeed = math.clamp(newSpeed, 30, 300)
    SpeedLabel.Text = "Speed: " .. currentSpeed
    
    if speedConnection then
        speedConnection:Disconnect()
    end
    
    speedConnection = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = currentSpeed
            end
        end
    end)
end

SpeedMinus.MouseButton1Click:Connect(function()
    local SpeedConfig = Instance.new("Frame")
    SpeedConfig.Name = "SpeedConfig"
    SpeedConfig.Parent = MainGUI
    SpeedConfig.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SpeedConfig.BorderSizePixel = 2
    SpeedConfig.BorderColor3 = Color3.fromRGB(255, 255, 255)
    SpeedConfig.Size = UDim2.new(0, 200, 0, 150)
    SpeedConfig.Position = UDim2.new(0.5, -100, 0.5, -75)
    
    local SpeedSlider = Instance.new("TextButton")
    SpeedSlider.Size = UDim2.new(0.8, 0, 0, 30)
    SpeedSlider.Position = UDim2.new(0.1, 0, 0.3, 0)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SpeedSlider.Text = "Set Speed: " .. currentSpeed
    SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedSlider.TextSize = 14
    SpeedSlider.Parent = SpeedConfig
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0.3, 0, 0, 25)
    CloseButton.Position = UDim2.new(0.35, 0, 0.7, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    CloseButton.Text = "Close"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Parent = SpeedConfig
    
    SpeedSlider.MouseButton1Click:Connect(function()
        currentSpeed = currentSpeed < 300 and currentSpeed + 30 or 30
        SpeedSlider.Text = "Set Speed: " .. currentSpeed
        updateSpeed(currentSpeed)
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        SpeedConfig:Destroy()
    end)
end)

updateSpeed(30)

-- Open/Close Menu
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    DragFrame.Visible = false
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    DragFrame.Visible = true
end)

-- Player added ESP
Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        createESP(player)
    end
end)

-- Initial ESP setup
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and espEnabled then
        createESP(player)
    end
end
