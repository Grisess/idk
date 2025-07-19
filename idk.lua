--[[
    Скрипт для создания иллюзии суперскорости у персонажа.
    Персонаж быстро перемещается в пределах круглой области,
    оставляя за собой затухающие копии (эффект "размножения").
    
    Местоположение: StarterPlayer > StarterCharacterScripts (в виде LocalScript)
]]

-- Службы Roblox
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- ================== НАСТРОЙКИ ЭФФЕКТА ==================

-- Радиус круга, в котором будет двигаться персонаж (в стадах)
local RADIUS = 25

-- Задержка между "прыжками". Чем меньше значение, тем выше скорость.
local JUMP_DELAY = 0.03

-- Создавать ли "копии" (afterimages) для эффекта "размножения"
local CREATE_AFTERIMAGES = true

-- Как долго существует копия в секундах
local AFTERIMAGE_DURATION = 0.4

-- Прозрачность копии (0 = непрозрачная, 1 = невидимая)
local AFTERIMAGE_TRANSPARENCY = 0.75

-- =======================================================


-- Получаем локального игрока и его персонажа
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Убедимся, что персонаж полностью загружен
wait(1)

-- Сохраняем начальную точку как центр области действия эффекта
local centerPosition = rootPart.Position

-- Отключаем стандартную физику для персонажа, чтобы его не отбрасывало
-- и чтобы он не падал во время быстрых перемещений.
humanoid.PlatformStand = true

-- Создаем функцию для создания копии
local function createAfterimage()
    if not CREATE_AFTERIMAGES then return end
    
    local afterimage = character:Clone()
    -- Удаляем Humanoid из клона, чтобы избежать проблем с AI и здоровьем
    local cloneHumanoid = afterimage:FindFirstChildOfClass("Humanoid")
    if cloneHumanoid then
        cloneHumanoid:Destroy()
    end
    
    -- Устанавливаем положение и делаем копию неинтерактивной
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
    
    -- Добавляем клон в службу Debris для автоматического удаления через AFTERIMAGE_DURATION секунд
    Debris:AddItem(afterimage, AFTERIMAGE_DURATION)
end

-- Основной цикл для создания эффекта
while true do
    -- Создаем копию в текущем положении перед перемещением
    createAfterimage()
    
    -- Вычисляем случайную точку внутри круга
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * RADIUS
    
    -- Рассчитываем смещение от центра
    local offsetX = math.cos(angle) * distance
    local offsetZ = math.sin(angle) * distance

    -- Создаем новую координату CFrame, сохраняя высоту Y, чтобы не провалиться под карту
    local newPosition = Vector3.new(centerPosition.X + offsetX, rootPart.Position.Y, centerPosition.Z + offsetZ)
    
    -- Мгновенно перемещаем персонажа
    rootPart.CFrame = CFrame.new(newPosition)
    
    -- Ждем короткое время перед следующим "прыжком"
    task.wait(JUMP_DELAY)
end


--[[
    ВАЖНО: Этот скрипт содержит бесконечный цикл (while true do).
    Чтобы остановить эффект, вам нужно будет добавить условие для прерывания цикла.
    После остановки цикла не забудьте вернуть персонажу нормальное состояние:
    humanoid.PlatformStand = false
]]
