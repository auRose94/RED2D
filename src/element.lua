
local ElementClass = inheritsFrom(nil)

function ElementClass:init(...)
    self.elements = {}
    for i = 1, select('#', ...) do
        local value = select(i, ...)
        local tValue = type(value)
        if tValue == "table" then
            if ElementClass.isa(value, ElementClass) then
                table.insert(self.elements, value)
                value.parent = self
            else
                for pKey, pValue in pairs(value) do
                    table.insert(self, pKey, pValue)
                end
            end
        elseif tValue == "string" then
            self.text = value
        end
    end

end

return ElementClass