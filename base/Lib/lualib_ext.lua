

------------number------------
--显示53位内的整数 而不是科学计数法
function numbertostring(n)
    if n < 0 then
        return "-" .. numbertostring(-n)
    end

    --会出现小数的问题 什么情况?
    if n <= 10^13 then
        return tostring(n)
    end

    if math.modf(n) ~= n then
        return tostring(n)
    end

    local low = math.fmod(n, 10^13)
    local high = math.modf(n / 10^13)

    local str = string.format("%s%013s", tostring(high), tostring(low))
    return str

 -- 备用方案
 	-- if 0 == n then
 	-- 	return "0"
 	-- end
	-- local ret = ""
	-- while(n > 0) do
	--     ret = (n % 10) .. ret
	--     n   = math.floor(n/10)
	-- end
	-- return ret  
end


------------string------------
function string.strtox16(buff)
	return (string.gsub(buff, ".", function(c)
		return string.format("%02X",string.byte(c))
	end))
end

function string.x16tostr(buff)
	return (string.gsub(buff, "..", function (c)
		local n = tonumber(c, 16)
		return string.char(n)
	end))
end

--打印出16进制内容
function string.dumpex(buff)
	return (string.gsub(buff, ".", function(c)
		return string.format("%02X ",string.byte(c))
	end))
end


------------table------------
--格式输出table内容
local function tableAddress(t)
    local str
    if _G._tostring then
    	str = _G._tostring(t)
    else
    	_G.tostring(t)
    end
    return string.gsub(str, "^table: ", "") or ""
end

local function getInnerRef(tbl)
    local loaded = {}
    local ref = {}
    local function _get(t)
        if loaded[t] then
            ref[t] = t
            return
        end
        loaded[t] = t
        for k, v in pairs(t) do
            if type(k) == "table" then
                _get(k)
            elseif type(v) == "table" then
                _get(v)
            end
        end
    end
    _get(tbl)
    return ref
end

function table.tostring(t, level, pre)
	local loaded = {}
	local showAddress = getInnerRef(t)
	local insert = table.insert
	local function _tostring(t, level, pre)
		level = level and (level - 1) or 10
		if level < 0 then
			return pre .. "..."
		end

		pre = pre or ""
		if next(t) == nil then
			return pre .. "{}"
		end

		loaded[t] = t 

		local strs = {}
		insert(strs, pre .. "{")
		if showAddress[t] then
            insert(strs, tableAddress(t))
		end
		
		insert(strs, "\n")
		pre = pre .. "  "

		for k, v in pairs(t) do
			insert(strs, pre)

			if type(k) == "table" then
                if loaded[t] then
                    insert(strs, tableAddress(t))
                else
                    insert(strs, _tostring(k, level, pre))
                end
			elseif type(k) == "number" then
				insert(strs, "[" .. numbertostring(k) .. "]")
			else
				insert(strs, _G.tostring(k))
			end

			insert(strs, "=")

			if type(v) == "table" then
                if loaded[v] then
                    insert(strs, tableAddress(v))
                else
                    insert(strs, "\n")
                    insert(strs, _tostring(v, level, pre))
                end
			elseif type(v) == "number" then
				insert(strs, numbertostring(v))
			elseif type(v) == "string" then
				insert(strs, '"' .. v .. '"')
			else
				insert(strs, _G.tostring(v))
			end

			insert(strs, ",\n")
		end

		strs[#strs] = ","  --last ",\n"
		insert(strs, "\n" .. string.sub(pre, 1, -3) .. "}")

		return table.concat(strs)
	end
	return _tostring(t, level, pre)
end


---紧缩格式
--限制数字key只能用于数组
function table.tostringex(t)
	local strs = {}
	table.insert(strs, "{")

	for k, v in pairs(t) do
		if type(k) == "table" then
			table.insert(strs, table.tostringex(k))
			table.insert(strs, "=")
		elseif type(k) == "number" then
			--do nothing
		else
			table.insert(strs, _G.tostring(k))
			table.insert(strs, "=")
		end

		if type(v) == "table" then
			table.insert(strs, table.tostringex(v))
		elseif type(v) == "number" then
			table.insert(strs, numbertostring(v))
		elseif type(v) == "string" then
			table.insert(strs, '"' .. v .. '"')
		else
			table.insert(strs, _G.tostring(v))
		end
		table.insert(strs, ",")
	end
	table.insert(strs, "}")
	return table.concat(strs)
end



-------------os----------------

function os.dir(path, depth, filter)
	local max = 100
	if type(depth) == "boolean" then
		depth = depth == false and 1 or max
	elseif type(depth) == "number" then
		depth = depth
	else
		depth = max
	end

	local folders = {}
	local files = {}

	local function _dir(path, depth)
		depth = depth - 1
		for entry in lfs.dir(path) do
			if entry ~= '.' and entry ~= '..' then
				local path = path .. '/' .. entry
				local attr = lfs.attributes(path)

				local isFolder = attr.mode == 'directory'
				if nil == filter or filter(path, isFolder) then
					if isFolder then
						table.insert(folders, path)
					else
						table.insert(files, path)
					end
				end

				if isFolder and depth > 0 then
					_dir(path, depth)
				end
			end
		end
	end

	_dir(path, depth)
    return files, folders 
end

function os.files(dir, match)
	if nil == match then
		return (os.dir(dir))
	end

	local files = os.dir(dir, true, function (path, isFolder)
						if isFolder then
							return false
						end
						return string.match(path, match)
					end)
	return files
end

-- {
--   modification=1486266066,
--   rdev=3,
--   size=213,
--   ino=0,
--   mode="file",
--   access=1486266066,
--   nlink=1,
--   uid=0,
--   gid=0,
--   permissions="rw-rw-rw-",
--   dev=3,
--   change=1486266066,
-- }
function os.filetime(path)
	local info = lfs.attributes(path)
	return info and info.modification or 0
end












