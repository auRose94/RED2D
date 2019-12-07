
local module = {}

function module.isStringTable(tableData)
	assert(type(tableData) == "table", "Needs to be table")
	for i, v in pairs(tableData) do
		if type(i) == "string" then
			return true
		end
	end
	return false
end

function module.stringifyArray(array, depth, newLine)
	assert(type(array) == "table", "Needs to be table")
	local line = "{ "
	for i, value in pairs(array) do
		if newLine and #array > 3 then
			line = line.."\n"
			line = line..string.rep("\t", depth)
		end
		if type(value) == "table" then
			if module.isStringTable(value) then
				line = line..module.stringify(value, depth+1, newLine)
			else
				line = line..module.stringifyArray(value, depth, newLine)
			end
		elseif type(value) == "string" then
			line = line.."\""..value.."\""
		elseif type(value) == "function" then
			line = line.."\"function\""
		elseif type(value) == "userdata" then
			line = line.."\"userdata\""
		elseif type(value) == "boolean" then
			if value then
				line = line.."true"
			else
				line = line.."false"
			end
		else
			line = line..value
		end
		if i ~= #array then
			line = line..", "
		end
	end
	if newLine and #array > 3 then
		line = line.."\n"
		line = line..string.rep("\t", depth-1)
	end
	line = line.." }"
	return line
end

function module.stringify(tableData, depth, newLine)
	assert(type(tableData) == "table", "Needs to be table")
	depth = depth or 1
	if not module.isStringTable(tableData) then
		return module.stringifyArray(tableData, depth, newLine)
	end
	local lines = {}
	for name, item in pairs(tableData) do
		local line = ""
		if newLine then
			line = line..string.rep("\t", depth)
		end
		line = line.."["
		if type(name) == "string" then
			line = line.."\""..name.."\""
		else
			line = line..name
		end
		line = line.."] = "
		if type(item) == "table" then
			line = line..module.stringify(item, depth+1, newLine)
		elseif type(item) == "string" then
			line = line.."\""..item.."\""
		elseif type(item) == "function" then
			line = line.."\"function\""
		elseif type(item) == "userdata" then
			line = line.."\"userdata\""
		elseif type(item) == "boolean" then
			if item then
				line = line.."true"
			else
				line = line.."false"
			end
		else
			line = line..item
		end
		table.insert(lines, line)
	end
	local data = "{ "
	if newLine then
		data = data.."\n"
	end
	for i, line in pairs(lines) do
		data = data..line
		if i ~= #lines then
			data = data..","
		end
		if newLine then
			data = data.."\n"
		else
			data = data.." "
		end
	end
	if newLine and depth > 1 then
		data = data..string.rep("\t", depth-1)
	end
	data=data.."}"
	return data
end

function module.echo(...)
	local args = {...}
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		local t = type(value)
		if t == "table" then
			args[i] = module.stringify(value, 1, true)
		end
	end
	print(unpack(args))
end

function module.convert2HEX(...)
	local hexadecimal = '#'
	local rgba = { ... }
	for key = 1, #rgba do
		local value = rgba[key]
		local hex = ''

		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex
		end

		if(string.len(hex) == 0)then
			hex = '00'
		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end
		hexadecimal = hexadecimal .. hex
	end
	return hexadecimal
end

for key,value in pairs(module) do
	if type(value) == "function" and _G[key] == nil then
		_G[key] = value
	end
end

return module