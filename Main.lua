-- [[ MRGHOST HUB - TTTT AUTO FLOATING GHOST ]]
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

-- Security Config
local SECRET_PASS = "TTTT"
local DISCORD_URL = "https://discord.gg/KDTDZjYSR"
local FNOTE_URL = "https://fnote.net/notes/jv9G9J"
local CACHE_NAME = "MrGhostVIP_KeyCache.json"
local EXPIRE_TIME = 86400

local AntiAFKEnabled = true
local AfkSeconds = 0

-- Dọn dẹp UI cũ
pcall(function()
    if CoreGui:FindFirstChild("MrGhost_TTTT_UI") then CoreGui["MrGhost_TTTT_UI"]:Destroy() end
    if LocalPlayer.PlayerGui:FindFirstChild("MrGhost_TTTT_UI") then LocalPlayer.PlayerGui["MrGhost_TTTT_UI"]:Destroy() end
end)

-- ScreenGui Parent
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MrGhost_TTTT_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- RGB Rainbow Generator
local function getRGBColor()
    return Color3.fromHSV((tick() % 3) / 3, 0.85, 1)
end

-- Key Cache Check
local function isPassValid()
    if readfile and isfile and isfile(CACHE_NAME) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CACHE_NAME)) end)
        if ok and type(data) == "table" and data.key == SECRET_PASS and data.time then
            if (os.time() - data.time) < EXPIRE_TIME then return true end
        end
    end
    return false
end

local function savePass()
    if writefile then
        pcall(function() writefile(CACHE_NAME, HttpService:JSONEncode({ key = SECRET_PASS, time = os.time() })) end)
    end
end

-- Smooth Dragging System (Vẫn hoạt động mượt khi nút nhún nhảy)
local function makeDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
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

-- Anti-AFK Engine 24/7
LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end
end)

task.spawn(function()
    while task.wait(25) do
        if AntiAFKEnabled then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(100, 100))
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if AntiAFKEnabled then AfkSeconds = AfkSeconds + 1 end
    end
end)

-- MAIN HUB DESIGN
local function loadMainHub()
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 330, 0, 235)
    MainFrame.Position = UDim2.new(0.5, -165, 0.35, -117)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 22); MainCorner.Parent = MainFrame
    local UIStroke = Instance.new("UIStroke"); UIStroke.Thickness = 2.5; UIStroke.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 52)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local LogoIcon = Instance.new("TextLabel")
    LogoIcon.Size = UDim2.new(0, 36, 0, 36)
    LogoIcon.Position = UDim2.new(0, 12, 0.5, -18)
    LogoIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
    LogoIcon.Text = "👻"
    LogoIcon.TextSize = 20
    LogoIcon.Parent = TitleBar
    local LogoCorner = Instance.new("UICorner"); LogoCorner.CornerRadius = UDim.new(0, 12); LogoCorner.Parent = LogoIcon

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 140, 1, 0)
    Title.Position = UDim2.new(0, 56, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "MrGhost VIP"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    local HeartLabel = Instance.new("TextLabel")
    HeartLabel.Size = UDim2.new(0, 90, 1, 0)
    HeartLabel.Position = UDim2.new(1, -100, 0, 0)
    HeartLabel.BackgroundTransparency = 1
    HeartLabel.Text = "💖 TTTT"
    HeartLabel.TextColor3 = Color3.fromRGB(255, 120, 190)
    HeartLabel.TextSize = 13
    HeartLabel.Font = Enum.Font.GothamBold
    HeartLabel.Parent = TitleBar

    -- Card Toggle Chống AFK
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -28, 0, 48)
    Card.Position = UDim2.new(0, 14, 0, 64)
    Card.BackgroundColor3 = Color3.fromRGB(24, 29, 45)
    Card.Parent = MainFrame
    local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 12); CardCorner.Parent = Card

    local CardLabel = Instance.new("TextLabel")
    CardLabel.Size = UDim2.new(0.65, 0, 1, 0)
    CardLabel.Position = UDim2.new(0, 14, 0, 0)
    CardLabel.BackgroundTransparency = 1
    CardLabel.Text = "🛡️ Chống AFK Treo Máy"
    CardLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
    CardLabel.TextSize = 12
    CardLabel.Font = Enum.Font.GothamMedium
    CardLabel.TextXAlignment = Enum.TextXAlignment.Left
    CardLabel.Parent = Card

    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Size = UDim2.new(0, 48, 0, 26)
    SwitchBg.Position = UDim2.new(1, -60, 0.5, -13)
    SwitchBg.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
    SwitchBg.Text = ""
    SwitchBg.AutoButtonColor = false
    SwitchBg.Parent = Card
    local SwitchCorner = Instance.new("UICorner"); SwitchCorner.CornerRadius = UDim.new(1, 0); SwitchCorner.Parent = SwitchBg

    local SwitchDot = Instance.new("Frame")
    SwitchDot.Size = UDim2.new(0, 20, 0, 20)
    SwitchDot.Position = UDim2.new(1, -23, 0.5, -10)
    SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchDot.Parent = SwitchBg
    local SwitchDotCorner = Instance.new("UICorner"); SwitchDotCorner.CornerRadius = UDim.new(1, 0); SwitchDotCorner.Parent = SwitchDot

    -- Status & Timer
    local StatusInfo = Instance.new("TextLabel")
    StatusInfo.Size = UDim2.new(1, -28, 0, 20)
    StatusInfo.Position = UDim2.new(0, 14, 0, 118)
    StatusInfo.BackgroundTransparency = 1
    StatusInfo.Text = "● Đang bảo vệ 24/7 (Bypass All Game)"
    StatusInfo.TextColor3 = Color3.fromRGB(0, 255, 160)
    StatusInfo.TextSize = 10.5
    StatusInfo.Font = Enum.Font.Gotham
    StatusInfo.Parent = MainFrame

    local TimerInfo = Instance.new("TextLabel")
    TimerInfo.Size = UDim2.new(1, -28, 0, 20)
    TimerInfo.Position = UDim2.new(0, 14, 0, 138)
    TimerInfo.BackgroundTransparency = 1
    TimerInfo.Text = "⏱️ Đã treo: 00g 00p 00s"
    TimerInfo.TextColor3 = Color3.fromRGB(0, 230, 255)
    TimerInfo.TextSize = 11.5
    TimerInfo.Font = Enum.Font.GothamBold
    TimerInfo.Parent = MainFrame

    -- Rejoin Button
    local RejoinBtn = Instance.new("TextButton")
    RejoinBtn.Size = UDim2.new(1, -28, 0, 34)
    RejoinBtn.Position = UDim2.new(0, 14, 0, 168)
    RejoinBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    RejoinBtn.Text = "🔄 Vào Lại Server Khi Văng"
    RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RejoinBtn.TextSize = 11.5
    RejoinBtn.Font = Enum.Font.GothamBold
    RejoinBtn.Parent = MainFrame
    local RejoinCorner = Instance.new("UICorner"); RejoinCorner.CornerRadius = UDim.new(0, 10); RejoinCorner.Parent = RejoinBtn

    -- 👻 NÚT PHỤ MINI TỰ NHÚN NHẢY BỒNG BỀNH
    local ToggleMenuBtn = Instance.new("TextButton")
    ToggleMenuBtn.Name = "MiniGhostBtn"
    ToggleMenuBtn.Size = UDim2.new(0, 56, 0, 56)
    ToggleMenuBtn.Position = UDim2.new(0.04, 0, 0.25, 0)
    ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(18, 20, 32)
    ToggleMenuBtn.Text = "👻"
    ToggleMenuBtn.TextSize = 26
    ToggleMenuBtn.AutoButtonColor = false
    ToggleMenuBtn.Parent = ScreenGui

    local ToggleCorner = Instance.new("UICorner"); ToggleCorner.CornerRadius = UDim.new(1, 0); ToggleCorner.Parent = ToggleMenuBtn
    local ToggleStroke = Instance.new("UIStroke"); ToggleStroke.Thickness = 3; ToggleStroke.Parent = ToggleMenuBtn

    makeDraggable(MainFrame)
    makeDraggable(ToggleMenuBtn)

    -- 🔥 HIỆU ỨNG TỰ NHÚN NHẢY KHÔNG CẦN CHẠM (Floating)
    task.spawn(function()
        local floatTime = 0
        while ToggleMenuBtn and ToggleMenuBtn.Parent do
            floatTime = floatTime + 0.08
            -- Nhún nhảy co giãn kích thước
            local scale = 56 + math.sin(floatTime * 2.5) * 4
            ToggleMenuBtn.Size = UDim2.new(0, scale, 0, scale)
            RunService.RenderStepped:Wait()
        end
    end)

    local menuVisible = true
    ToggleMenuBtn.MouseButton1Click:Connect(function()
        menuVisible = not menuVisible
        MainFrame.Visible = menuVisible
    end)

    SwitchBg.MouseButton1Click:Connect(function()
        AntiAFKEnabled = not AntiAFKEnabled
        if AntiAFKEnabled then
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 0, 110)}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -23, 0.5, -10)}):Play()
            StatusInfo.Text = "● Đang bảo vệ 24/7 (Bypass All Game)"
            StatusInfo.TextColor3 = Color3.fromRGB(0, 255, 160)
        else
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 52, 75)}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -10)}):Play()
            StatusInfo.Text = "○ Trạng thái: Đã tắt"
            StatusInfo.TextColor3 = Color3.fromRGB(160, 160, 175)
        end
    end)

    RejoinBtn.MouseButton1Click:Connect(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)

    -- Update Loops
    task.spawn(function()
        while task.wait(1) do
            local hrs = math.floor(AfkSeconds / 3600)
            local mins = math.floor((AfkSeconds % 3600) / 60)
            local secs = AfkSeconds % 60
            TimerInfo.Text = string.format("⏱️ Đã treo: %02dg %02dp %02ds", hrs, mins, secs)
        end
    end)

    RunService.RenderStepped:Connect(function()
        local color = getRGBColor()
        UIStroke.Color = color
        ToggleStroke.Color = color
    end)
end

-- SYSTEM ENTRY
if isPassValid() then
    loadMainHub()
else
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Size = UDim2.new(0, 300, 0, 205)
    KeyFrame.Position = UDim2.new(0.5, -150, 0.4, -102)
    KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
    KeyFrame.Parent = ScreenGui
    local KeyCorner = Instance.new("UICorner"); KeyCorner.CornerRadius = UDim.new(0, 16); KeyCorner.Parent = KeyFrame
    local KeyStroke = Instance.new("UIStroke"); KeyStroke.Thickness = 2.5; KeyStroke.Parent = KeyFrame

    RunService.RenderStepped:Connect(function() KeyStroke.Color = getRGBColor() end)

    local KeyTitle = Instance.new("TextLabel"); KeyTitle.Size = UDim2.new(1, 0, 0, 38); KeyTitle.BackgroundTransparency = 1; KeyTitle.Text = "🔑 KEY SYSTEM TTTT 💖"; KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255); KeyTitle.TextSize = 14; KeyTitle.Font = Enum.Font.GothamBold; KeyTitle.Parent = KeyFrame
    local KeyTextBox = Instance.new("TextBox"); KeyTextBox.Size = UDim2.new(1, -30, 0, 34); KeyTextBox.Position = UDim2.new(0, 15, 0, 42); KeyTextBox.BackgroundColor3 = Color3.fromRGB(24, 28, 42); KeyTextBox.PlaceholderText = "Nhập Key..."; KeyTextBox.Text = ""; KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255); KeyTextBox.TextSize = 12; KeyTextBox.Font = Enum.Font.Gotham; KeyTextBox.Parent = KeyFrame
    local BoxCorner = Instance.new("UICorner"); BoxCorner.CornerRadius = UDim.new(0, 8); BoxCorner.Parent = KeyTextBox

    local CheckBtn = Instance.new("TextButton"); CheckBtn.Size = UDim2.new(0.46, -4, 0, 34); CheckBtn.Position = UDim2.new(0, 15, 0, 86); CheckBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 110); CheckBtn.Text = "Check Key"; CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CheckBtn.TextSize = 12; CheckBtn.Font = Enum.Font.GothamBold; CheckBtn.Parent = KeyFrame
    local GetKeyBtn = Instance.new("TextButton"); GetKeyBtn.Size = UDim2.new(0.46, -4, 0, 34); GetKeyBtn.Position = UDim2.new(0.54, 0, 0, 86); GetKeyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242); GetKeyBtn.Text = "Discord Key"; GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); GetKeyBtn.TextSize = 12; GetKeyBtn.Font = Enum.Font.GothamBold; GetKeyBtn.Parent = KeyFrame
    local BackupBtn = Instance.new("TextButton"); BackupBtn.Size = UDim2.new(1, -30, 0, 30); BackupBtn.Position = UDim2.new(0, 15, 0, 126); BackupBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0); BackupBtn.Text = "🔗 Copy Link Lấy Key"; BackupBtn.TextColor3 = Color3.fromRGB(255, 255, 255); BackupBtn.TextSize = 11; BackupBtn.Font = Enum.Font.GothamBold; BackupBtn.Parent = KeyFrame
    local StatusText = Instance.new("TextLabel"); StatusText.Size = UDim2.new(1, -30, 0, 20); StatusText.Position = UDim2.new(0, 15, 0, 164); StatusText.BackgroundTransparency = 1; StatusText.Text = "Vui lòng nhập Key"; StatusText.TextColor3 = Color3.fromRGB(160, 170, 190); StatusText.TextSize = 11; StatusText.Font = Enum.Font.Gotham; StatusText.Parent = KeyFrame

    makeDraggable(KeyFrame)

    GetKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(DISCORD_URL); StatusText.Text = "✅ Đã copy link Discord!" end
    end)
    BackupBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(FNOTE_URL); StatusText.Text = "✅ Đã copy link Fnote!" end
    end)
    CheckBtn.MouseButton1Click:Connect(function()
        if string.gsub(KeyTextBox.Text, "^%s*(.-)%s*$", "%1") == SECRET_PASS then
            StatusText.Text = "🎉 Key đúng! Đang tải Hub..."
            savePass()
            task.wait(0.3)
            KeyFrame:Destroy()
            loadMainHub()
        else
            StatusText.Text = "❌ Key chưa chính xác!"
        end
    end)
end
