-- [[ MRGHOST HUB VIP ANTI AFK - INTERACTIVE DISCORD BOT SYSTEM ]]
getgenv().Hide_Menu = false 
getgenv().Auto_Execute = true
getgenv().StreamerMode = true -- Bật true để tự động ẩn tên (mr*****) trên Discord Discord Webhook

-- 🔗 API SERVER LINK (Link Render Backend Node.js của bạn)
getgenv().Server_API = "https://bot-thong-tin.onrender.com/api/report"

local SCRIPT_TITLE = "MrGhost Hub VIP Anti AFK"

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local AntiAFKEnabled = true
local UltraSaverMode = true
local AntiStaffEnabled = true
local AfkSeconds = 0

local function GetQuantumContainer()
    if gethui then return gethui()
    elseif syn and syn.protect_gui then
        local folder = Instance.new("Folder")
        syn.protect_gui(folder)
        folder.Parent = CoreGui
        return folder
    elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui.RobloxGui end
    return CoreGui
end

local function GetHttpRequest()
    return (syn and syn.request) or (http and http.request) or request or (fluxus and fluxus.request) or http_request
end

pcall(function()
    for _, child in pairs(GetQuantumContainer():GetChildren()) do
        if child.Name:find("MrGhostAFK_UI") then child:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MrGhostAFK_UI_" .. math.random(1000000, 9999999)
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GetQuantumContainer()

local function getRGBColor()
    return Color3.fromHSV((tick() % 2.5) / 2.5, 0.95, 1)
end

-- ⚡ GỬI DỮ LIỆU ĐẾN BACKEND NODE.JS API SERVER
local function dispatchWebhooks(eventTitle, statusMessage, isCritical)
    local req = GetHttpRequest()
    if not req or not getgenv().Server_API then return end

    local pingVal = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    local ramUsage = math.floor(collectgarbage("count") / 1024)
    local rawName = LocalPlayer.Name
    local rawDisplayName = LocalPlayer.DisplayName
    local rawJob = tostring(game.JobId)
    local timeAfk = math.floor(AfkSeconds / 60)

    task.spawn(function()
        pcall(function()
            local payload = {
                userId = LocalPlayer.UserId,
                username = rawName,
                displayName = rawDisplayName,
                hideName = getgenv().StreamerMode, -- Truyền cờ che tên sang Backend Node.js
                jobId = rawJob,
                placeId = game.PlaceId,
                ping = pingVal,
                ram = ramUsage,
                uptime = timeAfk .. " phút",
                status = statusMessage,
                isCritical = isCritical or false,
                eventTitle = eventTitle
            }

            req({
                Url = getgenv().Server_API,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end)
end

-- 🌐 HOP SERVER
local function Hop()
    dispatchWebhooks("SERVER HOP", "🔄 Đang tìm Server mới...", false)
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

local function HopToJobID(jobId)
    if not jobId or #jobId < 10 then return end
    dispatchWebhooks("HOP JOB ID", "🎯 Đang chuyển tới Job ID chỉ định...", false)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
end

-- 🛡️ ANTI-AFK
LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end
end)

task.spawn(function()
    while task.wait(60) do
        if AntiAFKEnabled then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.2)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

-- 🚨 CHECK ADMIN
local function CheckIsRealAdmin(player)
    if player == LocalPlayer then return false end
    local isAdmin = false
    pcall(function()
        if player:IsFriendsWith(1) or player:GetRankInGroup(1200769) > 0 then isAdmin = true end
    end)
    if isAdmin then return true end

    pcall(function()
        if game.CreatorType == Enum.CreatorType.Group and game.CreatorId > 0 then
            if player:GetRankInGroup(game.CreatorId) >= 100 then isAdmin = true end
        elseif game.CreatorType == Enum.CreatorType.User then
            if player.UserId == game.CreatorId then isAdmin = true end
        end
    end)
    return isAdmin
end

task.spawn(function()
    while task.wait(8) do
        if AntiStaffEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if CheckIsRealAdmin(player) then
                    dispatchWebhooks("PHÁT HIỆN ADMIN!", "⚠️ Admin/Mod (" .. player.Name .. ") vừa vào server! Đang Hop khẩn cấp...", true)
                    task.wait(0.5)
                    Hop()
                    break
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do if AntiAFKEnabled then AfkSeconds = AfkSeconds + 1 end end
end)

-- Báo cáo trạng thái định kỳ 60s/lần
task.spawn(function()
    while task.wait(60) do
        if AntiAFKEnabled then
            dispatchWebhooks("MrGhost System • BÁO CÁO TRẠNG THÁI", "🟢 Script đang cắm treo bình thường.", false)
        end
    end
end)

-- 🎨 GIAO DIỆN HUB
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
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 380, 0, 310)
    MainFrame.Position = UDim2.new(0.5, -190, 0.35, -155)
    MainFrame.BackgroundColor3 = Color3.fromRGB(6, 8, 16)
    MainFrame.Visible = not getgenv().Hide_Menu
    MainFrame.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 16); MainCorner.Parent = MainFrame
    local UIStroke = Instance.new("UIStroke"); UIStroke.Thickness = 3; UIStroke.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(12, 16, 30)
    TitleBar.Parent = MainFrame
    local TitleCorner = Instance.new("UICorner"); TitleCorner.CornerRadius = UDim.new(0, 16); TitleCorner.Parent = TitleBar

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -16, 1, 0)
    TitleText.Position = UDim2.new(0, 16, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "👑 " .. SCRIPT_TITLE
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 12
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -20, 0, 32)
    TabBar.Position = UDim2.new(0, 10, 0, 46)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = MainFrame

    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.Padding = UDim.new(0, 6)
    TabList.Parent = TabBar

    local PagesFolder = Instance.new("Frame")
    PagesFolder.Size = UDim2.new(1, -20, 0, 215)
    PagesFolder.Position = UDim2.new(0, 10, 0, 84)
    PagesFolder.BackgroundTransparency = 1
    PagesFolder.Parent = MainFrame

    local Tabs = {}
    local CurrentTabBtn = nil

    local function CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.31, 0, 1, 0)
        TabBtn.BackgroundColor3 = Color3.fromRGB(16, 22, 42)
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color3.fromRGB(160, 170, 200)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 10
        TabBtn.Parent = TabBar
        local TabCorner = Instance.new("UICorner"); TabCorner.CornerRadius = UDim.new(0, 8); TabCorner.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.Parent = PagesFolder

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page

        Tabs[tabName] = {Btn = TabBtn, Page = Page}

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Page.Visible = false
                t.Btn.BackgroundColor3 = Color3.fromRGB(16, 22, 42)
                t.Btn.TextColor3 = Color3.fromRGB(160, 170, 200)
            end
            Page.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(38, 110, 240)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        if not CurrentTabBtn then
            CurrentTabBtn = TabBtn
            Page.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(38, 110, 240)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        return Page
    end

    local MainPage = CreateTab("🏠 Trang Chủ")
    local HopPage = CreateTab("🌐 Server Hop")
    local SettingsPage = CreateTab("⚙️ Cài Đặt")

    local function createButton(parent, text, color, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 36)
        Btn.BackgroundColor3 = color
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 10.5
        Btn.Font = Enum.Font.GothamBold
        Btn.Parent = parent
        local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(0, 8); BtnCorner.Parent = Btn
        Btn.MouseButton1Click:Connect(callback)
    end

    local function createToggle(parent, textTitle, defaultState, callback)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 36)
        Card.BackgroundColor3 = Color3.fromRGB(12, 18, 34)
        Card.Parent = parent
        local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 8); CardCorner.Parent = Card

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = textTitle
        Label.TextColor3 = Color3.fromRGB(235, 240, 255)
        Label.TextSize = 9.5
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Card

        local SwitchBg = Instance.new("TextButton")
        SwitchBg.Size = UDim2.new(0, 38, 0, 18)
        SwitchBg.Position = UDim2.new(1, -44, 0.5, -9)
        SwitchBg.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(45, 54, 78)
        SwitchBg.Text = ""
        SwitchBg.Parent = Card
        local SwitchCorner = Instance.new("UICorner"); SwitchCorner.CornerRadius = UDim.new(1, 0); SwitchCorner.Parent = SwitchBg

        local SwitchDot = Instance.new("Frame")
        SwitchDot.Size = UDim2.new(0, 14, 0, 14)
        SwitchDot.Position = defaultState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchDot.Parent = SwitchBg
        local DotCorner = Instance.new("UICorner"); DotCorner.CornerRadius = UDim.new(1, 0); DotCorner.Parent = SwitchDot

        local active = defaultState
        SwitchBg.MouseButton1Click:Connect(function()
            active = not active
            SwitchBg.BackgroundColor3 = active and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(45, 54, 78)
            SwitchDot.Position = active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            callback(active)
        end)
    end

    createButton(MainPage, "📊 Báo Cáo Status Ngay Lập Tức", Color3.fromRGB(38, 110, 240), function()
        dispatchWebhooks("MrGhost System • BÁO CÁO TRẠNG THÁI", "✅ Báo cáo chủ động từ người dùng.", false)
    end)
    createButton(MainPage, "🧹 Giải Phóng Bộ Nhớ RAM", Color3.fromRGB(235, 120, 30), function()
        collectgarbage("collect")
        dispatchWebhooks("XẢ BÁO TẢI", "🧹 Đã giải phóng bộ nhớ RAM thành công!", false)
    end)

    local JobBoxFrame = Instance.new("Frame")
    JobBoxFrame.Size = UDim2.new(1, 0, 0, 36)
    JobBoxFrame.BackgroundColor3 = Color3.fromRGB(16, 22, 42)
    JobBoxFrame.Parent = HopPage
    local JobBoxCorner = Instance.new("UICorner"); JobBoxCorner.CornerRadius = UDim.new(0, 8); JobBoxCorner.Parent = JobBoxFrame

    local JobInput = Instance.new("TextBox")
    JobInput.Size = UDim2.new(0.68, 0, 1, 0)
    JobInput.Position = UDim2.new(0, 8, 0, 0)
    JobInput.BackgroundTransparency = 1
    JobInput.PlaceholderText = "Nhập Job ID..."
    JobInput.Text = ""
    JobInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    JobInput.PlaceholderColor3 = Color3.fromRGB(130, 140, 170)
    JobInput.Font = Enum.Font.GothamMedium
    JobInput.TextSize = 9.5
    JobInput.TextXAlignment = Enum.TextXAlignment.Left
    JobInput.Parent = JobBoxFrame

    local PasteBtn = Instance.new("TextButton")
    PasteBtn.Size = UDim2.new(0.28, 0, 0.75, 0)
    PasteBtn.Position = UDim2.new(0.7, 0, 0.125, 0)
    PasteBtn.BackgroundColor3 = Color3.fromRGB(38, 110, 240)
    PasteBtn.Text = "📋 Dán"
    PasteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PasteBtn.Font = Enum.Font.GothamBold
    PasteBtn.TextSize = 9.5
    PasteBtn.Parent = JobBoxFrame
    local PasteCorner = Instance.new("UICorner"); PasteCorner.CornerRadius = UDim.new(0, 6); PasteCorner.Parent = PasteBtn

    PasteBtn.MouseButton1Click:Connect(function()
        if getclipboard or setclipboard then
            local clip = (getclipboard and getclipboard()) or ""
            if #clip > 5 then JobInput.Text = clip end
        end
    end)

    createButton(HopPage, "🚀 HOP ĐẾN JOB ID NÀY", Color3.fromRGB(168, 85, 247), function()
        if #JobInput.Text > 5 then HopToJobID(JobInput.Text) end
    end)
    createButton(HopPage, "🌐 Hop Server Ngẫu Nhiên", Color3.fromRGB(90, 80, 240), function() Hop() end)

    createToggle(SettingsPage, "🔒 Streamer Mode (Ẩn Tên Acc)", getgenv().StreamerMode, function(val) getgenv().StreamerMode = val end)
    createToggle(SettingsPage, "🛡️ Anti-AFK An Toàn", AntiAFKEnabled, function(val) AntiAFKEnabled = val end)
    createToggle(SettingsPage, "❄️ Tối Ưu Hóa CPU/GPU", UltraSaverMode, function(val) UltraSaverMode = val end)
    createToggle(SettingsPage, "🚨 Né Admin Thông Minh", AntiStaffEnabled, function(val) AntiStaffEnabled = val end)

    local ToggleMenuBtn = Instance.new("TextButton")
    ToggleMenuBtn.Name = "FloatingIcon"
    ToggleMenuBtn.Size = UDim2.new(0, 48, 0, 48)
    ToggleMenuBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
    ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(10, 14, 26)
    ToggleMenuBtn.Text = "👑"
    ToggleMenuBtn.TextSize = 24
    ToggleMenuBtn.Parent = ScreenGui

    local FloatCorner = Instance.new("UICorner"); FloatCorner.CornerRadius = UDim.new(1, 0); FloatCorner.Parent = ToggleMenuBtn
    local FloatStroke = Instance.new("UIStroke"); FloatStroke.Thickness = 3; FloatStroke.Parent = ToggleMenuBtn

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

loadMainHub()
 
