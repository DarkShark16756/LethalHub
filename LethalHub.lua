-- GENGAR HUB x FLUENT COM BOTÃO FLUTUANTE FUNCIONAL + ABAS E CALCULADORA COM APAGAR

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Carregar Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Criar a Janela Fluent
local Window = Fluent:CreateWindow({
    Title = "Gengar Hub",
    SubTitle = "Script feito por um brasileiro",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Principal", Icon = "target" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    Combat = Window:AddTab({ Title = "Combate", Icon = "sword" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "package" }),
    Settings = Window:AddTab({ Title = "Config", Icon = "settings" })
}

-- Aba Principal - exemplo
Tabs.Main:AddButton({
    Title = "Mostrar Notificação",
    Description = "Testando o botão",
    Callback = function()
        Fluent:Notify({
            Title = "Funcionando!",
            Content = "O menu foi carregado com sucesso.",
            Duration = 5
        })
    end
})

Tabs.Main:AddToggle("TestToggle", {
    Title = "Alternar Algo",
    Default = false,
    Callback = function(v)
        print("Toggle:", v)
    end
})

-- Aqui você pode adicionar funcionalidades nas abas Visual e Combate, por exemplo:
Tabs.Visual:AddToggle("ESPPlayers", {
    Title = "ESP Players",
    Default = false,
    Callback = function(state)
        -- Exemplo de ativar/desativar ESP aqui
        print("ESP Players:", state)
        -- Coloque o código de ESP para ligar/desligar aqui
    end
})

Tabs.Combat:AddToggle("NoClip", {
    Title = "No Clip",
    Default = false,
    Callback = function(state)
        print("No Clip:", state)
        -- Coloque o código de NoClip para ligar/desligar aqui
    end
})

-- Criar a calculadora (inicialmente invisível)
local calcGui = Instance.new("ScreenGui")
calcGui.Name = "GengarCalculator"
calcGui.ResetOnSpawn = false
calcGui.Parent = CoreGui
calcGui.Enabled = false -- Começa oculta

local calcFrame = Instance.new("Frame")
calcFrame.Size = UDim2.new(0, 220, 0, 330)
calcFrame.Position = UDim2.new(0.4, 0, 0.3, 0)
calcFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
calcFrame.BorderSizePixel = 0
calcFrame.Active = true
calcFrame.Draggable = true
calcFrame.Parent = calcGui

Instance.new("UICorner", calcFrame).CornerRadius = UDim.new(0, 10)

local display = Instance.new("TextLabel")
display.Size = UDim2.new(1, -20, 0, 50)
display.Position = UDim2.new(0, 10, 0, 10)
display.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
display.Text = ""
display.TextSize = 24
display.TextColor3 = Color3.fromRGB(255, 255, 255)
display.TextXAlignment = Enum.TextXAlignment.Right
display.Parent = calcFrame
Instance.new("UICorner", display).CornerRadius = UDim.new(0, 5)

local buttons = {
    {"7","8","9","/"},
    {"4","5","6","*"},
    {"1","2","3","-"},
    {"0",".","←","+"}, -- Adicionei o botão apagar "←"
    {"C","="} -- Limpar (C) e igual (=)
}

local function removeLastChar(str)
    if #str > 0 then
        return str:sub(1, #str-1)
    end
    return str
end

local function clearDisplay()
    display.Text = ""
end

for row = 1, #buttons do
    for col = 1, #buttons[row] do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 45, 0, 45)
        btn.Position = UDim2.new(0, 10 + (col - 1) * 50, 0, 70 + (row - 1) * 50)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.Text = buttons[row][col]
        btn.TextSize = 20
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = calcFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

        btn.MouseButton1Click:Connect(function()
            local txt = btn.Text
            if txt == "=" then
                local success, result = pcall(function()
                    return loadstring("return "..display.Text)()
                end)
                if success then
                    display.Text = tostring(result)
                else
                    display.Text = "Erro"
                end
            elseif txt == "C" then
                clearDisplay()
            elseif txt == "←" then
                display.Text = removeLastChar(display.Text)
            else
                display.Text = display.Text .. txt
            end
        end)
    end
end

-- Toggle para ativar/desativar calculadora na aba Misc
Tabs.Misc:AddToggle("CalcToggle", {
    Title = "Mostrar Calculadora",
    Default = false,
    Callback = function(state)
        calcGui.Enabled = state
    end
})

-- BOTÃO FLUTUANTE (MÓVEL) PARA EXIBIR/OCULTAR MENU
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "GengarFloatingButton"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = CoreGui

local toggleBtn = Instance.new("ImageButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 10, 0.6, 0)
toggleBtn.Image = "rbxassetid://131536021675215" -- Ícone do Gengar
toggleBtn.BackgroundTransparency = 1
toggleBtn.Active = true
toggleBtn.ZIndex = 999
toggleBtn.Parent = toggleGui

local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    toggleBtn.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    if Window and Window.Minimize then
        Window:Minimize()
    end
end)

-- Configuração SaveManager e InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("GengarHubFluent")
SaveManager:SetFolder("GengarHubFluent/Game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
