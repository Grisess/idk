-- LocalScript в StarterPlayer.StarterCharacterScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Параметры эффекта
local EFFECT_RADIUS = 25 -- Радиус круга для перемещений
local JUMP_DELAY = 0.03 -- Задержка между прыжками
local CLONE_LIFETIME = 0.4 -- Время жизни клона
local CLONE_TRANSPARENCY_START = 0.5 -- Начальная прозрачность клона
local CLONE_TRANSPARENCY_END = 1 -- Конечная прозрачность клона (полностью прозрачный)
local CLONE_FADE_TIME = 0.3 -- Время затухания клона

-- Переменные состояния
local effectActive = false
local currentEffectCancellable = nil -- Функция для отмены текущего цикла эффекта
local originalWalkSpeed = Humanoid.WalkSpeed
local originalJumpPower = Humanoid.JumpPower

-- GUI элементы
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local EffectToggleGui = Instance.new("ScreenGui")
EffectToggleGui.Name = "EffectToggleGui"
EffectToggleGui.Parent = PlayerGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 150, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Включить Эффект"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Parent = EffectToggleGui

-- Функция для создания клона персонажа
local function createAfterimage()
    if not Character or not RootPart then return end

    local clone = Character:Clone()
    clone.Name = "Afterimage"
    
    -- Удаляем Humanoid и HumanoidRootPart скрипты
    local humanoidInClone = clone:FindFirstChildOfClass("Humanoid")
    if humanoidInClone then
        humanoidInClone:Destroy()
    end
    
    -- Анкерим все части и устанавливаем CanCollide на false
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
        end
    end

    -- Устанавливаем начальную прозрачность
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = CLONE_TRANSPARENCY_START
        end
    end
    
    -- Анимируем затухание
    local tweenInfo = TweenInfo.new(CLONE_FADE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            TweenService:Create(part, tweenInfo, {Transparency = CLONE_TRANSPARENCY_END}):Play()
        end
    end

    clone.Parent = workspace

    -- Удаляем клон через заданное время
    game:GetService("Debris"):AddItem(clone, CLONE_LIFETIME)
end

-- Функция для перемещения персонажа
local function teleportCharacter(centerPosition)
    if not Character or not RootPart then return end

    local randomAngle = math.random() * math.pi * 2
    local randomRadius = math.random() * EFFECT_RADIUS
    
    local offsetX = math.cos(randomAngle) * randomRadius
    local offsetZ = math.sin(randomAngle) * randomRadius
    
    local newPosition = centerPosition + Vector3.new(offsetX, 0, offsetZ)
    
    RootPart.CFrame = CFrame.new(newPosition)
end

-- Основная логика эффекта
local function startEffect()
    if effectActive then return end
    effectActive = true
    ToggleButton.Text = "Выключить Эффект"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

    -- Отключаем стандартные состояния Humanoid
    originalWalkSpeed = Humanoid.WalkSpeed
    originalJumpPower = Humanoid.JumpPower
    Humanoid.WalkSpeed = 0
    Humanoid.JumpPower = 0
    Humanoid.PlatformStand = true -- Чтобы персонаж не падал

    local effectCenter = RootPart.Position
    local shouldStop = false

    currentEffectCancellable = function()
        shouldStop = true
    end

    task.spawn(function()
        while effectActive and not shouldStop do
            -- Создаем копию перед прыжком
            createAfterimage()
            -- Телепортируем персонажа
            teleportCharacter(effectCenter)
            task.wait(JUMP_DELAY)
        end
        if shouldStop then
            effectActive = false
            ToggleButton.Text = "Включить Эффект"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            Humanoid.WalkSpeed = originalWalkSpeed
            Humanoid.JumpPower = originalJumpPower
            Humanoid.PlatformStand = false
            currentEffectCancellable = nil
        end
    end)
end

local function stopEffect()
    if currentEffectCancellable then
        currentEffectCancellable()
    end
end

-- Подключение кнопки
ToggleButton.Activated:Connect(function()
    if effectActive then
        stopEffect()
    else
        startEffect()
    end
end)

-- Убедимся, что GUI уничтожается при выходе игрока
LocalPlayer.CharacterRemoving:Connect(function()
    stopEffect()
    if EffectToggleGui and EffectToggleGui.Parent then
        EffectToggleGui:Destroy()
    end
end)

-- Если персонаж возрождается, убедимся, что скрипт снова активен
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    -- Привязываем GUI к новому PlayerGui, если он был удален
    if not EffectToggleGui.Parent then
        EffectToggleGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

