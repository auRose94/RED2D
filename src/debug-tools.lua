local EditorWindow = require "tree-editor-window"
local Window = require "gui-window"
local Button = require "elem-button"
local Entity = require "entity"
local DebugTools = inheritsFrom(Entity)

function DebugTools:init()
    Entity.init(self, _G.level)
    self.debugDrawPhysics =
        Button(
        "Debug Physics",
        {
            callback = function()
                _G.debugDrawPhysics = not _G.debugDrawPhysics
            end
        }
    )
    self.debugDrawNPCView =
        Button(
        "NPC View",
        {
            x = self.debugDrawPhysics:getRight(),
            callback = function()
                _G.debugDrawNPCView = not _G.debugDrawNPCView
            end
        }
    )
    self.showTreeEditor =
        Button(
        "Tree Editor",
        {
            x = self.debugDrawNPCView:getRight(),
            callback = function()
                _G.showTreeEditor = not _G.showTreeEditor
            end
        }
    )
    self.showFPS =
        Button(
        "Show FPS",
        {
            x = self.showTreeEditor:getRight(),
            callback = function()
                _G.showFPS = not _G.showFPS
            end
        }
    )
    self.showDebugTools =
        Button(
        "Hide (F12)",
        {
            x = self.showFPS:getRight(),
            callback = function()
                _G.showDebugTools = not _G.showDebugTools
            end
        }
    )
    self.treeEditor = EditorWindow(self)
    self.elements = {
        self.debugDrawPhysics,
        self.debugDrawNPCView,
        self.showTreeEditor,
        self.showFPS,
        self.showDebugTools,
        self.treeEditor
    }
end

return DebugTools
