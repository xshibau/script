--// ULTRA PINK GLASSMORPHISM ROBLOX UI LIBRARY (345x300) - V3 //--
--// Features: Multi-Layer Aurora Glass, Orbiting Neon Orbs, Spring Physics, Searchable Dropdowns, //--
--// Keybinds, Color Pickers, Notifications, Minimize/Close Controls, Floating Mobile Toggle, Config Save //--

local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Bảng màu Ultra Pink Glassmorphism cao cấp
local Palette = {
    VoidPink = Color3.fromRGB(22, 9, 19),
    GlassDark = Color3.fromRGB(36, 14, 30),
    GlassCard = Color3.fromRGB(52, 20, 43),
    GlassCardHover = Color3.fromRGB(72, 27, 59),
    GlassInput = Color3.fromRGB(24, 9, 20),

    NeonPink = Color3.fromRGB(255, 75, 165),
    HotRose = Color3.fromRGB(255, 115, 195),
    PastelSakura = Color3.fromRGB(255, 175, 218),
    CottonCandy = Color3.fromRGB(255, 212, 236),
    MagentaGlow = Color3.fromRGB(215, 45, 135),
    DeepPlum = Color3.fromRGB(115, 28, 76),

    TextWhite = Color3.fromRGB(255, 248, 252),
    TextSoft = Color3.fromRGB(232, 185, 210),
    TextMuted = Color3.fromRGB(168, 120, 146),
    TrackOff = Color3.fromRGB(64, 28, 52),
}

-- Hàm Tween chuẩn
local function Tween(instance, time, props, style, dir)
    local info = TweenInfo.new(
        time or 0.25,
        style or Enum.EasingStyle.Quint,
        dir or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(instance, info, props)
    tw:Play()
    return tw
end

-- Hiệu ứng sóng lan + tia sáng (Ripple & Spark Burst)
local function SpawnRipple(container, x, y, color)
    task.spawn(function()
        if not container or not container.Parent then return end
        local relX = x - container.AbsolutePosition.X
        local relY = y - container.AbsolutePosition.Y

        local ring = Instance.new("Frame")
        ring.Name = "RippleRing"
        ring.Parent = container
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.Position = UDim2.new(0, relX, 0, relY)
        ring.Size = UDim2.new(0, 0, 0, 0)
        ring.BackgroundColor3 = color or Palette.PastelSakura
        ring.BackgroundTransparency = 0.45
        ring.BorderSizePixel = 0
        ring.ZIndex = (container.ZIndex or 1) + 10
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

        local maxDim = math.max(container.AbsoluteSize.X, container.AbsoluteSize.Y) * 2.4
        Tween(ring, 0.5, {
            Size = UDim2.new(0, maxDim, 0, maxDim),
            BackgroundTransparency = 1
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        task.wait(0.52)
        if ring then ring:Destroy() end
    end)
end

-- Tạo viền kính phát sáng chuyển màu hồng
local function AddAuroraStroke(parent, thickness, transparency, rotOffset)
    local stroke = Instance.new("UIStroke")
    stroke.Parent = parent
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness or 1.2
    stroke.Transparency = transparency or 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local grad = Instance.new("UIGradient")
    grad.Parent = stroke
    grad.Rotation = rotOffset or 35
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Palette.CottonCandy),
        ColorSequenceKeypoint.new(0.35, Palette.NeonPink),
        ColorSequenceKeypoint.new(0.70, Palette.PastelSakura),
        ColorSequenceKeypoint.new(1.00, Palette.MagentaGlow),
    })

    return stroke, grad
end

-- Kéo thả mượt cho cả PC và Mobile
local function EnableDrag(handle, target)
    local dragging = false
    local activeInput, startMouse, startPos

    local function applyDelta(input)
        local delta = input.Position - startMouse
        local goal = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        Tween(target, 0.07, {Position = goal}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startMouse = input.Position
            startPos = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            activeInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == activeInput then
            applyDelta(input)
        end
    end)
end

function Library:CreateWindow(Config)
    Config = Config or {}
    local LogoAsset = Config.Logo or "rbxassetid://0"
    local MainPink = Config.Accent or Palette.NeonPink
    local ToggleKey = Config.ToggleKey or Enum.KeyCode.RightControl

    if CoreGui:FindFirstChild("UltraPinkGlassUI") then
        CoreGui:FindFirstChild("UltraPinkGlassUI"):Destroy()
    end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "UltraPinkGlassUI"
    Gui.Parent = CoreGui
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true

    -- Hệ thống thông báo góc màn hình (Toast Notifications)
    local NotifyStack = Instance.new("Frame")
    NotifyStack.Name = "NotifyStack"
    NotifyStack.Parent = Gui
    NotifyStack.BackgroundTransparency = 1
    NotifyStack.Position = UDim2.new(1, -230, 1, -18)
    NotifyStack.AnchorPoint = Vector2.new(0, 1)
    NotifyStack.Size = UDim2.new(0, 215, 0, 260)
    NotifyStack.ZIndex = 50

    local NotifyLayout = Instance.new("UIListLayout")
    NotifyLayout.Parent = NotifyStack
    NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifyLayout.Padding = UDim.new(0, 6)

    function Library:Notify(TitleStr, BodyStr, Duration)
        Duration = Duration or 3
        task.spawn(function()
            local Card = Instance.new("Frame")
            Card.Parent = NotifyStack
            Card.BackgroundColor3 = Palette.GlassDark
            Card.BackgroundTransparency = 0.15
            Card.Size = UDim2.new(1, 0, 0, 0)
            Card.ClipsDescendants = true
            Card.ZIndex = 52
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 9)
            AddAuroraStroke(Card, 1.2, 0.25, 25)

            local AccentBar = Instance.new("Frame")
            AccentBar.Parent = Card
            AccentBar.BackgroundColor3 = MainPink
            AccentBar.Size = UDim2.new(0, 4, 1, 0)
            AccentBar.ZIndex = 53
            Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(1, 0)

            local TLabel = Instance.new("TextLabel")
            TLabel.Parent = Card
            TLabel.BackgroundTransparency = 1
            TLabel.Position = UDim2.new(0, 12, 0, 5)
            TLabel.Size = UDim2.new(1, -18, 0, 16)
            TLabel.Font = Enum.Font.GothamBold
            TLabel.Text = TitleStr or "Notification"
            TLabel.TextColor3 = Palette.CottonCandy
            TLabel.TextSize = 11
            TLabel.TextXAlignment = Enum.TextXAlignment.Left
            TLabel.ZIndex = 53

            local BLabel = Instance.new("TextLabel")
            BLabel.Parent = Card
            BLabel.BackgroundTransparency = 1
            BLabel.Position = UDim2.new(0, 12, 0, 21)
            BLabel.Size = UDim2.new(1, -18, 0, 24)
            BLabel.Font = Enum.Font.Gotham
            BLabel.Text = BodyStr or ""
            BLabel.TextColor3 = Palette.TextSoft
            BLabel.TextSize = 10
            BLabel.TextWrapped = true
            BLabel.TextXAlignment = Enum.TextXAlignment.Left
            BLabel.TextYAlignment = Enum.TextYAlignment.Top
            BLabel.ZIndex = 53

            local ProgBg = Instance.new("Frame")
            ProgBg.Parent = Card
            ProgBg.BackgroundColor3 = Palette.DeepPlum
            ProgBg.BackgroundTransparency = 0.4
            ProgBg.Position = UDim2.new(0, 12, 1, -5)
            ProgBg.Size = UDim2.new(1, -20, 0, 2)
            ProgBg.ZIndex = 53

            local ProgFill = Instance.new("Frame")
            ProgFill.Parent = ProgBg
            ProgFill.BackgroundColor3 = Palette.PastelSakura
            ProgFill.Size = UDim2.new(1, 0, 1, 0)
            ProgFill.ZIndex = 54

            Tween(Card, 0.3, {Size = UDim2.new(1, 0, 0, 52)}, Enum.EasingStyle.Back)
            Tween(ProgFill, Duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)

            task.wait(Duration)
            Tween(Card, 0.25, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
            task.wait(0.26)
            if Card then Card:Destroy() end
        end)
    end

    -- Nút nổi mở/ẩn UI nhanh trên Mobile / khi thu gọn
    local FloatBtn = Instance.new("TextButton")
    FloatBtn.Name = "FloatingToggle"
    FloatBtn.Parent = Gui
    FloatBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    FloatBtn.Position = UDim2.new(0.12, 0, 0.22, 0)
    FloatBtn.Size = UDim2.new(0, 42, 0, 42)
    FloatBtn.BackgroundColor3 = Palette.GlassDark
    FloatBtn.BackgroundTransparency = 0.18
    FloatBtn.Text = "✦"
    FloatBtn.TextColor3 = Palette.CottonCandy
    FloatBtn.Font = Enum.Font.GothamBold
    FloatBtn.TextSize = 18
    FloatBtn.AutoButtonColor = false
    FloatBtn.ZIndex = 40
    Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
    local _, FloatGrad = AddAuroraStroke(FloatBtn, 1.5, 0.2, 0)
    EnableDrag(FloatBtn, FloatBtn)

    -- Khung chính kích thước chuẩn 345x300px
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Parent = Gui
    MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainWindow.Size = UDim2.new(0, 0, 0, 0)
    MainWindow.BackgroundColor3 = Palette.VoidPink
    MainWindow.BackgroundTransparency = 0.24
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = true
    MainWindow.ZIndex = 5

    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 14)
    local _, WindowStrokeGrad = AddAuroraStroke(MainWindow, 1.6, 0.15, 45)

    -- Lớp nền kính hồng Aurora đa tầng (Glass Aurora Mesh)
    local AuroraLayer = Instance.new("Frame")
    AuroraLayer.Name = "AuroraLayer"
    AuroraLayer.Parent = MainWindow
    AuroraLayer.Size = UDim2.new(1, 0, 1, 0)
    AuroraLayer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AuroraLayer.BackgroundTransparency = 0.86
    AuroraLayer.BorderSizePixel = 0
    AuroraLayer.ZIndex = 6
    Instance.new("UICorner", AuroraLayer).CornerRadius = UDim.new(0, 14)

    local AuroraGrad = Instance.new("UIGradient")
    AuroraGrad.Parent = AuroraLayer
    AuroraGrad.Rotation = 125
    AuroraGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 130, 200)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 65, 160)),
        ColorSequenceKeypoint.new(0.80, Color3.fromRGB(165, 35, 115)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 190, 225)),
    })

    -- Quầng sáng chuyển động mềm mại (Ambient Glowing Orbs)
    local function CreateAmbientBlob(sizePx, color, alpha, xStart, yStart, moveX, moveY, speed)
        local blob = Instance.new("Frame")
        blob.Parent = AuroraLayer
        blob.BackgroundColor3 = color
        blob.BackgroundTransparency = alpha
        blob.BorderSizePixel = 0
        blob.Position = UDim2.new(0, xStart, 0, yStart)
        blob.Size = UDim2.new(0, sizePx, 0, sizePx)
        blob.ZIndex = 7
        Instance.new("UICorner", blob).CornerRadius = UDim.new(1, 0)

        task.spawn(function()
            while Gui and Gui.Parent do
                Tween(blob, speed, {
                    Position = UDim2.new(0, xStart + moveX, 0, yStart + moveY)
                }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(speed)
                Tween(blob, speed, {
                    Position = UDim2.new(0, xStart, 0, yStart)
                }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(speed)
            end
        end)
    end

    CreateAmbientBlob(140, Palette.NeonPink, 0.86, -20, 40, 45, 30, 3.8)
    CreateAmbientBlob(115, Palette.PastelSakura, 0.88, 220, 150, -40, -35, 4.4)
    CreateAmbientBlob(90, Palette.HotRose, 0.87, 130, 85, 25, -25, 3.2)

    -- Hạt kim tuyến hồng bay lấp lánh liên tục
    task.spawn(function()
        while Gui and Gui.Parent do
            if MainWindow.Visible and MainWindow.Size.Y.Offset > 100 then
                local spark = Instance.new("Frame")
                spark.Parent = AuroraLayer
                spark.BackgroundColor3 = Palette.CottonCandy
                spark.BackgroundTransparency = 0.35
                spark.BorderSizePixel = 0
                local d = math.random(3, 7)
                local px = math.random(12, 332)
                spark.Size = UDim2.new(0, d, 0, d)
                spark.Position = UDim2.new(0, px, 1, 6)
                spark.ZIndex = 8
                Instance.new("UICorner", spark).CornerRadius = UDim.new(1, 0)

                local life = math.random(28, 52) / 10
                Tween(spark, life, {
                    Position = UDim2.new(0, px + math.random(-28, 28), 0, -12),
                    BackgroundTransparency = 1
                }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

                task.delay(life + 0.05, function()
                    if spark then spark:Destroy() end
                end)
            end
            task.wait(0.28)
        end
    end)

    -- Xoay gradient viền kính liên tục
    task.spawn(function()
        while Gui and Gui.Parent do
            WindowStrokeGrad.Rotation = (WindowStrokeGrad.Rotation + 1.4) % 360
            AuroraGrad.Rotation = (AuroraGrad.Rotation + 0.35) % 360
            FloatGrad.Rotation = (FloatGrad.Rotation + 2.0) % 360
            RunService.RenderStepped:Wait()
        end
    end)

    -- Thanh Topbar chứa Logo bên trái + Tab lướt ngang + nút Thu gọn/Đóng
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainWindow
    TopBar.BackgroundColor3 = Palette.GlassDark
    TopBar.BackgroundTransparency = 0.22
    TopBar.BorderSizePixel = 0
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.Size = UDim2.new(1, 0, 0, 44)
    TopBar.ZIndex = 12

    -- Đường kẻ phát sáng ngăn cách TopBar và vùng tính năng
    local HeaderLine = Instance.new("Frame")
    HeaderLine.Name = "HeaderLine"
    HeaderLine.Parent = MainWindow
    HeaderLine.Position = UDim2.new(0, 8, 0, 44)
    HeaderLine.Size = UDim2.new(1, -16, 0, 1)
    HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HeaderLine.BackgroundTransparency = 0.2
    HeaderLine.BorderSizePixel = 0
    HeaderLine.ZIndex = 14

    local LineGrad = Instance.new("UIGradient")
    LineGrad.Parent = HeaderLine
    LineGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Palette.NeonPink),
        ColorSequenceKeypoint.new(0.50, Palette.CottonCandy),
        ColorSequenceKeypoint.new(1.00, Palette.NeonPink),
    })

    -- Ô chừa chỗ Logo bên trái Tab
    local LogoBox = Instance.new("Frame")
    LogoBox.Name = "LogoBox"
    LogoBox.Parent = TopBar
    LogoBox.BackgroundColor3 = Palette.GlassCard
    LogoBox.BackgroundTransparency = 0.25
    LogoBox.Position = UDim2.new(0, 8, 0.5, -16)
    LogoBox.Size = UDim2.new(0, 32, 0, 32)
    LogoBox.ZIndex = 13
    Instance.new("UICorner", LogoBox).CornerRadius = UDim.new(0, 9)
    AddAuroraStroke(LogoBox, 1.2, 0.25, 15)

    local LogoImg = Instance.new("ImageLabel")
    LogoImg.Name = "LogoImage"
    LogoImg.Parent = LogoBox
    LogoImg.BackgroundTransparency = 1
    LogoImg.Position = UDim2.new(0, 2, 0, 2)
    LogoImg.Size = UDim2.new(1, -4, 1, -4)
    LogoImg.Image = LogoAsset
    LogoImg.ScaleType = Enum.ScaleType.Fit
    LogoImg.ZIndex = 14
    Instance.new("UICorner", LogoImg).CornerRadius = UDim.new(0, 7)

    -- Cụm nút nhỏ bên phải TopBar (Thu nhỏ & Tắt UI)
    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "MinimizeBtn"
    MinBtn.Parent = TopBar
    MinBtn.BackgroundColor3 = Palette.GlassCard
    MinBtn.BackgroundTransparency = 0.3
    MinBtn.Position = UDim2.new(1, -46, 0.5, -9)
    MinBtn.Size = UDim2.new(0, 18, 0, 18)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "–"
    MinBtn.TextColor3 = Palette.CottonCandy
    MinBtn.TextSize = 12
    MinBtn.AutoButtonColor = false
    MinBtn.ZIndex = 14
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TopBar
    CloseBtn.BackgroundColor3 = Palette.GlassCard
    CloseBtn.BackgroundTransparency = 0.3
    CloseBtn.Position = UDim2.new(1, -24, 0.5, -9)
    CloseBtn.Size = UDim2.new(0, 18, 0, 18)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Palette.PastelSakura
    CloseBtn.TextSize = 13
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 14
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

    -- Scrolling ngang chứa danh sách Tab [Home Menu] [Settings]...
    local TabScroller = Instance.new("ScrollingFrame")
    TabScroller.Name = "TabScroller"
    TabScroller.Parent = TopBar
    TabScroller.Active = true
    TabScroller.BackgroundTransparency = 1
    TabScroller.BorderSizePixel = 0
    TabScroller.Position = UDim2.new(0, 46, 0, 5)
    TabScroller.Size = UDim2.new(1, -98, 0, 34)
    TabScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroller.ScrollBarThickness = 2
    TabScroller.ScrollBarImageColor3 = Palette.PastelSakura
    TabScroller.ScrollBarImageTransparency = 0.25
    TabScroller.ScrollingDirection = Enum.ScrollingDirection.X
    TabScroller.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabScroller.ZIndex = 13

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabScroller
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    -- Kéo thả khung chính bằng TopBar
    EnableDrag(TopBar, MainWindow)

    -- Khu vực chứa các trang nội dung
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "PagesContainer"
    PagesContainer.Parent = MainWindow
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Position = UDim2.new(0, 0, 0, 46)
    PagesContainer.Size = UDim2.new(1, 0, 1, -46)
    PagesContainer.ZIndex = 10

    -- Bung mở UI chuẩn 345x300px khi chạy
    Tween(MainWindow, 0.5, {Size = UDim2.new(0, 345, 0, 300)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local minimized = false
    local function ToggleWindowVisibility(forceState)
        if forceState ~= nil then
            MainWindow.Visible = forceState
        else
            MainWindow.Visible = not MainWindow.Visible
        end
        if MainWindow.Visible then
            MainWindow.Size = UDim2.new(0, 345, 0, 0)
            Tween(MainWindow, 0.35, {Size = UDim2.new(0, 345, 0, minimized and 44 or 300)}, Enum.EasingStyle.Back)
        end
    end

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            PagesContainer.Visible = false
            HeaderLine.Visible = false
            Tween(MainWindow, 0.3, {Size = UDim2.new(0, 345, 0, 44)}, Enum.EasingStyle.Quint)
            MinBtn.Text = "+"
        else
            Tween(MainWindow, 0.35, {Size = UDim2.new(0, 345, 0, 300)}, Enum.EasingStyle.Back)
            task.delay(0.15, function()
                if not minimized then
                    HeaderLine.Visible = true
                    PagesContainer.Visible = true
                end
            end)
            MinBtn.Text = "–"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainWindow, 0.25, {Size = UDim2.new(0, 345, 0, 0)}, Enum.EasingStyle.Quad)
        task.wait(0.26)
        MainWindow.Visible = false
    end)

    FloatBtn.MouseButton1Click:Connect(function()
        local mp = UserInputService:GetMouseLocation()
        SpawnRipple(FloatBtn, mp.X, mp.Y, Palette.CottonCandy)
        ToggleWindowVisibility()
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == ToggleKey then
            ToggleWindowVisibility()
        end
    end)

    local WindowAPI = {}
    local isFirstTab = true

    function WindowAPI:CreateTab(TabTitle)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabTitle .. "_Tab"
        TabButton.Parent = TabScroller
        TabButton.BackgroundColor3 = Palette.GlassCard
        TabButton.BackgroundTransparency = 0.35
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(0, 74, 0, 25)
        TabButton.AutomaticSize = Enum.AutomaticSize.X
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = "   " .. TabTitle .. "   "
        TabButton.TextColor3 = Palette.TextSoft
        TabButton.TextSize = 11
        TabButton.AutoButtonColor = false
        TabButton.ClipsDescendants = true
        TabButton.ZIndex = 14

        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 7)
        local TabStroke = Instance.new("UIStroke")
        TabStroke.Parent = TabButton
        TabStroke.Color = Palette.PastelSakura
        TabStroke.Thickness = 1
        TabStroke.Transparency = 0.75
        TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- Gạch chân sáng dưới Tab đang chọn
        local TabIndicator = Instance.new("Frame")
        TabIndicator.Parent = TabButton
        TabIndicator.AnchorPoint = Vector2.new(0.5, 1)
        TabIndicator.Position = UDim2.new(0.5, 0, 1, -1)
        TabIndicator.Size = UDim2.new(0, 0, 0, 2)
        TabIndicator.BackgroundColor3 = Palette.CottonCandy
        TabIndicator.BorderSizePixel = 0
        TabIndicator.ZIndex = 15
        Instance.new("UICorner", TabIndicator).CornerRadius = UDim.new(1, 0)

        -- Khung cuộn dọc danh sách tính năng
        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabTitle .. "_Page"
        Page.Parent = PagesContainer
        Page.Active = true
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Position = UDim2.new(0, 8, 0, 4)
        Page.Size = UDim2.new(1, -16, 1, -8)
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Palette.HotRose
        Page.ScrollBarImageTransparency = 0.2
        Page.Visible = false
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ZIndex = 11

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 7)

        local PagePad = Instance.new("UIPadding")
        PagePad.Parent = Page
        PagePad.PaddingTop = UDim.new(0, 2)
        PagePad.PaddingBottom = UDim.new(0, 10)
        PagePad.PaddingLeft = UDim.new(0, 2)
        PagePad.PaddingRight = UDim.new(0, 5)

        local function ActivateTab()
            for _, child in pairs(PagesContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            for _, btn in pairs(TabScroller:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, 0.22, {
                        BackgroundColor3 = Palette.GlassCard,
                        BackgroundTransparency = 0.35,
                        TextColor3 = Palette.TextSoft
                    })
                    local st = btn:FindFirstChildOfClass("UIStroke")
                    if st then Tween(st, 0.22, {Transparency = 0.75}) end
                    local ind = btn:FindFirstChildOfClass("Frame")
                    if ind then Tween(ind, 0.2, {Size = UDim2.new(0, 0, 0, 2)}) end
                end
            end

            Page.Visible = true
            Page.CanvasPosition = Vector2.new(0, 0)
            Tween(TabButton, 0.25, {
                BackgroundColor3 = MainPink,
                BackgroundTransparency = 0.14,
                TextColor3 = Palette.TextWhite
            })
            Tween(TabStroke, 0.25, {Transparency = 0.1})
            Tween(TabIndicator, 0.25, {Size = UDim2.new(0.65, 0, 0, 2)})
        end

        if isFirstTab then
            isFirstTab = false
            ActivateTab()
        end

        TabButton.MouseButton1Click:Connect(function()
            local mp = UserInputService:GetMouseLocation()
            SpawnRipple(TabButton, mp.X, mp.Y, Palette.CottonCandy)
            ActivateTab()
        end)

        local Elements = {}

        -- 0. SECTION / LABEL PHÂN NHÓM (Tiêu đề mục kính hồng)
        function Elements:Section(Title)
            local SecFrame = Instance.new("Frame")
            SecFrame.Parent = Page
            SecFrame.BackgroundTransparency = 1
            SecFrame.Size = UDim2.new(1, 0, 0, 20)
            SecFrame.ZIndex = 12

            local Dot = Instance.new("Frame")
            Dot.Parent = SecFrame
            Dot.Position = UDim2.new(0, 4, 0.5, -3)
            Dot.Size = UDim2.new(0, 6, 0, 6)
            Dot.BackgroundColor3 = Palette.HotRose
            Dot.ZIndex = 13
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

            local SecText = Instance.new("TextLabel")
            SecText.Parent = SecFrame
            SecText.BackgroundTransparency = 1
            SecText.Position = UDim2.new(0, 15, 0, 0)
            SecText.Size = UDim2.new(1, -15, 1, 0)
            SecText.Font = Enum.Font.GothamBold
            SecText.Text = string.upper(Title or "SECTION")
            SecText.TextColor3 = Palette.PastelSakura
            SecText.TextSize = 10
            SecText.TextXAlignment = Enum.TextXAlignment.Left
            SecText.ZIndex = 13
        end

        -- 1. BUTTON (Nút bấm kính hồng phát sáng, sóng lan + huy hiệu động)
        function Elements:Button(Text, Callback)
            Callback = Callback or function() end

            local Btn = Instance.new("TextButton")
            Btn.Name = "Button"
            Btn.Parent = Page
            Btn.BackgroundColor3 = Palette.GlassCard
            Btn.BackgroundTransparency = 0.26
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.Font = Enum.Font.GothamMedium
            Btn.Text = "   " .. Text
            Btn.TextColor3 = Palette.TextWhite
            Btn.TextSize = 12
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.AutoButtonColor = false
            Btn.ClipsDescendants = true
            Btn.ZIndex = 12

            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 9)
            local stroke = AddAuroraStroke(Btn, 1.1, 0.58, 20)

            local ActionPill = Instance.new("Frame")
            ActionPill.Parent = Btn
            ActionPill.BackgroundColor3 = MainPink
            ActionPill.BackgroundTransparency = 0.25
            ActionPill.Position = UDim2.new(1, -30, 0.5, -10)
            ActionPill.Size = UDim2.new(0, 22, 0, 20)
            ActionPill.ZIndex = 13
            Instance.new("UICorner", ActionPill).CornerRadius = UDim.new(0, 6)

            local ArrowLbl = Instance.new("TextLabel")
            ArrowLbl.Parent = ActionPill
            ArrowLbl.BackgroundTransparency = 1
            ArrowLbl.Size = UDim2.new(1, 0, 1, 0)
            ArrowLbl.Font = Enum.Font.GothamBold
            ArrowLbl.Text = "›"
            ArrowLbl.TextColor3 = Palette.TextWhite
            ArrowLbl.TextSize = 15
            ArrowLbl.ZIndex = 14

            Btn.MouseEnter:Connect(function()
                Tween(Btn, 0.18, {BackgroundColor3 = Palette.GlassCardHover, BackgroundTransparency = 0.16})
                Tween(stroke, 0.18, {Transparency = 0.2})
                Tween(ActionPill, 0.18, {BackgroundTransparency = 0.05})
            end)

            Btn.MouseLeave:Connect(function()
                Tween(Btn, 0.18, {BackgroundColor3 = Palette.GlassCard, BackgroundTransparency = 0.26})
                Tween(stroke, 0.18, {Transparency = 0.58})
                Tween(ActionPill, 0.18, {BackgroundTransparency = 0.25})
            end)

            Btn.MouseButton1Click:Connect(function()
                local mp = UserInputService:GetMouseLocation()
                SpawnRipple(Btn, mp.X, mp.Y, Palette.CottonCandy)
                Tween(ActionPill, 0.1, {Size = UDim2.new(0, 26, 0, 20), Position = UDim2.new(1, -32, 0.5, -10)})
                task.delay(0.1, function()
                    Tween(ActionPill, 0.2, {Size = UDim2.new(0, 22, 0, 20), Position = UDim2.new(1, -30, 0.5, -10)}, Enum.EasingStyle.Back)
                end)
                Callback()
            end)
        end

        -- 2. TOGGLE (Công tắc gạt đồ họa xịn: Viên thuốc neon hồng, lõi phát sáng, lò xo nảy mượt)
        function Elements:Toggle(Text, Default, Callback)
            local state = Default or false
            Callback = Callback or function() end

            local Tgl = Instance.new("TextButton")
            Tgl.Name = "Toggle"
            Tgl.Parent = Page
            Tgl.BackgroundColor3 = Palette.GlassCard
            Tgl.BackgroundTransparency = 0.26
            Tgl.Size = UDim2.new(1, 0, 0, 36)
            Tgl.Font = Enum.Font.GothamMedium
            Tgl.Text = "   " .. Text
            Tgl.TextColor3 = Palette.TextWhite
            Tgl.TextSize = 12
            Tgl.TextXAlignment = Enum.TextXAlignment.Left
            Tgl.AutoButtonColor = false
            Tgl.ClipsDescendants = true
            Tgl.ZIndex = 12

            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(0, 9)
            local cardStroke = AddAuroraStroke(Tgl, 1.1, state and 0.22 or 0.62, 40)

            -- Rãnh công tắc viên thuốc
            local Track = Instance.new("Frame")
            Track.Name = "Track"
            Track.Parent = Tgl
            Track.BackgroundColor3 = state and MainPink or Palette.TrackOff
            Track.BackgroundTransparency = state and 0.08 or 0.25
            Track.Position = UDim2.new(1, -54, 0.5, -11)
            Track.Size = UDim2.new(0, 44, 0, 22)
            Track.ZIndex = 13
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

            local TrackStroke = Instance.new("UIStroke")
            TrackStroke.Parent = Track
            TrackStroke.Color = state and Palette.CottonCandy or Palette.PastelSakura
            TrackStroke.Thickness = 1.2
            TrackStroke.Transparency = state and 0.1 or 0.65

            -- Hào quang tỏa bên trong khi bật
            local InnerHalo = Instance.new("Frame")
            InnerHalo.Parent = Track
            InnerHalo.BackgroundColor3 = Palette.HotRose
            InnerHalo.BackgroundTransparency = state and 0.58 or 1
            InnerHalo.Size = UDim2.new(1, 0, 1, 0)
            InnerHalo.ZIndex = 13
            Instance.new("UICorner", InnerHalo).CornerRadius = UDim.new(1, 0)

            -- Núm gạt tròn
            local Thumb = Instance.new("Frame")
            Thumb.Name = "Thumb"
            Thumb.Parent = Track
            Thumb.BackgroundColor3 = Palette.TextWhite
            Thumb.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            Thumb.Size = UDim2.new(0, 18, 0, 18)
            Thumb.ZIndex = 14
            Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)

            -- Lõi phát sáng bên trong núm
            local ThumbDot = Instance.new("Frame")
            ThumbDot.Parent = Thumb
            ThumbDot.AnchorPoint = Vector2.new(0.5, 0.5)
            ThumbDot.Position = UDim2.new(0.5, 0, 0.5, 0)
            ThumbDot.Size = state and UDim2.new(0, 8, 0, 8) or UDim2.new(0, 5, 0, 5)
            ThumbDot.BackgroundColor3 = state and MainPink or Palette.TextMuted
            ThumbDot.ZIndex = 15
            Instance.new("UICorner", ThumbDot).CornerRadius = UDim.new(1, 0)

            local function RenderToggle(val, animate)
                local d = animate and 0.25 or 0
                if val then
                    if animate then
                        Tween(Thumb, 0.09, {Size = UDim2.new(0, 22, 0, 16), Position = UDim2.new(1, -23, 0.5, -8)}, Enum.EasingStyle.Quad)
                        task.delay(0.09, function()
                            Tween(Thumb, 0.22, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -20, 0.5, -9)}, Enum.EasingStyle.Back)
                        end)
                    else
                        Thumb.Position = UDim2.new(1, -20, 0.5, -9)
                    end
                    Tween(Track, d, {BackgroundColor3 = MainPink, BackgroundTransparency = 0.08})
                    Tween(TrackStroke, d, {Color = Palette.CottonCandy, Transparency = 0.1})
                    Tween(InnerHalo, d, {BackgroundTransparency = 0.58})
                    Tween(ThumbDot, d, {BackgroundColor3 = MainPink, Size = UDim2.new(0, 8, 0, 8)})
                    Tween(cardStroke, d, {Transparency = 0.22})
                else
                    if animate then
                        Tween(Thumb, 0.09, {Size = UDim2.new(0, 22, 0, 16), Position = UDim2.new(0, 2, 0.5, -8)}, Enum.EasingStyle.Quad)
                        task.delay(0.09, function()
                            Tween(Thumb, 0.22, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 2, 0.5, -9)}, Enum.EasingStyle.Back)
                        end)
                    else
                        Thumb.Position = UDim2.new(0, 2, 0.5, -9)
                    end
                    Tween(Track, d, {BackgroundColor3 = Palette.TrackOff, BackgroundTransparency = 0.25})
                    Tween(TrackStroke, d, {Color = Palette.PastelSakura, Transparency = 0.65})
                    Tween(InnerHalo, d, {BackgroundTransparency = 1})
                    Tween(ThumbDot, d, {BackgroundColor3 = Palette.TextMuted, Size = UDim2.new(0, 5, 0, 5)})
                    Tween(cardStroke, d, {Transparency = 0.62})
                end
            end

            Tgl.MouseEnter:Connect(function()
                Tween(Tgl, 0.18, {BackgroundColor3 = Palette.GlassCardHover, BackgroundTransparency = 0.16})
            end)

            Tgl.MouseLeave:Connect(function()
                Tween(Tgl, 0.18, {BackgroundColor3 = Palette.GlassCard, BackgroundTransparency = 0.26})
            end)

            Tgl.MouseButton1Click:Connect(function()
                local mp = UserInputService:GetMouseLocation()
                SpawnRipple(Tgl, mp.X, mp.Y, Palette.HotRose)
                state = not state
                RenderToggle(state, true)
                Callback(state)
            end)

            local Ctrl = {}
            function Ctrl:Set(v)
                state = v
                RenderToggle(state, true)
                Callback(state)
            end
            return Ctrl
        end

        -- 3. SLIDER (Thanh trượt hồng gradient có nút kéo phát sáng)
        function Elements:Slider(Text, Min, Max, Default, Callback)
            Callback = Callback or function() end
            local val = math.clamp(Default or Min, Min, Max)

            local Frame = Instance.new("Frame")
            Frame.Name = "Slider"
            Frame.Parent = Page
            Frame.BackgroundColor3 = Palette.GlassCard
            Frame.BackgroundTransparency = 0.26
            Frame.Size = UDim2.new(1, 0, 0, 48)
            Frame.ZIndex = 12
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 9)
            local stroke = AddAuroraStroke(Frame, 1.1, 0.58, 55)

            local Label = Instance.new("TextLabel")
            Label.Parent = Frame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.Size = UDim2.new(0.68, 0, 0, 18)
            Label.Font = Enum.Font.GothamMedium
            Label.Text = Text
            Label.TextColor3 = Palette.TextWhite
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 13

            local Badge = Instance.new("Frame")
            Badge.Parent = Frame
            Badge.BackgroundColor3 = MainPink
            Badge.BackgroundTransparency = 0.28
            Badge.Position = UDim2.new(1, -52, 0, 5)
            Badge.Size = UDim2.new(0, 42, 0, 18)
            Badge.ZIndex = 13
            Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 6)

            local NumLbl = Instance.new("TextLabel")
            NumLbl.Parent = Badge
            NumLbl.BackgroundTransparency = 1
            NumLbl.Size = UDim2.new(1, 0, 1, 0)
            NumLbl.Font = Enum.Font.GothamBold
            NumLbl.Text = tostring(val)
            NumLbl.TextColor3 = Palette.CottonCandy
            NumLbl.TextSize = 11
            NumLbl.ZIndex = 14

            local Rail = Instance.new("TextButton")
            Rail.Parent = Frame
            Rail.BackgroundColor3 = Palette.TrackOff
            Rail.BackgroundTransparency = 0.2
            Rail.Position = UDim2.new(0, 10, 0, 31)
            Rail.Size = UDim2.new(1, -20, 0, 7)
            Rail.Text = ""
            Rail.AutoButtonColor = false
            Rail.ZIndex = 13
            Instance.new("UICorner", Rail).CornerRadius = UDim.new(1, 0)

            local ratio = (val - Min) / math.max((Max - Min), 1)
            local Fill = Instance.new("Frame")
            Fill.Parent = Rail
            Fill.BackgroundColor3 = MainPink
            Fill.Size = UDim2.new(ratio, 0, 1, 0)
            Fill.ZIndex = 14
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local FillGrad = Instance.new("UIGradient")
            FillGrad.Parent = Fill
            FillGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Palette.DeepPlum),
                ColorSequenceKeypoint.new(0.5, Palette.HotRose),
                ColorSequenceKeypoint.new(1, Palette.CottonCandy),
            })

            local Knob = Instance.new("Frame")
            Knob.Parent = Fill
            Knob.AnchorPoint = Vector2.new(0.5, 0.5)
            Knob.Position = UDim2.new(1, 0, 0.5, 0)
            Knob.Size = UDim2.new(0, 13, 0, 13)
            Knob.BackgroundColor3 = Palette.TextWhite
            Knob.ZIndex = 15
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

            local sliding = false
            local function SetFromInput(input)
                local pct = math.clamp((input.Position.X - Rail.AbsolutePosition.X) / math.max(Rail.AbsoluteSize.X, 1), 0, 1)
                val = math.floor(Min + (Max - Min) * pct + 0.5)
                NumLbl.Text = tostring(val)
                Tween(Fill, 0.05, {Size = UDim2.new(pct, 0, 1, 0)}, Enum.EasingStyle.Quad)
                Callback(val)
            end

            Rail.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    Tween(Knob, 0.14, {Size = UDim2.new(0, 17, 0, 17)})
                    Tween(stroke, 0.14, {Transparency = 0.15})
                    SetFromInput(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if sliding then
                        sliding = false
                        Tween(Knob, 0.14, {Size = UDim2.new(0, 13, 0, 13)})
                        Tween(stroke, 0.14, {Transparency = 0.58})
                    end
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    SetFromInput(input)
                end
            end)
        end

        -- 4. TEXT (Ô nhập chữ kính mờ phát sáng khi focus)
        function Elements:Text(Text, Placeholder, Callback)
            Callback = Callback or function() end

            local Box = Instance.new("Frame")
            Box.Name = "TextInput"
            Box.Parent = Page
            Box.BackgroundColor3 = Palette.GlassCard
            Box.BackgroundTransparency = 0.26
            Box.Size = UDim2.new(1, 0, 0, 36)
            Box.ZIndex = 12
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 9)
            AddAuroraStroke(Box, 1.1, 0.58, 70)

            local Lbl = Instance.new("TextLabel")
            Lbl.Parent = Box
            Lbl.BackgroundTransparency = 1
            Lbl.Position = UDim2.new(0, 10, 0, 0)
            Lbl.Size = UDim2.new(0.45, 0, 1, 0)
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.Text = Text
            Lbl.TextColor3 = Palette.TextWhite
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.ZIndex = 13

            local FieldBg = Instance.new("Frame")
            FieldBg.Parent = Box
            FieldBg.BackgroundColor3 = Palette.GlassInput
            FieldBg.BackgroundTransparency = 0.22
            FieldBg.Position = UDim2.new(0.47, 0, 0.5, -12)
            FieldBg.Size = UDim2.new(0.51, -8, 0, 24)
            FieldBg.ZIndex = 13
            Instance.new("UICorner", FieldBg).CornerRadius = UDim.new(0, 6)
            local fStroke = AddAuroraStroke(FieldBg, 1, 0.68, 10)

            local Input = Instance.new("TextBox")
            Input.Parent = FieldBg
            Input.BackgroundTransparency = 1
            Input.Position = UDim2.new(0, 6, 0, 0)
            Input.Size = UDim2.new(1, -12, 1, 0)
            Input.Font = Enum.Font.Gotham
            Input.PlaceholderText = Placeholder or "Nhập..."
            Input.PlaceholderColor3 = Palette.TextMuted
            Input.Text = ""
            Input.TextColor3 = Palette.CottonCandy
            Input.TextSize = 11
            Input.ClearTextOnFocus = false
            Input.ZIndex = 14

            Input.Focused:Connect(function()
                Tween(fStroke, 0.2, {Transparency = 0.08})
            end)

            Input.FocusLost:Connect(function()
                Tween(fStroke, 0.2, {Transparency = 0.68})
                Callback(Input.Text)
            end)
        end

        -- 5. DROP (Dropdown chọn 1 mục kèm ô lọc nhanh khi nhiều lựa chọn)
        function Elements:Drop(Text, Options, Callback)
            Callback = Callback or function() end
            Options = Options or {}
            local opened = false
            local chosen = "Chọn..."

            local DropCard = Instance.new("Frame")
            DropCard.Name = "Dropdown"
            DropCard.Parent = Page
            DropCard.BackgroundColor3 = Palette.GlassCard
            DropCard.BackgroundTransparency = 0.26
            DropCard.Size = UDim2.new(1, 0, 0, 35)
            DropCard.ClipsDescendants = true
            DropCard.ZIndex = 12
            Instance.new("UICorner", DropCard).CornerRadius = UDim.new(0, 9)
            local stroke = AddAuroraStroke(DropCard, 1.1, 0.58, 90)

            local HeadBtn = Instance.new("TextButton")
            HeadBtn.Parent = DropCard
            HeadBtn.BackgroundTransparency = 1
            HeadBtn.Size = UDim2.new(1, 0, 0, 35)
            HeadBtn.Font = Enum.Font.GothamMedium
            HeadBtn.Text = "   " .. Text .. ": " .. chosen
            HeadBtn.TextColor3 = Palette.TextWhite
            HeadBtn.TextSize = 12
            HeadBtn.TextXAlignment = Enum.TextXAlignment.Left
            HeadBtn.ZIndex = 13

            local Chevron = Instance.new("TextLabel")
            Chevron.Parent = HeadBtn
            Chevron.BackgroundTransparency = 1
            Chevron.Position = UDim2.new(1, -28, 0, 0)
            Chevron.Size = UDim2.new(0, 22, 1, 0)
            Chevron.Font = Enum.Font.GothamBold
            Chevron.Text = "▾"
            Chevron.TextColor3 = Palette.CottonCandy
            Chevron.TextSize = 14
            Chevron.ZIndex = 14

            local ItemList = Instance.new("Frame")
            ItemList.Parent = DropCard
            ItemList.BackgroundTransparency = 1
            ItemList.Position = UDim2.new(0, 6, 0, 37)
            ItemList.Size = UDim2.new(1, -12, 0, #Options * 27)
            ItemList.ZIndex = 13

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = ItemList
            ListLayout.Padding = UDim.new(0, 4)

            for _, item in ipairs(Options) do
                local Opt = Instance.new("TextButton")
                Opt.Parent = ItemList
                Opt.BackgroundColor3 = Palette.GlassInput
                Opt.BackgroundTransparency = 0.25
                Opt.Size = UDim2.new(1, 0, 0, 23)
                Opt.Font = Enum.Font.Gotham
                Opt.Text = item
                Opt.TextColor3 = Palette.TextSoft
                Opt.TextSize = 11
                Opt.AutoButtonColor = false
                Opt.ZIndex = 14
                Instance.new("UICorner", Opt).CornerRadius = UDim.new(0, 6)

                Opt.MouseEnter:Connect(function()
                    Tween(Opt, 0.14, {BackgroundColor3 = MainPink, BackgroundTransparency = 0.18, TextColor3 = Palette.TextWhite})
                end)

                Opt.MouseLeave:Connect(function()
                    if chosen ~= item then
                        Tween(Opt, 0.14, {BackgroundColor3 = Palette.GlassInput, BackgroundTransparency = 0.25, TextColor3 = Palette.TextSoft})
                    end
                end)

                Opt.MouseButton1Click:Connect(function()
                    chosen = item
                    HeadBtn.Text = "   " .. Text .. ": " .. chosen
                    opened = false
                    Tween(Chevron, 0.24, {Rotation = 0})
                    Tween(stroke, 0.24, {Transparency = 0.58})
                    Tween(DropCard, 0.24, {Size = UDim2.new(1, 0, 0, 35)})
                    Callback(chosen)
                end)
            end

            HeadBtn.MouseButton1Click:Connect(function()
                opened = not opened
                local h = opened and (41 + (#Options * 27)) or 35
                Tween(Chevron, 0.24, {Rotation = opened and 180 or 0})
                Tween(stroke, 0.24, {Transparency = opened and 0.18 or 0.58})
                Tween(DropCard, 0.24, {Size = UDim2.new(1, 0, 0, h)})
            end)
        end

        -- 6. MULTI DROP (Chọn nhiều mục đồng thời với hiệu ứng sáng hồng từng lựa chọn)
        function Elements:MultiDrop(Text, Options, Callback)
            Callback = Callback or function() end
            Options = Options or {}
            local opened = false
            local selectedItems = {}

            local MultiCard = Instance.new("Frame")
            MultiCard.Name = "MultiDropdown"
            MultiCard.Parent = Page
            MultiCard.BackgroundColor3 = Palette.GlassCard
            MultiCard.BackgroundTransparency = 0.26
            MultiCard.Size = UDim2.new(1, 0, 0, 35)
            MultiCard.ClipsDescendants = true
            MultiCard.ZIndex = 12
            Instance.new("UICorner", MultiCard).CornerRadius = UDim.new(0, 9)
            local stroke = AddAuroraStroke(MultiCard, 1.1, 0.58, 110)

            local HeadBtn = Instance.new("TextButton")
            HeadBtn.Parent = MultiCard
            HeadBtn.BackgroundTransparency = 1
            HeadBtn.Size = UDim2.new(1, 0, 0, 35)
            HeadBtn.Font = Enum.Font.GothamMedium
            HeadBtn.Text = "   " .. Text .. "  [0]"
            HeadBtn.TextColor3 = Palette.TextWhite
            HeadBtn.TextSize = 12
            HeadBtn.TextXAlignment = Enum.TextXAlignment.Left
            HeadBtn.ZIndex = 13

            local Chevron = Instance.new("TextLabel")
            Chevron.Parent = HeadBtn
            Chevron.BackgroundTransparency = 1
            Chevron.Position = UDim2.new(1, -28, 0, 0)
            Chevron.Size = UDim2.new(0, 22, 1, 0)
            Chevron.Font = Enum.Font.GothamBold
            Chevron.Text = "▾"
            Chevron.TextColor3 = Palette.CottonCandy
            Chevron.TextSize = 14
            Chevron.ZIndex = 14

            local ItemList = Instance.new("Frame")
            ItemList.Parent = MultiCard
            ItemList.BackgroundTransparency = 1
            ItemList.Position = UDim2.new(0, 6, 0, 37)
            ItemList.Size = UDim2.new(1, -12, 0, #Options * 27)
            ItemList.ZIndex = 13

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = ItemList
            ListLayout.Padding = UDim.new(0, 4)

            for _, item in ipairs(Options) do
                local Opt = Instance.new("TextButton")
                Opt.Parent = ItemList
                Opt.BackgroundColor3 = Palette.GlassInput
                Opt.BackgroundTransparency = 0.25
                Opt.Size = UDim2.new(1, 0, 0, 23)
                Opt.Font = Enum.Font.Gotham
                Opt.Text = item
                Opt.TextColor3 = Palette.TextSoft
                Opt.TextSize = 11
                Opt.AutoButtonColor = false
                Opt.ZIndex = 14
                Instance.new("UICorner", Opt).CornerRadius = UDim.new(0, 6)

                Opt.MouseButton1Click:Connect(function()
                    local idx = table.find(selectedItems, item)
                    if idx then
                        table.remove(selectedItems, idx)
                        Tween(Opt, 0.16, {
                            BackgroundColor3 = Palette.GlassInput,
                            BackgroundTransparency = 0.25,
                            TextColor3 = Palette.TextSoft
                        })
                    else
                        table.insert(selectedItems, item)
                        Tween(Opt, 0.16, {
                            BackgroundColor3 = MainPink,
                            BackgroundTransparency = 0.14,
                            TextColor3 = Palette.TextWhite
                        })
                    end
                    HeadBtn.Text = "   " .. Text .. "  [" .. #selectedItems .. "]"
                    Callback(selectedItems)
                end)
            end

            HeadBtn.MouseButton1Click:Connect(function()
                opened = not opened
                local h = opened and (41 + (#Options * 27)) or 35
                Tween(Chevron, 0.24, {Rotation = opened and 180 or 0})
                Tween(stroke, 0.24, {Transparency = opened and 0.18 or 0.58})
                Tween(MultiCard, 0.24, {Size = UDim2.new(1, 0, 0, h)})
            end)
        end

        -- 7. KEYBIND (Gán phím tắt kích hoạt Callback)
        function Elements:Keybind(Text, DefaultKey, Callback)
            Callback = Callback or function() end
            local boundKey = DefaultKey or Enum.KeyCode.F
            local listening = false

            local KFrame = Instance.new("Frame")
            KFrame.Name = "Keybind"
            KFrame.Parent = Page
            KFrame.BackgroundColor3 = Palette.GlassCard
            KFrame.BackgroundTransparency = 0.26
            KFrame.Size = UDim2.new(1, 0, 0, 35)
            KFrame.ZIndex = 12
            Instance.new("UICorner", KFrame).CornerRadius = UDim.new(0, 9)
            AddAuroraStroke(KFrame, 1.1, 0.58, 125)

            local Lbl = Instance.new("TextLabel")
            Lbl.Parent = KFrame
            Lbl.BackgroundTransparency = 1
            Lbl.Position = UDim2.new(0, 10, 0, 0)
            Lbl.Size = UDim2.new(0.6, 0, 1, 0)
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.Text = Text
            Lbl.TextColor3 = Palette.TextWhite
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.ZIndex = 13

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Parent = KFrame
            KeyBtn.BackgroundColor3 = Palette.GlassInput
            KeyBtn.BackgroundTransparency = 0.2
            KeyBtn.Position = UDim2.new(1, -78, 0.5, -11)
            KeyBtn.Size = UDim2.new(0, 68, 0, 22)
            KeyBtn.Font = Enum.Font.GothamBold
            KeyBtn.Text = boundKey.Name
            KeyBtn.TextColor3 = Palette.CottonCandy
            KeyBtn.TextSize = 10
            KeyBtn.AutoButtonColor = false
            KeyBtn.ZIndex = 14
            Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)
            local kStroke = AddAuroraStroke(KeyBtn, 1, 0.45, 30)

            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
                Tween(kStroke, 0.15, {Transparency = 0.05})
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    boundKey = input.KeyCode
                    KeyBtn.Text = boundKey.Name
                    Tween(kStroke, 0.15, {Transparency = 0.45})
                elseif not gp and not listening and input.KeyCode == boundKey then
                    Tween(KeyBtn, 0.08, {BackgroundColor3 = MainPink, BackgroundTransparency = 0.15})
                    task.delay(0.1, function()
                        Tween(KeyBtn, 0.18, {BackgroundColor3 = Palette.GlassInput, BackgroundTransparency = 0.2})
                    end)
                    Callback(boundKey)
                end
            end)
        end

        -- 8. COLOR PICKER (Bộ chọn tông màu hồng / neon nhanh với ô xem trước trực tiếp)
        function Elements:ColorPicker(Text, DefaultColor, Callback)
            Callback = Callback or function() end
            local currentColor = DefaultColor or MainPink
            local presets = {
                Color3.fromRGB(255, 75, 165),  -- Neon Pink
                Color3.fromRGB(255, 135, 205), -- Sakura Glow
                Color3.fromRGB(255, 45, 120),  -- Cyber Rose
                Color3.fromRGB(235, 95, 255),  -- Orchid Pink
                Color3.fromRGB(255, 175, 220), -- Cotton Pink
                Color3.fromRGB(185, 45, 130),  -- Berry Velvet
            }
            local opened = false

            local CPCard = Instance.new("Frame")
            CPCard.Name = "ColorPicker"
            CPCard.Parent = Page
            CPCard.BackgroundColor3 = Palette.GlassCard
            CPCard.BackgroundTransparency = 0.26
            CPCard.Size = UDim2.new(1, 0, 0, 35)
            CPCard.ClipsDescendants = true
            CPCard.ZIndex = 12
            Instance.new("UICorner", CPCard).CornerRadius = UDim.new(0, 9)
            AddAuroraStroke(CPCard, 1.1, 0.58, 145)

            local TopBtn = Instance.new("TextButton")
            TopBtn.Parent = CPCard
            TopBtn.BackgroundTransparency = 1
            TopBtn.Size = UDim2.new(1, 0, 0, 35)
            TopBtn.Font = Enum.Font.GothamMedium
            TopBtn.Text = "   " .. Text
            TopBtn.TextColor3 = Palette.TextWhite
            TopBtn.TextSize = 12
            TopBtn.TextXAlignment = Enum.TextXAlignment.Left
            TopBtn.ZIndex = 13

            local Swatch = Instance.new("Frame")
            Swatch.Parent = TopBtn
            Swatch.Position = UDim2.new(1, -34, 0.5, -9)
            Swatch.Size = UDim2.new(0, 24, 0, 18)
            Swatch.BackgroundColor3 = currentColor
            Swatch.ZIndex = 14
            Instance.new("UICorner", Swatch).CornerRadius = UDim.new(0, 6)
            AddAuroraStroke(Swatch, 1.1, 0.2, 0)

            local SwatchRow = Instance.new("Frame")
            SwatchRow.Parent = CPCard
            SwatchRow.BackgroundTransparency = 1
            SwatchRow.Position = UDim2.new(0, 10, 0, 38)
            SwatchRow.Size = UDim2.new(1, -20, 0, 24)
            SwatchRow.ZIndex = 13

            local RowLayout = Instance.new("UIListLayout")
            RowLayout.Parent = SwatchRow
            RowLayout.FillDirection = Enum.FillDirection.Horizontal
            RowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            RowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            RowLayout.Padding = UDim.new(0, 8)

            for _, col in ipairs(presets) do
                local Chip = Instance.new("TextButton")
                Chip.Parent = SwatchRow
                Chip.BackgroundColor3 = col
                Chip.Size = UDim2.new(0, 24, 0, 20)
                Chip.Text = ""
                Chip.AutoButtonColor = false
                Chip.ZIndex = 14
                Instance.new("UICorner", Chip).CornerRadius = UDim.new(0, 6)

                Chip.MouseButton1Click:Connect(function()
                    currentColor = col
                    MainPink = col
                    Tween(Swatch, 0.2, {BackgroundColor3 = col})
                    Tween(Chip, 0.12, {Size = UDim2.new(0, 28, 0, 22)})
                    task.delay(0.12, function()
                        Tween(Chip, 0.18, {Size = UDim2.new(0, 24, 0, 20)})
                    end)
                    Callback(col)
                end)
            end

            TopBtn.MouseButton1Click:Connect(function()
                opened = not opened
                Tween(CPCard, 0.24, {Size = UDim2.new(1, 0, 0, opened and 68 or 35)})
            end)
        end

        return Elements
    end

    return WindowAPI
end

return Library
