-- ================================================
-- MRGHOST HUB - ALL GAME / CLIENT / DEVICE ENGINE
-- ================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

-- Cấu hình Key & Cache (Bảo mật - Không hiển thị key)
local TARGET_KEY = "TTTT"
local KEY_LINK = "https://discord.gg/KDTDZjYSR"
local BACKUP_LINK = "https://fnote.net/notes/jv9G9J"
local CACHE_FILE = "MrGhostVIP_KeyCache.json"
local EXPIRE_TIME = 86400 -- 24h

-- Trạng thái
local AntiAFKEnabled = true
local AutoReconnectEnabled = true
local BlackScreenEnabled = false
local AfkSeconds = 0

-- Dọn dẹp Gui cũ
pcall(function()
    if CoreGui:FindFirstChild("MrGhostHub_Full_Engine") then CoreGui["MrGhostHub_Full_Engine"]:Destroy() end
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MrGhostHub_Full_Engine") then 
        LocalPlayer.PlayerGui["MrGhostHub_Full_Engine"]:Destroy() 
    end
end)

-- Tạo ScreenGui tương thích All Client
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MrGhostHub_Full_Engine"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    local success = pcall(function() ScreenGui.Parent = CoreGui end)
    if not success or not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- Hàm RGB
local function getRGBColor(speed)
    return Color3.fromHSV((tick() % (speed or 3)) / (speed or 3), 0.85, 1)
end

-- ================================================
-- THÔNG BÁO (NOTIFICATION SYSTEM)
-- ================================================
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0, 260, 1, 0)
NotificationContainer.Position = UDim2.new(1, -270, 0, 20)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.ZIndex = 10005
NotificationContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Parent = NotificationContainer

local function showNotification(titleText, descText, duration)
    duration = duration or 3.5

    local NotifCard = Instance.new("Frame")
    NotifCard.Size = UDim2.new(1, 0, 0, 60)
    NotifCard.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
    NotifCard.BackgroundTransparency = 0.1
    NotifCard.ClipsDescendants = true
    NotifCard.ZIndex = 10006
    NotifCard.Parent = NotificationContainer

    local NotifCorner = Instance.new("UICorner"); NotifCorner.CornerRadius = UDim.new(0, 12); NotifCorner.Parent = NotifCard
    local NotifStroke = Instance.new("UIStroke"); NotifStroke.Thickness = 1.5; NotifStroke.Parent = NotifCard

    local NotifIcon = Instance.new("TextLabel")
    NotifIcon.Size = UDim2.new(0, 32, 0, 32)
    NotifIcon.Position = UDim2.new(0, 10, 0.5, -16)
    NotifIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
    NotifIcon.Text = "🔔"
    NotifIcon.TextSize = 16
    NotifIcon.ZIndex = 10007
    NotifIcon.Parent = NotifCard

    local IconCorner = Instance.new("UICorner"); IconCorner.CornerRadius = UDim.new(0, 8); IconCorner.Parent = NotifIcon

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -52, 0, 18)
    TitleLbl.Position = UDim2.new(0, 48, 0, 10)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = titleText
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.TextSize = 12
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 10007
    TitleLbl.Parent = NotifCard

    local DescLbl = Instance.new("TextLabel")
    DescLbl.Size = UDim2.new(1, -52, 0, 18)
    DescLbl.Position = UDim2.new(0, 48, 0, 28)
    DescLbl.BackgroundTransparency = 1
    DescLbl.Text = descText
    DescLbl.TextColor3 = Color3.fromRGB(170, 180, 200)
    DescLbl.TextSize = 11
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    DescLbl.ZIndex = 10007
    DescLbl.Parent = NotifCard

    local rgbConn
    rgbConn = RunService.RenderStepped:Connect(function()
        if NotifCard and NotifCard.Parent then 
            NotifStroke.Color = getRGBColor(3) 
        else 
            if rgbConn then rgbConn:Disconnect() end 
        end
    end)

    NotifCard.Position = UDim2.new(1.2, 0, 0, 0)
    TweenService:Create(NotifCard, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    task.delay(duration, function()
        if NotifCard and NotifCard.Parent then
            local hideTween = TweenService:Create(NotifCard, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1.2, 0, 0, 0)})
            hideTween:Play()
            hideTween.Completed:Connect(function() NotifCard:Destroy() end)
        end
    end)
end

-- ================================================
-- ENGINE ANTI AFK & AUTO RECONNECT
-- ================================================
LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(30)
        if AntiAFKEnabled then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if AntiAFKEnabled then AfkSeconds = AfkSeconds + 1 end
    end
end)

-- Tự Động Vào Lại Khi Bị Văng/Lỗi Kết Nối
GuiService.ErrorCodeChanged:Connect(function()
    if AutoReconnectEnabled then
        showNotification("⚠️ CẢNH BÁO MẤT MẠNG", "Đang tự động kết nối lại Server...", 5)
        task.wait(3)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- Màn Hình Đen
local BlackFrame = Instance.new("Frame")
BlackFrame.Name = "GPU_Saver_Overlay"
BlackFrame.Size = UDim2.new(1, 0, 1, 0)
BlackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackFrame.Visible = false
BlackFrame.ZIndex = 9999
BlackFrame.Parent = ScreenGui

local BlackText = Instance.new("TextLabel")
BlackText.Size = UDim2.new(1, 0, 0, 40)
BlackText.Position = UDim2.new(0, 0, 0.5, -20)
BlackText.BackgroundTransparency = 1
BlackText.Text = "🌙 CHẾ ĐỘ TIẾT KIỆM PIN (Bấm nút Ghost 👻 để tắt)"
BlackText.TextColor3 = Color3.fromRGB(0, 255, 160)
BlackText.TextSize = 13
BlackText.Font = Enum.Font.GothamBold
BlackText.ZIndex = 9999
BlackText.Parent = BlackFrame

-- Kéo Thả
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Key System
local function verifyInputKey(input)
    if type(input) ~= "string" then return false end
    return string.gsub(input, "^%s*(.-)%s*$", "%1") == TARGET_KEY
end

local function isKeySavedValid()
    if readfile and isfile and isfile(CACHE_FILE) then
        local successRead, data = pcall(function() return HttpService:JSONDecode(readfile(CACHE_FILE)) end)
        if successRead and type(data) == "table" and data.key and data.time then
            if verifyInputKey(data.key) and (os.time() - data.time) < EXPIRE_TIME then 
                return true 
            end
        end
    end
    return false
end

local function saveKeyCache(key)
    if writefile then
        pcall(function() writefile(CACHE_FILE, HttpService:JSONEncode({ key = key, time = os.time() })) end)
    end
end

-- ================================================
-- MAIN HUB GIAO DIỆN
-- ================================================
local function loadMainHub()
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 330, 0, 310)
    MainFrame.Position = UDim2.new(0.5, -165, 0.35, -155)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 500
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 18); MainCorner.Parent = MainFrame
    local UIStroke = Instance.new("UIStroke"); UIStroke.Thickness = 2; UIStroke.Parent = MainFrame

    RunService.RenderStepped:Connect(function() UIStroke.Color = getRGBColor(3) end)

    -- Header
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 48)
    TitleBar.BackgroundColor3 = Color3.fromRGB(16, 19, 30)
    TitleBar.ZIndex = 501
    TitleBar.Parent = MainFrame

    local LogoIcon = Instance.new("TextLabel")
    LogoIcon.Size = UDim2.new(0, 32, 0, 32)
    LogoIcon.Position = UDim2.new(0, 10, 0.5, -16)
    LogoIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
    LogoIcon.Text = "👻"
    LogoIcon.TextSize = 18
    LogoIcon.ZIndex = 502
    LogoIcon.Parent = TitleBar
    local LogoCorner = Instance.new("UICorner"); LogoCorner.CornerRadius = UDim.new(0, 8); LogoCorner.Parent = LogoIcon

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 180, 1, 0)
    Title.Position = UDim2.new(0, 48, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "MrGhost Anti-AFK VIP"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 13
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 502
    Title.Parent = TitleBar

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 1, -58)
    Container.Position = UDim2.new(0, 10, 0, 54)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 501
    Container.Parent = MainFrame

    -- Switch Card Chống AFK
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 45)
    Card.Position = UDim2.new(0, 0, 0, 0)
    Card.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
    Card.ZIndex = 502
    Card.Parent = Container
    local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 10); CardCorner.Parent = Card

    local CardLabel = Instance.new("TextLabel")
    CardLabel.Size = UDim2.new(0.65, 0, 1, 0)
    CardLabel.Position = UDim2.new(0, 12, 0, 0)
    CardLabel.BackgroundTransparency = 1
    CardLabel.Text = "🛡️ Chống AFK Treo Máy 24/7"
    CardLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
    CardLabel.TextSize = 11
    CardLabel.Font = Enum.Font.GothamMedium
    CardLabel.TextXAlignment = Enum.TextXAlignment.Left
    CardLabel.ZIndex = 503
    CardLabel.Parent = Card

    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Size = UDim2.new(0, 44, 0, 22)
    SwitchBg.Position = UDim2.new(1, -52, 0.5, -11)
    SwitchBg.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
    SwitchBg.Text = ""
    SwitchBg.AutoButtonColor = false
    SwitchBg.ZIndex = 503
    SwitchBg.Parent = Card
    local SwitchCorner = Instance.new("UICorner"); SwitchCorner.CornerRadius = UDim.new(1, 0); SwitchCorner.Parent = SwitchBg

    local SwitchDot = Instance.new("Frame")
    SwitchDot.Size = UDim2.new(0, 16, 0, 16)
    SwitchDot.Position = UDim2.new(1, -19, 0.5, -8)
    SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchDot.ZIndex = 504
    SwitchDot.Parent = SwitchBg
    local SwitchDotCorner = Instance.new("UICorner"); SwitchDotCorner.CornerRadius = UDim.new(1, 0); SwitchDotCorner.Parent = SwitchDot

    -- Trạng thái & Thời gian
    local StatusInfo = Instance.new("TextLabel")
    StatusInfo.Size = UDim2.new(1, 0, 0, 18)
    StatusInfo.Position = UDim2.new(0, 0, 0, 52)
    StatusInfo.BackgroundTransparency = 1
    StatusInfo.Text = "● Trạng thái: Đang bảo vệ (Tự kết nối lại khi văng)"
    StatusInfo.TextColor3 = Color3.fromRGB(0, 255, 160)
    StatusInfo.TextSize = 10
    StatusInfo.Font = Enum.Font.Gotham
    StatusInfo.ZIndex = 502
    StatusInfo.Parent = Container

    local TimerInfo = Instance.new("TextLabel")
    TimerInfo.Size = UDim2.new(1, 0, 0, 20)
    TimerInfo.Position = UDim2.new(0, 0, 0, 72)
    TimerInfo.BackgroundTransparency = 1
    TimerInfo.Text = "⏱️ Thời gian treo: 00g 00p 00s"
    TimerInfo.TextColor3 = Color3.fromRGB(0, 230, 255)
    TimerInfo.TextSize = 11
    TimerInfo.Font = Enum.Font.GothamBold
    TimerInfo.ZIndex = 502
    TimerInfo.Parent = Container

    -- Các Nút Chức Năng
    local BlackBtn = Instance.new("TextButton")
    BlackBtn.Size = UDim2.new(0.48, -4, 0, 32)
    BlackBtn.Position = UDim2.new(0, 0, 0, 98)
    BlackBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 56)
    BlackBtn.Text = "🌙 Tắt Màn Hình"
    BlackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BlackBtn.TextSize = 11
    BlackBtn.Font = Enum.Font.GothamBold
    BlackBtn.ZIndex = 502
    BlackBtn.Parent = Container
    local BlackBtnCorner = Instance.new("UICorner"); BlackBtnCorner.CornerRadius = UDim.new(0, 8); BlackBtnCorner.Parent = BlackBtn

    local RejoinBtn = Instance.new("TextButton")
    RejoinBtn.Size = UDim2.new(0.48, -4, 0, 32)
    RejoinBtn.Position = UDim2.new(0.52, 0, 0, 98)
    RejoinBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    RejoinBtn.Text = "🔄 Vào Lại Server"
    RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RejoinBtn.TextSize = 11
    RejoinBtn.Font = Enum.Font.GothamBold
    RejoinBtn.ZIndex = 502
    RejoinBtn.Parent = Container
    local RejoinBtnCorner = Instance.new("UICorner"); RejoinBtnCorner.CornerRadius = UDim.new(0, 8); RejoinBtnCorner.Parent = RejoinBtn

    local CopyLinkBtn = Instance.new("TextButton")
    CopyLinkBtn.Size = UDim2.new(0.48, -4, 0, 32)
    CopyLinkBtn.Position = UDim2.new(0, 0, 0, 136)
    CopyLinkBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    CopyLinkBtn.Text = "📋 Copy Link Server"
    CopyLinkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyLinkBtn.TextSize = 10
    CopyLinkBtn.Font = Enum.Font.GothamBold
    CopyLinkBtn.ZIndex = 502
    CopyLinkBtn.Parent = Container
    local CopyLinkCorner = Instance.new("UICorner"); CopyLinkCorner.CornerRadius = UDim.new(0, 8); CopyLinkCorner.Parent = CopyLinkBtn

    local CopyJobIdBtn = Instance.new("TextButton")
    CopyJobIdBtn.Size = UDim2.new(0.48, -4, 0, 32)
    CopyJobIdBtn.Position = UDim2.new(0.52, 0, 0, 136)
    CopyJobIdBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 220)
    CopyJobIdBtn.Text = "🆔 Copy JobID Server"
    CopyJobIdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyJobIdBtn.TextSize = 10
    CopyJobIdBtn.Font = Enum.Font.GothamBold
    CopyJobIdBtn.ZIndex = 502
    CopyJobIdBtn.Parent = Container
    local CopyJobCorner = Instance.new("UICorner"); CopyJobCorner.CornerRadius = UDim.new(0, 8); CopyJobCorner.Parent = CopyJobIdBtn

    local StatusBadgeLabel

    -- Vòng lặp đồng hồ
    task.spawn(function()
        while true do
            task.wait(1)
            local hrs = math.floor(AfkSeconds / 3600)
            local mins = math.floor((AfkSeconds % 3600) / 60)
            local secs = AfkSeconds % 60
            TimerInfo.Text = string.format("⏱️ Thời gian treo: %02dg %02dp %02ds", hrs, mins, secs)
        end
    end)

    -- Sự kiện các nút
    SwitchBg.MouseButton1Click:Connect(function()
        AntiAFKEnabled = not AntiAFKEnabled
        if AntiAFKEnabled then
            TweenService:Create(SwitchBg, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(255, 0, 110)}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.25), {Position = UDim2.new(1, -19, 0.5, -8)}):Play()
            StatusInfo.Text = "● Trạng thái: Đang bảo vệ (Tự kết nối lại khi văng)"
            StatusInfo.TextColor3 = Color3.fromRGB(0, 255, 160)
            if StatusBadgeLabel then StatusBadgeLabel.Text = "● ON"; StatusBadgeLabel.TextColor3 = Color3.fromRGB(0, 255, 160) end
            showNotification("🛡️ CHỐNG AFK", "Đã KÍCH HOẠT Chống AFK!", 2.5)
        else
            TweenService:Create(SwitchBg, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(45, 52, 75)}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.25), {Position = UDim2.new(0, 3, 0.5, -8)}):Play()
            StatusInfo.Text = "○ Trạng thái: Đã tạm dừng"
            StatusInfo.TextColor3 = Color3.fromRGB(160, 160, 175)
            if StatusBadgeLabel then StatusBadgeLabel.Text = "○ OFF"; StatusBadgeLabel.TextColor3 = Color3.fromRGB(160, 160, 175) end
            showNotification("🛡️ CHỐNG AFK", "Đã TẠM DỪNG Chống AFK!", 2.5)
        end
    end)

    BlackBtn.MouseButton1Click:Connect(function()
        BlackScreenEnabled = not BlackScreenEnabled
        BlackFrame.Visible = BlackScreenEnabled
        if BlackScreenEnabled then
            showNotification("🌙 TIẾT KIỆM PIN", "Đã bật màn hình đen tiết kiệm điện!", 3)
        end
    end)

    RejoinBtn.MouseButton1Click:Connect(function()
        showNotification("🔄 RECONNECT", "Đang tự động vào lại Server...", 3)
        task.wait(1)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)

    CopyLinkBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            local serverLink = "https://www.roblox.com/games/" .. tostring(game.PlaceId) .. "?jobId=" .. tostring(game.JobId)
            setclipboard(serverLink)
            showNotification("📋 ĐÃ COPY", "Đã copy Link Server vào bộ nhớ tạm!", 3)
        end
    end)

    CopyJobIdBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(tostring(game.JobId))
            showNotification("🆔 ĐÃ COPY", "Đã copy JobID vào bộ nhớ tạm!", 3)
        end
    end)

    -- Floating Ghost Button
    local ToggleMenuBtn = Instance.new("TextButton")
    ToggleMenuBtn.Name = "CyberGhostButton"
    ToggleMenuBtn.Size = UDim2.new(0, 56, 0, 56)
    ToggleMenuBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
    ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
    ToggleMenuBtn.Text = "👻"
    ToggleMenuBtn.TextSize = 26
    ToggleMenuBtn.ZIndex = 10000
    ToggleMenuBtn.Parent = ScreenGui
    local ToggleCorner = Instance.new("UICorner"); ToggleCorner.CornerRadius = UDim.new(1, 0); ToggleCorner.Parent = ToggleMenuBtn
    local ToggleStroke = Instance.new("UIStroke"); ToggleStroke.Thickness = 2.5; ToggleStroke.Parent = ToggleMenuBtn

    RunService.RenderStepped:Connect(function() ToggleStroke.Color = getRGBColor(3) end)

    local StatusBadge = Instance.new("Frame")
    StatusBadge.Size = UDim2.new(0, 38, 0, 16)
    StatusBadge.Position = UDim2.new(0.5, -19, 1, -6)
    StatusBadge.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
    StatusBadge.ZIndex = 10001
    StatusBadge.Parent = ToggleMenuBtn
    local BadgeCorner = Instance.new("UICorner"); BadgeCorner.CornerRadius = UDim.new(1, 0); BadgeCorner.Parent = StatusBadge

    StatusBadgeLabel = Instance.new("TextLabel")
    StatusBadgeLabel.Size = UDim2.new(1, 0, 1, 0)
    StatusBadgeLabel.BackgroundTransparency = 1
    StatusBadgeLabel.Text = "● ON"
    StatusBadgeLabel.TextColor3 = Color3.fromRGB(0, 255, 160)
    StatusBadgeLabel.TextSize = 9
    StatusBadgeLabel.Font = Enum.Font.GothamBold
    StatusBadgeLabel.ZIndex = 10002
    StatusBadgeLabel.Parent = StatusBadge

    makeDraggable(MainFrame)
    makeDraggable(ToggleMenuBtn)

    local menuVisible = true
    ToggleMenuBtn.MouseButton1Click:Connect(function()
        if BlackScreenEnabled then
            BlackScreenEnabled = false
            BlackFrame.Visible = false
        end
        menuVisible = not menuVisible
        MainFrame.Visible = menuVisible
    end)

    showNotification("★ MRGHOST HUB VIP ★", "Đã bật Anti-AFK Engine thành công!", 3.5)
end

-- ================================================
-- GIAO DIỆN CHECK KEY (BẢO MẬT - KHÔNG HỆ LỘ KEY)
-- ================================================
if isKeySavedValid() then
    loadMainHub()
    showNotification("🔑 HỆ THỐNG KEY", "Đã xác minh Key Cache thành công!", 3)
else
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Name = "KeyFrame"; KeyFrame.Size = UDim2.new(0, 290, 0, 200); KeyFrame.Position = UDim2.new(0.5, -145, 0.4, -100); KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26); KeyFrame.Parent = ScreenGui
    local KeyCorner = Instance.new("UICorner"); KeyCorner.CornerRadius = UDim.new(0, 16); KeyCorner.Parent = KeyFrame
    local KeyStroke = Instance.new("UIStroke"); KeyStroke.Thickness = 2; KeyStroke.Parent = KeyFrame

    RunService.RenderStepped:Connect(function() KeyStroke.Color = getRGBColor(3) end)

    local KeyTitle = Instance.new("TextLabel"); KeyTitle.Size = UDim2.new(1, 0, 0, 38); KeyTitle.BackgroundTransparency = 1; KeyTitle.Text = "🔑 KEY SYSTEM VIP"; KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255); KeyTitle.TextSize = 13; KeyTitle.Font = Enum.Font.GothamBold; KeyTitle.Parent = KeyFrame
    local KeyTextBox = Instance.new("TextBox"); KeyTextBox.Size = UDim2.new(1, -30, 0, 34); KeyTextBox.Position = UDim2.new(0, 15, 0, 42); KeyTextBox.BackgroundColor3 = Color3.fromRGB(24, 28, 42); KeyTextBox.PlaceholderText = "Nhập Key xác thực..."; KeyTextBox.Text = ""; KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255); KeyTextBox.TextSize = 12; KeyTextBox.Font = Enum.Font.Gotham; KeyTextBox.Parent = KeyFrame
    local BoxCorner = Instance.new("UICorner"); BoxCorner.CornerRadius = UDim.new(0, 8); BoxCorner.Parent = KeyTextBox

    local CheckBtn = Instance.new("TextButton"); CheckBtn.Size = UDim2.new(0.46, -4, 0, 34); CheckBtn.Position = UDim2.new(0, 15, 0, 86); CheckBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 110); CheckBtn.Text = "Check Key"; CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CheckBtn.TextSize = 12; CheckBtn.Font = Enum.Font.GothamBold; CheckBtn.Parent = KeyFrame
    local GetKeyBtn = Instance.new("TextButton"); GetKeyBtn.Size = UDim2.new(0.46, -4, 0, 34); GetKeyBtn.Position = UDim2.new(0.54, 0, 0, 86); GetKeyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242); GetKeyBtn.Text = "Discord Key"; GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); GetKeyBtn.TextSize = 12; GetKeyBtn.Font = Enum.Font.GothamBold; GetKeyBtn.Parent = KeyFrame
    local BackupBtn = Instance.new("TextButton"); BackupBtn.Size = UDim2.new(1, -30, 0, 32); BackupBtn.Position = UDim2.new(0, 15, 0, 128); BackupBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0); BackupBtn.Text = "🔗 Copy Link Lấy Key"; BackupBtn.TextColor3 = Color3.fromRGB(255, 255, 255); BackupBtn.TextSize = 11; BackupBtn.Font = Enum.Font.GothamBold; BackupBtn.Parent = KeyFrame

    local StatusText = Instance.new("TextLabel"); StatusText.Size = UDim2.new(1, -30, 0, 20); StatusText.Position = UDim2.new(0, 15, 0, 166); StatusText.BackgroundTransparency = 1; StatusText.Text = "Hãy nhập Key VIP để bắt đầu"; StatusText.TextColor3 = Color3.fromRGB(160, 170, 190); StatusText.TextSize = 11; StatusText.Font = Enum.Font.Gotham; StatusText.Parent = KeyFrame

    makeDraggable(KeyFrame)

    GetKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(KEY_LINK); StatusText.Text = "✅ Đã copy link Discord!" end
    end)

    BackupBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(BACKUP_LINK); StatusText.Text = "✅ Đã copy link Fnote!" end
    end)

    CheckBtn.MouseButton1Click:Connect(function()
        if verifyInputKey(KeyTextBox.Text) then
            StatusText.Text = "🎉 Key chính xác! Đang tải..."
            saveKeyCache(KeyTextBox.Text)
            task.wait(0.3)
            KeyFrame:Destroy()
            loadMainHub()
        else
            StatusText.Text = "❌ Key không đúng!"
        end
    end)
end
