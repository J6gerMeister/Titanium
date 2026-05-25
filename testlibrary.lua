-- onyxlibrary.lua  —  Black & White edition  (Linoria-style design)
-- Changes:
--   • Adopted LinoriaLib's visual design language (borders, frames, elements)
--   • Kept the black & white color palette
--   • All elements redesigned to match Linoria's aesthetic

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local TextService  = game:GetService("TextService")

-- ============================================================
--  PALETTE  —  black / white / gray only
-- ============================================================
local C = {
	shellOuter   = Color3.fromRGB(0,   0,   0),
	shellBorder  = Color3.fromRGB(0,   0,   0),
	bgMain       = Color3.fromRGB(28,  28,  28),
	bgDeep       = Color3.fromRGB(20,  20,  20),
	bgSurface    = Color3.fromRGB(20,  20,  20),
	bgRaised     = Color3.fromRGB(28,  28,  28),
	bgHover      = Color3.fromRGB(35,  35,  35),
	bgPress      = Color3.fromRGB(40,  40,  40),
	sidebarBg    = Color3.fromRGB(20,  20,  20),
	sidebarLine  = Color3.fromRGB(28,  28,  28),
	tabActive    = Color3.fromRGB(28,  28,  28),
	tabInact     = Color3.fromRGB(20,  20,  20),
	tabHover     = Color3.fromRGB(24,  24,  24),
	accentBright = Color3.fromRGB(255, 255, 255),
	accentMid    = Color3.fromRGB(200, 200, 200),
	accentDim    = Color3.fromRGB(120, 120, 120),
	textBright   = Color3.fromRGB(255, 255, 255),
	textMid      = Color3.fromRGB(200, 200, 200),
	textSub      = Color3.fromRGB(150, 150, 150),
	textDim      = Color3.fromRGB(100, 100, 100),
	borderHard   = Color3.fromRGB(50,  50,  50),
	borderSoft   = Color3.fromRGB(40,  40,  40),
	borderFaint  = Color3.fromRGB(30,  30,  30),
	rowBg        = Color3.fromRGB(28,  28,  28),
	rowBgAlt     = Color3.fromRGB(24,  24,  24),
	titleBg      = Color3.fromRGB(28,  28,  28),
	dialogBg     = Color3.fromRGB(20,  20,  20),
	knob         = Color3.fromRGB(255, 255, 255),
	sliderFill   = Color3.fromRGB(200, 200, 200),
	sliderTrack  = Color3.fromRGB(28,  28,  28),
	dropBg       = Color3.fromRGB(28,  28,  28),
	dropItem     = Color3.fromRGB(28,  28,  28),
	dropItemSel  = Color3.fromRGB(35,  35,  35),
	checkOff     = Color3.fromRGB(28,  28,  28),
	profileBg    = Color3.fromRGB(20,  20,  20),
	profileLine  = Color3.fromRGB(40,  40,  40),
	black        = Color3.fromRGB(0,   0,   0),
	accentDark   = Color3.fromRGB(160, 160, 160),
}

-- ============================================================
--  TWEEN PRESETS
-- ============================================================
local FONT_REG  = Enum.Font.Code
local FONT_BOLD = Enum.Font.Code
local FONT_SCI  = Enum.Font.SciFi

local SNAP   = TweenInfo.new(0.08, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local FAST   = TweenInfo.new(0.15, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local MED    = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SLOW   = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SPRING = TweenInfo.new(0.30, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)

local ITEM_H = 20

-- ============================================================
--  HELPERS
-- ============================================================
local function tw(inst, goals, info)
	return TweenService:Create(inst, info or FAST, goals)
end
local function corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 0)
	c.Parent = inst; return c
end
local function stroke(inst, col, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color = col or C.borderHard
	s.Thickness = thick or 1
	s.Transparency = trans or 0
	s.Parent = inst; return s
end
local function gradient(inst, c0, c1, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c0, c1)
	g.Rotation = rot or 90
	g.Parent = inst; return g
end
local function gradientN(inst, stops, rot)
	local kps = {}
	for _, s in ipairs(stops) do
		table.insert(kps, ColorSequenceKeypoint.new(s[1], s[2]))
	end
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(kps)
	g.Rotation = rot or 90
	g.Parent = inst; return g
end

local function applyTextStroke(inst)
	inst.TextStrokeTransparency = 0
	Instance.new("UIStroke", inst).Color = Color3.new(0, 0, 0)
	Instance.new("UIStroke", inst).Thickness = 1
end

local function getTextBounds(text, font, size)
	return TextService:GetTextSize(text, size, font, Vector2.new(1920, 1080))
end

local function getDarkerColor(color)
	local h, s, v = Color3.toHSV(color)
	return Color3.fromHSV(h, s, v / 1.5)
end

-- ============================================================
--  ARG NORMALISER
-- ============================================================
local function normaliseDropArgs(a1, a2, a3, a4, a5, a6, a7, a8, a9)
	if type(a1) == "string" and type(a2) == "string" then
		return a1, a2, a3, a4, a5, a6, a7, a8, a9
	else
		return nil, a1, a2, a3, a4, a5, a6, a7, a8
	end
end

local function normalisePaired(a1,a2,a3,a4,a5,a6,a7,a8)
	if type(a1)=="string" and type(a2)=="string" and type(a3)=="string" then
		return a1,a2,a3,a4,a5,a6,a7,a8
	else
		return nil,nil,a1,a2,a3,a4,a5,a6
	end
end

-- ============================================================
--  ELEMENT OBJECT
-- ============================================================
local function newElementObj(defaultValue, callback)
	local obj   = {}
	obj.Value    = defaultValue
	obj.Callback = callback
	local _changed = nil

	function obj:OnChanged(fn)
		_changed = fn
		if fn then fn(self.Value) end
	end
	function obj:GetValue() return self.Value end
	function obj:_fire(v)
		self.Value = v
		if self.Callback then pcall(self.Callback, v) end
		if _changed      then pcall(_changed,      v) end
	end
	function obj:SetValue(v) self:_fire(v) end
	return obj
end

-- ============================================================
--  COLOR PICKER  (Linoria-style with HSV map + hue slider)
-- ============================================================
local PICKER_H = 253

local function buildColorPicker(parent, defColor, defOpacity, colorCb)
	defColor   = defColor   or Color3.fromRGB(200, 200, 200)
	defOpacity = defOpacity or 1.0

	local curH, curS, curV = defColor:ToHSV()
	local curOp = math.clamp(defOpacity, 0, 1)

	local pickerFrameOuter = Instance.new("Frame")
	pickerFrameOuter.Name = "Color"
	pickerFrameOuter.BackgroundColor3 = C.black
	pickerFrameOuter.BorderColor3 = C.black
	pickerFrameOuter.Size = UDim2.new(0, 230, 0, defOpacity and PICKER_H or 235)
	pickerFrameOuter.Visible = false
	pickerFrameOuter.ZIndex = 15
	pickerFrameOuter.Parent = parent

	local pickerFrameInner = Instance.new("Frame")
	pickerFrameInner.BackgroundColor3 = C.bgDeep
	pickerFrameInner.BorderColor3 = C.borderHard
	pickerFrameInner.BorderMode = Enum.BorderMode.Inset
	pickerFrameInner.Size = UDim2.new(1, 0, 1, 0)
	pickerFrameInner.ZIndex = 16
	pickerFrameInner.Parent = pickerFrameOuter

	-- Accent highlight bar
	local highlight = Instance.new("Frame")
	highlight.BackgroundColor3 = C.accentMid
	highlight.BorderSizePixel = 0
	highlight.Size = UDim2.new(1, 0, 0, 2)
	highlight.ZIndex = 17
	highlight.Parent = pickerFrameInner

	-- Sat/Val map
	local satVibMapOuter = Instance.new("Frame")
	satVibMapOuter.BorderColor3 = C.black
	satVibMapOuter.Position = UDim2.new(0, 4, 0, 25)
	satVibMapOuter.Size = UDim2.new(0, 200, 0, 200)
	satVibMapOuter.ZIndex = 17
	satVibMapOuter.Parent = pickerFrameInner

	local satVibMapInner = Instance.new("Frame")
	satVibMapInner.BackgroundColor3 = C.bgDeep
	satVibMapInner.BorderColor3 = C.borderHard
	satVibMapInner.BorderMode = Enum.BorderMode.Inset
	satVibMapInner.Size = UDim2.new(1, 0, 1, 0)
	satVibMapInner.ZIndex = 18
	satVibMapInner.Parent = satVibMapOuter

	local satVibMap = Instance.new("ImageLabel")
	satVibMap.BorderSizePixel = 0
	satVibMap.Size = UDim2.new(1, 0, 1, 0)
	satVibMap.ZIndex = 18
	satVibMap.Image = "rbxassetid://4155801252"
	satVibMap.Parent = satVibMapInner
	satVibMap.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)

	-- Cursor on sat/val map
	local cursorOuter = Instance.new("ImageLabel")
	cursorOuter.AnchorPoint = Vector2.new(0.5, 0.5)
	cursorOuter.Size = UDim2.new(0, 6, 0, 6)
	cursorOuter.BackgroundTransparency = 1
	cursorOuter.Image = "http://www.roblox.com/asset/?id=9619665977"
	cursorOuter.ImageColor3 = C.black
	cursorOuter.ZIndex = 19
	cursorOuter.Parent = satVibMap

	local cursorInner = Instance.new("ImageLabel")
	cursorInner.Size = UDim2.new(0, cursorOuter.Size.X.Offset - 2, 0, cursorOuter.Size.Y.Offset - 2)
	cursorInner.Position = UDim2.new(0, 1, 0, 1)
	cursorInner.BackgroundTransparency = 1
	cursorInner.Image = "http://www.roblox.com/asset/?id=9619665977"
	cursorInner.ImageColor3 = C.accentMid
	cursorInner.ZIndex = 20
	cursorInner.Parent = cursorOuter

	-- Hue selector
	local hueSelectorOuter = Instance.new("Frame")
	hueSelectorOuter.BorderColor3 = C.black
	hueSelectorOuter.Position = UDim2.new(0, 208, 0, 25)
	hueSelectorOuter.Size = UDim2.new(0, 15, 0, 200)
	hueSelectorOuter.ZIndex = 17
	hueSelectorOuter.Parent = pickerFrameInner

	local hueSelectorInner = Instance.new("Frame")
	hueSelectorInner.BackgroundColor3 = Color3.new(1, 1, 1)
	hueSelectorInner.BorderSizePixel = 0
	hueSelectorInner.Size = UDim2.new(1, 0, 1, 0)
	hueSelectorInner.ZIndex = 18
	hueSelectorInner.Parent = hueSelectorOuter

	local hueCursor = Instance.new("Frame")
	hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
	hueCursor.AnchorPoint = Vector2.new(0, 0.5)
	hueCursor.BorderColor3 = C.black
	hueCursor.Size = UDim2.new(1, 0, 0, 1)
	hueCursor.ZIndex = 18
	hueCursor.Parent = hueSelectorInner

	-- Hue gradient
	local sequenceTable = {}
	for hue = 0, 1, 0.1 do
		table.insert(sequenceTable, ColorSequenceKeypoint.new(hue, Color3.fromHSV(hue, 1, 1)))
	end
	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = ColorSequence.new(sequenceTable)
	hueGradient.Rotation = 90
	hueGradient.Parent = hueSelectorInner

	-- Hex input
	local hueBoxOuter = Instance.new("Frame")
	hueBoxOuter.BorderColor3 = C.black
	hueBoxOuter.Position = UDim2.fromOffset(4, 228)
	hueBoxOuter.Size = UDim2.new(0.5, -6, 0, 20)
	hueBoxOuter.ZIndex = 18
	hueBoxOuter.Parent = pickerFrameInner

	local hueBoxInner = Instance.new("Frame")
	hueBoxInner.BackgroundColor3 = C.bgRaised
	hueBoxInner.BorderColor3 = C.borderHard
	hueBoxInner.BorderMode = Enum.BorderMode.Inset
	hueBoxInner.Size = UDim2.new(1, 0, 1, 0)
	hueBoxInner.ZIndex = 18
	hueBoxInner.Parent = hueBoxOuter

	gradient(hueBoxInner, Color3.new(1, 1, 1), Color3.fromRGB(212, 212, 212), 90)

	local hueBox = Instance.new("TextBox")
	hueBox.BackgroundTransparency = 1
	hueBox.Position = UDim2.new(0, 5, 0, 0)
	hueBox.Size = UDim2.new(1, -5, 1, 0)
	hueBox.Font = FONT_REG
	hueBox.PlaceholderColor3 = Color3.fromRGB(190, 190, 190)
	hueBox.PlaceholderText = "Hex color"
	hueBox.Text = "#" .. defColor:ToHex()
	hueBox.TextColor3 = C.textBright
	hueBox.TextSize = 14
	hueBox.TextStrokeTransparency = 0
	hueBox.TextXAlignment = Enum.TextXAlignment.Left
	hueBox.ZIndex = 20
	hueBox.Parent = hueBoxInner
	applyTextStroke(hueBox)

	-- RGB input
	local rgbBoxBase = hueBoxOuter:Clone()
	rgbBoxBase.Position = UDim2.new(0.5, 2, 0, 228)
	rgbBoxBase.Parent = pickerFrameInner

	local rgbBox = rgbBoxBase.Frame:FindFirstChild("TextBox")
	rgbBox.Text = string.format("%d, %d, %d", math.floor(defColor.R * 255), math.floor(defColor.G * 255), math.floor(defColor.B * 255))
	rgbBox.PlaceholderText = "RGB color"

	-- Transparency slider (Linoria-style)
	local transparencyBoxOuter, transparencyBoxInner, transparencyCursor
	if defOpacity then
		transparencyBoxOuter = Instance.new("Frame")
		transparencyBoxOuter.BorderColor3 = C.black
		transparencyBoxOuter.Position = UDim2.fromOffset(4, 251)
		transparencyBoxOuter.Size = UDim2.new(1, -8, 0, 15)
		transparencyBoxOuter.ZIndex = 19
		transparencyBoxOuter.Parent = pickerFrameInner

		transparencyBoxInner = Instance.new("Frame")
		transparencyBoxInner.BackgroundColor3 = defColor
		transparencyBoxInner.BorderColor3 = C.borderHard
		transparencyBoxInner.BorderMode = Enum.BorderMode.Inset
		transparencyBoxInner.Size = UDim2.new(1, 0, 1, 0)
		transparencyBoxInner.ZIndex = 19
		transparencyBoxInner.Parent = transparencyBoxOuter

		local checkerBG = Instance.new("ImageLabel")
		checkerBG.BackgroundTransparency = 1
		checkerBG.Size = UDim2.new(1, 0, 1, 0)
		checkerBG.Image = "http://www.roblox.com/asset/?id=12978095818"
		checkerBG.ZIndex = 20
		checkerBG.Parent = transparencyBoxInner

		transparencyCursor = Instance.new("Frame")
		transparencyCursor.BackgroundColor3 = Color3.new(1, 1, 1)
		transparencyCursor.AnchorPoint = Vector2.new(0.5, 0)
		transparencyCursor.BorderColor3 = C.black
		transparencyCursor.Size = UDim2.new(0, 1, 1, 0)
		transparencyCursor.ZIndex = 21
		transparencyCursor.Parent = transparencyBoxInner
	end

	-- Title label
	local displayLabel = Instance.new("TextLabel")
	displayLabel.BackgroundTransparency = 1
	displayLabel.Font = FONT_REG
	displayLabel.TextColor3 = C.textBright
	displayLabel.TextSize = 14
	displayLabel.Size = UDim2.new(1, 0, 0, 14)
	displayLabel.Position = UDim2.fromOffset(5, 5)
	displayLabel.TextXAlignment = Enum.TextXAlignment.Left
	displayLabel.Text = "Color Picker"
	displayLabel.TextWrapped = false
	displayLabel.ZIndex = 16
	displayLabel.Parent = pickerFrameInner
	applyTextStroke(displayLabel)

	local function getColor()   return Color3.fromHSV(curH, curS, curV) end
	local function getOpacity() return curOp end

	local function refreshAll()
		local c = getColor()
		satVibMap.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
		cursorOuter.Position = UDim2.new(curS, 0, 1 - curV, 0)
		hueCursor.Position = UDim2.new(0, 0, curH, 0)
		if transparencyBoxInner then
			transparencyBoxInner.BackgroundColor3 = c
			transparencyCursor.Position = UDim2.new(1 - curOp, 0, 0, 0)
		end
		hueBox.Text = "#" .. c:ToHex()
		rgbBox.Text = string.format("%d, %d, %d", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
		if colorCb then colorCb(c, curOp) end
	end

	-- Input handlers
	local svDrag, hueDrag, opDrag = false, false, false

	satVibMap.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			svDrag = true
			while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				local minX = satVibMap.AbsolutePosition.X
				local maxX = minX + satVibMap.AbsoluteSize.X
				local mouseX = math.clamp(UIS:GetMouseLocation().X, minX, maxX)
				local minY = satVibMap.AbsolutePosition.Y
				local maxY = minY + satVibMap.AbsoluteSize.Y
				local mouseY = math.clamp(UIS:GetMouseLocation().Y, minY, maxY)
				curS = (mouseX - minX) / (maxX - minX)
				curV = 1 - ((mouseY - minY) / (maxY - minY))
				refreshAll()
				RunService.RenderStepped:Wait()
			end
			svDrag = false
		end
	end)

	hueSelectorInner.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			hueDrag = true
			while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				local minY = hueSelectorInner.AbsolutePosition.Y
				local maxY = minY + hueSelectorInner.AbsoluteSize.Y
				local mouseY = math.clamp(UIS:GetMouseLocation().Y, minY, maxY)
				curH = (mouseY - minY) / (maxY - minY)
				refreshAll()
				RunService.RenderStepped:Wait()
			end
			hueDrag = false
		end
	end)

	if transparencyBoxInner then
		transparencyBoxInner.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				opDrag = true
				while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local minX = transparencyBoxInner.AbsolutePosition.X
					local maxX = minX + transparencyBoxInner.AbsoluteSize.X
					local mouseX = math.clamp(UIS:GetMouseLocation().X, minX, maxX)
					curOp = 1 - ((mouseX - minX) / (maxX - minX))
					refreshAll()
					RunService.RenderStepped:Wait()
				end
				opDrag = false
			end
		end)
	end

	-- Hex input handler
	hueBox.FocusLost:Connect(function(enter)
		if enter then
			local success, result = pcall(Color3.fromHex, hueBox.Text)
			if success and typeof(result) == "Color3" then
				curH, curS, curV = result:ToHSV()
			end
		end
		refreshAll()
	end)

	-- RGB input handler
	rgbBox.FocusLost:Connect(function(enter)
		if enter then
			local r, g, b = rgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
			if r and g and b then
				curH, curS, curV = Color3.toHSV(Color3.fromRGB(r, g, b))
			end
		end
		refreshAll()
	end)

	local function setColorRaw(color, opacity)
		curH, curS, curV = color:ToHSV()
		curOp = math.clamp(opacity or curOp, 0, 1)
		refreshAll()
	end

	refreshAll()
	return pickerFrameOuter, getColor, getOpacity, setColorRaw
end

-- ============================================================
--  COLUMN OBJECT
-- ============================================================
local function makeColumnObj(sf, registry, openDD, winOptions)
	if not registry[sf] then registry[sf] = {} end

	local function regItem(frame, baseY)
		table.insert(registry[sf], {frame=frame, baseY=baseY, extra=0})
	end
	local function shiftBelow(afterY, delta, animate)
		if animate == nil then animate = true end
		for _, e in ipairs(registry[sf]) do
			if e.baseY > afterY then
				e.extra = e.extra + delta
				local tp = UDim2.new(e.frame.Position.X.Scale, e.frame.Position.X.Offset, 0, e.baseY + e.extra)
				if animate and delta ~= 0 then tw(e.frame, {Position=tp}, MED):Play() else e.frame.Position = tp end
			end
		end
		local maxY = 0
		for _, e in ipairs(registry[sf]) do
			local bot = e.baseY + e.extra + e.frame.AbsoluteSize.Y
			if bot > maxY then maxY = bot end
		end
		sf.CanvasSize = UDim2.new(0, 0, 0, maxY + 20)
	end

	local col = {_sf=sf, _y=8}
	function col:Finalise() self._sf.CanvasSize = UDim2.new(0, 0, 0, self._y + 20) end

	function col:Header(text)
		local posY = self._y
		local wrap = Instance.new("Frame")
		wrap.Size = UDim2.new(1,-10,0,18); wrap.Position = UDim2.new(0,5,0,posY)
		wrap.BackgroundTransparency = 1; wrap.Parent = sf; regItem(wrap, posY)
		local lbl = Instance.new("TextLabel")
		lbl.Text = string.upper(text); lbl.Font = FONT_BOLD; lbl.TextSize = 10
		lbl.TextColor3 = C.accentDim; lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1,0,0,14); lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 3; lbl.Parent = wrap
		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1,0,0,1); bar.Position = UDim2.new(0,0,0,16)
		bar.BackgroundColor3 = C.borderSoft; bar.BorderSizePixel = 0; bar.ZIndex = 3; bar.Parent = wrap
		do local g = Instance.new("UIGradient"); g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); g.Rotation = 0; g.Parent = bar end
		self._y = posY + 22; return self
	end

	function col:Separator()
		local posY = self._y
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1,-24,0,1); f.Position = UDim2.new(0,12,0,posY)
		f.BackgroundColor3 = C.borderFaint; f.BorderSizePixel = 0; f.ZIndex = 3; f.Parent = sf
		do local g = Instance.new("UIGradient"); g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,0.4)}); g.Rotation = 0; g.Parent = f end
		regItem(f, posY); self._y = posY + 9; return self
	end

	function col:Spacer(h) self._y = self._y + (h or 8); return self end

	function col:Label(text)
		local posY = self._y
		local wrap = Instance.new("Frame")
		wrap.Size = UDim2.new(1,-4,0,15); wrap.Position = UDim2.new(0,4,0,posY)
		wrap.BackgroundTransparency = 1; wrap.ZIndex = 3; wrap.Parent = sf; regItem(wrap, posY)
		local lbl = Instance.new("TextLabel")
		lbl.Text = text; lbl.Font = FONT_REG; lbl.TextSize = 14; lbl.TextColor3 = C.textSub
		lbl.BackgroundTransparency = 1; lbl.Size = UDim2.fromScale(1,1)
		lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 4; lbl.Parent = wrap
		applyTextStroke(lbl)
		self._y = posY + 17; return self
	end

	-- ============================================================
	--  TOGGLE / CHECKBOX  (Linoria-style design)
	-- ============================================================
	function col:Checkbox(a1, a2, a3, a4, a5, a6, a7, a8)
		local key, labelText, default, callback, doColorPicker, defColor, defOpacity, colorCb
		if type(a1) == "string" and type(a2) == "string" then
			key, labelText, default, callback, doColorPicker, defColor, defOpacity, colorCb = a1, a2, a3, a4, a5, a6, a7, a8
		else
			key, labelText, default, callback, doColorPicker, defColor, defOpacity, colorCb = nil, a1, a2, a3, a4, a5, a6, a7
		end

		local posY = self._y
		local cpOpen = false
		local function containerH() return 13 + (cpOpen and (PICKER_H + 2) or 0) end

		-- Toggle outer (black border) - Linoria style: small square toggle
		local toggleOuter = Instance.new("Frame")
		toggleOuter.BackgroundColor3 = C.black
		toggleOuter.BorderColor3 = C.black
		toggleOuter.Size = UDim2.new(0, 13, 0, 13)
		toggleOuter.ZIndex = 5
		toggleOuter.Parent = sf
		toggleOuter.Position = UDim2.new(0, 4, 0, posY)

		local toggleInner = Instance.new("Frame")
		toggleInner.BackgroundColor3 = default and C.accentMid or C.bgRaised
		toggleInner.BorderColor3 = default and C.accentDark or C.borderHard
		toggleInner.BorderMode = Enum.BorderMode.Inset
		toggleInner.Size = UDim2.new(1, 0, 1, 0)
		toggleInner.ZIndex = 6
		toggleInner.Parent = toggleOuter

		-- Toggle label
		local toggleLabel = Instance.new("TextLabel")
		toggleLabel.BackgroundTransparency = 1
		toggleLabel.Font = FONT_REG
		toggleLabel.TextColor3 = default and C.textBright or C.textMid
		toggleLabel.TextSize = 14
		toggleLabel.Text = labelText
		toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
		toggleLabel.Size = UDim2.new(0, 200, 1, 0)
		toggleLabel.Position = UDim2.new(1, 6, 0, 0)
		toggleLabel.ZIndex = 6
		toggleLabel.Parent = toggleInner
		applyTextStroke(toggleLabel)

		-- UIListLayout for addons (color picker button, etc.)
		local addonLayout = Instance.new("UIListLayout")
		addonLayout.Padding = UDim.new(0, 4)
		addonLayout.FillDirection = Enum.FillDirection.Horizontal
		addonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		addonLayout.SortOrder = Enum.SortOrder.LayoutOrder
		addonLayout.Parent = toggleLabel

		local toggleRegion = Instance.new("Frame")
		toggleRegion.BackgroundTransparency = 1
		toggleRegion.Size = UDim2.new(0, 170, 1, 0)
		toggleRegion.ZIndex = 8
		toggleRegion.Parent = toggleOuter

		regItem(toggleOuter, posY)

		local obj = newElementObj(default or false, callback)

		-- Color picker swatch button (Linoria-style)
		local swatchBtn, pickerPanel, setPickerRaw, cpObj
		if doColorPicker then
			defColor = defColor or Color3.fromRGB(200, 200, 200)
			defOpacity = defOpacity or 1.0

			swatchBtn = Instance.new("Frame")
			swatchBtn.BackgroundColor3 = defColor
			swatchBtn.BorderColor3 = getDarkerColor(defColor)
			swatchBtn.BorderMode = Enum.BorderMode.Inset
			swatchBtn.Size = UDim2.new(0, 28, 0, 14)
			swatchBtn.ZIndex = 6
			swatchBtn.Parent = toggleLabel

			-- Checkerboard for transparency preview
			local checkerFrame = Instance.new("ImageLabel")
			checkerFrame.BorderSizePixel = 0
			checkerFrame.Size = UDim2.new(0, 27, 0, 13)
			checkerFrame.ZIndex = 5
			checkerFrame.Image = "http://www.roblox.com/asset/?id=12977615774"
			checkerFrame.Visible = not not defOpacity
			checkerFrame.Parent = swatchBtn

			-- Color display overlay
			local colorOverlay = Instance.new("Frame")
			colorOverlay.BackgroundColor3 = defColor
			colorOverlay.BackgroundTransparency = 1 - math.clamp(defOpacity, 0, 1)
			colorOverlay.BorderSizePixel = 0
			colorOverlay.Size = UDim2.new(1, 0, 1, 0)
			colorOverlay.ZIndex = 7
			colorOverlay.Parent = swatchBtn

			pickerPanel, _, _, setPickerRaw = buildColorPicker(sf, defColor, defOpacity, function(c, op)
				if swatchBtn and colorOverlay then
					colorOverlay.BackgroundColor3 = c
					colorOverlay.BackgroundTransparency = 1 - math.clamp(op or 1, 0, 1)
					swatchBtn.BorderColor3 = getDarkerColor(c)
				end
				if cpObj then cpObj:_fire({Color=c, Opacity=op}) end
				if colorCb then colorCb(c, op) end
			end)
			pickerPanel.Position = UDim2.new(0, toggleOuter.AbsolutePosition.X - sf.AbsolutePosition.X, 0, 15)

			cpObj = newElementObj({Color=defColor, Opacity=defOpacity}, colorCb)
			function cpObj:SetValue(color, opacity)
				if setPickerRaw then setPickerRaw(color, opacity or 1) end
				self:_fire({Color=color, Opacity=opacity or 1})
			end
			if key and winOptions then winOptions[key.."_Color"] = cpObj end

			local function closeCP()
				cpOpen = false
				pickerPanel.Visible = false
				shiftBelow(posY, -(PICKER_H + 2), true)
			end
			local function openCP()
				cpOpen = true
				pickerPanel.Visible = true
				shiftBelow(posY, PICKER_H + 2, true)
			end
			swatchBtn.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					if cpOpen then closeCP() else openCP() end
				end
			end)
		end

		-- Toggle state logic
		local function applyState(v)
			if v then
				toggleInner.BackgroundColor3 = C.accentMid
				toggleInner.BorderColor3 = C.accentDark
				toggleLabel.TextColor3 = C.textBright
			else
				toggleInner.BackgroundColor3 = C.bgRaised
				toggleInner.BorderColor3 = C.borderHard
				toggleLabel.TextColor3 = C.textMid
			end
		end

		function obj:SetValue(v)
			v = not not v; applyState(v); self:_fire(v)
		end

		toggleRegion.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				obj:SetValue(not obj.Value)
			end
		end)

		if key and winOptions then winOptions[key] = obj end
		self._y = posY + 20
		return obj, self
	end

	-- ============================================================
	--  DROPDOWN  (Linoria-style)
	-- ============================================================
	function col:Dropdown(a1,a2,a3,a4,a5,a6,a7,a8,a9)
		local key, labelText, options, default, callback, doColorPicker, defColor, defOpacity, colorCb
			= normaliseDropArgs(a1,a2,a3,a4,a5,a6,a7,a8,a9)

		local posY = self._y; local COUNT = #options; local LIST_H = COUNT * ITEM_H
		local ddOpen = false; local cpOpen = false
		local function containerH() return 20 + (ddOpen and LIST_H or 0) + (cpOpen and (PICKER_H+2) or 0) end

		local selIdx = 1
		for i, v in ipairs(options) do if v == (default or options[1]) then selIdx = i end end
		local obj = newElementObj(options[selIdx], callback)

		-- Dropdown outer (black border) - Linoria style
		local dropdownOuter = Instance.new("Frame")
		dropdownOuter.BackgroundColor3 = C.black
		dropdownOuter.BorderColor3 = C.black
		dropdownOuter.Size = UDim2.new(1, -4, 0, 20)
		dropdownOuter.Position = UDim2.new(0, 2, 0, posY)
		dropdownOuter.ZIndex = 5
		dropdownOuter.Parent = sf

		local dropdownInner = Instance.new("Frame")
		dropdownInner.BackgroundColor3 = C.bgRaised
		dropdownInner.BorderColor3 = C.borderHard
		dropdownInner.BorderMode = Enum.BorderMode.Inset
		dropdownInner.Size = UDim2.new(1, 0, 1, 0)
		dropdownInner.ZIndex = 6
		dropdownInner.Parent = dropdownOuter

		gradient(dropdownInner, Color3.new(1, 1, 1), Color3.fromRGB(212, 212, 212), 90)

		-- Dropdown arrow
		local dropdownArrow = Instance.new("ImageLabel")
		dropdownArrow.AnchorPoint = Vector2.new(0, 0.5)
		dropdownArrow.BackgroundTransparency = 1
		dropdownArrow.Position = UDim2.new(1, -16, 0.5, 0)
		dropdownArrow.Size = UDim2.new(0, 12, 0, 12)
		dropdownArrow.Image = "http://www.roblox.com/asset/?id=6282522798"
		dropdownArrow.ZIndex = 8
		dropdownArrow.Parent = dropdownInner

		-- Selected item label
		local itemList = Instance.new("TextLabel")
		itemList.BackgroundTransparency = 1
		itemList.Font = FONT_REG
		itemList.TextColor3 = C.textMid
		itemList.TextSize = 14
		itemList.Position = UDim2.new(0, 5, 0, 0)
		itemList.Size = UDim2.new(1, -5, 1, 0)
		itemList.Text = options[selIdx]
		itemList.TextXAlignment = Enum.TextXAlignment.Left
		itemList.TextWrapped = true
		itemList.ZIndex = 7
		itemList.Parent = dropdownInner
		applyTextStroke(itemList)

		-- Color picker swatch (if enabled)
		local swatchBtn
		if doColorPicker then
			defColor = defColor or Color3.fromRGB(200,200,200); defOpacity = defOpacity or 1.0
			swatchBtn = Instance.new("Frame")
			swatchBtn.BackgroundColor3 = defColor
			swatchBtn.BorderColor3 = getDarkerColor(defColor)
			swatchBtn.BorderMode = Enum.BorderMode.Inset
			swatchBtn.Size = UDim2.new(0, 28, 0, 14)
			swatchBtn.ZIndex = 6
			swatchBtn.Parent = dropdownInner
			swatchBtn.Position = UDim2.new(1, -32, 0.5, -7)

			local checkerFrame = Instance.new("ImageLabel")
			checkerFrame.BorderSizePixel = 0
			checkerFrame.Size = UDim2.new(0, 27, 0, 13)
			checkerFrame.ZIndex = 5
			checkerFrame.Image = "http://www.roblox.com/asset/?id=12977615774"
			checkerFrame.Visible = not not defOpacity
			checkerFrame.Parent = swatchBtn

			local colorOverlay = Instance.new("Frame")
			colorOverlay.BackgroundColor3 = defColor
			colorOverlay.BackgroundTransparency = 1 - math.clamp(defOpacity, 0, 1)
			colorOverlay.BorderSizePixel = 0
			colorOverlay.Size = UDim2.new(1, 0, 1, 0)
			colorOverlay.ZIndex = 7
			colorOverlay.Parent = swatchBtn
		end

		regItem(dropdownOuter, posY)

		-- Dropdown list (positioned in ScreenGui for proper layering)
		local listOuter = Instance.new("Frame")
		listOuter.BackgroundColor3 = C.black
		listOuter.BorderColor3 = C.black
		listOuter.ZIndex = 20
		listOuter.Visible = false
		listOuter.Parent = sf

		local function updateListPosition()
			listOuter.Position = UDim2.fromOffset(dropdownOuter.AbsolutePosition.X - sf.AbsolutePosition.X, posY + 21)
			listOuter.Size = UDim2.fromOffset(dropdownOuter.AbsoluteSize.X, math.min(COUNT, 8) * ITEM_H + 2)
		end

		updateListPosition()
		dropdownOuter:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateListPosition)

		local listInner = Instance.new("Frame")
		listInner.BackgroundColor3 = C.bgRaised
		listInner.BorderColor3 = C.borderHard
		listInner.BorderMode = Enum.BorderMode.Inset
		listInner.Size = UDim2.new(1, 0, 1, 0)
		listInner.ZIndex = 21
		listInner.Parent = listOuter

		local scrolling = Instance.new("ScrollingFrame")
		scrolling.BackgroundTransparency = 1
		scrolling.BorderSizePixel = 0
		scrolling.CanvasSize = UDim2.new(0, 0, 0, COUNT * ITEM_H + 1)
		scrolling.Size = UDim2.new(1, 0, 1, 0)
		scrolling.ZIndex = 21
		scrolling.Parent = listInner
		scrolling.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		scrolling.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		scrolling.ScrollBarThickness = 3
		scrolling.ScrollBarImageColor3 = C.accentMid

		local listLayout = Instance.new("UIListLayout")
		listLayout.Padding = UDim.new(0, 0)
		listLayout.FillDirection = Enum.FillDirection.Vertical
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Parent = scrolling

		-- Build dropdown items
		local optHighlights = {}
		for i, optText in ipairs(options) do
			local optBtn = Instance.new("Frame")
			optBtn.BackgroundColor3 = C.bgRaised
			optBtn.BorderColor3 = C.borderHard
			optBtn.BorderMode = Enum.BorderMode.Middle
			optBtn.Size = UDim2.new(1, -1, 0, ITEM_H)
			optBtn.ZIndex = 23
			optBtn.Active = true
			optBtn.Parent = scrolling

			local optLbl = Instance.new("TextLabel")
			optLbl.BackgroundTransparency = 1
			optLbl.Font = FONT_REG
			optLbl.TextColor3 = (i==selIdx) and C.textBright or C.textMid
			optLbl.TextSize = 14
			optLbl.Active = false
			optLbl.Size = UDim2.new(1, -6, 1, 0)
			optLbl.Position = UDim2.new(0, 6, 0, 0)
			optLbl.Text = optText
			optLbl.TextXAlignment = Enum.TextXAlignment.Left
			optLbl.ZIndex = 25
			optLbl.Parent = optBtn
			applyTextStroke(optLbl)

			optHighlights[i] = {btn=optBtn, lbl=optLbl}

			optBtn.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					for j, h in ipairs(optHighlights) do
						h.lbl.TextColor3 = (j==i) and C.textBright or C.textMid
					end
					selIdx = i
					itemList.Text = optText
					listOuter.Visible = false
					ddOpen = false
					obj:_fire(optText)
					if obj.Callback then pcall(obj.Callback, optText, i) end
				end
			end)

			-- Hover effects
			optBtn.MouseEnter:Connect(function()
				if i ~= selIdx then
					optLbl.TextColor3 = C.textBright
				end
			end)
			optBtn.MouseLeave:Connect(function()
				if i ~= selIdx then
					optLbl.TextColor3 = C.textMid
				end
			end)
		end

		-- Open/close dropdown
		local function closeDD()
			ddOpen = false
			listOuter.Visible = false
			dropdownArrow.Rotation = 0
		end
		local function openDD()
			if openDD.fn then openDD.fn() end
			ddOpen = true
			openDD.fn = closeDD
			listOuter.Visible = true
			dropdownArrow.Rotation = 180
		end

		dropdownOuter.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				if ddOpen then closeDD() else openDD() end
			end
		end)

		-- Close when clicking outside
		UIS.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 and ddOpen then
				local absPos, absSize = listOuter.AbsolutePosition, listOuter.AbsoluteSize
				local mousePos = UIS:GetMouseLocation()
				if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X
					or mousePos.Y < absPos.Y - 20 - 1 or mousePos.Y > absPos.Y + absSize.Y then
					closeDD()
				end
			end
		end)

		function obj:SetValue(v)
			for i, optText in ipairs(options) do
				if optText == v then
					selIdx = i
					itemList.Text = v
					for j, h in ipairs(optHighlights) do
						h.lbl.TextColor3 = (j==i) and C.textBright or C.textMid
					end
					self:_fire(v)
					return
				end
			end
		end

		-- Hover highlight on dropdown
		dropdownOuter.MouseEnter:Connect(function()
			if not ddOpen then
				dropdownOuter.BorderColor3 = C.accentMid
			end
		end)
		dropdownOuter.MouseLeave:Connect(function()
			if not ddOpen then
				dropdownOuter.BorderColor3 = C.black
			end
		end)

		if key and winOptions then winOptions[key] = obj end
		self._y = posY + 26
		return obj, self
	end

	-- ============================================================
	--  SLIDER  (Linoria-style)
	-- ============================================================
	function col:Slider(a1,a2,a3,a4,a5,a6)
		local key, labelText, minVal, maxVal, default, callback
		if type(a1) == "string" and type(a2) == "string" then
			key, labelText, minVal, maxVal, default, callback = a1, a2, a3, a4, a5, a6
		else
			key, labelText, minVal, maxVal, default, callback = nil, a1, a2, a3, a4, a5
		end

		local posY = self._y
		local obj = newElementObj(default, callback)

		-- Label (Linoria-style: above slider, smaller)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Font = FONT_REG
		label.TextColor3 = C.textMid
		label.TextSize = 14
		label.Size = UDim2.new(1, 0, 0, 10)
		label.Text = labelText
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Bottom
		label.ZIndex = 5
		label.Position = UDim2.new(0, 2, 0, posY)
		label.Parent = sf
		applyTextStroke(label)
		regItem(label, posY)

		-- Slider outer (black border)
		local sliderOuter = Instance.new("Frame")
		sliderOuter.BackgroundColor3 = C.black
		sliderOuter.BorderColor3 = C.black
		sliderOuter.Size = UDim2.new(1, -4, 0, 13)
		sliderOuter.Position = UDim2.new(0, 2, 0, posY + 14)
		sliderOuter.ZIndex = 5
		sliderOuter.Parent = sf

		local sliderInner = Instance.new("Frame")
		sliderInner.BackgroundColor3 = C.bgRaised
		sliderInner.BorderColor3 = C.borderHard
		sliderInner.BorderMode = Enum.BorderMode.Inset
		sliderInner.Size = UDim2.new(1, 0, 1, 0)
		sliderInner.ZIndex = 6
		sliderInner.Parent = sliderOuter

		local maxSize = sliderInner.AbsoluteSize.X

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = C.accentMid
		fill.BorderColor3 = C.accentDark
		local pct = (default - minVal) / math.max(maxVal - minVal, 1)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		fill.ZIndex = 7
		fill.Parent = sliderInner

		-- Hide right border of fill when at max
		local hideBorderRight = Instance.new("Frame")
		hideBorderRight.BackgroundColor3 = C.accentMid
		hideBorderRight.BorderSizePixel = 0
		hideBorderRight.Position = UDim2.new(1, 0, 0, 0)
		hideBorderRight.Size = UDim2.new(0, 1, 1, 0)
		hideBorderRight.ZIndex = 8
		hideBorderRight.Parent = fill

		-- Display value label
		local displayLabel = Instance.new("TextLabel")
		displayLabel.BackgroundTransparency = 1
		displayLabel.Font = FONT_REG
		displayLabel.TextColor3 = C.textBright
		displayLabel.TextSize = 14
		displayLabel.Size = UDim2.new(1, 0, 1, 0)
		displayLabel.Text = string.format("%s/%s", default, maxVal)
		displayLabel.ZIndex = 9
		displayLabel.Parent = sliderInner
		applyTextStroke(displayLabel)

		regItem(sliderOuter, posY + 14)

		local function applyValue(v)
			v = math.clamp(v, minVal, maxVal)
			local p = (v - minVal) / math.max(maxVal - minVal, 1)
			local x = math.ceil(p * maxSize)
			fill.Size = UDim2.new(0, x, 1, 0)
			hideBorderRight.Visible = not (x == maxSize or x == 0)
			displayLabel.Text = string.format("%s/%s", v, maxVal)
			obj:_fire(v)
		end

		function obj:SetValue(v)
			applyValue(v)
		end

		-- Dragging logic (Linoria-style: click anywhere on slider)
		sliderInner.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				local mPos = UIS:GetMouseLocation().X
				local gPos = fill.Size.X.Offset
				local diff = mPos - (fill.AbsolutePosition.X + gPos)

				while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local nMPos = UIS:GetMouseLocation().X
					local nX = math.clamp(gPos + (nMPos - mPos) + diff, 0, maxSize)
					local nValue = math.floor(((nX / maxSize) * (maxVal - minVal)) + minVal + 0.5)
					if nValue ~= obj.Value then
						applyValue(nValue)
					end
					RunService.RenderStepped:Wait()
				end
			end
		end)

		-- Hover highlight
		sliderOuter.MouseEnter:Connect(function()
			sliderOuter.BorderColor3 = C.accentMid
		end)
		sliderOuter.MouseLeave:Connect(function()
			sliderOuter.BorderColor3 = C.black
		end)

		if key and winOptions then winOptions[key] = obj end
		self._y = posY + 33
		return obj, self
	end

	-- ============================================================
	--  KEYBIND  (Linoria-style key picker)
	-- ============================================================
	function col:Keybind(a1,a2,a3,a4)
		local key, labelText, defaultKey, callback
		if type(a4) == "function" or (type(a3) == "function" and type(a2) == "string" and type(a1) == "string") then
			key, labelText, defaultKey, callback = a1, a2, a3, a4
		elseif type(a3) == "function" or a3 == nil then
			key, labelText, defaultKey, callback = nil, a1, a2, a3
		else
			key, labelText, defaultKey, callback = a1, a2, a3, a4
		end

		local posY = self._y
		local obj = newElementObj(defaultKey or "None", callback)

		-- Label
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Font = FONT_REG
		label.TextColor3 = C.textMid
		label.TextSize = 14
		label.Size = UDim2.new(1, 0, 0, 15)
		label.Text = labelText
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 5
		label.Position = UDim2.new(0, 2, 0, posY)
		label.Parent = sf
		applyTextStroke(label)
		regItem(label, posY)

		-- Key picker outer (black border)
		local pickOuter = Instance.new("Frame")
		pickOuter.BackgroundColor3 = C.black
		pickOuter.BorderColor3 = C.black
		pickOuter.Size = UDim2.new(0, 28, 0, 15)
		pickOuter.Position = UDim2.new(0, 2, 0, posY + 17)
		pickOuter.ZIndex = 6
		pickOuter.Parent = sf

		local pickInner = Instance.new("Frame")
		pickInner.BackgroundColor3 = C.bgDeep
		pickInner.BorderColor3 = C.borderHard
		pickInner.BorderMode = Enum.BorderMode.Inset
		pickInner.Size = UDim2.new(1, 0, 1, 0)
		pickInner.ZIndex = 7
		pickInner.Parent = pickOuter

		local displayLabel = Instance.new("TextLabel")
		displayLabel.BackgroundTransparency = 1
		displayLabel.Font = FONT_REG
		displayLabel.TextColor3 = C.textMid
		displayLabel.TextSize = 13
		displayLabel.Size = UDim2.new(1, 0, 1, 0)
		displayLabel.Text = obj.Value
		displayLabel.TextWrapped = true
		displayLabel.ZIndex = 8
		displayLabel.Parent = pickInner
		applyTextStroke(displayLabel)

		regItem(pickOuter, posY + 17)

		local picking = false

		function obj:SetValue(k)
			k = k or "None"
			displayLabel.Text = k
			self:_fire(k)
		end

		pickOuter.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				picking = true
				displayLabel.Text = ""

				-- Animated dots
				local breakLoop = false
				local text = ""
				task.spawn(function()
					while not breakLoop do
						if text == "..." then text = "" end
						text = text .. "."
						displayLabel.Text = text
						task.wait(0.4)
					end
				end)

				task.wait(0.2)

				local event
				event = UIS.InputBegan:Connect(function(input, gp)
					if gp then return end
					local k
					if input.UserInputType == Enum.UserInputType.Keyboard then
						k = input.KeyCode.Name
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
						k = "MB1"
					elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
						k = "MB2"
					end
					if k then
						breakLoop = true
						picking = false
						displayLabel.Text = k
						obj.Value = k
						event:Disconnect()
						self:_fire(k)
					end
				end)
			end
		end)

		-- Hover highlight
		pickOuter.MouseEnter:Connect(function()
			pickOuter.BorderColor3 = C.accentMid
		end)
		pickOuter.MouseLeave:Connect(function()
			pickOuter.BorderColor3 = C.black
		end)

		if key and winOptions then winOptions[key] = obj end
		self._y = posY + 38
		return obj, self
	end

	-- ============================================================
	--  BUTTON  (Linoria-style)
	-- ============================================================
	function col:Button(text, callback)
		local posY = self._y

		local buttonOuter = Instance.new("Frame")
		buttonOuter.BackgroundColor3 = C.black
		buttonOuter.BorderColor3 = C.black
		buttonOuter.Size = UDim2.new(1, -4, 0, 20)
		buttonOuter.Position = UDim2.new(0, 2, 0, posY)
		buttonOuter.ZIndex = 5
		buttonOuter.Parent = sf

		local buttonInner = Instance.new("Frame")
		buttonInner.BackgroundColor3 = C.bgRaised
		buttonInner.BorderColor3 = C.borderHard
		buttonInner.BorderMode = Enum.BorderMode.Inset
		buttonInner.Size = UDim2.new(1, 0, 1, 0)
		buttonInner.ZIndex = 6
		buttonInner.Parent = buttonOuter

		gradient(buttonInner, Color3.new(1, 1, 1), Color3.fromRGB(212, 212, 212), 90)

		local buttonLabel = Instance.new("TextLabel")
		buttonLabel.BackgroundTransparency = 1
		buttonLabel.Font = FONT_REG
		buttonLabel.TextColor3 = C.textBright
		buttonLabel.TextSize = 14
		buttonLabel.Size = UDim2.new(1, 0, 1, 0)
		buttonLabel.Text = text
		buttonLabel.ZIndex = 6
		buttonLabel.Parent = buttonInner
		applyTextStroke(buttonLabel)

		regItem(buttonOuter, posY)

		-- Hover highlight
		buttonOuter.MouseEnter:Connect(function()
			buttonOuter.BorderColor3 = C.accentMid
		end)
		buttonOuter.MouseLeave:Connect(function()
			buttonOuter.BorderColor3 = C.black
		end)

		-- Click handler
		buttonOuter.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				if callback then pcall(callback) end
			end
		end)

		self._y = posY + 26
		return self
	end

	-- ============================================================
	--  INPUT / TEXTBOX  (Linoria-style)
	-- ============================================================
	function col:Input(a1, a2, a3, a4, a5)
		local key, labelText, default, placeholder, callback
		if type(a1) == "string" and type(a2) == "string" then
			key, labelText, default, placeholder, callback = a1, a2, a3, a4, a5
		else
			key, labelText, default, placeholder, callback = nil, a1, a2, a3, a4
		end

		local posY = self._y
		local obj = newElementObj(default or "", callback)

		-- Label
		local inputLabel = Instance.new("TextLabel")
		inputLabel.BackgroundTransparency = 1
		inputLabel.Font = FONT_REG
		inputLabel.TextColor3 = C.textMid
		inputLabel.TextSize = 14
		inputLabel.Size = UDim2.new(1, 0, 0, 15)
		inputLabel.Text = labelText
		inputLabel.TextXAlignment = Enum.TextXAlignment.Left
		inputLabel.ZIndex = 5
		inputLabel.Position = UDim2.new(0, 2, 0, posY)
		inputLabel.Parent = sf
		applyTextStroke(inputLabel)
		regItem(inputLabel, posY)

		-- Textbox outer (black border)
		local textBoxOuter = Instance.new("Frame")
		textBoxOuter.BackgroundColor3 = C.black
		textBoxOuter.BorderColor3 = C.black
		textBoxOuter.Size = UDim2.new(1, -4, 0, 20)
		textBoxOuter.Position = UDim2.new(0, 2, 0, posY + 16)
		textBoxOuter.ZIndex = 5
		textBoxOuter.Parent = sf

		local textBoxInner = Instance.new("Frame")
		textBoxInner.BackgroundColor3 = C.bgRaised
		textBoxInner.BorderColor3 = C.borderHard
		textBoxInner.BorderMode = Enum.BorderMode.Inset
		textBoxInner.Size = UDim2.new(1, 0, 1, 0)
		textBoxInner.ZIndex = 6
		textBoxInner.Parent = textBoxOuter

		gradient(textBoxInner, Color3.new(1, 1, 1), Color3.fromRGB(212, 212, 212), 90)

		-- Clipping container
		local clipContainer = Instance.new("Frame")
		clipContainer.BackgroundTransparency = 1
		clipContainer.ClipsDescendants = true
		clipContainer.Position = UDim2.new(0, 5, 0, 0)
		clipContainer.Size = UDim2.new(1, -5, 1, 0)
		clipContainer.ZIndex = 7
		clipContainer.Parent = textBoxInner

		local box = Instance.new("TextBox")
		box.BackgroundTransparency = 1
		box.Position = UDim2.fromOffset(0, 0)
		box.Size = UDim2.fromScale(5, 1)
		box.Font = FONT_REG
		box.PlaceholderColor3 = Color3.fromRGB(190, 190, 190)
		box.PlaceholderText = placeholder or ""
		box.Text = default or ""
		box.TextColor3 = C.textBright
		box.TextSize = 14
		box.TextStrokeTransparency = 0
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.ZIndex = 7
		box.Parent = clipContainer
		applyTextStroke(box)

		regItem(textBoxOuter, posY + 16)

		-- Text update
		box:GetPropertyChangedSignal("Text"):Connect(function()
			obj:_fire(box.Text)
		end)

		function obj:SetValue(text)
			box.Text = text or ""
			self:_fire(box.Text)
		end

		-- Hover highlight
		textBoxOuter.MouseEnter:Connect(function()
			textBoxOuter.BorderColor3 = C.accentMid
		end)
		textBoxOuter.MouseLeave:Connect(function()
			textBoxOuter.BorderColor3 = C.black
		end)

		if key and winOptions then winOptions[key] = obj end
		self._y = posY + 41
		return obj, self
	end

	-- ============================================================
	--  DIVIDER  (Linoria-style)
	-- ============================================================
	function col:Divider()
		local posY = self._y

		local dividerOuter = Instance.new("Frame")
		dividerOuter.BackgroundColor3 = C.black
		dividerOuter.BorderColor3 = C.black
		dividerOuter.Size = UDim2.new(1, -4, 0, 5)
		dividerOuter.Position = UDim2.new(0, 2, 0, posY)
		dividerOuter.ZIndex = 5
		dividerOuter.Parent = sf

		local dividerInner = Instance.new("Frame")
		dividerInner.BackgroundColor3 = C.bgRaised
		dividerInner.BorderColor3 = C.borderHard
		dividerInner.BorderMode = Enum.BorderMode.Inset
		dividerInner.Size = UDim2.new(1, 0, 1, 0)
		dividerInner.ZIndex = 6
		dividerInner.Parent = dividerOuter

		regItem(dividerOuter, posY)
		self._y = posY + 10
		return self
	end

	-- ============================================================
	--  PAIRED CHECKBOX  (Linoria-style)
	-- ============================================================
	function col:PairedCheckbox(a1,a2,a3,a4,a5,a6,a7,a8)
		local keyL, keyR, lL, dL, lR, dR, cbL, cbR = normalisePaired(a1,a2,a3,a4,a5,a6,a7,a8)
		local posY = self._y
		local objL = newElementObj(dL or false, cbL)
		local objR = newElementObj(dR or false, cbR)

		local function makeMini(text, xOff, obj)
			local toggleOuter = Instance.new("Frame")
			toggleOuter.BackgroundColor3 = C.black
			toggleOuter.BorderColor3 = C.black
			toggleOuter.Size = UDim2.new(0, 13, 0, 13)
			toggleOuter.Position = UDim2.new(0, 4 + xOff, 0, posY)
			toggleOuter.ZIndex = 5
			toggleOuter.Parent = sf

			local toggleInner = Instance.new("Frame")
			toggleInner.BackgroundColor3 = obj.Value and C.accentMid or C.bgRaised
			toggleInner.BorderColor3 = obj.Value and C.accentDark or C.borderHard
			toggleInner.BorderMode = Enum.BorderMode.Inset
			toggleInner.Size = UDim2.new(1, 0, 1, 0)
			toggleInner.ZIndex = 6
			toggleInner.Parent = toggleOuter

			local toggleLabel = Instance.new("TextLabel")
			toggleLabel.BackgroundTransparency = 1
			toggleLabel.Font = FONT_REG
			toggleLabel.TextColor3 = obj.Value and C.textBright or C.textMid
			toggleLabel.TextSize = 14
			toggleLabel.Size = UDim2.new(0, 100, 1, 0)
			toggleLabel.Position = UDim2.new(1, 6, 0, 0)
			toggleLabel.Text = text
			toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
			toggleLabel.ZIndex = 6
			toggleLabel.Parent = toggleInner
			applyTextStroke(toggleLabel)

			local toggleRegion = Instance.new("Frame")
			toggleRegion.BackgroundTransparency = 1
			toggleRegion.Size = UDim2.new(0, 80, 1, 0)
			toggleRegion.ZIndex = 8
			toggleRegion.Parent = toggleOuter

			regItem(toggleOuter, posY)

			function obj:SetValue(v)
				v = not not v
				toggleInner.BackgroundColor3 = v and C.accentMid or C.bgRaised
				toggleInner.BorderColor3 = v and C.accentDark or C.borderHard
				toggleLabel.TextColor3 = v and C.textBright or C.textMid
				self:_fire(v)
			end

			toggleRegion.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					obj:SetValue(not obj.Value)
				end
			end)
		end

		makeMini(lL, 0, objL)
		makeMini(lR, 120, objR)

		if keyL and winOptions then winOptions[keyL] = objL end
		if keyR and winOptions then winOptions[keyR] = objR end
		self._y = posY + 20
		return objL, objR, self
	end

	-- ============================================================
	--  EXPANDABLE CHECKBOX  (Linoria-style with collapsible section)
	-- ============================================================
	function col:ExpandableCheckbox(a1,a2,a3,a4,a5)
		local key, labelText, default, callback, subBuilder
		if type(a1) == "string" and type(a2) == "string" then
			key, labelText, default, callback, subBuilder = a1, a2, a3, a4, a5
		else
			key, labelText, default, callback, subBuilder = nil, a1, a2, a3, a4
		end

		local posY = self._y
		local obj = newElementObj(default or false, callback)

		-- Toggle outer (black border)
		local toggleOuter = Instance.new("Frame")
		toggleOuter.BackgroundColor3 = C.black
		toggleOuter.BorderColor3 = C.black
		toggleOuter.Size = UDim2.new(0, 13, 0, 13)
		toggleOuter.Position = UDim2.new(0, 4, 0, posY)
		toggleOuter.ZIndex = 5
		toggleOuter.Parent = sf

		local toggleInner = Instance.new("Frame")
		toggleInner.BackgroundColor3 = default and C.accentMid or C.bgRaised
		toggleInner.BorderColor3 = default and C.accentDark or C.borderHard
		toggleInner.BorderMode = Enum.BorderMode.Inset
		toggleInner.Size = UDim2.new(1, 0, 1, 0)
		toggleInner.ZIndex = 6
		toggleInner.Parent = toggleOuter

		local toggleLabel = Instance.new("TextLabel")
		toggleLabel.BackgroundTransparency = 1
		toggleLabel.Font = FONT_REG
		toggleLabel.TextColor3 = default and C.textBright or C.textMid
		toggleLabel.TextSize = 14
		toggleLabel.Size = UDim2.new(0, 200, 1, 0)
		toggleLabel.Position = UDim2.new(1, 6, 0, 0)
		toggleLabel.Text = labelText
		toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
		toggleLabel.ZIndex = 6
		toggleLabel.Parent = toggleInner
		applyTextStroke(toggleLabel)

		local toggleRegion = Instance.new("Frame")
		toggleRegion.BackgroundTransparency = 1
		toggleRegion.Size = UDim2.new(0, 170, 1, 0)
		toggleRegion.ZIndex = 8
		toggleRegion.Parent = toggleOuter

		regItem(toggleOuter, posY)

		-- Sub panel
		local subPanel = Instance.new("Frame")
		subPanel.BackgroundColor3 = C.bgDeep
		subPanel.BorderColor3 = C.borderHard
		subPanel.BorderMode = Enum.BorderMode.Inset
		subPanel.Size = UDim2.new(1, -4, 0, 0)
		subPanel.Position = UDim2.new(0, 2, 0, posY + 16)
		subPanel.ClipsDescendants = true
		subPanel.Visible = false
		subPanel.ZIndex = 3
		subPanel.Parent = sf

		local subSF = Instance.new("ScrollingFrame")
		subSF.BackgroundTransparency = 1
		subSF.BorderSizePixel = 0
		subSF.Size = UDim2.fromScale(1, 1)
		subSF.ScrollBarThickness = 2
		subSF.ScrollBarImageColor3 = C.accentDim
		subSF.CanvasSize = UDim2.new(0, 0, 0, 2000)
		subSF.ZIndex = 2
		subSF.Parent = subPanel

		regItem(subPanel, posY + 16)

		local subReg = {}
		local subColObj = makeColumnObj(subSF, subReg, openDD, winOptions)
		if subBuilder then subBuilder(subColObj) end
		subColObj:Finalise()
		local subH = math.min(subColObj._y + 8, 220)
		subSF.CanvasSize = UDim2.new(0, 0, 0, subColObj._y + 8)

		local expanded = false
		local function openSub()
			expanded = true
			subPanel.Visible = true
			subPanel.Size = UDim2.new(1, -4, 0, 0)
			tw(subPanel, {Size=UDim2.new(1, -4, 0, subH)}, SPRING):Play()
			shiftBelow(posY + 16, subH + 2)
		end
		local function closeSub()
			expanded = false
			tw(subPanel, {Size=UDim2.new(1, -4, 0, 0)}, MED):Play()
			task.delay(0.26, function() subPanel.Visible = false end)
			shiftBelow(posY + 16, -(subH + 2))
		end

		local function applyState(v)
			if v then
				toggleInner.BackgroundColor3 = C.accentMid
				toggleInner.BorderColor3 = C.accentDark
				toggleLabel.TextColor3 = C.textBright
			else
				toggleInner.BackgroundColor3 = C.bgRaised
				toggleInner.BorderColor3 = C.borderHard
				toggleLabel.TextColor3 = C.textMid
			end
		end

		function obj:SetValue(v)
			v = not not v
			applyState(v)
			if v and not expanded then openSub() elseif not v and expanded then closeSub() end
			self:_fire(v)
		end

		toggleRegion.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				obj:SetValue(not obj.Value)
			end
		end)

		if key and winOptions then winOptions[key] = obj end
		self._y = posY + 22
		return obj, self
	end

	return col
end

-- ============================================================
--  TAB OBJECT FACTORY
-- ============================================================
local function makeTabObj(panel, registry, openDD, winOptions)
	local tabObj = {}
	local function makeScrollCol(size, pos)
		local sf = Instance.new("ScrollingFrame")
		sf.Size = size; sf.Position = pos or UDim2.new(0,0,0,0)
		sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0
		sf.ScrollBarThickness = 0
		sf.CanvasSize = UDim2.new(0,0,0,2000); sf.ZIndex = 2; sf.Parent = panel
		return sf
	end
	function tabObj:TwoColumn()
		local lSF = makeScrollCol(UDim2.new(0.5, -12 + 2, 1, 0), UDim2.new(0, 8 - 1, 0, 8 - 1))
		local rSF = makeScrollCol(UDim2.new(0.5, -12 + 2, 1, 0), UDim2.new(0.5, 4 + 1, 0, 8 - 1))
		return makeColumnObj(lSF, registry, openDD, winOptions),
		makeColumnObj(rSF, registry, openDD, winOptions)
	end
	function tabObj:SingleColumn()
		local sf = makeScrollCol(UDim2.fromScale(1, 1))
		return makeColumnObj(sf, registry, openDD, winOptions)
	end
	return tabObj
end

-- ============================================================
--  PUBLIC API
-- ============================================================
local OnyxiteLib = {}

function OnyxiteLib.new(config)
	local win = {}; win._tabPanels = {}; win._tabButtons = {}; win._activeTab = nil; win.Options = {}
	local registry = {}; local openDD = {fn=nil}

	local WIN_W      = config.Width  or 550
	local WIN_H      = config.Height or 600
	local BORDER     = 1
	local TITLEBAR_H = 25
	local SIDEBAR_W  = 0  -- No sidebar in Linoria style
	local TAB_AREA_H = 30

	local player    = Players.LocalPlayer
	local guiParent = player:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui"); gui.Name = "OnyxiteGUI"; gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = guiParent

	-- Main window outer (black border)
	local outerFrame = Instance.new("Frame"); outerFrame.Name = "WindowFrame"
	outerFrame.BackgroundColor3 = C.black
	outerFrame.BorderSizePixel = 0
	outerFrame.Size = UDim2.new(0, WIN_W, 0, WIN_H)
	outerFrame.Position = config.Position or UDim2.fromOffset(175, 50)
	outerFrame.ZIndex = 1
	outerFrame.Parent = gui

	-- Inner frame (main color)
	local innerFrame = Instance.new("Frame")
	innerFrame.BackgroundColor3 = C.bgRaised
	innerFrame.BorderColor3 = C.accentMid
	innerFrame.BorderMode = Enum.BorderMode.Inset
	innerFrame.Position = UDim2.new(0, 1, 0, 1)
	innerFrame.Size = UDim2.new(1, -2, 1, -2)
	innerFrame.ZIndex = 1
	innerFrame.Parent = outerFrame

	-- Window title
	local windowLabel = Instance.new("TextLabel")
	windowLabel.BackgroundTransparency = 1
	windowLabel.Font = FONT_REG
	windowLabel.TextColor3 = C.textBright
	windowLabel.TextSize = 16
	windowLabel.Position = UDim2.new(0, 7, 0, 0)
	windowLabel.Size = UDim2.new(0, 0, 0, TITLEBAR_H)
	windowLabel.Text = config.Title or "Onyxite"
	windowLabel.TextXAlignment = Enum.TextXAlignment.Left
	windowLabel.ZIndex = 1
	windowLabel.Parent = innerFrame
	applyTextStroke(windowLabel)

	-- Main section outer (background color)
	local mainSectionOuter = Instance.new("Frame")
	mainSectionOuter.BackgroundColor3 = C.bgDeep
	mainSectionOuter.BorderColor3 = C.borderHard
	mainSectionOuter.Position = UDim2.new(0, 8, 0, TITLEBAR_H)
	mainSectionOuter.Size = UDim2.new(1, -16, 1, -TITLEBAR_H - 8)
	mainSectionOuter.ZIndex = 1
	mainSectionOuter.Parent = innerFrame

	local mainSectionInner = Instance.new("Frame")
	mainSectionInner.BackgroundColor3 = C.bgDeep
	mainSectionInner.BorderColor3 = C.black
	mainSectionInner.BorderMode = Enum.BorderMode.Inset
	mainSectionInner.Size = UDim2.new(1, 0, 1, 0)
	mainSectionInner.ZIndex = 1
	mainSectionInner.Parent = mainSectionOuter

	-- Tab area
	local tabArea = Instance.new("Frame")
	tabArea.BackgroundTransparency = 1
	tabArea.Position = UDim2.new(0, 8, 0, 8)
	tabArea.Size = UDim2.new(1, -16, 0, 21)
	tabArea.ZIndex = 1
	tabArea.Parent = mainSectionInner

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.Padding = UDim.new(0, config.TabPadding or 0)
	tabListLayout.FillDirection = Enum.FillDirection.Horizontal
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Parent = tabArea

	-- Tab container
	local tabContainer = Instance.new("Frame")
	tabContainer.BackgroundColor3 = C.bgRaised
	tabContainer.BorderColor3 = C.borderHard
	tabContainer.Position = UDim2.new(0, 8, 0, TAB_AREA_H)
	tabContainer.Size = UDim2.new(1, -16, 1, -TAB_AREA_H - 8)
	tabContainer.ZIndex = 2
	tabContainer.Parent = mainSectionInner

	-- Dragging
	OnixiteLib.MakeDraggable(outerFrame, TITLEBAR_H)

	-- Expose internal frames
	win._outerFrame = outerFrame
	win._gui = gui

	local tabDefs = config.Tabs or {}
	if #tabDefs > 0 then win._activeTab = tabDefs[1].Name end

	for i, def in ipairs(tabDefs) do
		-- Tab button (Linoria-style tab buttons)
		local tabButtonWidth = getTextBounds(def.Name, FONT_REG, 16)

		local tabButton = Instance.new("Frame")
		tabButton.BackgroundColor3 = (def.Name == win._activeTab) and C.bgRaised or C.bgDeep
		tabButton.BorderColor3 = C.borderHard
		tabButton.Size = UDim2.new(0, tabButtonWidth + 12, 1, 0)
		tabButton.ZIndex = 1
		tabButton.Parent = tabArea

		local tabButtonLabel = Instance.new("TextLabel")
		tabButtonLabel.BackgroundTransparency = 1
		tabButtonLabel.Font = FONT_REG
		tabButtonLabel.TextColor3 = (def.Name == win._activeTab) and C.textBright or C.textMid
		tabButtonLabel.TextSize = 16
		tabButtonLabel.Position = UDim2.new(0, 0, 0, 0)
		tabButtonLabel.Size = UDim2.new(1, 0, 1, -1)
		tabButtonLabel.Text = def.Name
		tabButtonLabel.ZIndex = 1
		tabButtonLabel.Parent = tabButton
		applyTextStroke(tabButtonLabel)

		-- Blocker (covers bottom border when active)
		local blocker = Instance.new("Frame")
		blocker.BackgroundColor3 = C.bgRaised
		blocker.BorderSizePixel = 0
		blocker.Position = UDim2.new(0, 0, 1, 0)
		blocker.Size = UDim2.new(1, 0, 0, 1)
		blocker.BackgroundTransparency = (def.Name == win._activeTab) and 0 or 1
		blocker.ZIndex = 3
		blocker.Parent = tabButton

		-- Tab panel
		local tabPanel = Instance.new("Frame")
		tabPanel.BackgroundTransparency = 1
		tabPanel.Size = UDim2.fromScale(1, 1)
		tabPanel.Visible = (def.Name == win._activeTab)
		tabPanel.ZIndex = 2
		tabPanel.Parent = tabContainer

		local tabData = {
			name = def.Name,
			button = tabButton,
			blocker = blocker,
			panel = tabPanel,
			label = tabButtonLabel,
		}
		table.insert(win._tabButtons, tabData)
		win._tabPanels[def.Name] = tabPanel

		-- Show/hide tab
		local function showTab(name)
			if openDD.fn then openDD.fn(); openDD.fn = nil end
			for _, d in ipairs(win._tabButtons) do
				local active = d.name == name
				d.panel.Visible = active
				d.blocker.BackgroundTransparency = active and 0 or 1
				d.button.BackgroundColor3 = active and C.bgRaised or C.bgDeep
				d.label.TextColor3 = active and C.textBright or C.textMid
			end
			win._activeTab = name
		end

		tabButton.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				showTab(def.Name)
			end
		end)

		win._tabPanels[def.Name] = tabPanel
	end

	function win:GetTab(name)
		local panel = self._tabPanels[name]; assert(panel, "Tab '" .. tostring(name) .. "' not found.")
		return makeTabObj(panel, registry, openDD, self.Options)
	end

	function win:SetWindowTitle(title)
		windowLabel.Text = title
	end

	return win
end

-- Dragging utility (Linoria-style)
function OnyxiteLib.MakeDraggable(frame, cutoff)
	frame.Active = true
	local mouse = Players.LocalPlayer:GetMouse()

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local objPos = Vector2.new(
				mouse.X - frame.AbsolutePosition.X,
				mouse.Y - frame.AbsolutePosition.Y
			)

			if objPos.Y > (cutoff or 40) then
				return
			end

			while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				frame.Position = UDim2.new(
					0,
					mouse.X - objPos.X + (frame.Size.X.Offset * frame.AnchorPoint.X),
					0,
					mouse.Y - objPos.Y + (frame.Size.Y.Offset * frame.AnchorPoint.Y)
				)
				RunService.RenderStepped:Wait()
			end
		end
	end)
end

return OnyxiteLib
