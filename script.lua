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
DragFrame.Size = UDim2.new(0, 100, 0, 100)
DragFrame.Position = UDim2.new(0.5, -50, 0.5, -50)
DragFrame.Active = true
DragFrame.Draggable = true

OpenButton.Name = "OpenButton"
OpenButton.Parent = DragFrame
OpenButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
OpenButton.Size = UDim2.new(1, 0, 1, 0)
OpenButton.Text = "LR"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 20

-- Main Menu
local MainFrame = Instance.new("Frame")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGUI
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Size = UDim2.new(0, 1000, 0, 800)
MainFrame.Position = UDim2.new(0.5, -500, 0.5, -400)
MainFrame.Visible = false

ScrollFrame.Parent = MainFrame
ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollFrame.ScrollBarThickness = 5

UIListLayout.Parent = ScrollFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- NoClip
local NoClipToggle = Instance.new("TextButton")
NoClipToggle.Size = UDim2.new(0.9, 0, 0, 50)
NoClipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
NoClipToggle.Text = "NoClip: OFF"
NoClipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
NoClipToggle.TextSize = 16
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
InfJumpToggle.Size = UDim2.new(0.9, 0, 0, 50)
InfJumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
InfJumpToggle.Text = "Infinity Jump: OFF"
InfJumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
InfJumpToggle.TextSize = 16
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
ESPToggle.Size = UDim2.new(0.9, 0, 0, 50)
ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ESPToggle.Text = "ESP: OFF"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 16
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
FlyToggle.Size = UDim2.new(0.9, 0, 0, 50)
FlyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FlyToggle.Text = "Fly: OFF"
FlyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyToggle.TextSize = 16
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
SpeedFrame.Size = UDim2.new(0.9, 0, 0, 80)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedFrame.Parent = ScrollFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 30"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 16
SpeedLabel.Parent = SpeedFrame

local SpeedMinus = Instance.new("TextButton")
SpeedMinus.Size = UDim2.new(0.1, 0, 0.5, 0)
SpeedMinus.Position = UDim2.new(0.7, 0, 0, 0)
SpeedMinus.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedMinus.Text = "–"
SpeedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedMinus.TextSize = 20
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
    SpeedConfig.Size = UDim2.new(0, 300, 0, 200)
    SpeedConfig.Position = UDim2.new(0.5, -150, 0.5, -100)
    
    local SpeedSlider = Instance.new("TextButton")
    SpeedSlider.Size = UDim2.new(0.8, 0, 0, 30)
    SpeedSlider.Position = UDim2.new(0.1, 0, 0.3, 0)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SpeedSlider.Text = "Set Speed: " .. currentSpeed
    SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedSlider.TextSize = 16
    SpeedSlider.Parent = SpeedConfig
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0.3, 0, 0, 30)
    CloseButton.Position = UDim2.new(0.35, 0, 0.7, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    CloseButton.Text = "Close"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
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
    MainFrame.Visible = not MainFrame.Visible
    DragFrame.Visible = not MainFrame.Visible
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
