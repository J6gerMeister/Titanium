-- ============================================================
--  OnyxiteLib.lua
--  Black & White Linoria-layout GUI Library
--  Load via: loadstring(game:HttpGet('YOUR_RAW_URL'))()
--  Returns the Library table — call Library.new({...}) to build a window
-- ============================================================

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local TextService  = game:GetService("TextService")
local CoreGui      = game:GetService("CoreGui")
local Teams        = game:GetService("Teams")

-- ============================================================
--  PALETTE
-- ============================================================
local C = {
    windowBg     = Color3.fromRGB(12,  12,  12),
    windowBorder = Color3.fromRGB(50,  50,  50),
    titleBg      = Color3.fromRGB(8,   8,   8),
    sidebarBg    = Color3.fromRGB(7,   7,   7),
    sidebarLine  = Color3.fromRGB(22,  22,  22),
    tabActive    = Color3.fromRGB(22,  22,  22),
    tabInactive  = Color3.fromRGB(10,  10,  10),
    tabHover     = Color3.fromRGB(18,  18,  18),
    contentBg    = Color3.fromRGB(16,  16,  16),
    groupBg      = Color3.fromRGB(10,  10,  10),
    groupHeader  = Color3.fromRGB(8,   8,   8),
    elementBg    = Color3.fromRGB(14,  14,  14),
    elementBg2   = Color3.fromRGB(20,  20,  20),
    hover        = Color3.fromRGB(30,  30,  30),
    pressed      = Color3.fromRGB(38,  38,  38),
    borderHard   = Color3.fromRGB(48,  48,  48),
    borderMed    = Color3.fromRGB(35,  35,  35),
    borderSoft   = Color3.fromRGB(22,  22,  22),
    accentHi     = Color3.fromRGB(230, 230, 230),
    accentMid    = Color3.fromRGB(180, 180, 180),
    accentDim    = Color3.fromRGB(100, 100, 100),
    textBright   = Color3.fromRGB(240, 240, 240),
    textMid      = Color3.fromRGB(175, 175, 175),
    textSub      = Color3.fromRGB(105, 105, 105),
    textDim      = Color3.fromRGB(55,  55,  55),
    sliderFill   = Color3.fromRGB(200, 200, 200),
    knob         = Color3.fromRGB(220, 220, 220),
    checkOn      = Color3.fromRGB(210, 210, 210),
    checkOff     = Color3.fromRGB(12,  12,  12),
    dropBg       = Color3.fromRGB(10,  10,  10),
    dropItemHov  = Color3.fromRGB(22,  22,  22),
    dropItemSel  = Color3.fromRGB(28,  28,  28),
    riskColor    = Color3.fromRGB(255, 50,  50),
    black        = Color3.new(0,  0,  0),
    white        = Color3.new(1,  1,  1),
    profileBg    = Color3.fromRGB(8,   8,   8),
}

-- ============================================================
--  TWEEN HELPERS
-- ============================================================
local FONT      = Enum.Font.Code
local SNAP      = TweenInfo.new(0.07, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local FAST      = TweenInfo.new(0.14, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local MED       = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function tw(inst, goals, info)
    TweenService:Create(inst, info or FAST, goals):Play()
end

local function makeBorder(parent, col, thick)
    local s = Instance.new("UIStroke")
    s.Color     = col   or C.borderHard
    s.Thickness = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function makeCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 3)
    c.Parent = parent
    return c
end

local function makeGradient(parent, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color    = ColorSequence.new(c0, c1)
    g.Rotation = rot or 90
    g.Parent   = parent
    return g
end

local function makeStroke(inst)
    local s = Instance.new("UIStroke")
    s.Color = C.black
    s.Thickness = 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    inst.TextStrokeTransparency = 1
    s.Parent = inst
    return s
end

local function textBounds(text, size)
    return TextService:GetTextSize(text, size or 14, FONT, Vector2.new(9999, 9999))
end

local function getDarker(color)
    local h, s, v = Color3.toHSV(color)
    return Color3.fromHSV(h, s, v / 1.5)
end

local function mapVal(v, minA, maxA, minB, maxB)
    local t = math.clamp((v - minA) / (maxA - minA), 0, 1)
    return minB + t * (maxB - minB)
end

local function roundTo(v, places)
    if places == 0 then return math.floor(v + 0.5) end
    local m = 10 ^ places
    return math.floor(v * m + 0.5) / m
end

-- ============================================================
--  MAKE FRAME / LABEL HELPERS
-- ============================================================
local function newFrame(props)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = props.bg       or C.elementBg
    f.BorderSizePixel  = 0
    f.Size             = props.size     or UDim2.new(1, 0, 0, 20)
    f.Position         = props.pos      or UDim2.new(0, 0, 0, 0)
    f.ZIndex           = props.z        or 3
    f.ClipsDescendants = props.clip     or false
    if props.parent then f.Parent = props.parent end
    if props.border then makeBorder(f, props.border, props.borderThick) end
    if props.corner then makeCorner(f, props.corner) end
    if props.trans then f.BackgroundTransparency = props.trans end
    return f
end

local function newLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font          = FONT
    l.TextSize      = props.size  or 14
    l.TextColor3    = props.col   or C.textBright
    l.Text          = props.text  or ""
    l.TextXAlignment= props.alignX or Enum.TextXAlignment.Left
    l.TextYAlignment= props.alignY or Enum.TextYAlignment.Center
    l.TextWrapped   = props.wrap  or false
    l.Size          = props.sz    or UDim2.new(1, 0, 1, 0)
    l.Position      = props.pos   or UDim2.new(0, 0, 0, 0)
    l.ZIndex        = props.z     or 4
    if props.parent then l.Parent = props.parent end
    makeStroke(l)
    return l
end

-- outer black shell + inner styled frame (Onyxite element style)
local function shellFrame(parent, w, h, z)
    local outer = newFrame({
        bg = C.black, size = UDim2.new(w or 1, -4, 0, h or 20),
        z = z or 5, parent = parent
    })
    local inner = newFrame({
        bg = C.elementBg2, size = UDim2.new(1, 0, 1, 0),
        border = C.borderHard, z = (z or 5)+1, parent = outer
    })
    makeGradient(inner, C.white, Color3.fromRGB(212,212,212), 90)
    return outer, inner
end

-- ============================================================
--  ELEMENT OBJECT (OnChanged / SetValue plumbing)
-- ============================================================
local function newObj(default, cb)
    local obj    = { Value = default, Callback = cb }
    local _ch    = nil
    function obj:OnChanged(fn) _ch = fn; if fn then fn(self.Value) end end
    function obj:GetValue() return self.Value end
    function obj:_fire(v)
        self.Value = v
        if self.Callback then pcall(self.Callback, v) end
        if _ch           then pcall(_ch,           v) end
    end
    function obj:SetValue(v) self:_fire(v) end
    return obj
end

-- ============================================================
--  COLOR PICKER
-- ============================================================
local function buildColorPicker(parent, defColor, defTrans, callback)
    defColor = defColor or Color3.fromRGB(200, 200, 200)
    defTrans = defTrans or 0

    local p = {}
    p.Hue, p.Sat, p.Vib = defColor:ToHSV()
    p.Transparency = defTrans
    p.Value        = defColor
    p.Callback     = callback or function() end

    -- Outer popup frame
    local W, H = 230, 271
    local popup = newFrame({
        bg = C.black, size = UDim2.fromOffset(W, H),
        z = 25, parent = parent, border = C.borderHard
    })
    popup.Visible = false
    popup.Name    = "ColorPickerPopup"

    local inner = newFrame({
        bg = C.groupBg, size = UDim2.new(1,0,1,0), z = 26, parent = popup,
        border = C.borderMed
    })

    -- Highlight bar
    local hiBar = newFrame({ bg = C.accentMid, size = UDim2.new(1,0,0,2), z=27, parent=inner })

    -- Title
    newLabel({ text="Color Picker", sz=UDim2.new(1,-8,0,16),
        pos=UDim2.new(0,5,0,4), col=C.textMid, size=13, z=27, parent=inner })

    -- Sat/Vib map
    local svOuter = newFrame({
        bg=C.black, size=UDim2.new(0,200,0,200),
        pos=UDim2.new(0,4,0,24), z=27, parent=inner, border=C.borderHard
    })
    local svInner = newFrame({ bg=C.groupBg, size=UDim2.new(1,0,1,0), z=28, parent=svOuter })
    local svMap   = Instance.new("ImageLabel")
    svMap.Size = UDim2.new(1,0,1,0); svMap.BackgroundTransparency = 1
    svMap.Image = "rbxassetid://4155801252"; svMap.ZIndex = 29; svMap.Parent = svInner

    local cursor = Instance.new("ImageLabel")
    cursor.Size = UDim2.new(0,8,0,8); cursor.AnchorPoint = Vector2.new(0.5,0.5)
    cursor.BackgroundTransparency = 1
    cursor.Image = "http://www.roblox.com/asset/?id=9619665977"
    cursor.ImageColor3 = C.black; cursor.ZIndex = 31; cursor.Parent = svMap
    local cursorI = Instance.new("ImageLabel")
    cursorI.Size = UDim2.new(0,6,0,6); cursorI.Position = UDim2.new(0,1,0,1)
    cursorI.BackgroundTransparency = 1
    cursorI.Image = cursor.Image; cursorI.ImageColor3 = C.white
    cursorI.ZIndex = 32; cursorI.Parent = cursor

    -- Hue bar
    local hueOuter = newFrame({
        bg=C.black, size=UDim2.new(0,15,0,200),
        pos=UDim2.new(0,208,0,24), z=27, parent=inner, border=C.borderHard
    })
    local hueInner = newFrame({ bg=C.white, size=UDim2.new(1,0,1,0), z=28, parent=hueOuter })
    local hueSeq = {}
    for i=0,10 do table.insert(hueSeq, ColorSequenceKeypoint.new(i/10, Color3.fromHSV(i/10,1,1))) end
    local hueGrad = Instance.new("UIGradient")
    hueGrad.Color = ColorSequence.new(hueSeq); hueGrad.Rotation = 90; hueGrad.Parent = hueInner
    local hueCursor = newFrame({
        bg=C.white, size=UDim2.new(1,0,0,2), z=29, parent=hueInner, border=C.black
    })

    -- Transparency bar
    local trOuter = newFrame({
        bg=C.black, size=UDim2.new(1,-8,0,15),
        pos=UDim2.new(0,4,0,228), z=27, parent=inner, border=C.borderHard
    })
    local trInner = newFrame({ bg=defColor, size=UDim2.new(1,0,1,0), z=28, parent=trOuter })
    local checkerImg = Instance.new("ImageLabel")
    checkerImg.Size = UDim2.new(1,0,1,0); checkerImg.BackgroundTransparency=1
    checkerImg.Image = "http://www.roblox.com/asset/?id=12978095818"
    checkerImg.ZIndex = 29; checkerImg.Parent = trInner
    local trCursor = newFrame({ bg=C.white, size=UDim2.new(0,2,1,0), z=30, parent=trInner, border=C.black })
    trCursor.AnchorPoint = Vector2.new(0.5,0)

    -- Hex / RGB inputs
    local function makeInputBox(xScale, xOff, placeholder, defaultText)
        local o, i = shellFrame(inner, nil, 18, 27)
        o.Size = UDim2.new(0.5,-6,0,18)
        o.Position = UDim2.new(xScale, xOff, 0, 247)
        local box = Instance.new("TextBox")
        box.BackgroundTransparency = 1
        box.Font = FONT; box.TextSize = 12
        box.TextColor3 = C.textBright
        box.PlaceholderColor3 = C.textSub
        box.PlaceholderText = placeholder
        box.Text = defaultText
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.Size = UDim2.new(1,-4,1,0); box.Position = UDim2.new(0,4,0,0)
        box.ZIndex = 30; box.Parent = i
        makeStroke(box)
        return box
    end

    local hexBox = makeInputBox(0, 4,  "Hex",  "#"..defColor:ToHex())
    local rgbBox = makeInputBox(0.5, 2, "R,G,B",
        string.format("%d,%d,%d", math.floor(defColor.R*255), math.floor(defColor.G*255), math.floor(defColor.B*255)))

    -- Display / fire
    function p:Display()
        p.Value = Color3.fromHSV(p.Hue, p.Sat, p.Vib)
        svMap.BackgroundColor3 = Color3.fromHSV(p.Hue, 1, 1)
        cursor.Position        = UDim2.new(p.Sat, 0, 1 - p.Vib, 0)
        hueCursor.Position     = UDim2.new(0, 0, p.Hue, 0)
        trInner.BackgroundColor3 = p.Value
        trCursor.Position = UDim2.new(1 - p.Transparency, 0, 0, 0)
        hexBox.Text = "#"..p.Value:ToHex()
        rgbBox.Text = string.format("%d,%d,%d",
            math.floor(p.Value.R*255), math.floor(p.Value.G*255), math.floor(p.Value.B*255))
        pcall(p.Callback, p.Value, p.Transparency)
        if p.Changed then pcall(p.Changed, p.Value, p.Transparency) end
    end

    function p:SetValueRGB(col, trans)
        p.Hue, p.Sat, p.Vib = col:ToHSV()
        p.Transparency = trans or 0
        p:Display()
    end

    function p:OnChanged(fn) p.Changed = fn; fn(p.Value, p.Transparency) end

    local lp = Players.LocalPlayer
    local mouse = lp:GetMouse()

    local function dragLoop(getVal)
        while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
            getVal()
            RunService.RenderStepped:Wait()
        end
    end

    svMap.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragLoop(function()
            local minX = svMap.AbsolutePosition.X; local maxX = minX + svMap.AbsoluteSize.X
            local minY = svMap.AbsolutePosition.Y; local maxY = minY + svMap.AbsoluteSize.Y
            p.Sat = (math.clamp(mouse.X, minX, maxX) - minX) / (maxX - minX)
            p.Vib = 1 - (math.clamp(mouse.Y, minY, maxY) - minY) / (maxY - minY)
            p:Display()
        end)
    end)

    hueInner.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragLoop(function()
            local minY = hueInner.AbsolutePosition.Y; local maxY = minY + hueInner.AbsoluteSize.Y
            p.Hue = (math.clamp(mouse.Y, minY, maxY) - minY) / (maxY - minY)
            p:Display()
        end)
    end)

    trInner.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragLoop(function()
            local minX = trInner.AbsolutePosition.X; local maxX = minX + trInner.AbsoluteSize.X
            p.Transparency = 1 - (math.clamp(mouse.X, minX, maxX) - minX) / (maxX - minX)
            p:Display()
        end)
    end)

    hexBox.FocusLost:Connect(function(enter)
        if enter then
            local ok, col = pcall(Color3.fromHex, hexBox.Text:gsub("^#",""))
            if ok then p.Hue, p.Sat, p.Vib = col:ToHSV() end
        end
        p:Display()
    end)

    rgbBox.FocusLost:Connect(function(enter)
        if enter then
            local r,g,b = rgbBox.Text:match("(%d+),(%d+),(%d+)")
            if r then p.Hue, p.Sat, p.Vib = Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b)):ToHSV() end
        end
        p:Display()
    end)

    p:Display()
    p.Frame = popup
    return p
end

-- ============================================================
--  GROUPBOX ELEMENT METHODS
-- ============================================================
local GroupboxMeta = {}
GroupboxMeta.__index = GroupboxMeta

function GroupboxMeta:_blank(h)
    local f = newFrame({ bg=C.black, trans=1, size=UDim2.new(1,0,0,h or 5), z=1, parent=self.Container })
    f.BackgroundTransparency = 1
    return f
end

function GroupboxMeta:_resize()
    local h = 0
    for _, c in ipairs(self.Container:GetChildren()) do
        if not c:IsA("UIListLayout") and c.Visible then
            h = h + c.AbsoluteSize.Y
        end
    end
    self._box.Size = UDim2.new(1, 0, 0, 24 + h + 4)
end

-- ── Label ────────────────────────────────────────────────────
function GroupboxMeta:AddLabel(text, wrap)
    local h = wrap and select(2, textBounds(text, 14)) or 15
    local lbl = newLabel({
        text=text, sz=UDim2.new(1,-6,0,h), col=C.textMid,
        wrap=wrap or false, z=6, parent=self.Container
    })
    self:_blank(4)
    self:_resize()

    local obj = {}
    function obj:SetText(t)
        lbl.Text = t
        if wrap then
            local _, ny = textBounds(t, 14)
            lbl.Size = UDim2.new(1,-6,0,ny)
        end
    end
    return obj
end

-- ── Divider ──────────────────────────────────────────────────
function GroupboxMeta:AddDivider()
    self:_blank(3)
    local o = newFrame({ bg=C.black, size=UDim2.new(1,-4,0,1), z=5, parent=self.Container })
    newFrame({ bg=C.borderMed, size=UDim2.new(1,0,1,0), z=6, parent=o })
    self:_blank(3)
    self:_resize()
end

-- ── Button ───────────────────────────────────────────────────
function GroupboxMeta:AddButton(text, callback)
    local o, i = shellFrame(self.Container, nil, 20, 5)
    local lbl = newLabel({ text=text, sz=UDim2.new(1,0,1,0), col=C.textBright,
        alignX=Enum.TextXAlignment.Center, z=7, parent=i })

    o.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            tw(i, {BackgroundColor3=C.pressed}, SNAP)
            task.wait(0.08)
            tw(i, {BackgroundColor3=C.elementBg2}, SNAP)
            if callback then pcall(callback) end
        end
    end)
    o.MouseEnter:Connect(function() tw(o, {BackgroundColor3=C.borderSoft}, SNAP) end)
    o.MouseLeave:Connect(function() tw(o, {BackgroundColor3=C.black}, SNAP) end)

    self:_blank(5)
    self:_resize()

    local obj = {}
    function obj:SetText(t) lbl.Text = t end
    return obj
end

-- ── Toggle ───────────────────────────────────────────────────
function GroupboxMeta:AddToggle(info)
    info = info or {}
    local toggle = newObj(info.Default or false, info.Callback)
    toggle.Risky  = info.Risky

    local row = newFrame({
        bg=C.black, trans=1, size=UDim2.new(1,-4,0,20), z=5, parent=self.Container
    })
    row.BackgroundTransparency = 1

    -- Checkbox shell
    local cOuter = newFrame({ bg=C.black, size=UDim2.new(0,14,0,14),
        pos=UDim2.new(0,0,0.5,-7), z=6, parent=row })
    local cInner = newFrame({ bg=C.checkOff, size=UDim2.new(1,0,1,0),
        border=C.borderHard, z=7, parent=cOuter })

    -- Label
    local lbl = newLabel({
        text = info.Text or "",
        col  = toggle.Risky and C.riskColor or C.textBright,
        sz   = UDim2.new(1,-22,1,0), pos=UDim2.new(0,20,0,0),
        z=7, parent=row
    })

    -- Keybind badge (right side)
    local kbLabel
    local kbOuter = newFrame({ bg=C.black, size=UDim2.new(0,28,0,15),
        pos=UDim2.new(1,-28,0.5,-7), z=8, parent=row })
    local kbInner = newFrame({ bg=C.groupBg, size=UDim2.new(1,0,1,0),
        border=C.borderMed, z=9, parent=kbOuter })
    kbLabel = newLabel({ text="NONE", size=11, col=C.textSub,
        alignX=Enum.TextXAlignment.Center, z=10, parent=kbInner })
    kbOuter.Visible = false -- shown only when AddKeyPicker is called

    -- Color swatch (right side, shown when AddColorPicker is called)
    local cpSwatch = newFrame({ bg=info.DefaultColor or Color3.fromRGB(200,200,200),
        size=UDim2.new(0,28,0,15), pos=UDim2.new(1,-62,0.5,-7),
        border=C.borderMed, z=8, parent=row })
    cpSwatch.Visible = false

    local function refreshDisplay()
        if toggle.Value then
            cInner.BackgroundColor3 = C.checkOn
            tw(cInner, {BackgroundColor3=C.checkOn}, SNAP)
        else
            tw(cInner, {BackgroundColor3=C.checkOff}, SNAP)
        end
    end

    local _setVal = toggle.SetValue
    function toggle:SetValue(v)
        self.Value = not not v
        refreshDisplay()
        if self.Callback then pcall(self.Callback, self.Value) end
        if self._ch      then pcall(self._ch,      self.Value) end
    end
    toggle._ch = nil
    function toggle:OnChanged(fn) self._ch = fn; fn(self.Value) end

    row.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle:SetValue(not toggle.Value)
        end
    end)
    row.MouseEnter:Connect(function() tw(row, {BackgroundColor3=C.sidebarLine}, SNAP) end)
    row.MouseLeave:Connect(function() row.BackgroundTransparency = 1 end)

    refreshDisplay()
    self:_blank(6)
    self:_resize()

    -- ── AddColorPicker addon ──────────────────────────────────
    function toggle:AddColorPicker(cpInfo)
        cpInfo = cpInfo or {}
        cpSwatch.BackgroundColor3 = cpInfo.Default or Color3.fromRGB(200,200,200)
        cpSwatch.Visible = true

        local picker = buildColorPicker(
            row.Parent.Parent,  -- attach popup to groupbox outer so it floats above
            cpInfo.Default or Color3.fromRGB(200,200,200),
            cpInfo.Transparency or 0,
            cpInfo.Callback
        )

        -- Reposition popup relative to swatch each time swatch moves
        local function reposition()
            local ap = cpSwatch.AbsolutePosition
            picker.Frame.Position = UDim2.fromOffset(ap.X, ap.Y + 20)
        end
        cpSwatch:GetPropertyChangedSignal("AbsolutePosition"):Connect(reposition)
        task.defer(reposition)

        local open = false
        cpSwatch.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            open = not open
            picker.Frame.Visible = open
            if open then reposition() end
        end)

        UIS.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 and open then
                local ap = picker.Frame.AbsolutePosition
                local as = picker.Frame.AbsoluteSize
                local m  = Players.LocalPlayer:GetMouse()
                if m.X < ap.X or m.X > ap.X+as.X or m.Y < ap.Y-22 or m.Y > ap.Y+as.Y then
                    picker.Frame.Visible = false; open = false
                end
            end
        end)

        picker.OnChanged(function(col, trans)
            cpSwatch.BackgroundColor3 = col
        end)

        return toggle
    end

    -- ── AddKeyPicker addon ────────────────────────────────────
    function toggle:AddKeyPicker(kpInfo)
        kpInfo = kpInfo or {}
        local kp = {
            Value   = kpInfo.Default or "None",
            Toggled = false,
            Mode    = kpInfo.Mode or "Toggle",
            SyncToggleState = kpInfo.SyncToggleState or false,
            Callback = kpInfo.Callback or function() end,
        }
        kbOuter.Visible = true
        kbLabel.Text = kp.Value

        local picking = false
        kbOuter.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            picking = true; kbLabel.Text = "..."
            local conn; conn = UIS.InputBegan:Connect(function(i2, gp)
                if gp then return end
                local key
                if i2.UserInputType == Enum.UserInputType.Keyboard     then key = i2.KeyCode.Name
                elseif i2.UserInputType == Enum.UserInputType.MouseButton1 then key = "MB1"
                elseif i2.UserInputType == Enum.UserInputType.MouseButton2 then key = "MB2" end
                if key then
                    conn:Disconnect(); picking = false
                    kp.Value = key; kbLabel.Text = key
                    if kp.Changed then pcall(kp.Changed, key) end
                end
            end)
        end)

        function kp:GetState()
            if kp.Mode == "Always" then return true
            elseif kp.Mode == "Hold" then
                if kp.Value == "MB1" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                elseif kp.Value == "MB2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                else return UIS:IsKeyDown(Enum.KeyCode[kp.Value] or Enum.KeyCode.Unknown) end
            else return kp.Toggled end
        end

        function kp:OnChanged(fn) kp.Changed = fn end

        UIS.InputBegan:Connect(function(inp, gp)
            if gp or picking then return end
            if kp.Mode == "Toggle" then
                local match = false
                if kp.Value == "MB1" and inp.UserInputType == Enum.UserInputType.MouseButton1 then match = true
                elseif kp.Value == "MB2" and inp.UserInputType == Enum.UserInputType.MouseButton2 then match = true
                elseif inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode.Name == kp.Value then match = true end
                if match then
                    kp.Toggled = not kp.Toggled
                    if kp.SyncToggleState then toggle:SetValue(kp.Toggled) end
                    pcall(kp.Callback, kp.Toggled)
                end
            end
        end)

        return toggle
    end

    return toggle
end

-- ── Slider ───────────────────────────────────────────────────
function GroupboxMeta:AddSlider(info)
    info = info or {}
    local slider = newObj(info.Default or info.Min or 0, info.Callback)
    slider.Min      = info.Min or 0
    slider.Max      = info.Max or 100
    slider.Rounding = info.Rounding or 0
    slider.Suffix   = info.Suffix or ""

    if not info.Compact then
        newLabel({ text=info.Text or "", sz=UDim2.new(1,-4,0,14),
            col=C.textMid, size=13, z=5, parent=self.Container })
        self:_blank(2)
    end

    local o = newFrame({ bg=C.black, size=UDim2.new(1,-4,0,14), z=5, parent=self.Container })
    local i = newFrame({ bg=C.elementBg, size=UDim2.new(1,0,1,0), border=C.borderHard, z=6, parent=o })

    local fill = newFrame({ bg=C.sliderFill, size=UDim2.new(0,0,1,0), z=7, parent=i })
    fill.BorderSizePixel = 0

    local dispLbl = newLabel({
        text="", sz=UDim2.new(1,0,1,0), col=C.textBright,
        alignX=Enum.TextXAlignment.Center, size=12, z=9, parent=i
    })

    local MAX_W = 0
    i:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        MAX_W = i.AbsoluteSize.X
    end)
    task.defer(function() MAX_W = i.AbsoluteSize.X end)

    local function displaySlider()
        local range = slider.Max - slider.Min
        local pct   = (slider.Value - slider.Min) / range
        fill.Size   = UDim2.new(pct, 0, 1, 0)
        local suf = slider.Suffix
        if info.Compact then
            dispLbl.Text = (info.Text or "").." "..slider.Value..suf
        elseif info.HideMax then
            dispLbl.Text = slider.Value..suf
        else
            dispLbl.Text = slider.Value..suf.."/"..slider.Max..suf
        end
    end

    local _setVal = slider.SetValue
    function slider:SetValue(v)
        local num = tonumber(v)
        if not num then return end
        self.Value = roundTo(math.clamp(num, self.Min, self.Max), self.Rounding)
        displaySlider()
        if self.Callback then pcall(self.Callback, self.Value) end
        if self._ch      then pcall(self._ch,      self.Value) end
    end
    slider._ch = nil
    function slider:OnChanged(fn) self._ch = fn; fn(self.Value) end

    slider:SetValue(info.Default or info.Min or 0)

    local mouse = Players.LocalPlayer:GetMouse()
    i.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local startX  = mouse.X
        local startPx = fill.AbsoluteSize.X
        while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
            local dx  = mouse.X - startX
            local newPx = math.clamp(startPx + dx, 0, MAX_W)
            local newV  = mapVal(newPx, 0, MAX_W, slider.Min, slider.Max)
            slider:SetValue(newV)
            RunService.RenderStepped:Wait()
        end
    end)

    o.MouseEnter:Connect(function() tw(o, {BackgroundColor3=C.borderSoft}, SNAP) end)
    o.MouseLeave:Connect(function() tw(o, {BackgroundColor3=C.black}, SNAP) end)

    self:_blank(5)
    self:_resize()
    return slider
end

-- ── Input ────────────────────────────────────────────────────
function GroupboxMeta:AddInput(info)
    info = info or {}
    local input = newObj(info.Default or "", info.Callback)
    input.Numeric  = info.Numeric  or false
    input.Finished = info.Finished or false

    newLabel({ text=info.Text or "", sz=UDim2.new(1,-4,0,14),
        col=C.textMid, size=13, z=5, parent=self.Container })
    self:_blank(2)

    local o, i = shellFrame(self.Container, nil, 20, 5)

    local clip = newFrame({ bg=C.black, trans=1, size=UDim2.new(1,-6,1,0),
        pos=UDim2.new(0,5,0,0), clip=true, z=7, parent=i })
    clip.BackgroundTransparency = 1

    local box = Instance.new("TextBox")
    box.BackgroundTransparency = 1
    box.Font              = FONT
    box.TextSize          = 14
    box.TextColor3        = C.textBright
    box.PlaceholderColor3 = C.textSub
    box.PlaceholderText   = info.Placeholder or ""
    box.Text              = info.Default or ""
    box.TextXAlignment    = Enum.TextXAlignment.Left
    box.Size              = UDim2.new(4, 0, 1, 0)
    box.ZIndex            = 8
    box.Parent            = clip
    box.ClearTextOnFocus  = false
    makeStroke(box)

    local function applyVal(text)
        if input.Numeric and text ~= "" and not tonumber(text) then
            box.Text = input.Value; return
        end
        if info.MaxLength and #text > info.MaxLength then
            text = text:sub(1, info.MaxLength); box.Text = text
        end
        input.Value = text
        if input.Callback then pcall(input.Callback, text) end
        if input._ch      then pcall(input._ch,      text) end
    end

    local _setVal = input.SetValue
    function input:SetValue(v) box.Text = tostring(v); applyVal(box.Text) end
    input._ch = nil
    function input:OnChanged(fn) self._ch = fn; fn(self.Value) end

    if info.Finished then
        box.FocusLost:Connect(function(enter) if enter then applyVal(box.Text) end end)
    else
        box:GetPropertyChangedSignal("Text"):Connect(function() applyVal(box.Text) end)
    end

    o.MouseEnter:Connect(function() tw(o, {BackgroundColor3=C.borderSoft}, SNAP) end)
    o.MouseLeave:Connect(function() tw(o, {BackgroundColor3=C.black}, SNAP) end)

    self:_blank(5)
    self:_resize()
    return input
end

-- ── Dropdown ─────────────────────────────────────────────────
function GroupboxMeta:AddDropdown(info)
    info = info or {}

    if info.SpecialType == "Player" then
        info.Values = {}
        for _, p in ipairs(Players:GetPlayers()) do table.insert(info.Values, p.Name) end
        table.sort(info.Values); info.AllowNull = true
    elseif info.SpecialType == "Team" then
        info.Values = {}
        for _, t in ipairs(Teams:GetTeams()) do table.insert(info.Values, t.Name) end
        table.sort(info.Values); info.AllowNull = true
    end

    local dd = {}
    dd.Values    = info.Values or {}
    dd.Multi     = info.Multi  or false
    dd.Value     = info.Multi and {} or nil
    dd.Callback  = info.Callback or function() end
    dd._ch       = nil
    function dd:OnChanged(fn) self._ch = fn; fn(self.Value) end
    function dd:_fire()
        if self.Callback then pcall(self.Callback, self.Value) end
        if self._ch      then pcall(self._ch,      self.Value) end
    end

    if not info.Compact then
        newLabel({ text=info.Text or "", sz=UDim2.new(1,-4,0,14),
            col=C.textMid, size=13, z=5, parent=self.Container })
        self:_blank(2)
    end

    local o, i = shellFrame(self.Container, nil, 20, 5)

    -- Arrow icon
    local arrow = newLabel({ text="▾", sz=UDim2.new(0,16,1,0),
        pos=UDim2.new(1,-16,0,0), alignX=Enum.TextXAlignment.Center,
        col=C.textSub, size=13, z=8, parent=i })

    local itemLbl = newLabel({ text="--", sz=UDim2.new(1,-20,1,0),
        pos=UDim2.new(0,5,0,0), col=C.textBright, size=13, z=7, parent=i })

    -- Dropdown list popup (parented to the gui root so it floats above everything)
    local listContainer = newFrame({
        bg=C.dropBg, size=UDim2.fromOffset(10,10),
        z=30, parent=self._gui, border=C.borderHard
    })
    listContainer.Visible = false

    local scroll = Instance.new("ScrollingFrame")
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.Size   = UDim2.new(1,0,1,0)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = C.accentMid
    scroll.TopImage    = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    scroll.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    scroll.ZIndex = 31
    scroll.Parent = listContainer

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,1)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local MAX_VISIBLE = 8
    local isOpen = false

    local function reposition()
        local ap = o.AbsolutePosition
        local as = o.AbsoluteSize
        local itemCount = math.min(#dd.Values, MAX_VISIBLE)
        local listH = math.max(itemCount * 20, 20)
        listContainer.Size     = UDim2.fromOffset(as.X, listH)
        listContainer.Position = UDim2.fromOffset(ap.X, ap.Y + as.Y + 1)
        scroll.CanvasSize      = UDim2.fromOffset(0, #dd.Values * 20)
    end

    local function displayMain()
        if dd.Multi then
            local parts = {}
            for _, v in ipairs(dd.Values) do
                if dd.Value[v] then table.insert(parts, v) end
            end
            itemLbl.Text = #parts > 0 and table.concat(parts, ", ") or "--"
        else
            itemLbl.Text = dd.Value or "--"
        end
    end

    local function buildList()
        for _, c in ipairs(scroll:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        for _, val in ipairs(dd.Values) do
            local local_val = val
            local btn = newFrame({ bg=C.elementBg, size=UDim2.new(1,0,0,20), z=32, parent=scroll })
            local bLbl = newLabel({ text=local_val, sz=UDim2.new(1,-8,1,0),
                pos=UDim2.new(0,6,0,0), col=C.textMid, size=13, z=33, parent=btn })

            local selected = dd.Multi and (dd.Value[local_val] == true) or (dd.Value == local_val)

            local function refreshBtn()
                selected = dd.Multi and (dd.Value[local_val] == true) or (dd.Value == local_val)
                tw(bLbl, {TextColor3 = selected and C.accentHi or C.textMid}, SNAP)
                tw(btn,  {BackgroundColor3 = selected and C.dropItemSel or C.elementBg}, SNAP)
            end
            refreshBtn()

            btn.InputBegan:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                local try = not selected
                local activeCount = 0
                if dd.Multi then
                    for _, v2 in ipairs(dd.Values) do if dd.Value[v2] then activeCount += 1 end end
                else
                    activeCount = dd.Value and 1 or 0
                end
                if activeCount == 1 and not try and not info.AllowNull then return end
                if dd.Multi then
                    dd.Value[local_val] = try and true or nil
                else
                    dd.Value = try and local_val or nil
                end
                refreshBtn()
                displayMain()
                dd:_fire()
            end)

            btn.MouseEnter:Connect(function()
                if not selected then tw(btn, {BackgroundColor3=C.dropItemHov}, SNAP) end
            end)
            btn.MouseLeave:Connect(function()
                if not selected then tw(btn, {BackgroundColor3=C.elementBg}, SNAP) end
            end)
        end
    end

    local function openList()
        buildList(); reposition()
        listContainer.Visible = true; isOpen = true
        tw(arrow, {Rotation=180}, FAST)
    end
    local function closeList()
        listContainer.Visible = false; isOpen = false
        tw(arrow, {Rotation=0}, FAST)
    end

    o.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if isOpen then closeList() else openList() end
        end
    end)

    UIS.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
            local ap = listContainer.AbsolutePosition; local as = listContainer.AbsoluteSize
            local m  = Players.LocalPlayer:GetMouse()
            if m.X < ap.X or m.X > ap.X+as.X or m.Y < ap.Y-22 or m.Y > ap.Y+as.Y then
                closeList()
            end
        end
    end)

    o.MouseEnter:Connect(function() tw(o, {BackgroundColor3=C.borderSoft}, SNAP) end)
    o.MouseLeave:Connect(function() tw(o, {BackgroundColor3=C.black}, SNAP) end)

    function dd:SetValues(newVals)
        if newVals then self.Values = newVals end
        if self.Multi then
            local clean = {}
            for k,v in pairs(self.Value) do
                if table.find(self.Values, k) then clean[k] = v end
            end
            self.Value = clean
        else
            if not table.find(self.Values, self.Value) then self.Value = nil end
        end
        displayMain()
    end

    function dd:SetValue(v)
        if self.Multi then
            self.Value = {}
            if type(v) == "table" then
                for _, k in ipairs(v) do
                    if table.find(self.Values, k) then self.Value[k] = true end
                end
            end
        else
            self.Value = (v and table.find(self.Values, v)) and v or nil
        end
        displayMain(); self:_fire()
    end

    -- Apply default
    if info.Default then dd:SetValue(info.Default) end
    displayMain()

    self:_blank(5)
    self:_resize()
    return dd
end

-- ============================================================
--  GROUPBOX / TABBOX FACTORY
-- ============================================================
local function makeGroupbox(name, side, sideFrame, gui)
    local gb = setmetatable({}, GroupboxMeta)
    gb._gui  = gui

    -- Outer black shell
    local boxOuter = newFrame({
        bg=C.black, size=UDim2.new(1,0,0,28), z=2,
        parent=sideFrame, border=C.borderHard
    })

    -- Inner content bg
    local boxInner = newFrame({
        bg=C.groupBg, size=UDim2.new(1,0,1,0), z=3, parent=boxOuter
    })

    -- White accent top bar
    local topBar = newFrame({ bg=C.accentMid, size=UDim2.new(1,0,0,2), z=4, parent=boxInner })

    -- Groupbox title
    newLabel({ text=name, sz=UDim2.new(1,-6,0,18), pos=UDim2.new(0,5,0,3),
        col=C.textMid, size=13, z=4, parent=boxInner })

    -- Separator under header
    local sep = newFrame({ bg=C.borderSoft, size=UDim2.new(1,0,0,1), pos=UDim2.new(0,0,0,21), z=4, parent=boxInner })

    -- Content container
    local container = newFrame({
        bg=C.groupBg, trans=1, size=UDim2.new(1,-4,1,0), pos=UDim2.new(0,4,0,24),
        z=4, parent=boxInner
    })
    container.BackgroundTransparency = 1
    container.ClipsDescendants = false

    local layout = Instance.new("UIListLayout")
    layout.FillDirection     = Enum.FillDirection.Vertical
    layout.SortOrder         = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Parent = container

    gb.Container = container
    gb._box      = boxOuter

    gb:_blank(3)
    gb:_resize()
    return gb
end

-- ============================================================
--  TAB CONTENT FACTORY (left/right columns, Linoria style)
-- ============================================================
local function makeTab(panel, gui)
    local tab = { _gui = gui }

    -- Left scrolling column
    local leftScroll = Instance.new("ScrollingFrame")
    leftScroll.BackgroundTransparency = 1; leftScroll.BorderSizePixel = 0
    leftScroll.Position = UDim2.new(0,8,0,8)
    leftScroll.Size     = UDim2.new(0.5,-12,1,-16)
    leftScroll.CanvasSize  = UDim2.new(0,0,0,0)
    leftScroll.ScrollBarThickness = 3
    leftScroll.ScrollBarImageColor3 = C.accentMid
    leftScroll.TopImage    = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    leftScroll.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    leftScroll.ZIndex = 2; leftScroll.Parent = panel

    -- Right scrolling column
    local rightScroll = Instance.new("ScrollingFrame")
    rightScroll.BackgroundTransparency = 1; rightScroll.BorderSizePixel = 0
    rightScroll.Position = UDim2.new(0.5,4,0,8)
    rightScroll.Size     = UDim2.new(0.5,-12,1,-16)
    rightScroll.CanvasSize  = UDim2.new(0,0,0,0)
    rightScroll.ScrollBarThickness = 3
    rightScroll.ScrollBarImageColor3 = C.accentMid
    rightScroll.TopImage    = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    rightScroll.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    rightScroll.ZIndex = 2; rightScroll.Parent = panel

    local leftLayout  = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0,8); leftLayout.FillDirection = Enum.FillDirection.Vertical
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder; leftLayout.Parent = leftScroll

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0,8); rightLayout.FillDirection = Enum.FillDirection.Vertical
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder; rightLayout.Parent = rightScroll

    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        leftScroll.CanvasSize = UDim2.fromOffset(0, leftLayout.AbsoluteContentSize.Y+8)
    end)
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        rightScroll.CanvasSize = UDim2.fromOffset(0, rightLayout.AbsoluteContentSize.Y+8)
    end)

    function tab:AddLeftGroupbox(name)
        return makeGroupbox(name, "left", leftScroll, gui)
    end
    function tab:AddRightGroupbox(name)
        return makeGroupbox(name, "right", rightScroll, gui)
    end

    -- Tabbox (multiple named tabs inside a groupbox area)
    function tab:AddLeftTabbox()
        return tab:_makeTabbox(leftScroll, gui)
    end
    function tab:AddRightTabbox()
        return tab:_makeTabbox(rightScroll, gui)
    end

    function tab:_makeTabbox(sideScroll, g)
        local tbWrapper = newFrame({ bg=C.black, size=UDim2.new(1,0,0,28), z=2,
            parent=sideScroll, border=C.borderHard })
        local tbInner   = newFrame({ bg=C.groupBg, size=UDim2.new(1,0,1,0), z=3, parent=tbWrapper })
        local topBar2   = newFrame({ bg=C.accentMid, size=UDim2.new(1,0,0,2), z=4, parent=tbInner })

        -- Tab header row
        local tabRow = newFrame({ bg=C.sidebarBg, size=UDim2.new(1,0,0,20),
            pos=UDim2.new(0,0,0,2), z=4, parent=tbInner })
        local tabSep = newFrame({ bg=C.borderSoft, size=UDim2.new(1,0,0,1),
            pos=UDim2.new(0,0,1,-1), z=5, parent=tabRow })

        local tabRowLayout = Instance.new("UIListLayout")
        tabRowLayout.FillDirection = Enum.FillDirection.Horizontal
        tabRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabRowLayout.Parent = tabRow

        -- Content area (below the tab header)
        local contentArea = newFrame({ bg=C.groupBg, size=UDim2.new(1,0,0,0),
            pos=UDim2.new(0,0,0,23), z=4, parent=tbInner })

        local tbObj    = {}
        local pages    = {}
        local tabBtns  = {}
        local activeNm = nil

        local function showPage(name)
            for n, p in pairs(pages) do p.Visible = (n == name) end
            for n, btn in pairs(tabBtns) do
                tw(btn, {
                    BackgroundColor3 = (n == name) and C.tabActive or C.tabInactive,
                    TextColor3       = (n == name) and C.textBright or C.textSub
                }, SNAP)
            end
            activeNm = name
        end

        function tbObj:AddTab(name)
            local tabBtn = Instance.new("TextButton")
            tabBtn.BackgroundColor3 = C.tabInactive
            tabBtn.BorderSizePixel  = 0
            tabBtn.AutoButtonColor  = false
            tabBtn.Font    = FONT; tabBtn.TextSize = 12
            tabBtn.TextColor3 = C.textSub
            tabBtn.Text    = name
            tabBtn.Size    = UDim2.new(0, math.max(50, #name*7+12), 1, 0)
            tabBtn.ZIndex  = 5; tabBtn.Parent = tabRow
            makeBorder(tabBtn, C.borderMed, 1)
            tabBtns[name] = tabBtn

            -- Each page is its own groupbox-like container
            local page = newFrame({ bg=C.groupBg, trans=1, size=UDim2.new(1,0,1,0),
                z=5, parent=contentArea })
            page.BackgroundTransparency = 1
            page.Visible = false
            local pageLayout = Instance.new("UIListLayout")
            pageLayout.FillDirection = Enum.FillDirection.Vertical
            pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
            pageLayout.Parent = page

            -- Build a fake groupbox for this page
            local pageGb = setmetatable({}, GroupboxMeta)
            pageGb._gui  = g
            pageGb.Container = page
            pageGb._box  = tbWrapper

            function pageGb:_resize()
                local h = 0
                for _, c in ipairs(page:GetChildren()) do
                    if not c:IsA("UIListLayout") and c.Visible then
                        h += c.AbsoluteSize.Y
                    end
                end
                contentArea.Size = UDim2.new(1,0,0, h+6)
                tbWrapper.Size   = UDim2.new(1,0,0, 26 + h + 6)
            end

            pages[name] = page

            if not activeNm then showPage(name) end

            tabBtn.MouseButton1Click:Connect(function() showPage(name) end)
            tabBtn.MouseEnter:Connect(function()
                if activeNm ~= name then tw(tabBtn, {BackgroundColor3=C.tabHover}, SNAP) end
            end)
            tabBtn.MouseLeave:Connect(function()
                if activeNm ~= name then tw(tabBtn, {BackgroundColor3=C.tabInactive}, SNAP) end
            end)

            return pageGb
        end

        return tbObj
    end

    return tab
end

-- ============================================================
--  NOTIFICATION SYSTEM
-- ============================================================
local function setupNotifications(gui)
    local holder = newFrame({
        bg=C.black, trans=1, size=UDim2.new(0,240,1,0),
        pos=UDim2.new(1,-248,0,0), z=50, parent=gui
    })
    holder.BackgroundTransparency = 1
    holder.Name = "NotifHolder"

    local hLayout = Instance.new("UIListLayout")
    hLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    hLayout.FillDirection = Enum.FillDirection.Vertical
    hLayout.SortOrder = Enum.SortOrder.LayoutOrder
    hLayout.Padding = UDim.new(0,4)
    hLayout.Parent = holder

    local function notify(opts)
        opts = opts or {}
        local title    = opts.Title    or "Notification"
        local text     = opts.Text     or ""
        local duration = opts.Duration or 3

        local n = newFrame({ bg=C.black, size=UDim2.new(1,0,0,54), z=51, parent=holder,
            border=C.borderHard })
        n.ClipsDescendants = false

        local ni = newFrame({ bg=C.groupBg, size=UDim2.new(1,0,1,0), z=52, parent=n })
        local nTop = newFrame({ bg=C.accentMid, size=UDim2.new(1,0,0,2), z=53, parent=ni })

        newLabel({ text=title, sz=UDim2.new(1,-8,0,16), pos=UDim2.new(0,6,0,4),
            col=C.textBright, size=13, z=53, parent=ni })
        newLabel({ text=text, sz=UDim2.new(1,-8,0,28), pos=UDim2.new(0,6,0,20),
            col=C.textSub, size=12, wrap=true, z=53, parent=ni })

        -- Slide in
        n.Position = UDim2.new(1,10,0,0)
        tw(n, {Position=UDim2.new(0,0,0,0)}, MED)

        task.delay(duration, function()
            tw(n, {Position=UDim2.new(1,10,0,0)}, MED)
            task.wait(0.25); n:Destroy()
        end)
    end

    return notify
end

-- ============================================================
--  WATERMARK / KEY SYSTEM
-- ============================================================
local function makeWatermark(gui, text)
    local w = newFrame({ bg=C.black, size=UDim2.new(0,180,0,24),
        pos=UDim2.new(0,6,0,6), z=20, parent=gui, border=C.borderMed })
    local wi = newFrame({ bg=C.groupBg, size=UDim2.new(1,0,1,0), z=21, parent=w })
    local topB = newFrame({ bg=C.accentMid, size=UDim2.new(1,0,0,2), z=22, parent=wi })
    local lbl = newLabel({ text=text or "Onyxite", sz=UDim2.new(1,-8,1,0),
        pos=UDim2.new(0,5,0,0), col=C.textMid, size=12,
        alignX=Enum.TextXAlignment.Left, z=22, parent=wi })

    -- Drag watermark
    local drag, ds, dsp = false, nil, nil
    w.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drag=true; ds=inp.Position; dsp=w.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if drag and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - ds
            w.Position = UDim2.new(dsp.X.Scale, dsp.X.Offset+d.X, dsp.Y.Scale, dsp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
    end)

    local wmObj = {}
    function wmObj:SetText(t) lbl.Text = t end
    return wmObj
end

-- ============================================================
--  MAIN WINDOW FACTORY
-- ============================================================
local Library = {}

function Library.new(config)
    config = config or {}
    local win = {}
    win._tabPanels  = {}
    win._tabBtns    = {}
    win._activeTab  = nil
    win.Options     = {}

    local WIN_W    = config.Width  or 550
    local WIN_H    = config.Height or 600
    local TITLE_H  = 34
    local SIDEBAR_W = 180
    local MIN_W    = 480
    local MIN_H    = 380

    local player    = Players.LocalPlayer
    local guiParent = player:WaitForChild("PlayerGui")

    local gui = Instance.new("ScreenGui")
    gui.Name           = config.Name or "OnyxiteLib"
    gui.ResetOnSpawn   = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = guiParent end

    -- ── Outer window shell ────────────────────────────────────
    local outer = newFrame({ bg=C.windowBg, size=UDim2.new(0,WIN_W,0,WIN_H),
        pos=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2), z=1, parent=gui,
        border=C.windowBorder, corner=4 })

    -- ── Title bar ─────────────────────────────────────────────
    local titleBar = newFrame({ bg=C.titleBg, size=UDim2.new(1,0,0,TITLE_H),
        z=4, parent=outer, corner=4 })
    local titleSep = newFrame({ bg=C.borderSoft, size=UDim2.new(1,0,0,1),
        pos=UDim2.new(0,0,1,-1), z=5, parent=titleBar })
    local titleDot = newFrame({ bg=C.accentDim, size=UDim2.new(0,5,0,5),
        pos=UDim2.new(0,12,0.5,-2), z=6, parent=titleBar, corner=3 })
    newLabel({ text=config.Title or "Onyxite", sz=UDim2.new(0,200,1,0),
        pos=UDim2.new(0,24,0,0), col=C.textBright, size=14, z=6, parent=titleBar })

    if config.SubTitle then
        newLabel({ text=config.SubTitle, sz=UDim2.new(0,200,1,0),
            pos=UDim2.new(0,170,0,0), col=C.textDim, size=10, z=6, parent=titleBar })
    end

    -- Window control buttons
    local function winBtn(xOff, glyph, hoverCol, txtHover)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,20,0,20); b.Position = UDim2.new(1,xOff,0.5,-10)
        b.BackgroundColor3 = C.elementBg; b.BorderSizePixel=0
        b.Text=glyph; b.Font=FONT; b.TextSize=14; b.TextColor3=C.textDim
        b.AutoButtonColor=false; b.ZIndex=8; b.Parent=titleBar
        makeCorner(b,2); makeBorder(b,C.borderSoft,1)
        b.MouseEnter:Connect(function()  tw(b,{BackgroundColor3=hoverCol, TextColor3=txtHover},SNAP) end)
        b.MouseLeave:Connect(function()  tw(b,{BackgroundColor3=C.elementBg, TextColor3=C.textDim},SNAP) end)
        return b
    end
    local closeBtn    = winBtn(-28, "×", Color3.fromRGB(38,10,10), Color3.fromRGB(200,70,70))
    local minimizeBtn = winBtn(-52, "−", Color3.fromRGB(28,28,18), Color3.fromRGB(200,200,100))

    -- ── Close dialog ──────────────────────────────────────────
    local overlay = newFrame({ bg=C.black, trans=1, size=UDim2.fromScale(1,1), z=90, parent=gui })
    overlay.BackgroundTransparency = 1; overlay.Visible = false

    local dlg = newFrame({ bg=C.titleBg, size=UDim2.new(0,280,0,140),
        pos=UDim2.new(0.5,-140,0.5,-70), z=92, parent=overlay,
        border=C.borderHard, corner=4 })
    newLabel({ text="Close "..( config.Title or "Onyxite").."?",
        sz=UDim2.new(1,-20,0,30), pos=UDim2.new(0,12,0,10),
        col=C.textBright, size=14, z=93, parent=dlg })
    newLabel({ text="Re-execute to reopen.",
        sz=UDim2.new(1,-20,0,20), pos=UDim2.new(0,12,0,40),
        col=C.textSub, size=12, z=93, parent=dlg })

    local function dlgBtn(xOff, w, t, bg, tc)
        local b = Instance.new("TextButton")
        b.Size=UDim2.new(0,w,0,28); b.Position=UDim2.new(0,xOff,1,-38)
        b.BackgroundColor3=bg; b.BorderSizePixel=0; b.Text=t
        b.Font=FONT; b.TextSize=12; b.TextColor3=tc
        b.AutoButtonColor=false; b.ZIndex=94; b.Parent=dlg
        makeCorner(b,2); makeBorder(b,C.borderMed,1)
        return b
    end
    local cancelBtn  = dlgBtn(12,  110, "Cancel", C.elementBg2, C.textMid)
    local confirmBtn = dlgBtn(134, 110, "Close",  Color3.fromRGB(22,6,6), Color3.fromRGB(190,65,65))
    cancelBtn.MouseEnter:Connect(function()  tw(cancelBtn, {BackgroundColor3=C.hover},SNAP) end)
    cancelBtn.MouseLeave:Connect(function()  tw(cancelBtn, {BackgroundColor3=C.elementBg2},SNAP) end)
    confirmBtn.MouseEnter:Connect(function() tw(confirmBtn,{BackgroundColor3=Color3.fromRGB(36,8,8)},SNAP) end)
    confirmBtn.MouseLeave:Connect(function() tw(confirmBtn,{BackgroundColor3=Color3.fromRGB(22,6,6)},SNAP) end)

    local function openDlg()  overlay.Visible=true;  tw(overlay,{BackgroundTransparency=0.55},MED) end
    local function closeDlg() tw(overlay,{BackgroundTransparency=1},FAST); task.wait(0.2); overlay.Visible=false end
    closeBtn.MouseButton1Click:Connect(openDlg)
    cancelBtn.MouseButton1Click:Connect(closeDlg)
    confirmBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- ── Minimize pill ─────────────────────────────────────────
    local pill = Instance.new("TextButton")
    pill.Size=UDim2.new(0,120,0,24); pill.Position=UDim2.new(0.5,-60,0,-50)
    pill.BackgroundColor3=C.titleBg; pill.BorderSizePixel=0
    pill.Text=""; pill.AutoButtonColor=false; pill.ZIndex=50; pill.Visible=false; pill.Parent=gui
    makeCorner(pill,12); makeBorder(pill,C.borderHard,1)
    local pillDot = newFrame({ bg=C.accentDim, size=UDim2.new(0,5,0,5),
        pos=UDim2.new(0,10,0.5,-2), z=52, parent=pill, corner=3 })
    newLabel({ text=string.upper(config.Title or "ONYXITE"),
        sz=UDim2.new(1,-22,1,0), pos=UDim2.new(0,20,0,0),
        col=C.textMid, size=10, z=52, parent=pill })
    pill.MouseEnter:Connect(function()  tw(pill,{BackgroundColor3=C.elementBg2},SNAP) end)
    pill.MouseLeave:Connect(function()  tw(pill,{BackgroundColor3=C.titleBg},SNAP) end)

    local visible = true
    local function minimize()
        visible=false; tw(outer,{BackgroundTransparency=1},FAST)
        task.wait(0.18); outer.Visible=false
        pill.Position=UDim2.new(0.5,-60,0,-50); pill.Visible=true
        tw(pill,{Position=UDim2.new(0.5,-60,0,10)},MED)
    end
    local function restore()
        tw(pill,{Position=UDim2.new(0.5,-60,0,-50)},MED)
        task.wait(0.2); pill.Visible=false
        outer.Visible=true; outer.BackgroundTransparency=0; visible=true
    end
    minimizeBtn.MouseButton1Click:Connect(minimize)
    local pDrag,pDS,pSP=false,nil,nil
    pill.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then pDrag=true;pDS=inp.Position;pSP=pill.Position end end)
    UIS.InputChanged:Connect(function(inp) if pDrag and inp.UserInputType==Enum.UserInputType.MouseMovement then local d=inp.Position-pDS; pill.Position=UDim2.new(pSP.X.Scale,pSP.X.Offset+d.X,pSP.Y.Scale,pSP.Y.Offset+d.Y) end end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            if pDrag and (not (pill.Position.X.Offset~=pSP and pill.Position.Y.Offset~=pSP)) then restore() end
            pDrag=false
        end
    end)
    pill.MouseButton1Click:Connect(function() if not pDrag then restore() end end)

    UIS.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.Insert then
            if visible then minimize() else restore() end
        end
    end)

    -- ── Dragging ──────────────────────────────────────────────
    local drag,ds,dsp=false,nil,nil
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=inp.Position;dsp=outer.Position end
    end)
    UIS.InputChanged:Connect(function(inp)
        if drag and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local d=inp.Position-ds
            outer.Position=UDim2.new(dsp.X.Scale,dsp.X.Offset+d.X,dsp.Y.Scale,dsp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)

    -- ── Resize handle ─────────────────────────────────────────
    local rzHandle = Instance.new("TextButton")
    rzHandle.Size=UDim2.new(0,16,0,16); rzHandle.Position=UDim2.new(1,-18,1,-18)
    rzHandle.BackgroundColor3=C.elementBg; rzHandle.BackgroundTransparency=0.5
    rzHandle.BorderSizePixel=0; rzHandle.Text="↘"; rzHandle.Font=FONT
    rzHandle.TextSize=13; rzHandle.TextColor3=C.textDim
    rzHandle.AutoButtonColor=false; rzHandle.ZIndex=20; rzHandle.Parent=outer
    makeCorner(rzHandle,2)
    local rz,rzDS,rzSS=false,nil,nil
    rzHandle.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then rz=true;rzDS=inp.Position;rzSS=outer.AbsoluteSize end
    end)
    UIS.InputChanged:Connect(function(inp)
        if rz and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local d=inp.Position-rzDS
            outer.Size=UDim2.new(0,math.max(MIN_W,rzSS.X+d.X),0,math.max(MIN_H,rzSS.Y+d.Y))
        end
    end)
    UIS.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then rz=false end end)
    rzHandle.MouseEnter:Connect(function() tw(rzHandle,{BackgroundTransparency=0.2,TextColor3=C.textSub},SNAP) end)
    rzHandle.MouseLeave:Connect(function() tw(rzHandle,{BackgroundTransparency=0.5,TextColor3=C.textDim},SNAP) end)

    -- ── Sidebar ───────────────────────────────────────────────
    local sidebar = newFrame({ bg=C.sidebarBg, size=UDim2.new(0,SIDEBAR_W,1,-TITLE_H),
        pos=UDim2.new(0,0,0,TITLE_H), z=4, parent=outer })
    local sideRight = newFrame({ bg=C.borderSoft, size=UDim2.new(0,1,1,0),
        pos=UDim2.new(1,-1,0,0), z=5, parent=sidebar })

    -- Sidebar header label
    local sideHeader = newFrame({ bg=C.groupHeader, size=UDim2.new(1,0,0,36), z=5, parent=sidebar })
    local sideHDot   = newFrame({ bg=C.accentDim, size=UDim2.new(0,5,0,5),
        pos=UDim2.new(0,10,0.5,-2), z=6, parent=sideHeader, corner=3 })
    newLabel({ text=config.Creator or "Creator", sz=UDim2.new(1,-22,1,0),
        pos=UDim2.new(0,20,0,0), col=C.textSub, size=11, z=6, parent=sideHeader })
    newFrame({ bg=C.borderSoft, size=UDim2.new(1,0,0,1), pos=UDim2.new(0,0,1,-1), z=6, parent=sideHeader })

    -- Toggle sidebar button
    local sidebarOpen = true
    local sTgl = Instance.new("TextButton")
    sTgl.Size=UDim2.new(1,0,0,22); sTgl.Position=UDim2.new(0,0,1,-58)
    sTgl.BackgroundColor3=C.groupHeader; sTgl.BorderSizePixel=0
    sTgl.Text="◀ Collapse"; sTgl.Font=FONT; sTgl.TextSize=11; sTgl.TextColor3=C.textSub
    sTgl.AutoButtonColor=false; sTgl.ZIndex=6; sTgl.Parent=sidebar
    newFrame({ bg=C.borderSoft, size=UDim2.new(1,0,0,1), z=6, parent=sTgl })
    sTgl.MouseEnter:Connect(function()  tw(sTgl,{BackgroundColor3=C.tabHover,TextColor3=C.textMid},SNAP) end)
    sTgl.MouseLeave:Connect(function()  tw(sTgl,{BackgroundColor3=C.groupHeader,TextColor3=C.textSub},SNAP) end)

    -- Profile card
    local profCard = newFrame({ bg=C.profileBg, size=UDim2.new(1,0,0,54),
        pos=UDim2.new(0,0,1,-54), z=6, parent=sidebar })
    newFrame({ bg=C.borderSoft, size=UDim2.new(1,0,0,1), z=6, parent=profCard })
    local avatar = Instance.new("ImageLabel")
    avatar.Size=UDim2.new(0,36,0,36); avatar.Position=UDim2.new(0,8,0.5,-18)
    avatar.BackgroundColor3=C.elementBg2; avatar.BorderSizePixel=0
    avatar.Image="rbxthumb://type=AvatarHeadShot&id="..tostring(player.UserId).."&w=150&h=150"
    avatar.ZIndex=7; avatar.Parent=profCard; makeCorner(avatar,4)
    makeBorder(avatar, C.borderMed, 1)
    local profName = newLabel({ text=player.DisplayName, sz=UDim2.new(1,-54,0,16),
        pos=UDim2.new(0,50,0,10), col=C.textBright, size=12, z=7, parent=profCard })
    local profUser = newLabel({ text="@"..player.Name, sz=UDim2.new(1,-54,0,14),
        pos=UDim2.new(0,50,0,27), col=C.textSub, size=11, z=7, parent=profCard })
    player:GetPropertyChangedSignal("DisplayName"):Connect(function()
        profName.Text = player.DisplayName
    end)

    -- Content area
    local content = newFrame({ bg=C.contentBg, size=UDim2.new(1,-SIDEBAR_W-1,1,-TITLE_H),
        pos=UDim2.new(0,SIDEBAR_W+1,0,TITLE_H), z=2, parent=outer })

    -- Tab indicator strip on sidebar
    local tabIndicator = newFrame({ bg=C.accentMid, size=UDim2.new(0,2,0,16), z=8, parent=sidebar })
    tabIndicator.Position = UDim2.new(0,0,0,36)

    -- ── Build tabs from config ─────────────────────────────────
    local TAB_H    = 36
    local TAB_Y    = 36

    local function showTab(name)
        for n, p in pairs(win._tabPanels) do p.Visible = (n == name) end
        local idx = 0
        for ii, d in ipairs(win._tabBtns) do
            local active = (d.name == name)
            tw(d.btn, {
                BackgroundColor3 = active and C.tabActive or C.tabInactive,
                BorderColor3     = active and C.accentMid or C.borderMed,
            }, FAST)
            tw(d.lbl, { TextColor3 = active and C.textBright or C.textSub }, FAST)
            if active then idx = ii end
        end
        local targetY = TAB_Y + (idx-1)*TAB_H + TAB_H/2 - 8
        tw(tabIndicator, { Position=UDim2.new(0,0,0,targetY) }, MED)
        win._activeTab = name
    end

    local tabDefs = config.Tabs or {}
    for ii, def in ipairs(tabDefs) do
        -- Panel
        local panel = newFrame({ bg=C.groupBg, size=UDim2.fromScale(1,1), z=2, parent=content })
        panel.Visible = false
        win._tabPanels[def.Name] = panel

        -- Sidebar button
        local btn = newFrame({ bg=C.tabInactive, size=UDim2.new(1,0,0,TAB_H),
            pos=UDim2.new(0,0,0, TAB_Y+(ii-1)*TAB_H), z=6, parent=sidebar,
            border=C.borderMed })
        local iconL = newLabel({ text=def.Icon or "·", sz=UDim2.new(0,14,1,0),
            pos=UDim2.new(0,10,0,0), col=C.textSub, size=14, z=7, parent=btn })
        local lblL  = newLabel({ text=def.Name, sz=UDim2.new(1,-30,1,0),
            pos=UDim2.new(0,26,0,0), col=C.textSub, size=12, z=7, parent=btn })

        table.insert(win._tabBtns, { name=def.Name, btn=btn, lbl=lblL, icon=iconL })

        local cn = def.Name
        btn.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then showTab(cn) end
        end)
        btn.MouseEnter:Connect(function()
            if win._activeTab~=cn then tw(btn,{BackgroundColor3=C.tabHover},SNAP) end
        end)
        btn.MouseLeave:Connect(function()
            if win._activeTab~=cn then tw(btn,{BackgroundColor3=C.tabInactive},SNAP) end
        end)
    end

    -- Sidebar toggle logic
    local SIDEBAR_W_OPEN   = SIDEBAR_W
    local SIDEBAR_W_CLOSED = 42
    sTgl.MouseButton1Click:Connect(function()
        sidebarOpen = not sidebarOpen
        local sw = sidebarOpen and SIDEBAR_W_OPEN or SIDEBAR_W_CLOSED
        tw(sidebar,  {Size=UDim2.new(0,sw,1,-TITLE_H)}, MED)
        tw(content,  {Size=UDim2.new(1,-sw-1,1,-TITLE_H), Position=UDim2.new(0,sw+1,0,TITLE_H)}, MED)
        sTgl.Text = sidebarOpen and "◀ Collapse" or "▶"
        for _, d in ipairs(win._tabBtns) do
            tw(d.lbl,  {TextTransparency = sidebarOpen and 0 or 1}, MED)
        end
        tw(profName, {TextTransparency = sidebarOpen and 0 or 1}, MED)
        tw(profUser, {TextTransparency = sidebarOpen and 0 or 1}, MED)
        tw(avatar,   {ImageTransparency= sidebarOpen and 0 or 1}, MED)
    end)

    if #tabDefs > 0 then showTab(tabDefs[1].Name) end

    -- ── Notification system ───────────────────────────────────
    win.Notify = setupNotifications(gui)

    -- ── Watermark ─────────────────────────────────────────────
    function win:CreateWatermark(text)
        return makeWatermark(gui, text)
    end

    -- ── GetTab ────────────────────────────────────────────────
    function win:GetTab(name)
        local panel = self._tabPanels[name]
        assert(panel, "Tab '"..tostring(name).."' not found.")
        return makeTab(panel, gui)
    end

    -- ── Destroy ───────────────────────────────────────────────
    function win:Destroy() gui:Destroy() end

    return win
end

-- ============================================================
--  EXAMPLE USAGE (paste in a LocalScript):
--
--  local Lib = loadstring(game:HttpGet("YOUR_RAW_URL"))()
--
--  local Window = Lib.new({
--      Title    = "MyCheat",
--      SubTitle = "v1.0",
--      Creator  = "YourName",
--      Tabs     = {
--          { Name = "Combat",   Icon = "⚔" },
--          { Name = "Visuals",  Icon = "◈" },
--          { Name = "Movement", Icon = "↑" },
--          { Name = "Misc",     Icon = "⋯" },
--      }
--  })
--
--  local Combat = Window:GetTab("Combat")
--  local LeftGB = Combat:AddLeftGroupbox("Aimbot")
--
--  local Toggle = LeftGB:AddToggle({ Text="Enable", Default=false, Callback=function(v) print(v) end })
--  Toggle:AddKeyPicker({ Default="F", Mode="Toggle" })
--  Toggle:AddColorPicker({ Default=Color3.fromRGB(255,0,0), Callback=function(col) print(col) end })
--
--  local Slider = LeftGB:AddSlider({ Text="FOV", Min=0, Max=360, Default=90, Suffix="°", Rounding=0 })
--  local Drop   = LeftGB:AddDropdown({ Text="Target", Values={"Head","Torso","HumanoidRootPart"}, Default="Head" })
--  local Input  = LeftGB:AddInput({ Text="Tag", Placeholder="Enter text...", Finished=true })
--  LeftGB:AddButton("Fire", function() print("Fired!") end)
--  LeftGB:AddDivider()
--  LeftGB:AddLabel("This is a label.")
--
--  Window:Notify({ Title="Loaded", Text="MyCheat loaded successfully!", Duration=4 })
-- ============================================================

return Library
