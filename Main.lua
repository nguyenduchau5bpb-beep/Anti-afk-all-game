-- [[ MRGHOST HUB VIP - GOD OF HYPERION EDITION (V5.7 SCRIPT TAG) ]]
getgenv().Hide_Menu = false
getgenv().Auto_Execute = true
getgenv().Webhook_URL = "https://discord.com/api/webhooks/1542997106426380288/Op_ommDV05_lwjHsuQSA2nGbRMh1N1HHORv2YN4MI4fQWoPiGQKhxUFGtc84J3DrXN5h"

-- Tên script để phân biệt khi bạn treo nhiều acc / nhiều script khác nhau
local SCRIPT_NAME = "MrGhost Hub VIP (Anti AFK & Auto Hop)"

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
local CACHE_NAME = "MrGhostVIP_GodHyperionCache.json"
local EXPIRE_TIME = 86400

local AntiAFKEnabled = true
local UltraSaverMode = true
local AutoLowGFX = true
local AutoRAMCleaner = true
local AfkSeconds = 0

pcall(function()
    if CoreGui:FindFirstChild("MrGhost_God_UI") then CoreGui["MrGhost_God_UI"]:Destroy() end
    if LocalPlayer.PlayerGui:FindFirstChild("MrGhost_God_UI") then LocalPlayer.PlayerGui["MrGhost_God_UI"]:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MrGhost_God_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local function getRGBColor()
    return Color3.fromHSV((tick() % 3) / 3, 1, 1)
end

local function savePass()
    if writefile then
        pcall(function() writefile(CACHE_NAME, HttpService:JSONEncode({ key = SECRET_PASS, time = os.time() })) end)
    end
end

-- Đã tích hợp thêm dòng Tên Script vào Webhook
local function sendWebhookNotification(title, msg, color, shouldPing)
    local http_request = (syn and syn.request) or (http and http.request) or request or http_request
    if getgenv().Webhook_URL and #getgenv().Webhook_URL > 10 and http_request then
        pcall(function()
            local fullMsg = "📌 **Script:** `" .. SCRIPT_NAME .. "`\n\n" .. msg
            http_request({
                Url = getgenv().Webhook_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    content = shouldPing and "@everyone" or "",
                    embeds = {{
                        title = title or "⚡ MRGHOST HUB VIP LOGGER",
                        description = fullMsg,
                        color = color or 16711800,
                        footer = {text = "User: " .. LocalPlayer.Name .. " | JobId: " .. tostring(game.JobId)},
                        timestamp = DateTime.now():ToIsoDate()
                    }}
                })
            })
        end)
    end
end

-- Smooth Draggable Helper
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

-- Bypass Anti-Kick
if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and (method == "Kick" or method == "kick") then return nil end
        return oldNamecall(self, ...)
    end))
end

if getconnections then
    for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
        if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
    end
end

local function optimizeGraphics()
    if not AutoLowGFX then return end
    pcall(function()
        settings().Rendering.QualityLevel = 1
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 2
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

LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end
end)

task.spawn(function()
    while task.wait(math.random(4, 8)) do
        if AntiAFKEnabled then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.01)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end
end)

-- 🌐 HÀM HOP SERVER TỐI ƯU
local function Hop()
    sendWebhookNotification("🌐 SERVER HOP", "🔄 Đang tìm server ít người nhất để chuyển...", 3447003, false)
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        local servers = {}
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing > 0 and server.playing < server.maxPlayers then
                table.insert(servers, server)
            end
        end
        
        if #servers > 0 then
            table.sort(servers, function(a, b)
                return a.playing < b.playing
            end)
            
            local targetServer = servers[1].id
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, LocalPlayer)
            return true
        end
    end
    
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
    return false
end

local function sendStatusReport()
    local hrs = math.floor(AfkSeconds / 3600)
    local mins = math.floor((AfkSeconds % 3600) / 60)
    local secs = AfkSeconds % 60
    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local reportMsg = string.format("👤 **Player:** %s\n⏱️ **Treo:** %02dg %02dp %02ds\n📶 **Ping:** %d ms | 🚀 **FPS:** %d", LocalPlayer.Name, hrs, mins, secs, ping, fps)
    sendWebhookNotification("📊 BÁO CÁO STATUS THỦ CÔNG", reportMsg, 3066993, false)
end

local promptOverlay = CoreGui:FindFirstChild("RobloxPromptGui") and CoreGui.RobloxPromptGui:FindFirstChild("promptOverlay")
if promptOverlay then
    promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" and AntiAFKEnabled then
            sendWebhookNotification("🚨 CẢNH BÁO DISCONNECT", "Tài khoản **" .. LocalPlayer.Name .. "** bị ngắt kết nối! Đang tự động Reconnect...", 15158332, true)
            task.wait(2)
            Hop()
        end
    end)
end

-- Chat Commands (Quốc Tế)
LocalPlayer.Chatted:Connect(function(message)
    local msg = string.lower(message)
    if msg == "!status" then
        sendStatusReport()
    elseif msg == "!hop" then
        sendWebhookNotification("🎮 IN-GAME CHAT EXECUTE", "Nhận lệnh Hop từ khung chat game!", 65280, false)
        task.wait(0.5)
        Hop()
    elseif msg == "!clean" then
        collectgarbage("collect")
        sendWebhookNotification("🧹 MEMORY CLEAN", "Đã dọn dẹp RAM qua khung chat!", 16753920, false)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if AntiAFKEnabled then AfkSeconds = AfkSeconds + 1 end
    end
end)

-- MAIN UI INTERFACE (MRGHOST HUB VIP)
local function loadMainHub()
    optimizeGraphics()
    
    local pingInit = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    sendWebhookNotification("🚀 MRGHOST HUB VIP ONLINE", string.format("👤 **Player:** %s\n🟢 Đã kích hoạt thành công!\n📶 **Ping:** %d ms", LocalPlayer.Name, pingInit), 65280, false)

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "VipMainFrame"
    MainFrame.Size = UDim2.new(0, 360, 0, 335)
    MainFrame.Position = UDim2.new(0.5, -180, 0.35, -167)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
    MainFrame.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 14); MainCorner.Parent = MainFrame
    local UIStroke = Instance.new("UIStroke"); UIStroke.Thickness = 3.5; UIStroke.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 42)
    TitleBar.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
    TitleBar.Parent = MainFrame
    local TitleCorner = Instance.new("UICorner"); TitleCorner.CornerRadius = UDim.new(0, 14); TitleCorner.Parent = TitleBar

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -16, 1, 0)
    TitleText.Position = UDim2.new(0, 12, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "👑 MRGHOST HUB VIP (v5.7)"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 13
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    -- Function Toggle Card Builder
    local function createToggleCard(posY, textTitle, defaultState, callback)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, -20, 0, 38)
        Card.Position = UDim2.new(0, 10, 0, posY)
        Card.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
        Card.Parent = MainFrame
        local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 8); CardCorner.Parent = Card

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = textTitle
        Label.TextColor3 = Color3.fromRGB(230, 235, 250)
        Label.TextSize = 11
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Card

        local SwitchBg = Instance.new("TextButton")
        SwitchBg.Size = UDim2.new(0, 40, 0, 20)
        SwitchBg.Position = UDim2.new(1, -48, 0.5, -10)
        SwitchBg.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(45, 52, 75)
        SwitchBg.Text = ""
        SwitchBg.AutoButtonColor = false
        SwitchBg.Parent = Card
        local SwitchCorner = Instance.new("UICorner"); SwitchCorner.CornerRadius = UDim.new(1, 0); SwitchCorner.Parent = SwitchBg

        local SwitchDot = Instance.new("Frame")
        SwitchDot.Size = UDim2.new(0, 16, 0, 16)
        SwitchDot.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchDot.Parent = SwitchBg
        local DotCorner = Instance.new("UICorner"); DotCorner.CornerRadius = UDim.new(1, 0); DotCorner.Parent = SwitchDot

        local active = defaultState
        SwitchBg.MouseButton1Click:Connect(function()
            active = not active
            if active then
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 150)}):Play()
                TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
            else
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 52, 75)}):Play()
                TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
            end
            callback(active)
        end)
    end

    createToggleCard(50, "🛡️ Chống AFK & Treo Máy", AntiAFKEnabled, function(val) AntiAFKEnabled = val end)
    createToggleCard(94, "❄️ Tiết Kiệm CPU/GPU (Màn hình đen)", UltraSaverMode, function(val) UltraSaverMode = val end)
    createToggleCard(138, "🧹 Tự động xả RAM định kỳ", AutoRAMCleaner, function(val) AutoRAMCleaner = val end)

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
        local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(0, 8); BtnCorner.Parent = Btn

        Btn.MouseButton1Click:Connect(callback)
    end

    createActionButton(182, "📊 Gửi Báo Cáo Status Về Discord", Color3.fromRGB(40, 116, 240), function()
        sendStatusReport()
    end)

    createActionButton(222, "🌐 Server Hop Nhanh (Ít Người Nhất)", Color3.fromRGB(88, 101, 242), function()
        Hop()
    end)

    createActionButton(262, "🧹 Dọn Dẹp RAM (Clean RAM) Ngay", Color3.fromRGB(230, 126, 34), function()
        collectgarbage("collect")
        sendWebhookNotification("🧹 MEMORY CLEAN", "Đã dọn dẹp RAM thủ công từ Menu VIP!", 16753920, false)
    end)

    -- Floating Toggle Icon
    local ToggleMenuBtn = Instance.new("TextButton")
    ToggleMenuBtn.Name = "VipFloatingIcon"
    ToggleMenuBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleMenuBtn.Position = UDim2.new(0.04, 0, 0.25, 0)
    ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
    ToggleMenuBtn.Text = "👑"
    ToggleMenuBtn.TextSize = 24
    ToggleMenuBtn.AutoButtonColor = false
    ToggleMenuBtn.Parent = ScreenGui

    local FloatCorner = Instance.new("UICorner"); FloatCorner.CornerRadius = UDim.new(1, 0); FloatCorner.Parent = ToggleMenuBtn
    local FloatStroke = Instance.new("UIStroke"); FloatStroke.Thickness = 3; FloatStroke.Parent = ToggleMenuBtn

    makeDraggable(MainFrame)
    makeDraggable(ToggleMenuBtn)

    local menuVisible = true
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

savePass()
loadMainHub()
 
