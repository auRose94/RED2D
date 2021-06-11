local zip = require("3rdParty.zip")
local Archive = require("3rdParty.zip.Archive")

local xml2lua = require("3rdParty.xml2lua.xml2lua")
local xmlHandlerTree = require("3rdParty.xml2lua.xmlhandler.tree")

local OraLoader = inheritsFrom()

function GetLastModified(fileName)
    local info = love.filesystem.getInfo(fileName)
    if info then
        return info.modtime
    end
    return nil
end

function OraLoader:init(fileName)
    assert(type(fileName) == "string", "missing fileName! " .. type(fileName) .. " given!")
    self.layers = {}
    self:load(fileName)
end

function OraLoader:load(fileName)
    fileName = fileName or self.fileName
    if self.lastModified and self.fileName == fileName then
        local now = GetLastModified(fileName)
        if now == self.lastModified then
            return
        end
    end
    local archive = Archive:read(fileName)
    local disk = archive:GetDisk(0)
    local entries = disk:GetFolderEntries("")
    local stack = nil
    local imageFiles = {}
    for index, entry in disk:GetEntryIterator() do
        if index == "stack.xml" then
            stack = entry
        elseif string.match(index, "data/") and index ~= "data/" then
            table.insert(imageFiles, {
                index = index,
                entry = entry
            })
        end
    end
    assert(stack, "Stack couldn't be found inside")
    assert(#imageFiles > 0, "Not a single image was found inside")

    local stackHandler = xmlHandlerTree:new()
    local stackparser = xml2lua.parser(stackHandler)
    stack:open()
    stackparser:parse(stack:read("*a"))
    stack:close()

    local image = stackHandler.root.image
    self.width = image._attr.w
    self.height = image._attr.h
    for i, p in pairs(image.stack) do
        for ai, ap in pairs(p) do
            if ap._attr then
                local compositeOp = ap._attr["composite-op"]
                local opacity = ap._attr.opacity
                local src = ap._attr.src
                local name = ap._attr.name
                local visible = ap._attr.visibility == "visible"
                local lx, ly = ap._attr.x, ap._attr.y
                local imageFile = nil
                for ii, ie in pairs(imageFiles) do
                    if ie.index == src then
                        imageFile = ie.entry
                        break
                    end
                end
                if imageFile and visible then
                    imageFile:open()
                    local fileData = love.filesystem.newFileData(imageFile:read("*a"), name)
                    imageFile:close()
                    if fileData then
                        local imageData = love.image.newImageData(fileData)
                        if imageData then
                            table.insert(self.layers, {
                                name = name,
                                x = lx,
                                y = ly,
                                opacity = opacity,
                                imageData = imageData,
                                image = love.graphics.newImage(imageData)
                            })
                        end
                    end
                end
            end
        end
    end
    self.fileName = fileName
    self.lastModified = GetLastModified(fileName)
end

function OraLoader:count()
    return #self.layers
end

function OraLoader:getLayer(name)
    assert(type(name) == "string", "Name is not a string")
    assert(self.layers, "Missing layers")
    local layer = nil
    for i, l in pairs(self.layers) do
        if l.name == name then
            layer = l
            break
        end
    end
    return layer
end

function OraLoader:getOpacity(name)
    local layer = self:getLayer(name)
    if layer then
        return layer.opacity
    end
end

function OraLoader:getOffset(name)
    local layer = self:getLayer(name)
    if layer then
        return layer.x, layer.y
    end
end

function OraLoader:getImage(name)
    local layer = self:getLayer(name)
    if layer then
        return layer.image
    end
end

function OraLoader:getImageData(name)
    local layer = self:getLayer(name)
    if layer then
        return layer.imageData
    end
end

return OraLoader
