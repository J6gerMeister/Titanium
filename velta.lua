-- VeltaLibrary.lua
-- Compact GUI Library based on Velta's design system

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = {}
Library.Theme = {
	shellLight  = Color3.fromRGB(120, 120, 120),
	shellMid    = Color3.fromRGB(72,  72,  72),
	shellDark   = Color3.fromRGB(40,  40,  40),
	bgTop       = Color3.fromRGB(50, 50, 50),
	bgBot       = Color3.fromRGB(50, 50, 50),
	panel       = Color3.fromRGB(20, 20, 20),
	panelHover  = Color3.fromRGB(28, 28, 28),
	violet      = Color3.fromRGB(140, 70, 240),
	violetDim   = Color3.fromRGB(90, 45, 160),
	violetGlow  = Color3.fromRGB(175, 110, 255),
	border      = Color3.fromRGB(42, 42, 42),
	borderBt    = Color3.fromRGB(62, 62, 62),
	textBright  = Color3.fromRGB(245, 245, 245),
	text        = Color3.fromRGB(190, 190, 190),
	textDim     = Color3.fromRGB(95, 95, 95),
	textError   = Color3.fromRGB(220, 60, 60),
	header      = Color3.fromRGB(215, 215, 215),
	tabActive   = Color3.fromRGB(24, 24, 24),
	tabInact    = Color3.fromRGB(14, 14, 14),
	checkOn     = Color3.fromRGB(130, 60, 230),
	checkOff    = Color3.fromRGB(18, 18, 18),
	rowBg       = Color3.fromRGB(20, 20, 20),
	rowBgLight  = Color3.fromRGB(28, 28, 28),
	sidebarBg   = Color3.fromRGB(12, 12, 12),
	keyBg       = Color3.fromRGB(100, 40, 200),
	dropBg      = Color3.fromRGB(14, 14, 14),
	sliderFill  = Color3.fromRGB(130, 60, 230),
	sliderKnob  = Color3.fromRGB(230, 230, 230),
	yellow      = Color3.fromRGB(230, 190, 50),
}

local TweenInfo = {
	FAST = TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	MED  = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	SLOW = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

-- Utility functions
local function CreateInstance(class, properties)
	local inst = Instance.new(class)
	for k, v in pairs(properties) do
		if k == "Parent" then
			inst.Parent = v
		else
			inst[k] = v
		end
	end
	return inst
end

local function Tween(inst, goals, info)
	return TweenService:Create(inst, info or TweenInfo.FAST, goals)
end

local function Corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 1)
	c.Parent = inst
	return c
end

local function Stroke(inst, col, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color = col or Library.Theme.border
	s.Thickness = thick or 1
	s.Transparency = trans or 0
	s.Parent = inst
	return s
end

local function Gradient(inst, c0, c1, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c0, c1)
	g.Rotation = rot or 90
	g.Parent = inst
	return g
end

-- Window Class
function Library:CreateWindow(options)
	options = options or {}
	local C = Library.Theme
	local TI = TweenInfo
	
	local Window = {}
	Window.Name = options.Name or "Velta"
	Window.Version = options.Version or "v1.0"
	Window.Creator = options.Creator or "@user"
	Window.Size = options.Size or UDim2.new(0, 880, 0, 530)
	Window.MinSize = options.MinSize or Vector2.new(600, 380)
	
	local player = Players.LocalPlayer
	local guiParent = player:WaitForChild("PlayerGui")
	local gui = CreateInstance("ScreenGui", {Name = Window.Name.."GUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = guiParent})
	
	-- Window Frame
	local WIN_W, WIN_H = Window.Size.X.Offset, Window.Size.Y.Offset
	local BORDER = 5
	
	local outerFrame = CreateInstance("Frame", {
		Name = "WindowFrame",
		Size = UDim2.new(0, WIN_W + BORDER*2, 0, WIN_H + BORDER*2),
		Position = UDim2.new(0.5, -(WIN_W + BORDER*2)/2, 0.5, -(WIN_H + BORDER*2)/2),
		BackgroundColor3 = C.shellMid,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = gui
	})
	Corner(outerFrame, 0)
	Gradient(outerFrame, C.shellLight, C.shellDark, 135)
	Stroke(outerFrame, Color3.fromRGB(80, 80, 80), 1, 0)
	
	local main = CreateInstance("Frame", {
		Name = "Main",
		Size = UDim2.new(1, -BORDER*2, 1, -BORDER*2),
		Position = UDim2.new(0, BORDER, 0, BORDER),
		BackgroundColor3 = C.bgTop,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = outerFrame
	})
	Corner(main, 0)
	Gradient(main, C.bgTop, C.bgBot, 160)
	Stroke(main, C.borderBt, 1, 0)
	
	-- Title Bar
	local TITLEBAR_H = 32
	local titleBar = CreateInstance("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, TITLEBAR_H),
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = main
	})
	Corner(titleBar, 0)
	Gradient(titleBar, Color3.fromRGB(28, 28, 28), Color3.fromRGB(14, 14, 14), 180)
	
	local titleSep = CreateInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = C.borderBt,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = titleBar
	})
	
	-- Status Dot
	local statusDot = CreateInstance("Frame", {
		Size = UDim2.new(0, 6, 0, 6),
		Position = UDim2.new(0, 12, 0.5, -3),
		BackgroundColor3 = C.violet,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = titleBar
	})
	Corner(statusDot, 3)
	
	task.spawn(function()
		local t = 0
		while gui.Parent do
			t = t + task.wait(0.05)
			local p = (math.sin(t * 1.4) + 1) / 2
			statusDot.BackgroundColor3 = Color3.fromRGB(math.floor(100 + 70*p), math.floor(40 + 30*p), math.floor(200 + 55*p))
		end
	end)
	
	CreateInstance("TextLabel", {
		Text = Window.Name..".Lua",
		Font = Enum.Font.Code,
		TextSize = 14,
		TextColor3 = C.textBright,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 120, 1, 0),
		Position = UDim2.new(0, 24, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
		Parent = titleBar
	})
	
	CreateInstance("TextLabel", {
		Text = Window.Version.." · mod menu",
		Font = Enum.Font.Code,
		TextSize = 9,
		TextColor3 = C.textDim,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 140, 0, 12),
		Position = UDim2.new(0, 138, 0.5, -6),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
		Parent = titleBar
	})
	
	-- Window Controls
	local function MakeWinBtn(xOffset, glyph, hoverBg, hoverText)
		local btn = CreateInstance("TextButton", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(1, xOffset, 0.5, -10),
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
			BorderSizePixel = 0,
			Text = glyph,
			Font = Enum.Font.Code,
			TextSize = 14,
			TextColor3 = C.textDim,
			AutoButtonColor = false,
			ZIndex = 8,
			Parent = titleBar
		})
		Corner(btn, 0)
		local s = Stroke(btn, C.border, 1, 0.4)
		
		btn.MouseEnter:Connect(function()
			Tween(btn, {BackgroundColor3 = hoverBg, TextColor3 = hoverText}):Play()
			Tween(s, {Color = hoverText, Transparency = 0}):Play()
		end)
		btn.MouseLeave:Connect(function()
			Tween(btn, {BackgroundColor3 = Color3.fromRGB(22,22,22), TextColor3 = C.textDim}):Play()
			Tween(s, {Color = C.border, Transparency = 0.4}):Play()
		end)
		return btn
	end
	
	local closeBtn = MakeWinBtn(-28, "×", Color3.fromRGB(50,12,12), C.textError)
	local minimizeBtn = MakeWinBtn(-52, "−", Color3.fromRGB(36,32,8), C.yellow)
	
	-- Drag functionality
	local dragging, dragStart, startPos = false, nil, nil
	titleBar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = inp.Position
			startPos = outerFrame.Position
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local d = inp.Position - dragStart
			outerFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	
	-- Resize handle
	local resizeHandle = CreateInstance("TextButton", {
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(1, -18, 1, -18),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 20,
		Parent = main
	})
	Corner(resizeHandle, 0)
	
	CreateInstance("TextLabel", {
		Text = "↘",
		Font = Enum.Font.Code,
		TextSize = 20,
		TextColor3 = C.textDim,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		ZIndex = 21,
		Parent = resizeHandle
	})
	
	local resizing, resizeDragStart, resizeStartSize = false, nil, nil
	resizeHandle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeDragStart = inp.Position
			resizeStartSize = outerFrame.AbsoluteSize
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if resizing and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local d = inp.Position - resizeDragStart
			local newW = math.max(Window.MinSize.X, resizeStartSize.X + d.X)
			local newH = math.max(Window.MinSize.Y, resizeStartSize.Y + d.Y)
			outerFrame.Size = UDim2.new(0, newW, 0, newH)
		end
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
	end)
	
	-- Sidebar
	local SIDEBAR_OPEN_W = 140
	local SIDEBAR_CLOSED_W = 36
	local sidebarOpen = true
	
	local sidebar = CreateInstance("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, SIDEBAR_OPEN_W, 1, -TITLEBAR_H),
		Position = UDim2.new(0, 0, 0, TITLEBAR_H),
		BackgroundColor3 = C.sidebarBg,
		BorderSizePixel = 0,
		ZIndex = 4,
		ClipsDescendants = true,
		Parent = main
	})
	Corner(sidebar, 0)
	Gradient(sidebar, Color3.fromRGB(22,22,22), Color3.fromRGB(10,10,10), 180)
	
	local sidebarBorder = CreateInstance("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = C.borderBt,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = sidebar
	})
	
	local sidebarFlush = CreateInstance("Frame", {
		Size = UDim2.new(0, 8, 1, 0),
		Position = UDim2.new(1, -8, 0, 0),
		BackgroundColor3 = C.sidebarBg,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = sidebar
	})
	
	-- Sidebar logo
	local sideLogoArea = CreateInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = sidebar
	})
	Corner(sideLogoArea, 0)
	Gradient(sideLogoArea, Color3.fromRGB(30,30,30), Color3.fromRGB(12,12,12), 170)
	
	CreateInstance("Frame", {
		Size = UDim2.new(0, 7, 0, 7),
		Position = UDim2.new(0, 10, 0.5, -3),
		BackgroundColor3 = C.violet,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = sideLogoArea
	})
	
	local sideLogoText = CreateInstance("TextLabel", {
		Text = "Creator: "..Window.Creator,
		Font = Enum.Font.SciFi,
		TextSize = 11,
		TextColor3 = C.textBright,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.new(0, 22, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
		Parent = sideLogoArea
	})
	
	CreateInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = C.borderBt,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = sideLogoArea
	})
	
	-- Sidebar toggle
	local sideToggleBtn = CreateInstance("TextButton", {
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.new(0, 0, 1, -28),
		BackgroundColor3 = Color3.fromRGB(14, 14, 14),
		BorderSizePixel = 0,
		Text = "◀",
		Font = Enum.Font.Code,
		TextSize = 11,
		TextColor3 = C.textDim,
		AutoButtonColor = false,
		ZIndex = 7,
		Parent = sidebar
	})
	
	CreateInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = C.borderBt,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = sideToggleBtn
	})
	
	-- Content Area
	local contentArea = CreateInstance("Frame", {
		Name = "ContentArea",
		Size = UDim2.new(1, -(SIDEBAR_OPEN_W+1), 1, -TITLEBAR_H),
		Position = UDim2.new(0, SIDEBAR_OPEN_W+1, 0, TITLEBAR_H),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = main
	})
	
	-- Sidebar toggle function
	local function SetSidebar(open)
		sidebarOpen = open
		local targetW = open and SIDEBAR_OPEN_W or SIDEBAR_CLOSED_W
		Tween(sidebar, {Size=UDim2.new(0, targetW, 1, -TITLEBAR_H)}, TI.MED):Play()
		Tween(contentArea, {
			Size = UDim2.new(1, -(targetW+1), 1, -TITLEBAR_H),
			Position = UDim2.new(0, targetW+1, 0, TITLEBAR_H),
		}, TI.MED):Play()
		sideToggleBtn.Text = open and "◀" or "▶"
		for _, data in ipairs(Window.Tabs) do
			Tween(data.lbl, {TextTransparency = open and 0 or 1}, TI.MED):Play()
		end
		Tween(sideLogoText, {TextTransparency = open and 0 or 1}, TI.MED):Play()
	end
	
	sideToggleBtn.MouseButton1Click:Connect(function() SetSidebar(not sidebarOpen) end)
	
	-- Minimize/Restore
	local restorePill = CreateInstance("TextButton", {
		Name = "RestorePill",
		Size = UDim2.new(0, 120, 0, 26),
		Position = UDim2.new(0.5, -60, 0, -40),
		BackgroundColor3 = Color3.fromRGB(16, 16, 16),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 50,
		Visible = false,
		Parent = gui
	})
	Corner(restorePill, 13)
	Stroke(restorePill, C.borderBt, 1)
	Gradient(restorePill, Color3.fromRGB(26,26,26), Color3.fromRGB(10,10,10), 180)
	
	CreateInstance("Frame", {
		Size = UDim2.new(0, 6, 0, 6),
		Position = UDim2.new(0, 10, 0.5, -3),
		BackgroundColor3 = C.violet,
		BorderSizePixel = 0,
		ZIndex = 52,
		Parent = restorePill
	})
	
	CreateInstance("TextLabel", {
		Text = string.upper(Window.Name)..".LUA",
		Font = Enum.Font.Code,
		TextSize = 11,
		TextColor3 = C.textBright,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.new(0, 22, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 52,
		Parent = restorePill
	})
	
	local menuVisible = true
	local function Minimize()
		menuVisible = false
		Tween(outerFrame, {BackgroundTransparency=1}, TI.MED):Play()
		task.delay(0.08, function()
			outerFrame.Visible = false
			restorePill.Position = UDim2.new(0.5, -60, 0, -40)
			restorePill.Visible = true
			Tween(restorePill, {Position=UDim2.new(0.5,-60,0,10)}, TI.SLOW):Play()
		end)
	end
	
	local function Restore()
		Tween(restorePill, {Position=UDim2.new(restorePill.Position.X.Scale, restorePill.Position.X.Offset, 0, -40)}, TI.MED):Play()
		task.delay(0.18, function() restorePill.Visible = false end)
		outerFrame.BackgroundTransparency = 0
		outerFrame.Visible = true
		menuVisible = true
	end
	
	minimizeBtn.MouseButton1Click:Connect(Minimize)
	restorePill.MouseButton1Click:Connect(Restore)
	closeBtn.MouseButton1Click:Connect(function()
		task.wait(0.22)
		gui:Destroy()
	end)
	
	UIS.InputBegan:Connect(function(inp, gp)
		if gp then return end
		if inp.KeyCode == Enum.KeyCode.Insert then
			if menuVisible then Minimize() else Restore() end
		end
	end)
	
	-- Restore pill drag
	local pillDragging, pillDragStart, pillStartPos = false, nil, nil
	restorePill.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			pillDragging = true
			pillDragStart = inp.Position
			pillStartPos = restorePill.Position
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if pillDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local d = inp.Position - pillDragStart
			restorePill.Position = UDim2.new(pillStartPos.X.Scale, pillStartPos.X.Offset + d.X, pillStartPos.Y.Scale, pillStartPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then pillDragging = false end
	end)
	
	-- Tab management
	Window.Tabs = {}
	Window.ActiveTab = nil
	
	local TAB_BTN_H = 34
	function Window:AddTab(tabInfo)
		local i = #Window.Tabs + 1
		local yPos = 40 + (i-1) * TAB_BTN_H
		local isActive = not Window.ActiveTab
		
		local btn = CreateInstance("TextButton", {
			Name = tabInfo.Name.."Tab",
			Size = UDim2.new(1, 0, 0, TAB_BTN_H),
			Position = UDim2.new(0, 0, 0, yPos),
			BackgroundColor3 = isActive and C.tabActive or C.tabInact,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 6,
			Parent = sidebar
		})
		
		local accent = CreateInstance("Frame", {
			Size = UDim2.new(0, 2, 0.55, 0),
			Position = UDim2.new(0, 0, 0.22, 0),
			BackgroundColor3 = C.violet,
			BorderSizePixel = 0,
			Visible = isActive,
			ZIndex = 7,
			Parent = btn
		})
		Corner(accent, 0)
		
		local iconLbl = CreateInstance("TextLabel", {
			Text = tabInfo.Icon or "",
			Font = Enum.Font.SciFi,
			TextSize = 14,
			TextColor3 = isActive and C.violetGlow or C.textDim,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, SIDEBAR_CLOSED_W, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 7,
			Parent = btn
		})
		
		local lbl = CreateInstance("TextLabel", {
			Text = tabInfo.Name,
			Font = Enum.Font.Code,
			TextSize = 12,
			TextColor3 = isActive and C.textBright or C.textDim,
			TextTransparency = sidebarOpen and 0 or 1,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -(SIDEBAR_CLOSED_W+2), 1, 0),
			Position = UDim2.new(0, SIDEBAR_CLOSED_W, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 7,
			Parent = btn
		})
		
		if i > 1 then
			CreateInstance("Frame", {
				Size = UDim2.new(0.8, 0, 0, 1),
				Position = UDim2.new(0.1, 0, 0, -1),
				BackgroundColor3 = C.border,
				BackgroundTransparency = 0.3,
				BorderSizePixel = 0,
				ZIndex = 6,
				Parent = btn
			})
		end
		
		-- Create tab panel
		local panel = CreateInstance("Frame", {
			Name = tabInfo.Name.."Panel",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = isActive or false,
			ZIndex = 2,
			Parent = contentArea
		})
		
		-- Create two-column layout
		local leftCol = CreateInstance("ScrollingFrame", {
			Name = "LeftCol",
			Size = UDim2.new(0.5, -1, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = C.violet,
			CanvasSize = UDim2.new(0, 0, 0, 2000),
			ZIndex = 2,
			Parent = panel
		})
		
		CreateInstance("Frame", {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			BackgroundColor3 = C.border,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = panel
		})
		
		local rightCol = CreateInstance("ScrollingFrame", {
			Name = "RightCol",
			Size = UDim2.new(0.5, -1, 1, 0),
			Position = UDim2.new(0.5, 1, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = C.violet,
			CanvasSize = UDim2.new(0, 0, 0, 2000),
			ZIndex = 2,
			Parent = panel
		})
		
		local tabData = {
			Name = tabInfo.Name,
			btn = btn,
			iconLbl = iconLbl,
			lbl = lbl,
			accent = accent,
			Panel = panel,
			Left = leftCol,
			Right = rightCol,
			LeftY = 8,
			RightY = 8,
		}
		
		table.insert(Window.Tabs, tabData)
		
		-- Tab switching
		btn.MouseButton1Click:Connect(function()
			for _, tab in ipairs(Window.Tabs) do
				local active = tab == tabData
				tab.Panel.Visible = active
				Tween(tab.btn, {BackgroundColor3 = active and C.tabActive or C.tabInact}):Play()
				Tween(tab.iconLbl, {TextColor3 = active and C.violetGlow or C.textDim}):Play()
				Tween(tab.lbl, {TextColor3 = active and C.textBright or C.textDim}):Play()
				tab.accent.Visible = active
			end
			Window.ActiveTab = tabData
		end)
		
		btn.MouseEnter:Connect(function()
			if Window.ActiveTab ~= tabData then
				Tween(btn, {BackgroundColor3=C.panelHover}):Play()
				Tween(iconLbl, {TextColor3=C.text}):Play()
				Tween(lbl, {TextColor3=C.text}):Play()
			end
		end)
		btn.MouseLeave:Connect(function()
			if Window.ActiveTab ~= tabData then
				Tween(btn, {BackgroundColor3=C.tabInact}):Play()
				Tween(iconLbl, {TextColor3=C.textDim}):Play()
				Tween(lbl, {TextColor3=C.textDim}):Play()
			end
		end)
		
		if isActive then Window.ActiveTab = tabData end
		
		return {
			AddCheckbox = function(self, column, label, default, callback)
				local sf = column == "Left" and leftCol or rightCol
				local yVar = column == "Left" and "LeftY" or "RightY"
				local y = tabData[yVar]
				
				local row = CreateInstance("Frame", {
					Size = UDim2.new(1, -12, 0, 22),
					Position = UDim2.new(0, 6, 0, y),
					BackgroundColor3 = C.rowBg,
					BorderSizePixel = 0,
					ZIndex = 3,
					Parent = sf
				})
				Corner(row, 0)
				Stroke(row, C.border, 1, 0.4)
				Gradient(row, C.rowBgLight, C.rowBg, 180)
				
				local box = CreateInstance("TextButton", {
					Size = UDim2.new(0, 14, 0, 14),
					Position = UDim2.new(0, 0, 0.5, -7),
					BackgroundColor3 = default and C.checkOn or C.checkOff,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 4,
					Parent = row
				})
				Corner(box, 0)
				local boxStroke = Stroke(box, default and C.violet or C.border, 1)
				if default then Gradient(box, C.violet, C.violetDim, 135) end
				
				local tick = CreateInstance("TextLabel", {
					Text = "✓",
					Font = Enum.Font.Code,
					TextSize = 9,
					TextColor3 = C.textBright,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					Visible = default or false,
					ZIndex = 5,
					Parent = box
				})
				
				local lbl = CreateInstance("TextLabel", {
					Text = label,
					Font = Enum.Font.Code,
					TextSize = 12,
					TextColor3 = default and C.violetGlow or C.text,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -20, 1, 0),
					Position = UDim2.new(0, 20, 0, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 4,
					Parent = row
				})
				
				local checked = default
				box.MouseButton1Click:Connect(function()
					checked = not checked
					tick.Visible = checked
					if checked then
						box.BackgroundColor3 = C.checkOn
						boxStroke.Color = C.violet
						if not box:FindFirstChildWhichIsA("UIGradient") then Gradient(box, C.violet, C.violetDim, 135) end
						Tween(lbl, {TextColor3=C.violetGlow}):Play()
					else
						box.BackgroundColor3 = C.checkOff
						boxStroke.Color = C.border
						local g = box:FindFirstChildWhichIsA("UIGradient"); if g then g:Destroy() end
						Tween(lbl, {TextColor3=C.text}):Play()
					end
					if callback then callback(checked) end
				end)
				
				tabData[yVar] = y + 26
			end,
			
			AddSlider = function(self, column, label, min, max, default, callback)
				local sf = column == "Left" and leftCol or rightCol
				local yVar = column == "Left" and "LeftY" or "RightY"
				local y = tabData[yVar]
				
				local row = CreateInstance("Frame", {
					Size = UDim2.new(1, -12, 0, 22),
					Position = UDim2.new(0, 6, 0, y),
					BackgroundColor3 = C.rowBg,
					BorderSizePixel = 0,
					ZIndex = 3,
					Parent = sf
				})
				Corner(row, 0)
				Stroke(row, C.border, 1, 0.4)
				Gradient(row, C.rowBgLight, C.rowBg, 180)
				
				local lbl = CreateInstance("TextLabel", {
					Text = label,
					Font = Enum.Font.Code,
					TextSize = 12,
					TextColor3 = C.text,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.42, 0, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 4,
					Parent = row
				})
				
				local valLbl = CreateInstance("TextLabel", {
					Text = tostring(default),
					Font = Enum.Font.Code,
					TextSize = 10,
					TextColor3 = C.violetGlow,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.13, 0, 1, 0),
					Position = UDim2.new(0.87, 0, 0, 0),
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 4,
					Parent = row
				})
				
				local track = CreateInstance("Frame", {
					Size = UDim2.new(0.42, 0, 0, 4),
					Position = UDim2.new(0.43, 0, 0.5, -2),
					BackgroundColor3 = Color3.fromRGB(24, 24, 24),
					BorderSizePixel = 0,
					ZIndex = 4,
					Parent = row
				})
				Corner(track, 0)
				Stroke(track, C.border, 1, 0.4)
				
				local pct = (default - min) / math.max(max - min, 1)
				local fill = CreateInstance("Frame", {
					Size = UDim2.new(pct, 0, 1, 0),
					BackgroundColor3 = C.sliderFill,
					BorderSizePixel = 0,
					ZIndex = 5,
					Parent = track
				})
				Corner(fill, 0)
				Gradient(fill, C.violetGlow, C.violet, 0)
				
				local knob = CreateInstance("TextButton", {
					Size = UDim2.new(0, 10, 0, 10),
					Position = UDim2.new(pct, -5, 0.5, -5),
					BackgroundColor3 = C.sliderKnob,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 6,
					Parent = track
				})
				Corner(knob, 5)
				Stroke(knob, C.violetDim, 1)
				
				local draggingSlider = false
				knob.MouseButton1Down:Connect(function() draggingSlider = true end)
				UIS.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
				end)
				UIS.InputChanged:Connect(function(inp)
					if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
						local mouse = UIS:GetMouseLocation()
						local tp = track.AbsolutePosition
						local ts = track.AbsoluteSize
						local p = math.clamp((mouse.X - tp.X) / ts.X, 0, 1)
						local val = math.floor(min + (max - min) * p + 0.5)
						fill.Size = UDim2.new(p, 0, 1, 0)
						knob.Position = UDim2.new(p, -5, 0.5, -5)
						valLbl.Text = tostring(val)
						if callback then callback(val) end
					end
				end)
				
				tabData[yVar] = y + 26
			end,
			
			AddDropdown = function(self, column, label, options, default, callback)
				local sf = column == "Left" and leftCol or rightCol
				local yVar = column == "Left" and "LeftY" or "RightY"
				local y = tabData[yVar]
				local COUNT = #options
				local LIST_H = COUNT * 21
				
				local container = CreateInstance("Frame", {
					Size = UDim2.new(1, -12, 0, 22),
					Position = UDim2.new(0, 6, 0, y),
					BackgroundColor3 = C.rowBg,
					BorderSizePixel = 0,
					ZIndex = 3,
					Parent = sf
				})
				Corner(container, 0)
				Stroke(container, C.border, 1, 0.4)
				Gradient(container, C.rowBgLight, C.rowBg, 180)
				
				local btnX = label ~= "" and 0.45 or 0
				local btnW = label ~= "" and 0.54 or 1
				
				if label ~= "" then
					CreateInstance("TextLabel", {
						Text = label,
						Font = Enum.Font.Code,
						TextSize = 12,
						TextColor3 = C.text,
						BackgroundTransparency = 1,
						Size = UDim2.new(0.44, 0, 0, 22),
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 4,
						Parent = container
					})
				end
				
				local selIdx = 1
				for i, v in ipairs(options) do if v == (default or options[1]) then selIdx = i end end
				
				local btn = CreateInstance("TextButton", {
					Size = UDim2.new(btnW, 0, 0, 22),
					Position = UDim2.new(btnX, 0, 0, 0),
					BackgroundColor3 = C.dropBg,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 6,
					Parent = container
				})
				Corner(btn, 0)
				local btnStroke = Stroke(btn, C.border, 1)
				Gradient(btn, Color3.fromRGB(22,22,22), Color3.fromRGB(12,12,12), 180)
				
				local selLbl = CreateInstance("TextLabel", {
					Text = options[selIdx],
					Font = Enum.Font.Code,
					TextSize = 11,
					TextColor3 = C.text,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -20, 1, 0),
					Position = UDim2.new(0, 6, 0, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 7,
					Parent = btn
				})
				
				local arrow = CreateInstance("TextLabel", {
					Text = "▾",
					Font = Enum.Font.Code,
					TextSize = 10,
					TextColor3 = C.textDim,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 16, 1, 0),
					Position = UDim2.new(1, -18, 0, 0),
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 7,
					Parent = btn
				})
				
				local listFrame = CreateInstance("Frame", {
					Name = "DropList",
					Size = UDim2.new(btnW, 0, 0, 0),
					Position = UDim2.new(btnX, 0, 0, 24),
					BackgroundColor3 = Color3.fromRGB(16,16,16),
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Visible = false,
					ZIndex = 20,
					Parent = container
				})
				Corner(listFrame, 0)
				Stroke(listFrame, C.borderBt, 1, 0.2)
				Gradient(listFrame, Color3.fromRGB(22,22,22), Color3.fromRGB(12,12,12), 180)
				
				local isOpen = false
				
				for i, optText in ipairs(options) do
					local optBtn = CreateInstance("TextButton", {
						Size = UDim2.new(1, 0, 0, 21),
						Position = UDim2.new(0, 0, 0, (i-1)*21),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Text = "",
						AutoButtonColor = false,
						ZIndex = 21,
						Parent = listFrame
					})
					
					local selBar = CreateInstance("Frame", {
						Size = UDim2.new(0, 2, 0.55, 0),
						Position = UDim2.new(0, 2, 0.22, 0),
						BackgroundColor3 = C.violet,
						BorderSizePixel = 0,
						Visible = (i == selIdx),
						ZIndex = 22,
						Parent = optBtn
					})
					Corner(selBar, 0)
					
					local optLbl = CreateInstance("TextLabel", {
						Text = optText,
						Font = Enum.Font.Code,
						TextSize = 11,
						TextColor3 = (i == selIdx) and C.violetGlow or C.text,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -14, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 22,
						Parent = optBtn
					})
					
					optBtn.MouseButton1Click:Connect(function()
						for _, child in ipairs(listFrame:GetChildren()) do
							if child:IsA("TextButton") then
								child.BackgroundTransparency = 1
								local cLbl = child:FindFirstChildWhichIsA("TextLabel")
								if cLbl then cLbl.TextColor3 = C.text end
								for _, cc in ipairs(child:GetChildren()) do
									if cc:IsA("Frame") and cc.Size == UDim2.new(0,2,0.55,0) then cc.Visible = false end
								end
							end
						end
						selIdx = i
						selLbl.Text = optText
						optLbl.TextColor3 = C.violetGlow
						selBar.Visible = true
						isOpen = false
						Tween(arrow, {Rotation=0, TextColor3=C.textDim}):Play()
						Tween(listFrame, {Size=UDim2.new(btnW,0,0,0)}, TI.MED):Play()
						task.delay(0.24, function() listFrame.Visible = false end)
						container.Size = UDim2.new(1,-12,0,22)
						if callback then callback(optText) end
					end)
				end
				
				local function CloseDD()
					isOpen = false
					Tween(arrow, {Rotation=0, TextColor3=C.textDim}):Play()
					Tween(listFrame, {Size=UDim2.new(btnW,0,0,0)}, TI.MED):Play()
					task.delay(0.24, function() listFrame.Visible = false end)
					container.Size = UDim2.new(1,-12,0,22)
				end
				
				local function OpenDD()
					isOpen = true
					listFrame.Visible = true
					listFrame.Size = UDim2.new(btnW, 0, 0, 0)
					Tween(arrow, {Rotation=180, TextColor3=C.violet}):Play()
					Tween(listFrame, {Size=UDim2.new(btnW,0,0,LIST_H)}, TI.MED):Play()
					container.Size = UDim2.new(1,-12,0,22+LIST_H)
				end
				
				btn.MouseButton1Click:Connect(function()
					if isOpen then CloseDD() else OpenDD() end
				end)
				
				tabData[yVar] = y + 28
			end,
			
			AddKeybind = function(self, column, label, key, callback)
				local sf = column == "Left" and leftCol or rightCol
				local yVar = column == "Left" and "LeftY" or "RightY"
				local y = tabData[yVar]
				
				local row = CreateInstance("Frame", {
					Size = UDim2.new(1, -12, 0, 22),
					Position = UDim2.new(0, 6, 0, y),
					BackgroundColor3 = C.rowBg,
					BorderSizePixel = 0,
					ZIndex = 3,
					Parent = sf
				})
				Corner(row, 0)
				Stroke(row, C.border, 1, 0.4)
				Gradient(row, C.rowBgLight, C.rowBg, 180)
				
				CreateInstance("TextLabel", {
					Text = label,
					Font = Enum.Font.Code,
					TextSize = 12,
					TextColor3 = C.text,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.55, 0, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 4,
					Parent = row
				})
				
				local keyBtn = CreateInstance("TextButton", {
					Size = UDim2.new(0.4, 0, 0.8, 0),
					Position = UDim2.new(0.57, 0, 0.1, 0),
					BackgroundColor3 = C.keyBg,
					BorderSizePixel = 0,
					Text = key or "None",
					Font = Enum.Font.Code,
					TextSize = 10,
					TextColor3 = C.textBright,
					AutoButtonColor = false,
					ZIndex = 4,
					Parent = row
				})
				Corner(keyBtn, 0)
				Stroke(keyBtn, C.violetDim, 1, 0.2)
				Gradient(keyBtn, C.violet, C.violetDim, 135)
				
				if callback then
					keyBtn.MouseButton1Click:Connect(callback)
				end
				
				tabData[yVar] = y + 26
			end,
			
			AddSeparator = function(self, column)
				local sf = column == "Left" and leftCol or rightCol
				local yVar = column == "Left" and "LeftY" or "RightY"
				local y = tabData[yVar]
				
				CreateInstance("Frame", {
					Size = UDim2.new(1, -12, 0, 1),
					Position = UDim2.new(0, 6, 0, y),
					BackgroundColor3 = C.border,
					BorderSizePixel = 0,
					ZIndex = 3,
					Parent = sf
				})
				
				tabData[yVar] = y + 8
			end,
			
			AddHeader = function(self, column, text)
				local sf = column == "Left" and leftCol or rightCol
				local yVar = column == "Left" and "LeftY" or "RightY"
				local y = tabData[yVar]
				
				local wrap = CreateInstance("Frame", {
					Size = UDim2.new(1, -10, 0, 20),
					Position = UDim2.new(0, 5, 0, y),
					BackgroundTransparency = 1,
					Parent = sf
				})
				
				CreateInstance("TextLabel", {
					Text = string.upper(text),
					Font = Enum.Font.Code,
					TextSize = 10,
					TextColor3 = C.header,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 14),
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 3,
					Parent = wrap
				})
				
				CreateInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 1),
					Position = UDim2.new(0, 0, 0, 15),
					BackgroundColor3 = C.borderBt,
					BorderSizePixel = 0,
					ZIndex = 3,
					Parent = wrap
				})
				
				tabData[yVar] = y + 22
			end,
		}
	end
	
	-- Update canvas sizes
	function Window:UpdateCanvas()
		for _, tab in ipairs(Window.Tabs) do
			tab.Left.CanvasSize = UDim2.new(0, 0, 0, tab.LeftY + 20)
			tab.Right.CanvasSize = UDim2.new(0, 0, 0, tab.RightY + 20)
		end
	end
	
	return Window
end

return Library
