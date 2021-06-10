
local defaultMaxDepth = 1
local arrayNewlineMin = 4

function _G.CheckValue(t, ...)
	for i, v in ipairs(t) do
		for argI = 1, select("#", ...) do
			local value = select(argI, ...)
			if v == value then
				return true
			end
		end
	end
	return false
end

function _G.UniquePush(t, value)
	if not CheckValue(t, value) then
		table.insert(t, value)
	end
end

function _G.sortedKeys(tbl, sortFunction)
	sortFunction = sortFunction or function(a, b)
		return a < b
	end
	local keys = {}
	for key, value in pairs(tbl) do
		table.insert(keys, key)
	end

	table.sort(keys, sortFunction)

	return keys
end

function _G.isStringTable(tableData)
	assert(type(tableData) == "table", "Needs to be table")
	for i, v in pairs(tableData) do
		if type(i) == "string" then
			return true
		end
	end
	return false
end

function _G.stringifyArray(array, depth, newLine, maxDepth)
	maxDepth = maxDepth or defaultMaxDepth
	assert(type(array) == "table", "Needs to be table")
	local line = "{ "
	for i, value in pairs(array) do
		if newLine and #array > arrayNewlineMin then
			line = line .. "\n"
			line = line .. string.rep("\t", depth)
		end
		if type(value) == "table" then
			if depth <= maxDepth then
				if isStringTable(value) then
					line = line .. stringify(value, depth + 1, newLine)
				else
					line = line .. stringifyArray(value, depth, newLine)
				end
			else
				line = line .. "{--[[Table depth exceeded]]--}"
			end
		elseif type(value) == "string" then
			line = line .. '"' .. value .. '"'
		elseif type(value) == "function" then
			line = line .. '"function"'
		elseif type(value) == "userdata" then
			line = line .. '"userdata"'
		elseif type(value) == "boolean" then
			if value then
				line = line .. "true"
			else
				line = line .. "false"
			end
		else
			line = line .. value
		end
		if i ~= #array then
			line = line .. ", "
		end
	end
	if newLine and #array > arrayNewlineMin then
		line = line .. "\n"
		line = line .. string.rep("\t", depth - 1)
	end
	line = line .. " }"
	return line
end

function _G.stringify(tableData, depth, newLine, maxDepth)
	maxDepth = maxDepth or defaultMaxDepth
	assert(type(tableData) == "table", "Needs to be table")
	depth = depth or 1
	if not isStringTable(tableData) then
		return stringifyArray(tableData, depth, newLine)
	end
	local lines = {}
	for name, item in pairs(tableData) do
		local line = ""
		if newLine then
			line = line .. string.rep("\t", depth)
		end
		line = line .. "["
		if type(name) == "string" then
			line = line .. '"' .. name .. '"'
		else
			line = line .. name
		end
		line = line .. "] = "
		if type(item) == "table" then
			if depth <= maxDepth then
				line = line .. stringify(item, depth + 1, newLine)
			else
				line = line .. "{--[[Table depth exceeded]]--}"
			end
		elseif type(item) == "string" then
			line = line .. '"' .. item .. '"'
		elseif type(item) == "function" then
			line = line .. '"function"'
		elseif type(item) == "userdata" then
			line = line .. '"userdata"'
		elseif type(item) == "boolean" then
			if item then
				line = line .. "true"
			else
				line = line .. "false"
			end
		else
			line = line .. item
		end
		table.insert(lines, line)
	end
	local data = "{ "
	if newLine then
		data = data .. "\n"
	end
	for i, line in pairs(lines) do
		data = data .. line
		if i ~= #lines then
			data = data .. ","
		end
		if newLine then
			data = data .. "\n"
		else
			data = data .. " "
		end
	end
	if newLine and depth > 1 then
		data = data .. string.rep("\t", depth - 1)
	end
	data = data .. "}"
	return data
end

function _G.echo(...)
	local args = { ... }
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		local t = type(value)
		if t == "table" then
			args[i] = stringify(value, 1, true)
		end
	end
	print(unpack(args))
end

function _G.convert2HEX(...)
	local hexadecimal = "#"
	local chanels = { ... }
	for key = 1, #chanels do
		local value = chanels[key]
		local hex = ""

		while (value > 0) do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub("0123456789ABCDEF", index, index) .. hex
		end

		if (string.len(hex) == 0) then
			hex = "00"
		elseif (string.len(hex) == 1) then
			hex = "0" .. hex
		end
		hexadecimal = hexadecimal .. hex
	end
	return hexadecimal
end

function _G.clone(t)
	assert(type(t) == "table", "argument not a table")
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end

function _G.tableMerge(t1, t2)
	-- https://stackoverflow.com/a/1283608
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

