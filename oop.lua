function _G.inheritsFrom(baseClass)

	local new_class = {}
	new_class.__index = new_class

	if baseClass ~= nil then
		for key,value in pairs(baseClass) do
			if type(value) == "function" and new_class[key] == nil then
				new_class[key] = value
			end
		end
	end

	local call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:init(...)
		return self
	end

	local meta = { __call = call }
	if nil ~= baseClass then
		meta.__index = baseClass
	end
	setmetatable(new_class, meta)

	-- Implementation of additional OO properties starts here --

	-- Return the class object of the instance
	function new_class:class()
			return new_class
	end

	-- Return the super class object of the instance
	function new_class:superClass()
			return baseClass
	end

	-- Return true if the caller is an instance of theClass
	function new_class:isa(theClass)
			local b_isa = false

			local cur_class = new_class

			while ( nil ~= cur_class ) and ( false == b_isa ) do
					if cur_class == theClass then
							b_isa = true
							break;
					else
							cur_class = cur_class:superClass()
					end
			end

			return b_isa
	end

	return new_class
end

function _G.clone(base_object, clone_object)
  if type( base_object ) ~= "table" then
    return clone_object or base_object 
  end
  clone_object = clone_object or {}
  clone_object.__index = base_object
  return setmetatable(clone_object, clone_object)
end

function _G.isa(clone_object, base_object)
  local clone_object_type = type(clone_object)
  local base_object_type = type(base_object)
  if clone_object_type ~= "table" and base_object_type ~= table then
    return clone_object_type == base_object_type
  end
  local index = clone_object.__index
  local _isa = index == base_object
  while not _isa and index ~= nil do
    index = index.__index
    _isa = index == base_object
  end
  return _isa
end