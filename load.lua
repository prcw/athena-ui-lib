local UserInputService = game:GetService("UserInputService")

local UILib = {}

function UILib.CreateWindow(title, position, size)
	local player = game.Players.LocalPlayer

	local function roundify(instance, radius)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, radius or 6)
		corner.Parent = instance
	end

	local windowSize = UDim2.new(0, size.X, 0, size.Y)
	local windowPosition = UDim2.new(0, position.X - (size.X / 2), 0, position.Y - (size.Y / 2))

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = title .. "_GUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local window = Instance.new("Frame")
	window.Name = "MainWindow"
	window.Size = windowSize
	window.Position = windowPosition
	window.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	window.BorderSizePixel = 0
	window.Active = true
	window.Draggable = false
	window.ClipsDescendants = true -- ✅ Add this
	window.Parent = screenGui


	roundify(window, 12)

	local resizeHandle = Instance.new("Frame")
	resizeHandle.Size = UDim2.new(0, 20, 0, 20)
	resizeHandle.Position = UDim2.new(1, -20, 1, -20)
	resizeHandle.AnchorPoint = Vector2.new(0, 0)
	resizeHandle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	resizeHandle.BorderSizePixel = 0
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.Parent = window
	resizeHandle.ZIndex = 10
	resizeHandle.Active = true

	roundify(resizeHandle)

	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local startPos = input.Position
			local startSize = window.Size
			local startAbsSize = window.AbsoluteSize

			local moveConn, releaseConn

			moveConn = UserInputService.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = moveInput.Position - startPos
					local newWidth = math.max(200, startAbsSize.X + delta.X)
					local newHeight = math.max(150, startAbsSize.Y + delta.Y)
					window.Size = UDim2.new(0, newWidth, 0, newHeight)

					-- Update content layout bounds
					contentFrame.Size = UDim2.new(1, 0, 1, -60)
					tabBar.Size = UDim2.new(1, 0, 0, 30)
					resizeHandle.Position = UDim2.new(1, -20, 1, -20)
				end
			end)

			releaseConn = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
					moveConn:Disconnect()
					releaseConn:Disconnect()
				end
			end)
		end
	end)

	local titleBar = Instance.new("TextLabel")
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	titleBar.TextColor3 = Color3.new(1, 1, 1)
	titleBar.Text = "  " .. title
	titleBar.Font = Enum.Font.SourceSansBold
	titleBar.TextSize = 18
	titleBar.TextXAlignment = Enum.TextXAlignment.Left
	titleBar.Parent = window

	roundify(titleBar) -- ImGui-style large rounding

	local dragging = false
	local dragStart, startPos

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = window.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	local closeButton = Instance.new("TextLabel")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -30, 0, 0)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.TextSize = 18
	closeButton.Parent = window
	closeButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			screenGui:Destroy()
		end
	end)

	roundify(closeButton)

	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, 0, 0, 30)
	tabBar.Position = UDim2.new(0, 0, 0, 30)
	tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	tabBar.BorderSizePixel = 0
	tabBar.Parent = window

	roundify(tabBar)

	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, 0, 1, -60)
	contentFrame.Position = UDim2.new(0, 0, 0, 60)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = window

	local tabs = {}

	local Theme = {
		BackgroundColor = Color3.fromRGB(40, 40, 40),
		TextColor = Color3.new(1, 1, 1),
		AccentColor = Color3.fromRGB(90, 90, 90),
		Font = Enum.Font.SourceSans,
		FontSize = 18
	}

	local function ApplyTheme(instance)
		for _, child in pairs(instance:GetDescendants()) do
			if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
				child.TextColor3 = Theme.TextColor
				child.Font = Theme.Font
				if child:IsA("TextLabel") or child:IsA("TextButton") then
					child.TextSize = Theme.FontSize
				end
			elseif child:IsA("Frame") then
				child.BackgroundColor3 = Theme.BackgroundColor
			end
		end
	end

	local function CreateTab(tabTitle)
		local tabButton = Instance.new("TextButton")
		tabButton.Size = UDim2.new(0, 100, 1, 0)
		tabButton.Position = UDim2.new(0, #tabs * 100, 0, 0)
		tabButton.Text = tabTitle
		tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		tabButton.TextColor3 = Color3.new(1, 1, 1)
		tabButton.Font = Enum.Font.SourceSans
		tabButton.TextSize = 14
		tabButton.Parent = tabBar
		roundify(tabButton)

		local tabContent = Instance.new("Frame")
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.Position = UDim2.new(0, 0, 0, 0)
		tabContent.BackgroundTransparency = 1
		tabContent.Visible = false
		tabContent.Parent = contentFrame

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = tabContent

		local function showTab()
			for _, tab in ipairs(tabs) do
				tab.Content.Visible = false
				tab.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			end
			tabContent.Visible = true
			tabButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
		end

		tabButton.MouseButton1Click:Connect(showTab)

		local newTab = {
			Title = tabTitle,
			Button = tabButton,
			Content = tabContent,
			Show = showTab
		}

		function newTab:TextLabel(text)
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -20, 0, 24)
			container.Position = UDim2.new(0, 10, 0, 0) -- Left padding
			container.BackgroundTransparency = 1
			container.Parent = tabContent

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = text
			label.TextColor3 = Color3.new(1, 1, 1)
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Font = Enum.Font.SourceSans
			label.TextSize = 18
			label.Parent = container

			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 10)  -- Push everything inside to the right
			padding.PaddingRight = UDim.new(0, 10)
			padding.Parent = container

			return label
		end
		
		function newTab:NumberBox(labelText, defaultValue, minValue, maxValue, callback)
			-- Container for the number box
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -20, 0, 30)  -- Width and Height
			container.Position = UDim2.new(0, 10, 0, 0) -- Left padding
			container.BackgroundTransparency = 1
			container.Parent = tabContent

			-- Label for the number box
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 20)
			label.Text = labelText
			label.TextColor3 = Color3.new(1, 1, 1)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.SourceSans
			label.TextSize = 16
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = container

			-- Padding for the container
			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 10)  -- Push everything inside to the right
			padding.PaddingRight = UDim.new(0, 10)
			padding.Parent = container

			-- Input box for the number value
			local numberBox = Instance.new("TextBox")
			numberBox.Size = UDim2.new(0, 70, 0, 20)
			numberBox.Position = UDim2.new(1, -80, 0, 0)  -- Position it to the right of the label
			numberBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			numberBox.TextColor3 = Color3.new(1, 1, 1)
			numberBox.Font = Enum.Font.SourceSans
			numberBox.TextSize = 16
			numberBox.Text = tostring(defaultValue)
			numberBox.ClearTextOnFocus = false
			numberBox.Parent = container
			roundify(numberBox)

			-- Allow the user to input only numbers
			numberBox.FocusLost:Connect(function(enter)
				if enter then
					local inputValue = tonumber(numberBox.Text)
					if inputValue then
						-- Clamp the value within the min and max range
						inputValue = math.clamp(inputValue, minValue, maxValue)
						numberBox.Text = tostring(inputValue)  -- Update the input box text
						if callback then
							callback(inputValue)  -- Call the callback with the new value
						end
					else
						-- If the input is invalid, reset the number box to the default value
						numberBox.Text = tostring(defaultValue)
					end
				end
			end)

			return numberBox
		end

		function newTab:Keybind(labelText, defaultKey, callback)
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -20, 0, 30)
			container.Position = UDim2.new(0, 10, 0, 0)
			container.BackgroundTransparency = 1
			container.Parent = tabContent

			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 10)
			padding.PaddingRight = UDim.new(0, 10)
			padding.Parent = container

			local label = Instance.new("TextLabel")
			label.Name = "KeybindLabel"
			label.Size = UDim2.new(1, -80, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = labelText
			label.TextColor3 = Color3.new(1, 1, 1)
			label.Font = Enum.Font.SourceSans
			label.TextSize = 16
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.AnchorPoint = Vector2.new(0, 0.5)
			label.Position = UDim2.new(0, 0, 0.5, 0)
			label.Parent = container

			local button = Instance.new("TextButton")
			button.Size = UDim2.new(0, 70, 0, 24)
			button.AnchorPoint = Vector2.new(1, 0.5)
			button.Position = UDim2.new(1, 0, 0.5, 0)
			button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			button.TextColor3 = Color3.new(1, 1, 1)
			button.Font = Enum.Font.SourceSans
			button.TextSize = 16
			button.Text = tostring(defaultKey)
			button.AutoButtonColor = true
			button.Parent = container

			roundify(button)

			local binding = false
			button.MouseButton1Click:Connect(function()
				if binding then return end
				binding = true
				button.Text = "Waiting..."

				local inputConn
				inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then return end
					local keyName

					if input.UserInputType == Enum.UserInputType.Keyboard then
						keyName = input.KeyCode.Name
					elseif input.UserInputType.Name:match("^MouseButton%d$") then
						keyName = input.UserInputType.Name:gsub("MouseButton", "MB")
					else
						keyName = input.UserInputType.Name
					end

					button.Text = keyName
					binding = false
					inputConn:Disconnect()

					if callback then callback(keyName) end
				end)
			end)

			return button
		end

		function newTab:Slider(name, min, max, default, callback)
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -30, 0, 40)                  -- Shrink width
			container.Position = UDim2.new(0, 10, 0, 0)                -- Move it right
			container.BackgroundTransparency = 1
			container.Parent = tabContent

			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 10)  -- Push everything inside to the right
			padding.PaddingRight = UDim.new(0, 10)
			padding.Parent = container

			local label = Instance.new("TextLabel")
			label.Text = name .. ": " .. tostring(default)
			label.Size = UDim2.new(1, 0, 0, 20)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.new(1, 1, 1)
			label.Font = Enum.Font.SourceSans
			label.TextSize = 16
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = container

			local slider = Instance.new("TextButton")
			slider.Size = UDim2.new(1, 0, 0, 20)
			slider.Position = UDim2.new(0, 0, 0, 20)
			slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			slider.Text = ""
			slider.AutoButtonColor = false
			slider.Parent = container

			roundify(slider)

			local fill = Instance.new("Frame")
			fill.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
			fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			fill.BorderSizePixel = 0
			fill.Parent = slider

			roundify(fill)

			local function update(input)
				local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
				local value = math.floor((min + (max - min) * rel) + 0.5)
				fill.Size = UDim2.new(rel, 0, 1, 0)
				label.Text = name .. ": " .. tostring(value)
				if callback then callback(value) end
			end

			slider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local moveConn, upConn
					moveConn = game:GetService("UserInputService").InputChanged:Connect(function(input2)
						if input2.UserInputType == Enum.UserInputType.MouseMovement then
							update(input2)
						end
					end)
					upConn = game:GetService("UserInputService").InputEnded:Connect(function(input2)
						if input2.UserInputType == Enum.UserInputType.MouseButton1 then
							moveConn:Disconnect()
							upConn:Disconnect()
						end
					end)
				end
			end)

			return slider
		end

		function newTab:Dropdown(labelText, options, defaultIndex, onSelect)
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -20, 0, 48)
			container.BackgroundTransparency = 1
			container.Parent = tabContent

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 20)
			label.Text = labelText
			label.TextColor3 = Color3.new(1, 1, 1)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.SourceSans
			label.TextSize = 16
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = container

			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 10)  -- Push everything inside to the right
			padding.PaddingRight = UDim.new(0, 10)
			padding.Parent = container

			local dropdown = Instance.new("TextButton")
			dropdown.Size = UDim2.new(1, 0, 0, 24)
			dropdown.Position = UDim2.new(0, 0, 0, 24)
			dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			dropdown.TextColor3 = Color3.new(1, 1, 1)
			dropdown.Font = Enum.Font.SourceSans
			dropdown.TextSize = 16
			dropdown.Text = options[defaultIndex]
			dropdown.Parent = container
			roundify(dropdown)

			local dropdownMenu = Instance.new("Frame")
			dropdownMenu.Size = UDim2.new(1, 0, 0, #options * 24)
			dropdownMenu.Position = UDim2.new(0, 0, 0, 48)
			dropdownMenu.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			dropdownMenu.Visible = false
			dropdownMenu.ClipsDescendants = true
			dropdownMenu.Parent = container
			roundify(dropdownMenu)

			local layout = Instance.new("UIListLayout")
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Parent = dropdownMenu

			for i, option in ipairs(options) do
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 24)
				btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
				btn.Text = option
				btn.TextColor3 = Color3.new(1, 1, 1)
				btn.Font = Enum.Font.SourceSans
				btn.TextSize = 16
				btn.Parent = dropdownMenu

				roundify(btn)

				btn.MouseButton1Click:Connect(function()
					dropdown.Text = option
					dropdownMenu.Visible = false
					if onSelect then
						onSelect(i, option)
					end
				end)
			end

			dropdown.MouseButton1Click:Connect(function()
				dropdownMenu.Visible = not dropdownMenu.Visible
			end)

			return dropdown
		end

		function newTab:Checkbox(labelText, defaultState, callback)
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -20, 0, 24)
			container.Position = UDim2.new(0, 10, 0, 0)
			container.BackgroundTransparency = 1
			container.Parent = tabContent

			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 10)  -- Push everything inside to the right
			padding.PaddingRight = UDim.new(0, 10)
			padding.Parent = container

			local box = Instance.new("TextButton")
			box.Size = UDim2.new(0, 20, 0, 20)
			box.Position = UDim2.new(0, 0, 0.5, -10)
			box.BackgroundColor3 = defaultState and Color3.fromRGB(120, 200, 120) or Color3.fromRGB(60, 60, 60)
			box.Text = ""
			box.AutoButtonColor = false
			box.Parent = container

			roundify(box)

			local check = Instance.new("TextLabel")
			check.Size = UDim2.new(1, 0, 1, 0)
			check.BackgroundTransparency = 1
			check.Text = defaultState and "✓" or ""
			check.TextColor3 = Color3.new(1, 1, 1)
			check.Font = Enum.Font.SourceSansBold
			check.TextSize = 16
			check.Parent = box

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -30, 1, 0)
			label.Position = UDim2.new(0, 30, 0, 0)
			label.Text = labelText
			label.TextColor3 = Color3.new(1, 1, 1)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.SourceSans
			label.TextSize = 16
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = container

			local state = defaultState

			box.MouseButton1Click:Connect(function()
				state = not state
				box.BackgroundColor3 = state and Color3.fromRGB(120, 200, 120) or Color3.fromRGB(60, 60, 60)
				check.Text = state and "✓" or ""
				if callback then callback(state) end
			end)

			return box
		end


		function newTab:ColorWheel(title, defaultColor, callback)
			local UserInputService = game:GetService("UserInputService")

			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -20, 0, 30)
			container.Position = UDim2.new(0, 10, 0, 0) -- Adds left padding
			container.BackgroundTransparency = 1
			container.Parent = tabContent

			local button = Instance.new("TextButton")
			button.Size = UDim2.new(0, 50, 0, 24)
			button.Position = UDim2.new(0, 0, 0, 3)
			button.Text = ""
			button.BackgroundColor3 = defaultColor
			button.BorderColor3 = Color3.new(1, 1, 1)
			button.Parent = container
			roundify(button)

			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 10)  -- Push everything inside to the right
			padding.PaddingRight = UDim.new(0, 10)
			padding.Parent = container

			local function rgbToHex(c)
				return string.format("#%02X%02X%02X", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
			end

			local function hexToColor(hex)
				hex = hex:gsub("#", "")
				if #hex == 6 then
					local r = tonumber(hex:sub(1, 2), 16)
					local g = tonumber(hex:sub(3, 4), 16)
					local b = tonumber(hex:sub(5, 6), 16)
					if r and g and b then
						return Color3.fromRGB(r, g, b)
					end
				end
			end

			local function openPicker()
				local pickerGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
				pickerGui.Name = "ColorPicker"
				pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

				local modal = Instance.new("Frame")
				modal.Size = UDim2.new(0, 320, 0, 390)
				modal.Position = UDim2.new(0.5, -160, 0.5, -195)
				modal.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				modal.BorderSizePixel = 0
				modal.AnchorPoint = Vector2.new(0.5, 0.5)
				modal.Active = true
				modal.Draggable = true
				modal.Parent = pickerGui
				roundify(modal)

				-- Title Bar
				local titleBar = Instance.new("TextLabel")
				titleBar.Size = UDim2.new(1, 0, 0, 30)
				titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				titleBar.TextColor3 = Color3.new(1, 1, 1)
				titleBar.Font = Enum.Font.SourceSansBold
				titleBar.TextSize = 18
				titleBar.TextXAlignment = Enum.TextXAlignment.Left
				titleBar.Text = "  " .. title
				titleBar.BorderSizePixel = 0
				titleBar.Parent = modal

				local h, s, v = Color3.toHSV(defaultColor)

				local function getCurrentColor()
					return Color3.fromHSV(h, s, v)
				end

				local preview = Instance.new("Frame", modal)
				preview.Size = UDim2.new(0, 50, 0, 50)
				preview.Position = UDim2.new(1, -60, 0, 40)
				preview.BackgroundColor3 = defaultColor
				preview.BorderColor3 = Color3.new(1, 1, 1)

				local close = Instance.new("TextButton", modal)
				close.Size = UDim2.new(0, 60, 0, 24)
				close.Position = UDim2.new(1, -70, 1, -34)
				close.Text = "Close"
				close.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
				close.TextColor3 = Color3.new(1, 1, 1)
				close.Font = Enum.Font.SourceSans
				close.TextSize = 16
				close.MouseButton1Click:Connect(function()
					pickerGui:Destroy()
				end)

				local hsBox = Instance.new("ImageLabel", modal)
				hsBox.Size = UDim2.new(0, 200, 0, 200)
				hsBox.Position = UDim2.new(0, 10, 0, 40)
				hsBox.Image = "rbxassetid://6020299385"
				hsBox.BackgroundTransparency = 1
				hsBox.BorderColor3 = Color3.fromRGB(100, 100, 100)

				local hsCursor = Instance.new("Frame", hsBox)
				hsCursor.Size = UDim2.new(0, 6, 0, 6)
				hsCursor.AnchorPoint = Vector2.new(0.5, 0.5)
				hsCursor.BackgroundColor3 = Color3.new(1, 1, 1)
				hsCursor.BorderColor3 = Color3.new(0, 0, 0)
				hsCursor.BorderSizePixel = 1
				hsCursor.ZIndex = 2

				local vSlider = Instance.new("Frame", modal)
				vSlider.Size = UDim2.new(0, 200, 0, 20)
				vSlider.Position = UDim2.new(0, 10, 0, 250)

				local vGradient = Instance.new("UIGradient")
				vGradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, 1))
				}
				vGradient.Parent = vSlider

				local vThumb = Instance.new("Frame", vSlider)
				vThumb.Size = UDim2.new(0, 2, 1, 0)
				vThumb.BackgroundColor3 = Color3.new(0, 0, 0)
				vThumb.BorderSizePixel = 0

				local percentLabel = Instance.new("TextLabel", modal)
				percentLabel.Size = UDim2.new(0, 60, 0, 20)
				percentLabel.Position = UDim2.new(0, 220, 0, 250)
				percentLabel.TextColor3 = Color3.new(1, 1, 1)
				percentLabel.Font = Enum.Font.SourceSans
				percentLabel.TextSize = 14
				percentLabel.BackgroundTransparency = 1

				local hexBox = Instance.new("TextBox", modal)
				hexBox.Size = UDim2.new(0, 120, 0, 24)
				hexBox.Position = UDim2.new(0, 10, 0, 290)
				hexBox.Text = rgbToHex(defaultColor)
				hexBox.TextColor3 = Color3.new(1, 1, 1)
				hexBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				hexBox.Font = Enum.Font.Code
				hexBox.TextSize = 14
				hexBox.ClearTextOnFocus = false

				local rgbBox = Instance.new("TextBox", modal)
				rgbBox.Size = UDim2.new(0, 180, 0, 24)
				rgbBox.Position = UDim2.new(0, 140, 0, 290)
				rgbBox.Text = string.format("R: %d  G: %d  B: %d", defaultColor.R * 255, defaultColor.G * 255, defaultColor.B * 255)
				rgbBox.TextColor3 = Color3.new(1, 1, 1)
				rgbBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				rgbBox.Font = Enum.Font.Code
				rgbBox.TextSize = 14
				rgbBox.ClearTextOnFocus = false

				local function updateUI()
					local color = getCurrentColor()
					button.BackgroundColor3 = color
					preview.BackgroundColor3 = color
					hsCursor.Position = UDim2.new(h, 0, 1 - s, 0)
					vThumb.Position = UDim2.new(v, -1, 0, 0)
					percentLabel.Text = "Opacity: " .. math.floor(v * 100 + 0.5) .. "%"
					hexBox.Text = rgbToHex(color)
					rgbBox.Text = string.format("R: %d  G: %d  B: %d", color.R * 255, color.G * 255, color.B * 255)
					vGradient.Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, 1))
					}
					if callback then callback(color) end
				end

				local function pickHS(input)
					modal.Draggable = false
					h = math.clamp((input.Position.X - hsBox.AbsolutePosition.X) / hsBox.AbsoluteSize.X, 0, 1)
					s = 1 - math.clamp((input.Position.Y - hsBox.AbsolutePosition.Y) / hsBox.AbsoluteSize.Y, 0, 1)
					updateUI()
				end

				local function pickV(input)
					modal.Draggable = false
					v = math.clamp((input.Position.X - vSlider.AbsolutePosition.X) / vSlider.AbsoluteSize.X, 0, 1)
					updateUI()
				end

				hsBox.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						pickHS(input)
						local move, release
						move = UserInputService.InputChanged:Connect(function(i)
							if i.UserInputType == Enum.UserInputType.MouseMovement then pickHS(i) end
						end)
						release = UserInputService.InputEnded:Connect(function(i)
							if i.UserInputType == Enum.UserInputType.MouseButton1 then
								modal.Draggable = true
								move:Disconnect()
								release:Disconnect()
							end
						end)
					end
				end)

				vSlider.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						pickV(input)
						local move, release
						move = UserInputService.InputChanged:Connect(function(i)
							if i.UserInputType == Enum.UserInputType.MouseMovement then pickV(i) end
						end)
						release = UserInputService.InputEnded:Connect(function(i)
							if i.UserInputType == Enum.UserInputType.MouseButton1 then
								modal.Draggable = true
								move:Disconnect()
								release:Disconnect()
							end
						end)
					end
				end)

				hexBox.FocusLost:Connect(function(enter)
					if enter then
						local col = hexToColor(hexBox.Text)
						if col then
							h, s, v = Color3.toHSV(col)
							updateUI()
						else
							hexBox.Text = rgbToHex(getCurrentColor())
						end
					end
				end)

				rgbBox.FocusLost:Connect(function(enter)
					if enter then
						local r, g, b = rgbBox.Text:match("R:%s*(%d+)%s*G:%s*(%d+)%s*B:%s*(%d+)")
						r, g, b = tonumber(r), tonumber(g), tonumber(b)
						if r and g and b then
							r, g, b = math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255)
							local col = Color3.fromRGB(r, g, b)
							h, s, v = Color3.toHSV(col)
							updateUI()
						else
							local c = getCurrentColor()
							rgbBox.Text = string.format("R: %d  G: %d  B: %d", c.R * 255, c.G * 255, c.B * 255)
						end
					end
				end)

				updateUI()
			end

			button.MouseButton1Click:Connect(openPicker)
			return button
		end

		table.insert(tabs, newTab)

		if #tabs == 1 then
			showTab()
		end

		return newTab
	end

	local themeTab = CreateTab("Theme")

	themeTab:TextLabel("Background:")
	themeTab:ColorWheel("Background", Theme.BackgroundColor, function(color)
		Theme.BackgroundColor = color
		ApplyTheme(screenGui)
	end)

	themeTab:TextLabel("Text:")
	themeTab:ColorWheel("Text", Theme.TextColor, function(color)
		Theme.TextColor = color
		ApplyTheme(screenGui)
	end)

	themeTab:TextLabel("Accent:")
	themeTab:ColorWheel("Accent", Theme.AccentColor, function(color)
		Theme.AccentColor = color
		for _, tab in pairs(tabs) do
			tab.Button.BackgroundColor3 = Theme.AccentColor
		end
	end)

	themeTab:Slider("Font Size", 10, 30, Theme.FontSize, function(size)
		Theme.FontSize = size
		ApplyTheme(screenGui)
	end)

	local fonts = { "SourceSans", "Arial", "Gotham", "Cartoon", "Code", "SciFi" }
	themeTab:Dropdown("Font Style", fonts, 1, function(_, selected)
		Theme.Font = Enum.Font[selected]
		ApplyTheme(screenGui)
	end)

	return {
		Gui = screenGui,
		Window = window,
		Theme = Theme,
		ApplyTheme = ApplyTheme,
		CreateTab = CreateTab,
		Tabs = tabs
	}
end

return UILib
