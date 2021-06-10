
local ElementClass = inheritsFrom(nil)

function ElementClass:init(...)
    self.elements = {}
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
    for i = 1, select('#', ...) do
        local value = select(i, ...)
        local tValue = type(value)
        echo(value)
        if tValue == "table" then
            if isa(value, ElementClass) then
                table.insert(self.elements, value)
                value.parent = self
            else
                self = tableMerge(self, value)
            end
        elseif tValue == "string" then
            self.text = value
        end
    end

end

return ElementClass