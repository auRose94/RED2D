function _G.inheritsFrom(baseClass)
	local new_class = {}
	new_class.__index = new_class

	if baseClass ~= nil then
		for key, value in pairs(baseClass) do
			if type(value) == "function" and new_class[key] == nil then
				new_class[key] = value
			end
		end
	end

	local call = function(cls, ...)
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
		assert(type(theClass) == "table", "base_object is not a table")
		assert(type(theClass.class) == "function", "base_object is not a class")
		local cur_class = new_class

		while cur_class do
			if cur_class == theClass then
				return true
			end
			cur_class = cur_class:superClass()
		end

		return false
	end

	return new_class
end

function _G.clone(base_object, clone_object)
	if type(base_object) ~= "table" then
		return nil
	end
	if type(clone_object) ~= "table" then
		return nil
	end
	clone_object.__index = base_object
	return setmetatable(clone_object, clone_object)
end

function _G.isa(clone_object, base_object)
	if type(base_object) ~= "table" or type(base_object.class) ~= "function" then
		return false
	end
	if type(clone_object) ~= "table" or type(clone_object.class) ~= "function" then
		return false
	end
	local cur_class = clone_object:class()

	while cur_class do
		if cur_class == base_object then
			return true
		end
		cur_class = cur_class:superClass()
	end

	return false
end