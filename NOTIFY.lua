--// SYNTH X SIMPLE FANCY NOTIFY SOURCE

local TweenService = game:GetService("TweenService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")

local gethui = gethui or function()
    return CoreGui
end

local Theme = {
    Background = Color3.fromRGB(16, 18, 18),
    Element = Color3.fromRGB(25, 29, 29),
    Accent = Color3.fromRGB(0, 191, 255),
    AccentSoft = Color3.fromRGB(90, 220, 255),
    Stroke = Color3.fromRGB(58, 66, 66),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(185, 190, 190),
    Shadow = Color3.fromRGB(0, 0, 0)
}

local FALLBACK_ICON = "rbxassetid://136879043989014"
local LUCIDE_BASE_URL = "https://raw.githubusercontent.com/latte-soft/lucide-roblox/master/icons/compiled/48px/"
local IconCache = {}

local function Trim(text)
    text = tostring(text or "")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    return text
end

local function NormalizeIconName(icon)
    local value = Trim(icon)
    value = value:gsub("https://lucide.dev/icons/", "")
    value = value:gsub("http://lucide.dev/icons/", "")
    value = value:gsub("%?.*$", "")
    value = value:gsub("/$", "")
    value = value:match("([^/]+)$") or value
    value = value:gsub("([a-z])([A-Z])", "%1-%2")
    value = value:gsub("_", "-")
    value = value:gsub("%s+", "-")
    value = value:lower()
    return value
end

local function SafeMakeFolder(path)
    if not isfolder or not makefolder then return end

    if not isfolder(path) then
        pcall(function()
            makefolder(path)
        end)
    end
end

local function ResolveIcon(icon)
    local raw = Trim(icon)

    if raw == "" then
        return FALLBACK_ICON
    end

    if raw:find("^rbxassetid://") then
        return raw
    end

    if tonumber(raw) then
        return "rbxassetid://" .. raw
    end

    local iconName = NormalizeIconName(raw)

    if IconCache[iconName] then
        return IconCache[iconName]
    end

    if not (isfolder and makefolder and isfile and writefile and getcustomasset) then
        return FALLBACK_ICON
    end

    SafeMakeFolder("SynthXNotify")
    SafeMakeFolder("SynthXNotify/Assets")
    SafeMakeFolder("SynthXNotify/Assets/Icons")

    local filePath = "SynthXNotify/Assets/Icons/" .. iconName .. ".png"

    if not isfile(filePath) then
        local success, result = pcall(function()
            return game:HttpGet(LUCIDE_BASE_URL .. iconName .. ".png")
        end)

        if not success or type(result) ~= "string" or #result < 50 then
            return FALLBACK_ICON
        end

        pcall(function()
            writefile(filePath, result)
        end)
    end

    local ok, asset = pcall(function()
        return getcustomasset(filePath)
    end)

    if ok and asset then
        IconCache[iconName] = asset
        return asset
    end

    return FALLBACK_ICON
end

local Gui = gethui():FindFirstChild("SynthXNotifyGui")

if not Gui then
    Gui = Instance.new("ScreenGui")
    Gui.Name = "SynthXNotifyGui"
    Gui.Parent = gethui()
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
end

local NotifyHolder = Gui:FindFirstChild("NotifyHolder")

if not NotifyHolder then
    NotifyHolder = Instance.new("Frame", Gui)
    NotifyHolder.Name = "NotifyHolder"
    NotifyHolder.AnchorPoint = Vector2.new(1, 1)
    NotifyHolder.Position = UDim2.new(1, -24, 1, -24)
    NotifyHolder.Size = UDim2.new(0, 360, 0, 380)
    NotifyHolder.BackgroundTransparency = 1
    NotifyHolder.BorderSizePixel = 0

    local NotifyList = Instance.new("UIListLayout", NotifyHolder)
    NotifyList.Padding = UDim.new(0, 10)
    NotifyList.SortOrder = Enum.SortOrder.LayoutOrder
    NotifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

local NotifyCount = 0

local function Notify(title, message, icon, duration)
    NotifyCount += 1

    title = tostring(title or "Notification")
    message = tostring(message or "")
    icon = icon or "bell"
    duration = tonumber(duration) or 4

    local Wrapper = Instance.new("Frame", NotifyHolder)
    Wrapper.Name = "NotifyWrapper"
    Wrapper.Size = UDim2.new(1, 0, 0, 84)
    Wrapper.BackgroundTransparency = 1
    Wrapper.BorderSizePixel = 0
    Wrapper.LayoutOrder = NotifyCount
    Wrapper.ClipsDescendants = false

    local Shadow = Instance.new("Frame", Wrapper)
    Shadow.Position = UDim2.new(0, 6, 0, 6)
    Shadow.Size = UDim2.new(1, -2, 1, -2)
    Shadow.BackgroundColor3 = Theme.Shadow
    Shadow.BackgroundTransparency = 0.55
    Shadow.BorderSizePixel = 0

    Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 12)

    local Box = Instance.new("Frame", Wrapper)
    Box.Position = UDim2.new(1, 28, 0, 0)
    Box.Size = UDim2.new(1, 0, 1, 0)
    Box.BackgroundColor3 = Theme.Element
    Box.BorderSizePixel = 0
    Box.ClipsDescendants = true

    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 12)

    local Stroke = Instance.new("UIStroke", Box)
    Stroke.Color = Theme.Stroke
    Stroke.Thickness = 1.2
    Stroke.Transparency = 0.08
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local IconCircle = Instance.new("Frame", Box)
    IconCircle.Position = UDim2.new(0, 16, 0, 17)
    IconCircle.Size = UDim2.new(0, 38, 0, 38)
    IconCircle.BackgroundColor3 = Theme.Accent
    IconCircle.BackgroundTransparency = 0.9
    IconCircle.BorderSizePixel = 0

    Instance.new("UICorner", IconCircle).CornerRadius = UDim.new(1, 0)

    local IconStroke = Instance.new("UIStroke", IconCircle)
    IconStroke.Color = Theme.Accent
    IconStroke.Thickness = 1
    IconStroke.Transparency = 0.35

    local Icon = Instance.new("ImageLabel", IconCircle)
    Icon.AnchorPoint = Vector2.new(0.5, 0.5)
    Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    Icon.Size = UDim2.new(0, 18, 0, 18)
    Icon.BackgroundTransparency = 1
    Icon.Image = ResolveIcon(icon)
    Icon.ImageColor3 = Theme.Accent

    local Title = Instance.new("TextLabel", Box)
    Title.Position = UDim2.new(0, 66, 0, 14)
    Title.Size = UDim2.new(1, -84, 0, 22)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Theme.Text
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextTruncate = Enum.TextTruncate.AtEnd

    local Message = Instance.new("TextLabel", Box)
    Message.Position = UDim2.new(0, 66, 0, 39)
    Message.Size = UDim2.new(1, -84, 0, 26)
    Message.BackgroundTransparency = 1
    Message.Text = message
    Message.TextColor3 = Theme.TextDim
    Message.TextSize = 12.5
    Message.Font = Enum.Font.GothamMedium
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.TextWrapped = true

    local ProgressBack = Instance.new("Frame", Box)
    ProgressBack.AnchorPoint = Vector2.new(0, 1)
    ProgressBack.Position = UDim2.new(0, 16, 1, -10)
    ProgressBack.Size = UDim2.new(1, -32, 0, 2)
    ProgressBack.BackgroundColor3 = Theme.Stroke
    ProgressBack.BackgroundTransparency = 0.35
    ProgressBack.BorderSizePixel = 0

    Instance.new("UICorner", ProgressBack).CornerRadius = UDim.new(1, 0)

    local Progress = Instance.new("Frame", ProgressBack)
    Progress.Size = UDim2.new(1, 0, 1, 0)
    Progress.BackgroundColor3 = Theme.Accent
    Progress.BorderSizePixel = 0

    Instance.new("UICorner", Progress).CornerRadius = UDim.new(1, 0)

    local ProgressGradient = Instance.new("UIGradient", Progress)
    ProgressGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentSoft)
    })

    local Scale = Instance.new("UIScale", Box)
    Scale.Scale = 0.97

    TweenService:Create(Box, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    TweenService:Create(Scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1
    }):Play()

    TweenService:Create(Progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    task.delay(duration, function()
        if not Box or not Box.Parent then return end

        TweenService:Create(Box, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 28, 0, 0)
        }):Play()

        TweenService:Create(Shadow, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()

        task.wait(0.3)

        if Wrapper then
            Wrapper:Destroy()
        end
    end)
end

getgenv().Notify = Notify
getgenv().SynthXNotify = Notify
