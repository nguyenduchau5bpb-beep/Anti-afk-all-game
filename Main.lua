-- [[ MRGHOST HUB VIP - ULTIMATE ANTI-AFK & PREMIUM UI ]]
local success, err = pcall(function()

    -- Services
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local VirtualUser = game:GetService("VirtualUser")
    local TeleportService = game:GetService("TeleportService")
    local GuiService = game:GetService("GuiService")
    local VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end) and game:GetService("VirtualInputManager")

    local LocalPlayer = Players.LocalPlayer

    -- Config Key System (Bảo Mật Tuyệt Đối)
    local CORRECT_KEY = "TTTT"
    local KEY_LINK = "https://discord.gg/KDTDZjYSR"
    local BACKUP_LINK = "https://fnote.net/notes/jv9G9J"
    local CACHE_FILE = "MrGhostVIP_KeyCache.json"
    local EXPIRE_TIME = 86400 -- 24h

    -- Config Feature
    local AntiAFKEnabled = true
    local AfkSeconds = 0

    -- Dọn dẹp Gui cũ
    pcall(function()
        if CoreGui:FindFirstChild("MrGhostHub_AntiAFK_Ultra") then CoreGui["MrGhostHub_AntiAFK_Ultra"]:Destroy() end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MrGhostHub_AntiAFK_Ultra") then 
            LocalPlayer.PlayerGui["MrGhostHub_AntiAFK_Ultra"]:Destroy() 
        end
    end)

    -- ScreenGui Parent (Tương Thích All Client & Máy)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MrGhostHub_AntiAFK_Ultra"
    ScreenGui.ResetOnSpawn = false

    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        local ok = pcall(function() ScreenGui.Parent = CoreGui end)
        if not ok or not ScreenGui.Parent then
            ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end

    -- Fast Rainbow RGB
    local function getRGBColor(speed)
        return Color3.fromHSV((tick() % (speed or 3)) / (speed or 3), 0.85, 1)
    end

    -- Key Cache System (24h)
    local function isKeySavedValid()
        if readfile and isfile and isfile(CACHE_FILE) then
            local successRead, data = pcall(function() return HttpService:JSONDecode(readfile(CACHE_FILE)) end)
            if successRead and type(data) == "table" and data.key == CORRECT_KEY and data.time then
                if (os.time() - data.time) < EXPIRE_TIME then return true end
            end
        end
        return false
    end

    local function saveKeyCache(key)
        if writefile then
            pcall(function() writefile(CACHE_FILE, HttpService:JSONEncode({ key = key, time = os.time() })) end)
        end
    end

    -- Draggable Function
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

    -- 🛡️ ANTI-AFK ENGINE ĐA TẦNG (BYPASS ABSOLUTE - BẤT CHẤP ALL GAME)
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
            task.wait(25)
            if AntiAFKEnabled then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(100, 100))
                end)
                if VirtualInputManager then
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Unknown, false, game)
                    end)
                end
            end
        end
    end)

    -- Đếm thời gian treo
    task.spawn(function()
        while true do
            task.wait(1)
            if AntiAFKEnabled then AfkSeconds = AfkSeconds + 1 end
        end
    end)

    -- Auto Reconnect Khi Mất Mạng/Văng Game
    GuiService.ErrorCodeChanged:Connect(function()
        task.wait(3)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)

    -- MAIN HUB
    local function loadMainHub()
        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, 320, 0, 240)
        MainFrame.Position = UDim2.new(0.5, -160, 0.35, -120)
        MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
        MainFrame.BackgroundTransparency = 0.08
        MainFrame.BorderSizePixel = 0
        MainFrame.ClipsDescendants = true
        MainFrame.Parent = ScreenGui

        local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 20); MainCorner.Parent = MainFrame
        local UIStroke = Instance.new("UIStroke"); UIStroke.Thickness = 2.5; UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; UIStroke.Parent = MainFrame

        -- Title Bar
        local TitleBar = Instance.new("Frame")
        TitleBar.Size = UDim2.new(1, 0, 0, 52)
        TitleBar.BackgroundColor3 = Color3.fromRGB(18, 21, 33)
        TitleBar.BackgroundTransparency = 0.1
        TitleBar.Parent = MainFrame

        local TitleBarCorner = Instance.new("UICorner"); TitleBarCorner.CornerRadius = UDim.new(0, 20); TitleBarCorner.Parent = TitleBar

        local LogoIcon = Instance.new("TextLabel")
        LogoIcon.Size = UDim2.new(0, 34, 0, 34)
        LogoIcon.Position = UDim2.new(0, 12, 0.5, -17)
        LogoIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
        LogoIcon.Text = "👻"
        LogoIcon.TextSize = 18
        LogoIcon.Parent = TitleBar

        local LogoCorner = Instance.new("UICorner"); LogoCorner.CornerRadius = UDim.new(0, 12); LogoCorner.Parent = LogoIcon

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0, 140, 1, 0)
        Title.Position = UDim2.new(0, 54, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "MrGhost VIP"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 15
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = TitleBar

        local HeartLabel = Instance.new("TextLabel")
        HeartLabel.Size = UDim2.new(0, 80, 1, 0)
        HeartLabel.Position = UDim2.new(1, -90, 0, 0)
        HeartLabel.BackgroundTransparency = 1
        HeartLabel.Text = "💖 VIP HUB"
        HeartLabel.TextColor3 = Color3.fromRGB(255, 120, 190)
        HeartLabel.TextSize = 12
        HeartLabel.Font = Enum.Font.GothamBold
        HeartLabel.Parent = TitleBar

        -- Content Container
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, -24, 1, -66)
        Container.Position = UDim2.new(0, 12, 0, 58)
        Container.BackgroundTransparency = 1
        Container.Parent = MainFrame

        -- Toggle Card
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 48)
        Card.Position = UDim2.new(0, 0, 0, 4)
        Card.BackgroundColor3 = Color3.fromRGB(22, 26, 40)
        Card.BackgroundTransparency = 0.2
        Card.Parent = Container

        local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 12); CardCorner.Parent = Card

        local CardLabel = Instance.new("TextLabel")
        CardLabel.Size = UDim2.new(0.65, 0, 1, 0)
        CardLabel.Position = UDim2.new(0, 14, 0, 0)
        CardLabel.BackgroundTransparency = 1
        CardLabel.Text = "🛡️ Chống AFK Treo Máy VIP"
        CardLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
        CardLabel.TextSize = 11
        CardLabel.Font = Enum.Font.GothamMedium
        CardLabel.TextXAlignment = Enum.TextXAlignment.Left
        CardLabel.Parent = Card

        local SwitchBg = Instance.new("TextButton")
        SwitchBg.Size = UDim2.new(0, 48, 0, 24)
        SwitchBg.Position = UDim2.new(1, -58, 0.5, -12)
        SwitchBg.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
        SwitchBg.Text = ""
        SwitchBg.AutoButtonColor = false
        SwitchBg.Parent = Card

        local SwitchCorner = Instance.new("UICorner"); SwitchCorner.CornerRadius = UDim.new(1, 0); SwitchCorner.Parent = SwitchBg

        local SwitchDot = Instance.new("Frame")
        SwitchDot.Size = UDim2.new(0, 18, 0, 18)
        SwitchDot.Position = UDim2.new(1, -21, 0.5, -9)
        SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchDot.Parent = SwitchBg

        local SwitchDotCorner = Instance.new("UICorner"); SwitchDotCorner.CornerRadius = UDim.new(1, 0); SwitchDotCorner.Parent = SwitchDot

        -- Status Indicator
        local StatusInfo = Instance.new("TextLabel")
        StatusInfo.Size = UDim2.new(1, 0, 0, 20)
        StatusInfo.Position = UDim2.new(0, 0, 0, 58)
        StatusInfo.BackgroundTransparency = 1
        StatusInfo.Text = "● Đang bảo vệ 24/7 (Tự vào lại khi văng)"
        StatusInfo.TextColor3 = Color3.fromRGB(0, 255, 160)
        StatusInfo.TextSize = 10
        StatusInfo.Font = Enum.Font.Gotham
        StatusInfo.Parent = Container

        local TimerInfo = Instance.new("TextLabel")
        TimerInfo.Size = UDim2.new(1, 0, 0, 22)
        TimerInfo.Position = UDim2.new(0, 0, 0, 78)
        TimerInfo.BackgroundTransparency = 1
        TimerInfo.Text = "⏱️ Đã treo: 00g 00p 00s"
        TimerInfo.TextColor3 = Color3.fromRGB(0, 230, 255)
        TimerInfo.TextSize = 11
        TimerInfo.Font = Enum.Font.GothamBold
        TimerInfo.Parent = Container

        -- Extra Quick Buttons
        local RejoinBtn = Instance.new("TextButton")
        RejoinBtn.Size = UDim2.new(0.48, -4, 0, 30)
        RejoinBtn.Position = UDim2.new(0, 0, 0, 108)
        RejoinBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        RejoinBtn.Text = "🔄 Vào Lại Game"
        RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        RejoinBtn.TextSize = 10
        RejoinBtn.Font = Enum.Font.GothamBold
        RejoinBtn.Parent = Container
        local RejoinCorner = Instance.new("UICorner"); RejoinCorner.CornerRadius = UDim.new(0, 8); RejoinCorner.Parent = RejoinBtn

        local CopyLinkBtn = Instance.new("TextButton")
        CopyLinkBtn.Size = UDim2.new(0.48, -4, 0, 30)
        CopyLinkBtn.Position = UDim2.new(0.52, 0, 0, 108)
        CopyLinkBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        CopyLinkBtn.Text = "📋 Copy Link Game"
        CopyLinkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CopyLinkBtn.TextSize = 10
        CopyLinkBtn.Font = Enum.Font.GothamBold
        CopyLinkBtn.Parent = Container
        local CopyCorner = Instance.new("UICorner"); CopyCorner.CornerRadius = UDim.new(0, 8); CopyCorner.Parent = CopyLinkBtn

        -- Clock Loop
        task.spawn(function()
            while true do
                task.wait(1)
                local hrs = math.floor(AfkSeconds / 3600)
                local mins = math.floor((AfkSeconds % 3600) / 60)
                local secs = AfkSeconds % 60
                TimerInfo.Text = string.format("⏱️ Đã treo: %02dg %02dp %02ds", hrs, mins, secs)
            end
        end)

        RejoinBtn.MouseButton1Click:Connect(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)

        CopyLinkBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard("https://www.roblox.com/games/" .. tostring(game.PlaceId) .. "?jobId=" .. tostring(game.JobId))
            end
        end)

        -- Switch Event
        SwitchBg.MouseButton1Click:Connect(function()
            AntiAFKEnabled = not AntiAFKEnabled
            if AntiAFKEnabled then
                TweenService:Create(SwitchBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(255, 0, 110)}):Play()
                TweenService:Create(SwitchDot, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
                StatusInfo.Text = "● Đang bảo vệ 24/7 (Tự vào lại khi văng)"
                StatusInfo.TextColor3 = Color3.fromRGB(0, 255, 160)
            else
                TweenService:Create(SwitchBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(45, 52, 75)}):Play()
                TweenService:Create(SwitchDot, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
                StatusInfo.Text = "○ Trạng thái: Đã tắt"
                StatusInfo.TextColor3 = Color3.fromRGB(160, 160, 175)
            end
        end)

        -- 💎 NÚT PHỤ MINI ULTRA VIP (GLOW & ANIMATED)
        local ToggleMenuBtn = Instance.new("TextButton")
        ToggleMenuBtn.Name = "MiniToggleUltraVIP"
        ToggleMenuBtn.Size = UDim2.new(0, 56, 0, 56)
        ToggleMenuBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
        ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
        ToggleMenuBtn.Text = "👻"
        ToggleMenuBtn.TextSize = 24
        ToggleMenuBtn.AutoButtonColor = false
        ToggleMenuBtn.Parent = ScreenGui

        local ToggleCorner = Instance.new("UICorner"); ToggleCorner.CornerRadius = UDim.new(1, 0); ToggleCorner.Parent = ToggleMenuBtn
        local ToggleStroke = Instance.new("UIStroke"); ToggleStroke.Thickness = 3; ToggleStroke.Parent = ToggleMenuBtn

        makeDraggable(MainFrame)
        makeDraggable(ToggleMenuBtn)

        local menuVisible = true

        -- Animation Click Elastic Bounce cho Nút Phụ
        ToggleMenuBtn.MouseButton1Click:Connect(function()
            local bounceDown = TweenService:Create(ToggleMenuBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 46, 0, 46)})
            local bounceUp = TweenService:Create(ToggleMenuBtn, TweenInfo.new(0.25, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 56, 0, 56)})
            
            bounceDown:Play()
            bounceDown.Completed:Connect(function() bounceUp:Play() end)

            menuVisible = not menuVisible
            
            if menuVisible then
                MainFrame.Visible = true
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 320, 0, 240),
                    BackgroundTransparency = 0.08
                }):Play()
            else
                local hideTween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 320, 0, 0),
                    BackgroundTransparency = 1
                })
                hideTween:Play()
                hideTween.Completed:Connect(function() if not menuVisible then MainFrame.Visible = false end end)
            end
        end)

        -- Render Loop RGB Rainbow Sync
        RunService.RenderStepped:Connect(function()
            local rainbow = getRGBColor(3)
            UIStroke.Color = rainbow
            ToggleStroke.Color = rainbow
        end)

        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "★ MRGHOST HUB VIP ★",
                Text = "Đã kích hoạt Anti-AFK Ultra Engine!",
                Duration = 3
            })
        end)
    end

    -- KEY SYSTEM UI
    if isKeySavedValid() then
        loadMainHub()
    else
        local KeyFrame = Instance.new("Frame")
        KeyFrame.Name = "KeyFrame"; KeyFrame.Size = UDim2.new(0, 300, 0, 215); KeyFrame.Position = UDim2.new(0.5, -150, 0.4, -107); KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26); KeyFrame.Parent = ScreenGui
        local KeyCorner = Instance.new("UICorner"); KeyCorner.CornerRadius = UDim.new(0, 16); KeyCorner.Parent = KeyFrame
        local KeyStroke = Instance.new("UIStroke"); KeyStroke.Thickness = 2.5; KeyStroke.Parent = KeyFrame

        RunService.RenderStepped:Connect(function() KeyStroke.Color = getRGBColor(3) end)

        local KeyTitle = Instance.new("TextLabel"); KeyTitle.Size = UDim2.new(1, 0, 0, 38); KeyTitle.BackgroundTransparency = 1; KeyTitle.Text = "🔑 KEY SYSTEM VIP 💖"; KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255); KeyTitle.TextSize = 14; KeyTitle.Font = Enum.Font.GothamBold; KeyTitle.Parent = KeyFrame
        local KeyTextBox = Instance.new("TextBox"); KeyTextBox.Size = UDim2.new(1, -30, 0, 34); KeyTextBox.Position = UDim2.new(0, 15, 0, 42); KeyTextBox.BackgroundColor3 = Color3.fromRGB(24, 28, 42); KeyTextBox.PlaceholderText = "Nhập Key VIP..."; KeyTextBox.Text = ""; KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255); KeyTextBox.TextSize = 12; KeyTextBox.Font = Enum.Font.Gotham; KeyTextBox.Parent = KeyFrame
        local BoxCorner = Instance.new("UICorner"); BoxCorner.CornerRadius = UDim.new(0, 8); BoxCorner.Parent = KeyTextBox

        local CheckBtn = Instance.new("TextButton"); CheckBtn.Size = UDim2.new(0.46, -4, 0, 34); CheckBtn.Position = UDim2.new(0, 15, 0, 86); CheckBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 110); CheckBtn.Text = "Check Key"; CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CheckBtn.TextSize = 12; CheckBtn.Font = Enum.Font.GothamBold; CheckBtn.Parent = KeyFrame
        local GetKeyBtn = Instance.new("TextButton"); GetKeyBtn.Size = UDim2.new(0.46, -4, 0, 34); GetKeyBtn.Position = UDim2.new(0.54, 0, 0, 86); GetKeyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242); GetKeyBtn.Text = "Discord Key"; GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); GetKeyBtn.TextSize = 12; GetKeyBtn.Font = Enum.Font.GothamBold; GetKeyBtn.Parent = KeyFrame
        local BackupBtn = Instance.new("TextButton"); BackupBtn.Size = UDim2.new(1, -30, 0, 32); BackupBtn.Position = UDim2.new(0, 15, 0, 128); BackupBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0); BackupBtn.Text = "🔗 Copy Link Lấy Key"; BackupBtn.TextColor3 = Color3.fromRGB(255, 255, 255); BackupBtn.TextSize = 11; BackupBtn.Font = Enum.Font.GothamBold; BackupBtn.Parent = KeyFrame

        local StatusText = Instance.new("TextLabel"); StatusText.Size = UDim2.new(1, -30, 0, 20); StatusText.Position = UDim2.new(0, 15, 0, 166); StatusText.BackgroundTransparency = 1; StatusText.Text = "Nhập Key VIP để bắt đầu"; StatusText.TextColor3 = Color3.fromRGB(160, 170, 190); StatusText.TextSize = 11; StatusText.Font = Enum.Font.Gotham; StatusText.Parent = KeyFrame

        makeDraggable(KeyFrame)

        GetKeyBtn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(KEY_LINK); StatusText.Text = "✅ Đã copy link Discord!" end
        end)

        BackupBtn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(BACKUP_LINK); StatusText.Text = "✅ Đã copy link Fnote!" end
        end)

        CheckBtn.MouseButton1Click:Connect(function()
            if string.gsub(KeyTextBox.Text, "^%s*(.-)%s*$", "%1") == CORRECT_KEY then
                StatusText.Text = "🎉 Đang tải Hub..."
                saveKeyCache(CORRECT_KEY)
                task.wait(0.3)
                KeyFrame:Destroy()
                loadMainHub()
            else
                StatusText.Text = "❌ Key sai rồi anh ơi!"
            end
        end)
    end
end)
