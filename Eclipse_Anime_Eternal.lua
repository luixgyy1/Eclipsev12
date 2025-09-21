-- 🌌 Eclipse - Anime Eternal Script 🌑
-- Versão Mobile Otimizada
-- [Seu nome ou nickname aqui]
-- Versão: 2.1 Mobile Premium

-- Configurações iniciais
getgenv().Eclipse = {
    KillAura = true,
    AutoRank = true,
    Range = 30,
    AttackCooldown = 0.3,
    RankUpCooldown = 5,
    Theme = "Dark",
    UISize = "Normal"
}

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

-- Variáveis de controle
local killAuraConnection
local rankUpLoop
local lastAttack = 0
local uiHidden = false
local dragging, dragInput, dragStart, startPos
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Verificação de segurança
if not ReplicatedStorage:FindFirstChild("Remotes") then
    warn("⚠️ Remotes não encontrados! Verifique se está no jogo correto.")
    return
end

-- Detectar se é mobile e ajustar configurações
if isMobile then
    getgenv().Eclipse.UISize = "Large"
    getgenv().Eclipse.Theme = "Dark"
end

-- Função de notificação
function Notify(title, text, duration)
    duration = duration or 5
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration,
        Icon = "rbxassetid://7072716642"
    })
end

-- Função para criar a interface
function CreateUI()
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj.Name == "EclipseUI" then
            obj:Destroy()
        end
    end

    local uiWidth = isMobile and 400 or 350
    local uiHeight = isMobile and 450 or 400
    local headerHeight = isMobile and 50 or 40
    local toggleHeight = isMobile and 70 or 60
    local sliderHeight = isMobile and 70 or 60
    local buttonHeight = isMobile and 40 or 30
    local textSize = isMobile and 16 or 14
    local titleSize = isMobile and 18 or 16

    local themes = {
        Dark = {
            Background = Color3.fromRGB(30, 30, 40),
            Header = Color3.fromRGB(20, 20, 30),
            Text = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(0, 170, 255),
            ToggleOn = Color3.fromRGB(0, 200, 100),
            ToggleOff = Color3.fromRGB(200, 60, 60),
            Border = Color3.fromRGB(60, 60, 80)
        },
        Light = {
            Background = Color3.fromRGB(240, 240, 245),
            Header = Color3.fromRGB(220, 220, 230),
            Text = Color3.fromRGB(40, 40, 50),
            Accent = Color3.fromRGB(0, 120, 215),
            ToggleOn = Color3.fromRGB(0, 180, 80),
            ToggleOff = Color3.fromRGB(220, 80, 80),
            Border = Color3.fromRGB(200, 200, 210)
        },
        Purple = {
            Background = Color3.fromRGB(40, 30, 50),
            Header = Color3.fromRGB(30, 20, 40),
            Text = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(170, 0, 255),
            ToggleOn = Color3.fromRGB(140, 0, 255),
            ToggleOff = Color3.fromRGB(100, 30, 100),
            Border = Color3.fromRGB(70, 50, 90)
        }
    }
    
    local theme = themes[getgenv().Eclipse.Theme] or themes.Dark

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EclipseUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, uiWidth, 0, uiHeight)
    MainFrame.Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = theme.Border
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, headerHeight)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = theme.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 250, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🌌 Eclipse Script v2.1"
    Title.TextColor3 = theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = titleSize
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local StatusFrame = Instance.new("Frame")
    StatusFrame.Name = "StatusFrame"
    StatusFrame.Size = UDim2.new(0, 60, 1, 0)
    StatusFrame.Position = UDim2.new(1, -65, 0, 0)
    StatusFrame.BackgroundTransparency = 1
    StatusFrame.Parent = Header
    
    local KillAuraStatus = Instance.new("Frame")
    KillAuraStatus.Name = "KillAuraStatus"
    KillAuraStatus.Size = UDim2.new(0, 20, 0, 20)
    KillAuraStatus.Position = UDim2.new(0, 5, 0.5, -10)
    KillAuraStatus.BackgroundColor3 = getgenv().Eclipse.KillAura and theme.ToggleOn or theme.ToggleOff
    KillAuraStatus.BorderSizePixel = 0
    KillAuraStatus.Parent = StatusFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 10)
    StatusCorner.Parent = KillAuraStatus
    
    local KillAuraLabel = Instance.new("TextLabel")
    KillAuraLabel.Name = "KillAuraLabel"
    KillAuraLabel.Size = UDim2.new(0, 30, 1, 0)
    KillAuraLabel.Position = UDim2.new(0, 25, 0, 0)
    KillAuraLabel.BackgroundTransparency = 1
    KillAuraLabel.Text = "KA"
    KillAuraLabel.TextColor3 = theme.Text
    KillAuraLabel.Font = Enum.Font.GothamBold
    KillAuraLabel.TextSize = 12
    KillAuraLabel.TextXAlignment = Enum.TextXAlignment.Left
    KillAuraLabel.Parent = StatusFrame
    
    local AutoRankStatus = Instance.new("Frame")
    AutoRankStatus.Name = "AutoRankStatus"
    AutoRankStatus.Size = UDim2.new(0, 20, 0, 20)
    AutoRankStatus.Position = UDim2.new(0, 60, 0.5, -10)
    AutoRankStatus.BackgroundColor3 = getgenv().Eclipse.AutoRank and theme.ToggleOn or theme.ToggleOff
    AutoRankStatus.BorderSizePixel = 0
    AutoRankStatus.Parent = StatusFrame
    
    local StatusCorner2 = Instance.new("UICorner")
    StatusCorner2.CornerRadius = UDim.new(0, 10)
    StatusCorner2.Parent = AutoRankStatus
    
    local AutoRankLabel = Instance.new("TextLabel")
    AutoRankLabel.Name = "AutoRankLabel"
    AutoRankLabel.Size = UDim2.new(0, 30, 1, 0)
    AutoRankLabel.Position = UDim2.new(0, 80, 0, 0)
    AutoRankLabel.BackgroundTransparency = 1
    AutoRankLabel.Text = "AR"
    AutoRankLabel.TextColor3 = theme.Text
    AutoRankLabel.Font = Enum.Font.GothamBold
    AutoRankLabel.TextSize = 12
    AutoRankLabel.TextXAlignment = Enum.TextXAlignment.Left
    AutoRankLabel.Parent = StatusFrame

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, isMobile and 40 or 30, 0, isMobile and 40 or 30)
    MinimizeButton.Position = UDim2.new(1, -45, 0, 5)
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = theme.Text
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = isMobile and 22 or 18
    MinimizeButton.Parent = Header
    
    MinimizeButton.MouseButton1Click:Connect(function()
        ToggleUI()
    end)

    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 1, -headerHeight - 10)
    Content.Position = UDim2.new(0, 10, 0, headerHeight + 10)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 6
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.Parent = MainFrame

    function CreateToggle(name, description, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = name .. "Toggle"
        ToggleFrame.Size = UDim2.new(1, 0, 0, toggleHeight)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = Content
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Name = "Label"
        ToggleLabel.Size = UDim2.new(0.7, 0, 0, 30)
        ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = theme.Text
        ToggleLabel.Font = Enum.Font.GothamSemibold
        ToggleLabel.TextSize = textSize
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame
        
        local ToggleDesc = Instance.new("TextLabel")
        ToggleDesc.Name = "Description"
        ToggleDesc.Size = UDim2.new(0.7, 0, 0, 25)
        ToggleDesc.Position = UDim2.new(0, 0, 0, 30)
        ToggleDesc.BackgroundTransparency = 1
        ToggleDesc.Text = description
        ToggleDesc.TextColor3 = theme.Text
        ToggleDesc.TextTransparency = 0.3
        ToggleDesc.Font = Enum.Font.Gotham
        ToggleDesc.TextSize = textSize - 2
        ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
        ToggleDesc.Parent = ToggleFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Size = UDim2.new(0, isMobile and 70 or 50, 0, isMobile and 35 or 25)
        ToggleButton.Position = UDim2.new(1, -isMobile and -75 or -50, 0, isMobile and 17 or 17)
        ToggleButton.BackgroundColor3 = default and theme.ToggleOn or theme.ToggleOff
        ToggleButton.AutoButtonColor = false
        ToggleButton.Text = ""
        ToggleButton.Parent = ToggleFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 12)
        ToggleCorner.Parent = ToggleButton
        
        local ToggleDot = Instance.new("Frame")
        ToggleDot.Name = "ToggleDot"
        ToggleDot.Size = UDim2.new(0, isMobile and 25 or 19, 0, isMobile and 25 or 19)
        ToggleDot.Position = UDim2.new(0, default and (isMobile and 40 or 26) or (isMobile and 5 or 5), 0, isMobile and 5 or 3)
        ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleDot.Parent = ToggleButton
        
        local DotCorner = Instance.new("UICorner")
        DotCorner.CornerRadius = UDim.new(0, 10)
        DotCorner.Parent = ToggleDot
        
        ToggleButton.MouseButton1Click:Connect(function()
            local newValue = not getgenv().Eclipse[name]
            getgenv().Eclipse[name] = newValue
            
            if name == "KillAura" then
                KillAuraStatus.BackgroundColor3 = newValue and theme.ToggleOn or theme.ToggleOff
            elseif name == "AutoRank" then
                AutoRankStatus.BackgroundColor3 = newValue and theme.ToggleOn or theme.ToggleOff
            end
            
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(ToggleDot, tweenInfo, {
                Position = UDim2.new(0, newValue and (isMobile and 40 or 26) or (isMobile and 5 or 5), 0, isMobile and 5 or 3)
            })
            tween:Play()
            
            ToggleButton.BackgroundColor3 = newValue and theme.ToggleOn or theme.ToggleOff
            
            if callback then
                callback(newValue)
            end
        end)
        
        return ToggleFrame
    end

    function CreateSlider(name, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = name .. "Slider"
        SliderFrame.Size = UDim2.new(1, 0, 0, sliderHeight)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = Content
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Name = "Label"
        SliderLabel.Size = UDim2.new(1, 0, 0, 30)
        SliderLabel.Position = UDim2.new(0, 0, 0, 0)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = name .. ": " .. default
        SliderLabel.TextColor3 = theme.Text
        SliderLabel.Font = Enum.Font.GothamSemibold
        SliderLabel.TextSize = textSize
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame
        
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Name = "Track"
        SliderTrack.Size = UDim2.new(1, 0, 0, isMobile and 10 or 5)
        SliderTrack.Position = UDim2.new(0, 0, 0, 35)
        SliderTrack.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        SliderTrack.Parent = SliderFrame
        
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(0, 5)
        TrackCorner.Parent = SliderTrack
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "Fill"
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        SliderFill.Position = UDim2.new(0, 0, 0, 0)
        SliderFill.BackgroundColor3 = theme.Accent
        SliderFill.Parent = SliderTrack
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 5)
        FillCorner.Parent = SliderFill
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Name = "SliderButton"
        SliderButton.Size = UDim2.new(0, isMobile and 30 or 20, 0, isMobile and 30 or 20)
        SliderButton.Position = UDim2.new((default - min) / (max - min), -isMobile and 15 or 10, 0, isMobile and -10 or -7)
        SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderButton.Text = ""
        SliderButton.Parent = SliderTrack
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 15)
        ButtonCorner.Parent = SliderButton
        
        local dragging = false
        
        local function updateValue(value)
            local percent = math.clamp((value - min) / (max - min), 0, 1)
            local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            local fillTween = TweenService:Create(SliderFill, tweenInfo, {Size = UDim2.new(percent, 0, 1, 0)})
            local buttonTween = TweenService:Create(SliderButton, tweenInfo, {Position = UDim2.new(percent, -isMobile and 15 or 10, 0, isMobile and -10 or -7)})
            
            fillTween:Play()
            buttonTween:Play()
            
            SliderLabel.Text = name .. ": " .. math.floor(value * 10) / 10
            getgenv().Eclipse[name] = value
            if callback then
                callback(value)
            end
        end
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        SliderTrack.MouseButton1Down:Connect(function(x, y)
            local percent = (x - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
            updateValue(min + (max - min) * percent)
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local percent = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
                updateValue(min + (max - min) * math.clamp(percent, 0, 1))
            end
        end)
        
        return SliderFrame
    end

    local KillAuraToggle = CreateToggle("KillAura", "Ataca inimigos automaticamente", getgenv().Eclipse.KillAura, function(value)
        if value then
            StartKillAura()
        else
            StopKillAura()
        end
    end)
    
    local AutoRankToggle = CreateToggle("AutoRank", "Sobe de rank automaticamente", getgenv().Eclipse.AutoRank, function(value)
        if value then
            StartRankUp()
        else
            StopRankUp()
        end
    end)
    
    local RangeSlider = CreateSlider("Range", 10, 50, getgenv().Eclipse.Range, function(value)
    end)
    
    local AttackCooldownSlider = CreateSlider("AttackCooldown", 0.1, 1, getgenv().Eclipse.AttackCooldown, function(value)
    end)
    
    local RankUpCooldownSlider = CreateSlider("RankUpCooldown", 1, 10, getgenv().Eclipse.RankUpCooldown, function(value)
    end)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = Content
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(1, -20, 0, buttonHeight)
    CloseButton.Position = UDim2.new(0, 10, 1, -buttonHeight - 10)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    CloseButton.Text = "FECHAR SCRIPT"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = textSize
    CloseButton.Parent = MainFrame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        if isMobile then
            local answer = confirm("Tem certeza que deseja fechar o script?")
            if answer then
                StopScript()
            end
        else
            StopScript()
        end
    end)
    
    function confirm(message)
        Notify("Confirmação", message, 3)
        return true
    end
    
    local function updateInput(input)
        if not MainFrame or not MainFrame.Parent then return end
        
        local delta = (input.Position - dragStart)
        if isMobile then
            delta = delta * 0.7
        end
        
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end
    
    if isMobile then
        local ToggleUIButton = Instance.new("TextButton")
        ToggleUIButton.Name = "ToggleUIButton"
        ToggleUIButton.Size = UDim2.new(0, 50, 0, 50)
        ToggleUIButton.Position = UDim2.new(1, -60, 0, 10)
        ToggleUIButton.BackgroundColor3 = theme.Accent
        ToggleUIButton.Text = "🌌"
        ToggleUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleUIButton.Font = Enum.Font.GothamBold
        ToggleUIButton.TextSize = 20
        ToggleUIButton.Parent = ScreenGui
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 25)
        ToggleCorner.Parent = ToggleUIButton
        
        ToggleUIButton.MouseButton1Click:Connect(function()
            ToggleUI()
        end)
    end
    
    return ScreenGui
end

function ToggleUI()
    local EclipseUI = CoreGui:FindFirstChild("EclipseUI")
    if not EclipseUI then return end
    
    local MainFrame = EclipseUI:FindFirstChild("MainFrame")
    if not MainFrame then return end
    
    uiHidden = not uiHidden
    
    local targetSize = uiHidden and UDim2.new(0, MainFrame.AbsoluteSize.X, 0, 50) or UDim2.new(0, MainFrame.AbsoluteSize.X, 0, 450)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = targetSize})
    tween:Play()
end

function StartKillAura()
    if killAuraConnection then return end
    
    killAuraConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().Eclipse.KillAura then return end
        
        pcall(function()
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then
                return
            end
            
            local playerHRP = character.HumanoidRootPart
            local currentTime = tick()
            
            local closestEnemy, closestDistance = nil, math.huge
            
            for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                    local distance = (playerHRP.Position - enemy.HumanoidRootPart.Position).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestEnemy = enemy
                    end
                end
            end
            
            if closestEnemy and closestDistance <= getgenv().Eclipse.Range and currentTime - lastAttack >= getgenv().Eclipse.AttackCooldown then
                ReplicatedStorage.Remotes.Attack:FireServer(closestEnemy)
                lastAttack = currentTime
            end
        end)
    end)
end

function StopKillAura()
    if killAuraConnection then
        killAuraConnection:Disconnect()
        killAuraConnection = nil
    end
end

function StartRankUp()
    if rankUpLoop then return end
    
    rankUpLoop = task.spawn(function()
        while true do
            if not getgenv().Eclipse.AutoRank then
                break
            end
            
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
                    ReplicatedStorage.Remotes.RankUp:FireServer()
                end
            end)
            
            task.wait(getgenv().Eclipse.RankUpCooldown)
        end
        rankUpLoop = nil
    end)
end

function StopRankUp()
    if rankUpLoop then
        task.cancel(rankUpLoop)
        rankUpLoop = nil
    end
end

function StopScript()
    StopKillAura()
    StopRankUp()
    
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj.Name == "EclipseUI" then
            obj:Destroy()
        end
    end
    
    Notify("🌌 Eclipse", "Script parado com sucesso!", 5)
    print("🌌 Eclipse Script parado com sucesso!")
end

CreateUI()

if getgenv().Eclipse.KillAura then
    StartKillAura()
end

if getgenv().Eclipse.AutoRank then
    StartRankUp()
end

Notify("🌌 Eclipse", "Script carregado com sucesso!\nUse a interface para controlar as funções.", 5)

if not isMobile then
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F then
            ToggleUI()
        end
    end)
end

print("🌌 Eclipse Script carregado com sucesso!")
print("📱 Modo Mobile: " .. tostring(isMobile))
print("📋 Comandos:")
if not isMobile then
    print("  - F: Mostrar/Ocultar interface")
else
    print("  - Toque no botão 🌌 para mostrar/ocultar interface")
end
print("  - Use a interface para controlar todas as funções")
