local success, err = pcall(function()

    -- ================================================
    -- 1. BIẾN & CẤU HÌNH HỆ THỐNG
    -- ================================================
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local VirtualUser = game:GetService("VirtualUser")
    local TeleportService = game:GetService("TeleportService")
    local GuiService = game:GetService("GuiService")

    local LocalPlayer = Players.LocalPlayer

    -- 🔑 Key & File lưu Cache
    local TARGET_KEY = "TTTT"
    local KEY_LINK = "https://discord.gg/KDTDZjYSR"
    local BACKUP_LINK = "https://fnote.net/notes/jv9G9J"
    local CACHE_FILE = "MrGhostVIP_KeyCache.json"
    local EXPIRE_TIME = 86400 -- Lưu key 24 tiếng

    -- ⚙️ Trạng thái tính năng
    local AntiAFKEnabled = true
    local AutoReconnectEnabled = true
    local BlackScreenEnabled = false
    local AfkSeconds = 0

    -- 🎨 Tạo ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MrGhostHub_UltraVIP_Engine"
    local guiParent = (gethui and gethui()) or CoreGui or (LocalPlayer and LocalPlayer:WaitForChild("PlayerGui"))
    ScreenGui.Parent = guiParent
    ScreenGui.ResetOnSpawn = false

    -- 🌈 Màu RGB đổi liên tục
    local function getRGBColor(speed)
        return Color3.fromHSV((tick() % (speed or 3)) / (speed or 3), 0.85, 1)
    end

    -- ================================================
    -- 2. HỆ THỐNG THÔNG BÁO (FULL LIGHT)
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

    -- 🔔 Hiện thông báo góc màn hình
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

        -- Viền RGB đổi màu
        local rgbConn
        rgbConn = RunService.RenderStepped:Connect(function()
            if NotifCard.Parent then NotifStroke.Color = getRGBColor(3) else rgbConn:Disconnect() end
        end)

        -- Hiệu ứng trượt vào
        NotifCard.Position = UDim2.new(1.2, 0, 0, 0)
        TweenService:Create(NotifCard, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

        -- Tự ẩn sau vài giây
        task.delay(duration, function()
            if NotifCard and NotifCard.Parent then
                local hideTween = TweenService:Create(NotifCard, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1.2, 0, 0, 0)})
                hideTween:Play()
                hideTween.Completed:Connect(function() NotifCard:Destroy() end)
            end
        end)
    end

    -- ================================================
    -- 3. XÁC MINH & LƯU KEY (CACHE 24H)
    -- ================================================
    -- 🔍 Kiểm tra key nhập
    local function verifyInputKey(input)
        if type(input) ~= "string" then return false end
        return string.gsub(input, "^%s*(.-)%s*$", "%1") == TARGET_KEY
    end

    -- 📂 Kiểm tra key đã lưu còn hạn 24h không
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

    -- 💾 Lưu key vào máy
    local function saveKeyCache(key)
        if writefile then
            pcall(function() writefile(CACHE_FILE, HttpService:JSONEncode({ key = key, time = os.time() })) end)
        end
    end

    -- ================================================
    -- 4. KÉO THẢ UI (DRAGGABLE)
    -- ================================================
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

    -- ================================================
    -- 5. ENGINE CHỐNG AFK & VĂNG GAME
    -- ================================================
    -- 🛡️ Chống AFK 1: Khi game báo rảnh rỗi (Idled)
    LocalPlayer.Idled:Connect(function()
        if AntiAFKEnabled then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end
    end)

    -- 🛡️ Chống AFK 2: Click ngẫu nhiên mỗi 30-45 giây
    task.spawn(function()
        while true do
            task.wait(math.random(30, 45))
            if AntiAFKEnabled then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end)
            end
        end
    end)

    -- ⏱️ Đếm thời gian treo máy
    task.spawn(function()
        while true do
            task.wait(1)
            if AntiAFKEnabled then AfkSeconds = AfkSeconds + 1 end
        end
    end)

    -- 🔄 Tự vào lại server khi văng mạng
    GuiService.ErrorCodeChanged:Connect(function()
        if AutoReconnectEnabled then
            showNotification("⚠️ CẢNH BÁO MẤT MẠNG", "Đang tự động kết nối lại Server...", 5)
            task.wait(3)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)

    -- 🌙 Màn hình đen tiết kiệm pin (Nằm dưới nút Ghost)
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
    BlackText.Text = "🌙 CHẾ ĐỘ TIẾT KIỆM PIN / MÁT MÁY (Bấm nút Ghost để tắt)"
    BlackText.TextColor3 = Color3.fromRGB(0, 255, 160)
    BlackText.TextSize = 14
    BlackText.Font = Enum.Font.GothamBold
    BlackText.ZIndex = 9999
    BlackText.Parent = BlackFrame

    -- ================================================
    -- 6. MENU CHÍNH (MAIN HUB)
    -- ================================================
    local function loadMainHub()
        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, 330, 0, 270)
        MainFrame.Position = UDim2.new(0.5, -165, 0.35, -135)
        MainFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
        MainFrame.BackgroundTransparency = 0.05
        MainFrame.BorderSizePixel = 0
        MainFrame.ClipsDescendants = true
        MainFrame.ZIndex = 500
        MainFrame.Parent = ScreenGui

        local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 22); MainCorner.Parent = MainFrame
        local UIStroke = Instance.new("UIStroke"); UIStroke.Thickness = 2.5; UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; UIStroke.Parent = MainFrame

        -- Thanh tiêu đề
        local TitleBar = Instance.new("Frame")
        TitleBar.Size = UDim2.new(1, 0, 0, 54)
        TitleBar.BackgroundColor3 = Color3.fromRGB(16, 19, 30)
        TitleBar.BackgroundTransparency = 0.1
        TitleBar.ZIndex = 501
        TitleBar.Parent = MainFrame

        local TitleBarCorner = Instance.new("UICorner"); TitleBarCorner.CornerRadius = UDim.new(0, 22); TitleBarCorner.Parent = TitleBar

        local LogoIcon = Instance.new("TextLabel")
        LogoIcon.Size = UDim2.new(0, 36, 0, 36)
        LogoIcon.Position = UDim2.new(0, 12, 0.5, -18)
        LogoIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
        LogoIcon.Text = "👻"
        LogoIcon.TextSize = 20
        LogoIcon.ZIndex = 502
        LogoIcon.Parent = TitleBar

        local LogoCorner = Instance.new("UICorner"); LogoCorner.CornerRadius = UDim.new(0, 12); LogoCorner.Parent = LogoIcon

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0, 140, 1, 0)
        Title.Position = UDim2.new(0, 56, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "MrGhost Anti-AFK"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 14
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.ZIndex = 502
        Title.Parent = TitleBar

        local HeartLabel = Instance.new("TextLabel")
        HeartLabel.Size = UDim2.new(0, 80, 1, 0)
        HeartLabel.Position = UDim2.new(1, -90, 0, 0)
        HeartLabel.BackgroundTransparency = 1
        HeartLabel.Text = "⚡ ULTRA VIP"
        HeartLabel.TextColor3 = Color3.fromRGB(255, 0, 110)
        HeartLabel.TextSize = 11
        HeartLabel.Font = Enum.Font.GothamBold
        HeartLabel.ZIndex = 502
        HeartLabel.Parent = TitleBar

        -- Container nội dung
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, -24, 1, -66)
        Container.Position = UDim2.new(0, 12, 0, 60)
        Container.BackgroundTransparency = 1
        Container.ZIndex = 501
        Container.Parent = MainFrame

        -- Thẻ bật/tắt Anti-AFK
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 50)
        Card.Position = UDim2.new(0, 0, 0, 4)
        Card.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
        Card.BackgroundTransparency = 0.2
        Card.ZIndex = 502
        Card.Parent = Container

        local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 12); CardCorner.Parent = Card

        local CardLabel = Instance.new("TextLabel")
        CardLabel.Size = UDim2.new(0.65, 0, 1, 0)
        CardLabel.Position = UDim2.new(0, 14, 0, 0)
        CardLabel.BackgroundTransparency = 1
        CardLabel.Text = "🛡️ Chống AFK Treo Máy VIP"
        CardLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
        CardLabel.TextSize = 12
        CardLabel.Font = Enum.Font.GothamMedium
        CardLabel.TextXAlignment = Enum.TextXAlignment.Left
        CardLabel.ZIndex = 503
        CardLabel.Parent = Card

        local SwitchBg = Instance.new("TextButton")
        SwitchBg.Size = UDim2.new(0, 48, 0, 24)
        SwitchBg.Position = UDim2.new(1, -58, 0.5, -12)
        SwitchBg.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
        SwitchBg.Text = ""
        SwitchBg.AutoButtonColor = false
        SwitchBg.ZIndex = 503
        SwitchBg.Parent = Card

        local SwitchCorner = Instance.new("UICorner"); SwitchCorner.CornerRadius = UDim.new(1, 0); SwitchCorner.Parent = SwitchBg

        local SwitchDot = Instance.new("Frame")
        SwitchDot.Size = UDim2.new(0, 18, 0, 18)
        SwitchDot.Position = UDim2.new(1, -21, 0.5, -9)
        SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchDot.ZIndex = 504
        SwitchDot.Parent = SwitchBg

        local SwitchDotCorner = Instance.new("UICorner"); SwitchDotCorner.CornerRadius = UDim.new(1, 0); SwitchDotCorner.Parent = SwitchDot

        -- Chữ trạng thái
        local StatusInfo = Instance.new("TextLabel")
        StatusInfo.Size = UDim2.new(1, 0, 0, 18)
        StatusInfo.Position = UDim2.new(0, 0, 0, 60)
        StatusInfo.BackgroundTransparency = 1
        StatusInfo.Text = "● Trạng thái: Đang bảo vệ 24/7"
        StatusInfo.TextColor3 = Color3.fromRGB(0, 255, 160)
        StatusInfo.TextSize = 11
        StatusInfo.Font = Enum.Font.Gotham
        StatusInfo.ZIndex = 502
        StatusInfo.Parent = Container

        -- Đồng hồ đếm giờ
        local TimerInfo = Instance.new("TextLabel")
        TimerInfo.Size = UDim2.new(1, 0, 0, 18)
        TimerInfo.Position = UDim2.new(0, 0, 0, 80)
        TimerInfo.BackgroundTransparency = 1
        TimerInfo.Text = "⏱️ Thời gian treo: 00g 00p 00s"
        TimerInfo.TextColor3 = Color3.fromRGB(0, 230, 255)
        TimerInfo.TextSize = 11
        TimerInfo.Font = Enum.Font.GothamBold
        TimerInfo.ZIndex = 502
        TimerInfo.Parent = Container

        -- Nút Tắt màn hình
        local BlackBtn = Instance.new("TextButton")
        BlackBtn.Size = UDim2.new(0.48, -4, 0, 32)
        BlackBtn.Position = UDim2.new(0, 0, 0, 106)
        BlackBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 56)
        BlackBtn.Text = "🌙 Tắt Màn Hình"
        BlackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BlackBtn.TextSize = 11
        BlackBtn.Font = Enum.Font.GothamBold
        BlackBtn.ZIndex = 502
        BlackBtn.Parent = Container

        local BlackBtnCorner = Instance.new("UICorner"); BlackBtnCorner.CornerRadius = UDim.new(0, 8); BlackBtnCorner.Parent = BlackBtn

        -- Nút Rejoin Server
        local RejoinBtn = Instance.new("TextButton")
        RejoinBtn.Size = UDim2.new(0.48, -4, 0, 32)
        RejoinBtn.Position = UDim2.new(0.52, 0, 0, 106)
        RejoinBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        RejoinBtn.Text = "🔄 Vào Lại Server"
        RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        RejoinBtn.TextSize = 11
        RejoinBtn.Font = Enum.Font.GothamBold
        RejoinBtn.ZIndex = 502
        RejoinBtn.Parent = Container

        local RejoinBtnCorner = Instance.new("UICorner"); RejoinBtnCorner.CornerRadius = UDim.new(0, 8); RejoinBtnCorner.Parent = RejoinBtn

        local StatusBadgeLabel

        -- Cập nhật đồng hồ mỗi giây
        task.spawn(function()
            while true do
                task.wait(1)
                local hrs = math.floor(AfkSeconds / 3600)
                local mins = math.floor((AfkSeconds % 3600) / 60)
                local secs = AfkSeconds % 60
                TimerInfo.Text = string.format("⏱️ Thời gian treo: %02dg %02dp %02ds", hrs, mins, secs)
            end
        end)

        -- 🖱️ Click nút công tắc Anti-AFK
        SwitchBg.MouseButton1Click:Connect(function()
            AntiAFKEnabled = not AntiAFKEnabled
            if AntiAFKEnabled then
                TweenService:Create(SwitchBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(255, 0, 110)}):Play()
                TweenService:Create(SwitchDot, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
                StatusInfo.Text = "● Trạng thái: Đang bảo vệ 24/7"
                StatusInfo.TextColor3 = Color3.fromRGB(0, 255, 160)
                if StatusBadgeLabel then StatusBadgeLabel.Text = "● ON"; StatusBadgeLabel.TextColor3 = Color3.fromRGB(0, 255, 160) end
                showNotification("🛡️ CHỐNG AFK", "Đã KÍCH HOẠT hệ thống Anti-AFK!", 2.5)
            else
                TweenService:Create(SwitchBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(45, 52, 75)}):Play()
                TweenService:Create(SwitchDot, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
                StatusInfo.Text = "○ Trạng thái: Đã tạm dừng"
                StatusInfo.TextColor3 = Color3.fromRGB(160, 160, 175)
                if StatusBadgeLabel then StatusBadgeLabel.Text = "○ OFF"; StatusBadgeLabel.TextColor3 = Color3.fromRGB(160, 160, 175) end
                showNotification("🛡️ CHỐNG AFK", "Đã TẠM DỪNG hệ thống Anti-AFK!", 2.5)
            end
        end)

        -- 🖱️ Click bật Màn hình đen
        BlackBtn.MouseButton1Click:Connect(function()
            BlackScreenEnabled = not BlackScreenEnabled
            BlackFrame.Visible = BlackScreenEnabled
            if BlackScreenEnabled then
                showNotification("🌙 TIẾT KIỆM PIN", "Đã bật màn hình đen tiết kiệm điện!", 3)
            end
        end)

        -- 🖱️ Click Rejoin
        RejoinBtn.MouseButton1Click:Connect(function()
            showNotification("🔄 RECONNECT", "Đang tự động vào lại Server...", 3)
            task.wait(1)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)

        -- ================================================
        -- 7. NÚT PHỤ CYBER GHOST (ZINDEX 10000 NỔI ĐÈ)
        -- ================================================
        local ToggleMenuBtn = Instance.new("TextButton")
        ToggleMenuBtn.Name = "CyberGhostFloatingButton"
        ToggleMenuBtn.Size = UDim2.new(0, 62, 0, 62)
        ToggleMenuBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
        ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
        ToggleMenuBtn.Text = "👻"
        ToggleMenuBtn.TextSize = 28
        ToggleMenuBtn.AutoButtonColor = false
        ToggleMenuBtn.ZIndex = 10000 -- Nổi đè lên màn hình đen
        ToggleMenuBtn.Parent = ScreenGui

        local ToggleCorner = Instance.new("UICorner"); ToggleCorner.CornerRadius = UDim.new(1, 0); ToggleCorner.Parent = ToggleMenuBtn
        local ToggleStroke = Instance.new("UIStroke"); ToggleStroke.Thickness = 3; ToggleStroke.Parent = ToggleMenuBtn

        -- Badge trạng thái ON/OFF dưới chân nút Ghost
        local StatusBadge = Instance.new("Frame")
        StatusBadge.Size = UDim2.new(0, 42, 0, 18)
        StatusBadge.Position = UDim2.new(0.5, -21, 1, -8)
        StatusBadge.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
        StatusBadge.ZIndex = 10001
        StatusBadge.Parent = ToggleMenuBtn

        local BadgeCorner = Instance.new("UICorner"); BadgeCorner.CornerRadius = UDim.new(1, 0); BadgeCorner.Parent = StatusBadge
        local BadgeStroke = Instance.new("UIStroke"); BadgeStroke.Thickness = 1; BadgeStroke.Color = Color3.fromRGB(40, 50, 75); BadgeStroke.Parent = StatusBadge

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

        -- 🖱️ Click Nút Ghost -> Đóng/Mở Menu & Tắt Màn hình đen
        ToggleMenuBtn.MouseButton1Click:Connect(function()
            if BlackScreenEnabled then
                BlackScreenEnabled = false
                BlackFrame.Visible = false
            end

            -- Hiệu ứng nảy
            local bounceDown = TweenService:Create(ToggleMenuBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)})
            local bounceUp = TweenService:Create(ToggleMenuBtn, TweenInfo.new(0.25, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 62, 0, 62)})
            
            bounceDown:Play()
            bounceDown.Completed:Connect(function() bounceUp:Play() end)

            menuVisible = not menuVisible
            
            if menuVisible then
                MainFrame.Visible = true
                TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 330, 0, 270),
                    BackgroundTransparency = 0.05
                }):Play()
            else
                local hideTween = TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 330, 0, 0),
                    BackgroundTransparency = 1
                })
                hideTween:Play()
                hideTween.Completed:Connect(function() if not menuVisible then MainFrame.Visible = false end end)
            end
        end)

        -- Đổi màu LED cầu vồng
        RunService.RenderStepped:Connect(function()
            local rainbow = getRGBColor(3)
            UIStroke.Color = rainbow
            ToggleStroke.Color = rainbow
        end)

        showNotification("★ MRGHOST HUB VIP ★", "Đã bật Anti-AFK Ultra Engine!", 3.5)
    end

    -- ================================================
    -- 8. GIAO DIỆN NHẬP KEY (KEY SYSTEM)
    -- ================================================
    if isKeySavedValid() then
        loadMainHub()
        showNotification("🔑 HỆ THỐNG KEY", "Đã tự động xác minh Key Cache 24h!", 3)
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

        local StatusText = Instance.new("TextLabel"); StatusText.Size = UDim2.new(1, -30, 0, 20); StatusText.Position = UDim2.new(0, 15, 0, 166); StatusText.BackgroundTransparency = 1; StatusText.Text = "Hãy nhập Key VIP để bắt đầu"; StatusText.TextColor3 = Color3.fromRGB(160, 170, 190); StatusText.TextSize = 11; StatusText.Font = Enum.Font.Gotham; StatusText.Parent = KeyFrame

        makeDraggable(KeyFrame)

        GetKeyBtn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(KEY_LINK); StatusText.Text = "✅ Đã copy link Discord!" end
        end)

        BackupBtn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(BACKUP_LINK); StatusText.Text = "✅ Đã copy link Fnote!" end
        end)

        -- 🖱️ Click kiểm tra key
        CheckBtn.MouseButton1Click:Connect(function()
            if verifyInputKey(KeyTextBox.Text) then
                StatusText.Text = "🎉 Key chính xác! Đang tải..."
                saveKeyCache(KeyTextBox.Text)
                task.wait(0.3)
                KeyFrame:Destroy()
                loadMainHub()
            else
                StatusText.Text = "❌ Key không hợp lệ!"
            end
        end)
    end
end)
