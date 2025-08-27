local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer

-- Maid simples
local function newMaid()
local m = {cons = {}, inst = {}}
function m:GiveConnection(c) table.insert(self.cons, c) end
function m:GiveInstance(i) table.insert(self.inst, i) end
function m:Cleanup()
for _,c in ipairs(self.cons) do pcall(function() c:Disconnect() end) end
for _,i in ipairs(self.inst) do pcall(function() i:Destroy() end) end
self.cons = {}; self.inst = {}
end
return m
end

-- Carregar Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Janela Fluent
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
Main     = Window:AddTab({ Title = "Principal", Icon = "target" }),
Visual   = Window:AddTab({ Title = "Visual",    Icon = "eye" }),
Combat   = Window:AddTab({ Title = "Combate",   Icon = "sword" }),
Misc     = Window:AddTab({ Title = "Misc",      Icon = "package" }),
Scripts  = Window:AddTab({ Title = "Scripts",   Icon = "file" }), -- nova aba Scripts
Settings = Window:AddTab({ Title = "Config",    Icon = "settings" })
}

-- ---------- Exemplos na aba Main ----------
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
Callback = function(v) print("Toggle:", v) end
})

-- ======================
-- VISUAL — ESP PLAYERS
-- ======================
local ESP_Maid = newMaid()
local espEnabled = false

local function attachHighlight(char)
if not char or not char.Parent then return end
if char:FindFirstChild("GengarESP_Highlight") then return end
local h = Instance.new("Highlight")
h.Name = "GengarESP_Highlight"
h.FillColor = Color3.fromRGB(255,170,0)
h.FillTransparency = 0.7
h.OutlineColor = Color3.fromRGB(255,255,255)
h.OutlineTransparency = 0
h.Adornee = char
h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
h.Parent = char
ESP_Maid:GiveInstance(h)
end

local function enableESP()
ESP_Maid:Cleanup()
for _,plr in ipairs(Players:GetPlayers()) do
if plr ~= lp then
if plr.Character then attachHighlight(plr.Character) end
ESP_Maid:GiveConnection(plr.CharacterAdded:Connect(function(char)
char:WaitForChild("HumanoidRootPart", 10)
attachHighlight(char)
end))
end
end
ESP_Maid:GiveConnection(Players.PlayerAdded:Connect(function(plr)
if plr == lp then return end
ESP_Maid:GiveConnection(plr.CharacterAdded:Connect(function(char)
char:WaitForChild("HumanoidRootPart", 10)
attachHighlight(char)
end))
end))
end

local function disableESP()
ESP_Maid:Cleanup()
for _,plr in ipairs(Players:GetPlayers()) do
if plr.Character then
local h = plr.Character:FindFirstChild("GengarESP_Highlight")
if h then pcall(function() h:Destroy() end) end
end
end
end

Tabs.Visual:AddToggle("ESPPlayers", {
Title = "ESP Players",
Default = false,
Callback = function(state)
espEnabled = state
if state then enableESP() else disableESP() end
end
})

-- =========================
-- COMBATE — AIMBOT e outros
-- =========================

-- variáveis/maids
local AIM_Maid = newMaid()
local aimbotOn = false

local function startAimbot()
AIM_Maid:Cleanup()
local cam = workspace.CurrentCamera
AIM_Maid:GiveConnection(RunService.RenderStepped:Connect(function()
if not aimbotOn then return end
if not lp.Character or not lp.Character:FindFirstChild("Head") then return end

local closestHead = nil  
    local shortest = math.huge  
    local myPos = lp.Character.Head.Position  

    for _,plr in ipairs(Players:GetPlayers()) do  
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild("Head") then  
            local head = plr.Character.Head  
            local mag = (myPos - head.Position).Magnitude  
            if mag < shortest then  
                shortest = mag  
                closestHead = head  
            end  
        end  
    end  

    if closestHead and closestHead.Parent then  
        pcall(function()  
            cam.CFrame = CFrame.new(cam.CFrame.Position, closestHead.Position)  
        end)  
    end  
end))

end

local function stopAimbot()
AIM_Maid:Cleanup()
end

-- NoClip
local NC_Maid = newMaid()
local noclipOn = false
local function setCharacterCollide(char, canCollide)
for _,v in ipairs(char:GetDescendants()) do
if v:IsA("BasePart") then v.CanCollide = canCollide end
end
end
local function startNoClip()
NC_Maid:Cleanup()
if lp.Character then setCharacterCollide(lp.Character, false) end
NC_Maid:GiveConnection(RunService.Stepped:Connect(function()
if noclipOn and lp.Character then setCharacterCollide(lp.Character, false) end
end))
NC_Maid:GiveConnection(lp.CharacterAdded:Connect(function(char)
char:WaitForChild("Humanoid", 10)
if noclipOn then setCharacterCollide(char, false) end
end))
end
local function stopNoClip()
NC_Maid:Cleanup()
if lp.Character then setCharacterCollide(lp.Character, true) end
end

-- Infinite Jump
local IJ_Maid = newMaid()
local infJumpOn = false
local function startInfJump()
IJ_Maid:Cleanup()
IJ_Maid:GiveConnection(UserInputService.JumpRequest:Connect(function()
if infJumpOn and lp.Character then
local hum = lp.Character:FindFirstChildOfClass("Humanoid")
if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end
end))
end
local function stopInfJump() IJ_Maid:Cleanup() end

-- Speed 2x
local SPEED_Maid = newMaid()
local speedOn = false
local normalWalk = 16
local function setWalkSpeed(v)
if lp.Character then
local hum = lp.Character:FindFirstChildOfClass("Humanoid")
if hum then hum.WalkSpeed = v end
end
end
local function startSpeed()
SPEED_Maid:Cleanup()
setWalkSpeed(32)
SPEED_Maid:GiveConnection(lp.CharacterAdded:Connect(function(char)
local hum = char:WaitForChild("Humanoid", 10)
if speedOn and hum then hum.WalkSpeed = 32 end
end))
end
local function stopSpeed()
SPEED_Maid:Cleanup()
setWalkSpeed(normalWalk)
end

-- Fly
local FLY_Maid = newMaid()
local flyOn = false
local flySpeed = 50
local function startFly()
FLY_Maid:Cleanup()
local function setup(char)
local hum = char:WaitForChild("Humanoid", 10)
local root = char:WaitForChild("HumanoidRootPart", 10)
if not hum or not root then return end

hum.PlatformStand = true  
    local bg = Instance.new("BodyGyro")  
    bg.P = 9e4  
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)  
    bg.CFrame = root.CFrame  
    bg.Parent = root  
    local bv = Instance.new("BodyVelocity")  
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)  
    bv.Velocity = Vector3.new(0,0.1,0)  
    bv.Parent = root  

    FLY_Maid:GiveInstance(bg)  
    FLY_Maid:GiveInstance(bv)  

    FLY_Maid:GiveConnection(RunService.RenderStepped:Connect(function()  
        if not flyOn then return end  
        local cam = workspace.CurrentCamera  
        local dir = Vector3.new(0,0,0)  
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end  
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end  
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end  
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end  
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end  
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end  

        if dir.Magnitude > 0 then  
            dir = dir.Unit * flySpeed  
        end  
        bv.Velocity = dir  
        bg.CFrame = cam.CFrame  
    end))  
end  

if lp.Character then setup(lp.Character) end  
FLY_Maid:GiveConnection(lp.CharacterAdded:Connect(function(char)  
    if flyOn then task.defer(function() setup(char) end) end  
end))

end
local function stopFly()
FLY_Maid:Cleanup()
if lp.Character then
local hum = lp.Character:FindFirstChildOfClass("Humanoid")
if hum then hum.PlatformStand = false end
end
end

-- ======================
-- Botões toggles na aba Combate
-- ======================

-- helper: set Fluent toggle programaticamente (se disponível)
local function setFluentToggle(key, value)
pcall(function()
if Fluent and Fluent.Options and Fluent.Options[key] and Fluent.Options[key].SetValue then
Fluent.Options[key]:SetValue(value)
end
end)
end

Tabs.Combat:AddToggle("Aimbot", {
Title = "🎯 Aimbot",
Default = false,
Callback = function(state)
aimbotOn = state
if state then
startAimbot()
-- mostrar botão flutuante
pcall(function() getgenv().ShowAimbotFloatingButton() end)
else
stopAimbot()
pcall(function() getgenv().HideAimbotFloatingButton() end)
end
end
})

Tabs.Combat:AddToggle("NoClip", {
Title = "🌀 No Clip",
Default = false,
Callback = function(state)
noclipOn = state
if state then startNoClip() else stopNoClip() end
end
})

Tabs.Combat:AddToggle("InfJump", {
Title = "⛷️ Infinite Jump",
Default = false,
Callback = function(state)
infJumpOn = state
if state then startInfJump() else stopInfJump() end
end
})

Tabs.Combat:AddToggle("Fly", {
Title = "🪂 Fly (WASD/Space/Ctrl)",
Default = false,
Callback = function(state)
flyOn = state
if state then startFly() else stopFly() end
end
})

Tabs.Combat:AddToggle("Speed2x", {
Title = "⚡ Velocidade 2x",
Default = false,
Callback = function(state)
speedOn = state
if state then startSpeed() else stopSpeed() end
end
})

-- ======================
-- BOTÃO FLUTUANTE DO AIMBOT (aparece no canto superior direito)
-- ======================

-- Guardar GUI para poder remover
local AimbotButtonGui = nil

-- Remove se existir
local function removeAimbotButton()
if AimbotButtonGui then
pcall(function() AimbotButtonGui:Destroy() end)
AimbotButtonGui = nil
end
end

-- Criar botão (não transparente, arredondado vermelho)
local function createAimbotButton()
removeAimbotButton()

-- tentar CoreGui, fallback PlayerGui  
local parentOK, parent = pcall(function() return CoreGui end)  
parent = parentOK and CoreGui or (lp:FindFirstChild("PlayerGui") or Players.LocalPlayer:WaitForChild("PlayerGui"))  

local gui = Instance.new("ScreenGui")  
gui.Name = "GengarAimbotButton"  
gui.ResetOnSpawn = false  
gui.Parent = parent  

local btn = Instance.new("TextButton", gui)  
btn.Name = "AimbotToggleBtn"  
btn.Size = UDim2.new(0, 56, 0, 56)  
btn.Position = UDim2.new(1, -70, 0, 10) -- canto superior direito com offset  
btn.AnchorPoint = Vector2.new(1, 0)  
btn.BackgroundColor3 = Color3.fromRGB(200, 30, 30) -- vermelho  
btn.BackgroundTransparency = 0  
btn.BorderSizePixel = 0  
btn.Text = "🎯" -- ícone de mira (emoji)  
btn.TextSize = 28  
btn.Font = Enum.Font.SourceSansBold  
btn.TextColor3 = Color3.fromRGB(255,255,255)  
btn.AutoButtonColor = true  
btn.ZIndex = 9999  

local corner = Instance.new("UICorner", btn)  
corner.CornerRadius = UDim.new(1, 0) -- totalmente arredondado  

local stroke = Instance.new("UIStroke", btn)  
stroke.Thickness = 1  
stroke.Transparency = 0.6  
stroke.Color = Color3.fromRGB(0,0,0)  

-- indicador de estado visual:  
local stateDot = Instance.new("Frame", btn)  
stateDot.Size = UDim2.new(0,12,0,12)  
stateDot.Position = UDim2.new(1, -18, 0, 6)  
stateDot.AnchorPoint = Vector2.new(1,0)  
stateDot.BackgroundColor3 = aimbotOn and Color3.fromRGB(0,200,0) or Color3.fromRGB(120,120,120)  
stateDot.BorderSizePixel = 0  
Instance.new("UICorner", stateDot).CornerRadius = UDim.new(1,0)  

-- clique alterna o aimbot  
btn.MouseButton1Click:Connect(function()  
    aimbotOn = not aimbotOn  
    if aimbotOn then  
        startAimbot()  
        stateDot.BackgroundColor3 = Color3.fromRGB(0,200,0)  
        setFluentToggle("Aimbot", true)  
    else  
        stopAimbot()  
        stateDot.BackgroundColor3 = Color3.fromRGB(120,120,120)  
        setFluentToggle("Aimbot", false)  
    end  
end)  

AimbotButtonGui = gui

end

-- Expor funções globais para uso por outras partes do script
getgenv().ShowAimbotFloatingButton = function()
-- criar apenas se ainda não existir
if not AimbotButtonGui then createAimbotButton() end
end
getgenv().HideAimbotFloatingButton = function()
removeAimbotButton()
end

-- Se o toggle já estiver ligado (recarregar script), garantir botão visível
if aimbotOn then getgenv().ShowAimbotFloatingButton() end

-- ======================
-- CALCULADORA (igual antes)
-- ======================
local calcGui = Instance.new("ScreenGui")
calcGui.Name = "GengarCalculator"
calcGui.ResetOnSpawn = false
calcGui.Parent = CoreGui
calcGui.Enabled = false

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
{"0",".","←","+"},
{"C","="}
}
local function removeLastChar(str) if #str > 0 then return str:sub(1, #str-1) end return str end
local function clearDisplay() display.Text = "" end

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
local success, result = pcall(function() return loadstring("return "..display.Text)() end)
display.Text = success and tostring(result) or "Erro"
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

Tabs.Misc:AddToggle("CalcToggle", {
Title = "Mostrar Calculadora",
Default = false,
Callback = function(state) calcGui.Enabled = state end
})

-- ======================
-- SCRIPTS TAB (esqueleto para seus scripts específicos)
-- ======================
Tabs.Scripts:AddParagraph({
Title = "Scripts específicos",
Content = "Coloque seus scripts de jogos aqui. Ex.: LuckyBlock, Benverse, ProjectSmash. Use botões abaixo para carregar."
})

Tabs.Scripts:AddButton({
Title = "Exemplo: Script para Jogo X (placeholder)",
Description = "Clique para executar (substitua o callback pelo seu loadstring).",
Callback = function()
Fluent:Notify({Title="Scripts", Content="Placeholder executado (substitua pelo seu script).", Duration=3})
-- aqui você pode executar: loadstring(game:HttpGet("RAW_URL"))()
end
})

-- ======================
-- BOTÃO FLUTUANTE DO HUB (mantido)
-- ======================
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "GengarFloatingButton"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = CoreGui

local toggleBtn = Instance.new("ImageButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 10, 0.6, 0)
toggleBtn.Image = "rbxassetid://131536021675215"
toggleBtn.BackgroundTransparency = 1
toggleBtn.Active = true
toggleBtn.ZIndex = 999
toggleBtn.Parent = toggleGui

local dragging, dragInput, dragStart, startPos
local function update(input)
local delta = input.Position - dragStart
toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
toggleBtn.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true; dragStart = input.Position; startPos = toggleBtn.Position
input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging=false end end)
end
end)
toggleBtn.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
toggleBtn.MouseButton1Click:Connect(function() if Window and Window.Minimize then Window:Minimize() end end)

-- ======================
-- SaveManager / InterfaceManager
-- ======================
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

-- Notificação final
Fluent:Notify({ Title = "Gengar Hub", Content = "Atualizado: Aimbot flutuante pronto. Teste com cuidado.", Duration = 4 })
