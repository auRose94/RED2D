local GUIButton = require ".gui.button"
local GUIDropdown = inheritsFrom(GUIButton)

function GUIDropdown:init(parent, menu, text)
	GUIButton.init(self, parent, text)
end