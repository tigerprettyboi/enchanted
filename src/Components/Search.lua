local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)

local New = Creator.New
local Spring = Flipper.Spring.new

return function(Parent, Window, OnSearch)
	local Search = {
		Query = "",
		Results = {},
		IsOpen = false,
	}

	local Library = require(Root)

	-- Search Icon (Lucide)
	local SearchIcon = Library:GetIcon("search") or "rbxassetid://10734896206"

	-- Results Dropdown
	Search.ResultsFrame = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 1, 4),
		BackgroundTransparency = 0,
		Visible = false,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		ThemeTag = {
			BackgroundColor3 = "DropdownHolder",
			ScrollBarImageColor3 = "Text",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
		}),
		New("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		}),
	})

	-- Search Input
	Search.Input = New("TextBox", {
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.fromOffset(24, 0),
		BackgroundTransparency = 1,
		PlaceholderText = "Search...",
		Text = "",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		ClipsDescendants = true,
		ThemeTag = {
			TextColor3 = "Text",
			PlaceholderColor3 = "SubText",
		},
	})

	-- Search Container
	Search.Frame = New("Frame", {
		Size = UDim2.new(0, 180, 0, 28),
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 0.92,
		Parent = Parent,
		ThemeTag = {
			BackgroundColor3 = "Element",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		New("UIStroke", {
			Transparency = 0.7,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		New("ImageLabel", {
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.new(0, 8, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = SearchIcon,
			ImageTransparency = 0.4,
			ThemeTag = {
				ImageColor3 = "Text",
			},
		}),
		Search.Input,
		Search.ResultsFrame,
	})

	-- Hover effects
	local Motor, SetTransparency = Creator.SpringMotor(0.92, Search.Frame, "BackgroundTransparency")

	Creator.AddSignal(Search.Frame.MouseEnter, function()
		SetTransparency(0.88)
	end)
	Creator.AddSignal(Search.Frame.MouseLeave, function()
		if not Search.Input:IsFocused() then
			SetTransparency(0.92)
		end
	end)

	-- Focus effects
	Creator.AddSignal(Search.Input.Focused, function()
		SetTransparency(0.85)
	end)
	Creator.AddSignal(Search.Input.FocusLost, function()
		SetTransparency(0.92)
		task.delay(0.1, function()
			if not Search.Input:IsFocused() then
				Search:CloseResults()
			end
		end)
	end)

	-- Create result item
	function Search:CreateResultItem(data)
		local isTab = data.Type == "Tab"
		
		local ResultItem = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			Text = "",
			ThemeTag = {
				BackgroundColor3 = "DropdownOption",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			New("ImageLabel", {
				Size = UDim2.fromOffset(14, 14),
				Position = UDim2.new(0, 8, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Image = isTab and (Library:GetIcon("folder") or "") or (Library:GetIcon("settings") or ""),
				ThemeTag = {
					ImageColor3 = isTab and "Accent" or "SubText",
				},
			}),
			New("TextLabel", {
				Size = UDim2.new(1, -50, 0, 14),
				Position = UDim2.fromOffset(28, 5),
				BackgroundTransparency = 1,
				Text = data.Title or data.Name,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
				ThemeTag = {
					TextColor3 = "Text",
				},
			}),
			New("TextLabel", {
				Size = UDim2.new(1, -50, 0, 10),
				Position = UDim2.fromOffset(28, 19),
				BackgroundTransparency = 1,
				Text = isTab and "Tab" or (data.TabName or "Element"),
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
				ThemeTag = {
					TextColor3 = "SubText",
				},
			}),
		})

		-- Hover effect
		local ItemMotor, SetItemTransparency = Creator.SpringMotor(1, ResultItem, "BackgroundTransparency")
		Creator.AddSignal(ResultItem.MouseEnter, function()
			SetItemTransparency(0.9)
		end)
		Creator.AddSignal(ResultItem.MouseLeave, function()
			SetItemTransparency(1)
		end)
		Creator.AddSignal(ResultItem.MouseButton1Click, function()
			if OnSearch then
				OnSearch(data)
			end
			Search.Input.Text = ""
			Search:CloseResults()
		end)

		return ResultItem
	end

	-- Perform search
	function Search:DoSearch(query)
		Search.Query = query
		
		-- Clear old results
		for _, child in ipairs(Search.ResultsFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		if query == "" or #query < 1 then
			Search:CloseResults()
			return
		end

		local results = {}
		query = query:lower()

		-- Search in AllElements (registered by Library)
		if Library.AllElements then
			for _, elementData in ipairs(Library.AllElements) do
				local title = (elementData.Title or elementData.Name or ""):lower()
				local desc = (elementData.Description or ""):lower()
				
				if title:find(query, 1, true) or desc:find(query, 1, true) then
					table.insert(results, elementData)
				end
			end
		end

		-- Show results
		if #results > 0 then
			Search:OpenResults()
			for i, data in ipairs(results) do
				if i > 8 then break end -- Limit results
				local item = Search:CreateResultItem(data)
				item.LayoutOrder = i
				item.Parent = Search.ResultsFrame
			end
			
			local count = math.min(#results, 8)
			Search.ResultsFrame.Size = UDim2.new(1, 0, 0, count * 34 + 8)
		else
			Search:CloseResults()
		end
	end

	function Search:OpenResults()
		Search.IsOpen = true
		Search.ResultsFrame.Visible = true
	end

	function Search:CloseResults()
		Search.IsOpen = false
		Search.ResultsFrame.Visible = false
	end

	-- Listen to input changes
	Creator.AddSignal(Search.Input:GetPropertyChangedSignal("Text"), function()
		Search:DoSearch(Search.Input.Text)
	end)

	return Search
end
