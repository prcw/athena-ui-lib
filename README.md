# Athena UI Library

A sleek, modular Roblox UI framework featuring resizable windows, theming, sliders, dropdowns, color pickers, keybinds, and more.

---

## ✨ Features

- Draggable, Resizable Windows  
- Built-in Theme System  
- Sliders, Dropdowns, Color Pickers  
- Checkboxes & Keybinds  
- Tab-Based Layout  
- Auto Layout & Padded Components  

---

## 📦 Installation

Paste `UILib.lua` into your project, then:

```lua
local UILib = require(path.to.UILib)
```

---

## 🔧 Usage Example

```lua
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize

local screenWidth = screenSize.X
local screenHeight = screenSize.Y

local window = UILib.CreateWindow("Athena", Vector2.new(screenWidth / 2, screenHeight / 2), Vector2.new(400, 300))
local tab = window.CreateTab("Main")

tab:Slider("Volume", 0, 100, 50, function(value)
	print("Volume:", value)
end)

tab:Checkbox("Enable Feature", true, function(state)
	print("Enabled:", state)
end)

tab:Keybind("Activate", "E", function(key)
	print("Keybind:", key)
end)
```

---

## 🎨 Theming

A "Theme" tab is included automatically, with real-time updates for:

- Background color  
- Text color  
- Accent color  
- Font & size  

---

## 📚 Components

| Method      | Description                               |
|-------------|-------------------------------------------|
| TextLabel   | Simple left-aligned label                 |
| Slider      | Integer slider with label & value         |
| Checkbox    | Toggle state on/off                       |
| Dropdown    | Select from predefined options            |
| Keybind     | Set a key or mouse button                 |
| ColorWheel  | Full HSV/RGB picker with preview          |
