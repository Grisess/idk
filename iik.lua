local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local effectActive = false
local effectCoroutine = nil
local centerPosition = nil

local RADIUS = 25
local JUMP_DELAY = 0.03
local AFTERIMAGE_DURATION = 0.4
local AFTERIMAGE_TRANSPARENCY = 0.75

local function createAfterimage()
    local afterimage = character:Clone()
    if afterimage:FindFirstChild("Humanoid") then
        afterimage.Humanoid:Destroy()
    end
    afterimage:SetPrimaryPartCFrame(rootPart.CFrame)
    afterimage.Parent = workspace

    for _, part in ipairs(afterimage:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = AFTERIMAGE_TRANSPARENCY
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Anchored = true
            end
        end
    end
    Debris:AddItem(afterimage, AFTERIMAGE_DURATION)
end

local function startEffect()
    if effectActive then return end
    effectActive = true
    centerPosition = rootPart.Position
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

    effectCoroutine = coroutine.create(function()
        while effectActive do
            createAfterimage()
            local angle = math.random() * 2 * math.pi
            local distance = math.random() * RADIUS
            local offsetX = math.cos(angle) * distance
            local offsetZ = math.sin(angle) * distance
            local newPosition = Vector3.new(centerPosition.X + offsetX, centerPosition.Y, centerPosition.Z + offsetZ)
            rootPart.CFrame = CFrame.new(newPosition)
            task.wait(JUMP_DELAY)
        end
    end)
    coroutine.resume(effectCoroutine)
end

local function stopEffect()
    if not effectActive then return end
    effectActive = false
    if effectCoroutine then
        coroutine.close(effectCoroutine)
        effectCoroutine = nil
    end
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local toggleButton = Instance.new("TextButton")
toggleButton.Parent = screenGui
toggleButton.Size = UDim2.new(0, 100, 0, 50)
toggleButton.Position = UDim2.new(0.5, -50, 0.1, 0)
toggleButton.Text = "Speed ON/OFF"
toggleButton.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 18
toggleButton.Draggable = true
toggleButton.Active = true

toggleButton.MouseButton1Click:Connect(function()
    if effectActive then
        stopEffect()
    else
        startEffect()
    end
end)
