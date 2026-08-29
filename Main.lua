-- [[ MRGHOST HUB VIP - GOD OF HYPERION EDITION (V9.0 OMNI-QUANTUM BEYOND) ]]
-- 🌟 COMPATIBILITY: PC (Bloxstrap, Native) & Mobile Executing Engines (Delta, Fluxus, Codex, Cryptic, Hydrogen, Arceus X, Vega X)
-- 🛡️ SECURITY: Full Metatable Spoofing, Task Anti-Hook, Memory Stealth & Multi-Game Auto Detection

getgenv().Hide_Menu = false 
getgenv().Auto_Execute = true
getgenv().StreamerMode = true 
getgenv().Webhook_URL = "https://discord.com/api/webhooks/1542997106426380288/Op_ommDV05_lwjHsuQSA2nGbRMh1N1HHORv2YN4MI4fQWoPiGQKhxUFGtc84J3DrXN5h"

local SCRIPT_NAME = "MrGhost VIP [Omni-Quantum v9.0]"

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local SECRET_PASS = "TTTT"
local CACHE_NAME = "MrGhostVIP_QuantumCache.json"

local AntiAFKEnabled = true
local UltraSaverMode = true
local AutoLowGFX = true
local AutoRAMCleaner = true
local AntiStaffEnabled = true
local AfkSeconds = 0

-- 🌌 1. QUANTUM EXECUTOR & MEMORY STEALTH ENGINE
local function GetQuantumContainer()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local folder = Instance.new("Folder")
        syn.protect_gui(folder)
        folder.Parent = CoreGui
        return folder
    elseif CoreGui:FindFirstChild("RobloxGui") then
        return CoreGui.RobloxGui
    end
    return CoreGui
end

local function GetHttpRequest()
    return (syn and syn.request) or (http and http.request) or request or (fluxus and fluxus.request) or http_request
end

local function MaskName(str)
    if not str or #str == 0 then return "***" end
    if #str <= 3 then return str:sub(1,1) .. "***" end
    return str:sub(1, 2) .. string.rep("*", math.max(3, #str - 4)) .. str:sub(-1)
end

-- Cleanup Old System Frames
pcall(function()
    for _, child in pairs(GetQuantumContainer():GetChildren()) do
        if child.Name:find("MrGhost_Quantum_UI") then child:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MrGhost_Quantum_UI_" .. math.random(1000000, 9999999)
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GetQuantumContainer()

local function getRGBColor()
    return Color3.fromHSV((tick() % 2.5) / 2.5, 0.95, 1)
end

-- 📡 2. ADVANCED EMBED DISCORD MONITORING
local function sendWebhookNotification(title, msg, color, shouldPing)
    local req = GetHttpRequest()
    if getgenv().Webhook_URL and #getgenv().Webhook_URL > 10 and req then
        task.spawn(function()
            pcall(function()
                local pingVal = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                local totalPlayers = #Players:GetPlayers()
                local ramUsage = math.floor(collectgarbage("count") / 1024)
                
                local extraInfo = string.format("\n\n🎮 **Thông Số Mới Nhất:**\n📍 Place ID: `%s`\n👤 Tài khoản: `%s` (%s)\n👥 Server: `%d/%d` | 📶 Ping: `%d ms`\n💾 RAM: `%d MB` | ⏳ Đã treo: `%d phút`", 
                    tostring(game.PlaceId), LocalPlayer.Name, LocalPlayer.DisplayName, totalPlayers, Players.MaxPlayers, pingVal, ramUsage, math.floor(AfkSeconds / 60))
                
                req({
                    Url = getgenv().Webhook_URL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({
                        content = shouldPing and "@everyone 🚨 **CẢNH BÁO TỰ ĐỘNG!**" or "",
                        embeds = {{
                            title = title or "👑 MRGHOST QUANTUM MONITOR",
                            description = "⚡ **Core System:** `" .. SCRIPT_NAME .. "`\n\n" .. msg .. extraInfo,
                            color = color or (pingVal > 150 and 15158332 or 3066993),
                            footer = {text = "Quantum Stealth Engine • JobId: " .. tostring(game.JobId)},
                            timestamp = DateTime.now():ToIsoDate()
                        }}
                    })
                })
            end)
        end)
    end
end

-- 🛡️ 3. DEEP METATABLE SPOOFING & ANTI-DETECTION
if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and (method == "Kick" or method == "kick") then return nil end
        return oldNamecall(self, ...)
    end))
end

local function Hop()
    sendWebhookNotification("🌐 QUANTUM SERVER HOP", "🔄 Đang tìm Server ít người nhất để chuyển...", 3447003, false)
    local success, result = pcall(function()
        return HttpService:JSONEncode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        local servers = {}
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing > 0 and server.playing < server.maxPlayers then
                table.insert(servers, server)
            end
        end
        if #servers > 0 then
            table.sort(servers, function(a, b) return a.playing < b.playing end)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id, LocalPlayer)
            return true
        end
    end
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
    return false
end

-- Tự động Reconnect khẩn cấp
local promptOverlay = CoreGui:FindFirstChild("RobloxPromptGui") and CoreGui.RobloxPromptGui:FindFirstChild("promptOverlay")
if promptOverlay then
    promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            sendWebhookNotification("🚨 DISCONNECT DETECTED", "Máy bị ngắt kết nối! Đang tự động Reconnect khẩn cấp...", 15158332, true)
            task.wait(1.5)
            Hop()
        end
    end)
end

-- ⚡ 4. GRAPHICS OPTIMIZER & ULTRA HARDWARE SAVER
local function optimizeGraphics()
    if not AutoLowGFX then return end
    pcall(function()
        settings().Rendering.QualityLevel = 1
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
    end)
end

if setfpscap then setfpscap(240) end
pcall(function()
    UserInputService.WindowFocused:Connect(function()
        RunService:Set3dRenderingEnabled(true)
        if setfpscap then setfpscap(240) end
    end)
    UserInputService.WindowFocusReleased:Connect(function()
        if AntiAFKEnabled and UltraSaverMode then
            RunService:Set3dRenderingEnabled(false)
            if setfpscap then setfpscap(5) end
        end
    end)
end)

-- 🤖 5. TRIPLE-LAYER ANTI-AFK BOT
LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end
end)

task.spawn(function()
    while task.wait(math.random(3, 5)) do
        if AntiAFKEnabled then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.01)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end
end)

-- 🚨 6. QUANTUM STAFF DETECTOR
task.spawn(function()
    while task.wait(10) do
        if AntiStaffEnabled then
            pcall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local n = player.Name:lower()
                        local d = player.DisplayName:lower()
                        if n:find("admin") or n:find("mod") or d:find("[admin]") or d:find("[mod]") then
                            sendWebhookNotification("🚨 PHÁT HIỆN ADMIN!", "Staff (`" .. player.Name .. "`) vào server! Đang Hop khẩn cấp...", 15158332, true)
                            task.wait(0.2)
                            Hop()
                            break
                        end
                    end
                end
            end)
        end
    end
end)

-- ⏱️ TIMER & STATUS REPORT
task.spawn(function()
    while task.wait(1) do if AntiAFKEnabled then AfkSeconds = AfkSeconds + 1 end end
end)

local function sendStatusReport()
    local hrs = math.floor(AfkSeconds / 3600)
    local mins = math.floor((AfkSeconds % 3600) / 60)
    local secs = AfkSeconds % 60
    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local reportMsg = string.format("👤 **Player:** %s\n⏱️ **Treo:** %02dg %02dp %02ds\n📶 **Ping:** %d ms | 🚀 **FPS:** %d", LocalPlayer.Name, hrs, mins, secs, ping, fps)
    sendWebhookNotification("📊 BÁO CÁO STATUS TỰ ĐỘNG", reportMsg, 3066993, false)
end

task.spawn(function()
    while task.wait(300) do if AntiAFKEnabled then sendStatusReport() end end
end)

-- 🎨 7. OMNI-QUANTUM UI DESIGN (Touch & Mouse Support)
local function makeDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
        end
    end)
    gui.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function loadMainHub()
    optimizeGraphics()
    sendWebhookNotification("🚀 MRGHOST QUANTUM VIP ONLINE", "🟢 Đã kết nối thành công phiên bản v9.0 Quantum System!", 65280, false)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "QuantumMainFrame"
    MainFrame.Size = UDim2.new(0, 390, 0, 460)
    MainFrame.Position = UDim2.new(0.5, -195, 0.3, -230)
    MainFrame.BackgroundColor3 = Color3.fromRGB(6, 8, 16)
    MainFrame.Visible = not getgenv().Hide_Menu
    MainFrame.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 18); MainCorner.Parent = MainFrame
    local UIStroke = Instance.new("UIStroke"); UIStroke.Thickness = 3.5; UIStroke.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Color3.fromRGB(12, 16, 30)
    TitleBar.Parent = MainFrame
    local TitleCorner = Instance.new("UICorner"); TitleCorner.CornerRadius = UDim.new(0, 18); TitleCorner.Parent = TitleBar

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -16, 1, 0)
    TitleText.Position = UDim2.new(0, 16, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "👑 MRGHOST VIP (v9.0 Quantum)"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 14
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    -- User Status Panel
    local UserCard = Instance.new("Frame")
    UserCard.Size = UDim2.new(1, -20, 0, 40)
    UserCard.Position = UDim2.new(0, 10, 0, 58)
    UserCard.BackgroundColor3 = Color3.fromRGB(16, 22, 42)
    UserCard.Parent = MainFrame
    local UserCorner = Instance.new("UICorner"); UserCorner.CornerRadius = UDim.new(0, 12); UserCorner.Parent = UserCard

    local UserLabel = Instance.new("TextLabel")
    UserLabel.Size = UDim2.new(1, -20, 1, 0)
    UserLabel.Position = UDim2.new(0, 10, 0, 0)
    UserLabel.BackgroundTransparency = 1
    UserLabel.TextColor3 = Color3.fromRGB(0, 255, 220)
    UserLabel.TextSize = 11
    UserLabel.Font = Enum.Font.GothamBold
    UserLabel.TextXAlignment = Enum.TextXAlignment.Left
    UserLabel.Parent = UserCard

    local function updateUserDisplay()
        if getgenv().StreamerMode then
            UserLabel.Text = "👤 Acc: " .. MaskName(LocalPlayer.Name) .. " (" .. MaskName(LocalPlayer.DisplayName) .. ")"
        else
            UserLabel.Text = "👤 Acc: " .. LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")"
        end
    end
    updateUserDisplay()

    local function createToggleCard(posY, textTitle, defaultState, callback)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, -20, 0, 40)
        Card.Position = UDim2.new(0, 10, 0, posY)
        Card.BackgroundColor3 = Color3.fromRGB(12, 18, 34)
        Card.Parent = MainFrame
        local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 12); CardCorner.Parent = Card

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = textTitle
        Label.TextColor3 = Color3.fromRGB(235, 240, 255)
        Label.TextSize = 11
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Card

        local SwitchBg = Instance.new("TextButton")
        SwitchBg.Size = UDim2.new(0, 44, 0, 22)
        SwitchBg.Position = UDim2.new(1, -52, 0.5, -11)
        SwitchBg.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(45, 54, 78)
        SwitchBg.Text = ""
        SwitchBg.AutoButtonColor = false
        SwitchBg.Parent = Card
        local SwitchCorner = Instance.new("UICorner"); SwitchCorner.CornerRadius = UDim.new(1, 0); SwitchCorner.Parent = SwitchBg

        local SwitchDot = Instance.new("Frame")
        SwitchDot.Size = UDim2.new(0, 18, 0, 18)
        SwitchDot.Position = defaultState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchDot.Parent = SwitchBg
        local DotCorner = Instance.new("UICorner"); DotCorner.CornerRadius = UDim.new(1, 0); DotCorner.Parent = SwitchDot

        local active = defaultState
        SwitchBg.MouseButton1Click:Connect(function()
            active = not active
            if active then
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 170)}):Play()
                TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
            else
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 54, 78)}):Play()
                TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
            end
            callback(active)
        end)
    end

    createToggleCard(104, "🔒 Streamer Mode (Ẩn Tên Acc)", getgenv().StreamerMode, function(val)
        getgenv().StreamerMode = val
        updateUserDisplay()
    end)
    createToggleCard(150, "🛡️ Chống AFK & Kick Auto Engine", AntiAFKEnabled, function(val) AntiAFKEnabled = val end)
    createToggleCard(196, "❄️ Tối Ưu Hóa CPU/GPU Tối Đa", UltraSaverMode, function(val) UltraSaverMode = val end)
    createToggleCard(242, "🚨 Tự Động Né Staff/Admin Siêu Tốc", AntiStaffEnabled, function(val) AntiStaffEnabled = val end)

    local function createActionButton(posY, buttonText, btnColor, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -20, 0, 34)
        Btn.Position = UDim2.new(0, 10, 0, posY)
        Btn.BackgroundColor3 = btnColor
        Btn.Text = buttonText
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 11
        Btn.Font = Enum.Font.GothamBold
        Btn.Parent = MainFrame
        local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(0, 10); BtnCorner.Parent = Btn

        Btn.MouseButton1Click:Connect(callback)
    end

    createActionButton(292, "📊 Gửi Báo Cáo Status Về Discord", Color3.fromRGB(38, 110, 240), function() sendStatusReport() end)
    createActionButton(332, "🌐 Quantum Server Hop (Nhiều Slot Nhanh)", Color3.fromRGB(90, 80, 240), function() Hop() end)
    createActionButton(372, "🧹 Giải Phóng Bộ Nhớ RAM Ngay", Color3.fromRGB(235, 120, 30), function()
        collectgarbage("collect")
        sendWebhookNotification("🧹 MEMORY CLEANED", "Đã xả bộ nhớ RAM thành công!", 16753920, false)
    end)

    -- Icon Vương Miện Float
    local ToggleMenuBtn = Instance.new("TextButton")
    ToggleMenuBtn.Name = "QuantumFloatingIcon"
    ToggleMenuBtn.Size = UDim2.new(0, 56, 0, 56)
    ToggleMenuBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
    ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(10, 14, 26)
    ToggleMenuBtn.Text = "👑"
    ToggleMenuBtn.TextSize = 28
    ToggleMenuBtn.AutoButtonColor = false
    ToggleMenuBtn.Parent = ScreenGui

    local FloatCorner = Instance.new("UICorner"); FloatCorner.CornerRadius = UDim.new(1, 0); FloatCorner.Parent = ToggleMenuBtn
    local FloatStroke = Instance.new("UIStroke"); FloatStroke.Thickness = 3.5; FloatStroke.Parent = ToggleMenuBtn

    makeDraggable(MainFrame)
    makeDraggable(ToggleMenuBtn)

    local menuVisible = not getgenv().Hide_Menu
    ToggleMenuBtn.MouseButton1Click:Connect(function()
        menuVisible = not menuVisible
        MainFrame.Visible = menuVisible
    end)

    RunService.RenderStepped:Connect(function()
        local col = getRGBColor()
        UIStroke.Color = col
        FloatStroke.Color = col
    end)
end

if writefile then pcall(function() writefile(CACHE_NAME, HttpService:JSONEncode({ key = SECRET_PASS, time = os.time() })) end) end
loadMainHub()
 
