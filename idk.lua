local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local center = rootPart.Position

while true do
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * 20
    local offsetX = math.cos(angle) * distance
    local offsetZ = math.sin(angle) * distance
    local newPos = Vector3.new(center.X + offsetX, rootPart.Position.Y, center.Z + offsetZ)
    rootPart.CFrame = CFrame.new(newPos)
    task.wait(0.05)
end
