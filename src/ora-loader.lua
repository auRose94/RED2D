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
    local tFileType = type(fileName)
    assert(tFileType == "string" or tFileType == "userdata", "missing fileName! " .. type(fileName) .. " given!")
    self.layers = {}
    self:load(fileName)
end

function OraLoader:loadData(file)
end

function OraLoader:load(fileName)
    local tFileType = type(fileName)
    if tFileType == "string" then
        local fileName = fileName or self.fileName
        if self.lastModified and self.fileName == fileName then
            local now = GetLastModified(fileName)
            if now == self.lastModified then
                return
            end
        end
    end

    local file = nil
    local mountpoint = nil
    if tFileType == "string" then
        mountpoint = fileName:match("^.+[/|\\](.+).ora$")
        file = love.filesystem.newFile(fileName)
    elseif tFileType == "userdata" then
        file = fileName
        fileName = file:getFilename()
        mountpoint = fileName:match("^.+[/|\\](.+).ora$")
    end
    local saveDir = love.filesystem.getSaveDirectory()
    file:open("r")
    local contents, size = file:read("data")
    local zipPath = mountpoint .. ".zip"
    file:close()
    local renameSuccess, message = love.filesystem.write(zipPath, contents, size)
    assert(renameSuccess, message)

    assert(love.filesystem.mount(zipPath, mountpoint, true), "Couldn't mount path " .. zipPath)
    --local archive = Archive:read(fileName)
    --local disk = archive:GetDisk(0)
    --local entries = disk:GetFolderEntries("")
    local stack = nil
    local imageFiles = {}
    local files = love.filesystem.getDirectoryItems(mountpoint)
    for _, itemName in ipairs(files) do
        local index = mountpoint .. "/" .. itemName
        local info = love.filesystem.getInfo(index)
        if info.type == "file" and itemName == "stack.xml" then
            stack = love.filesystem.newFile(index, "r")
        elseif info.type == "directory" and itemName == "data" then
            local dataFiles = love.filesystem.getDirectoryItems(index)
            for _, subItemName in ipairs(dataFiles) do
                local subIndex = mountpoint .. "/" .. itemName .. "/" .. subItemName
                table.insert(
                    imageFiles,
                    {
                        index = subIndex,
                        entry = love.filesystem.newFile(subIndex, "r")
                    }
                )
            end
        end
    end
    assert(stack, "Stack couldn't be found inside")
    assert(#imageFiles > 0, "Not a single image was found inside")

    local stackHandler = xmlHandlerTree:new()
    local stackparser = xml2lua.parser(stackHandler)
    local stackContent = stack:read()
    stack:open("r")
    stackparser:parse(stackContent)
    stack:close()

    local image = stackHandler.root.image
    self.width = image._attr.w
    self.height = image._attr.h
    for i, p in pairs(image.stack.layer) do
        if p._attr then
            local compositeOp = p._attr["composite-op"]
            local opacity = p._attr.opacity
            local src = p._attr.src
            local name = p._attr.name
            local visible = p._attr.visibility == "visible"
            local lx, ly = p._attr.x, p._attr.y
            local imageFile = nil
            for ii, ie in pairs(imageFiles) do
                if ie.index:find(src) then
                    imageFile = ie.entry
                    break
                end
            end
            if imageFile and visible then
                imageFile:open("r")
                local fileData = imageFile:read("data")
                imageFile:close()
                if fileData then
                    local imageData = love.image.newImageData(fileData)
                    if imageData then
                        table.insert(
                            self.layers,
                            {
                                name = name,
                                x = lx,
                                y = ly,
                                opacity = opacity,
                                imageData = imageData,
                                image = love.graphics.newImage(imageData)
                            }
                        )
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
