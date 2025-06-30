module("util.async", package.seeall)



function loadFile(_, data)
	if type(data) == "string" then
		CAsyncFile:GetSingleton():LoadFile(data)
	elseif type(data) == "table" then
		CAsyncFile:GetSingleton():LoadFiles(table.concat(data, ";"))
	else
		assert(false)
	end
end

local _callback
function setCallback(_, cb)
	_callback = cb
end

-- type:'loadone'  'finish'
local function onAsyncFileLoadCb(type, filename)
	if _callback then
		_callback(type, filename)
	end
end

CAsyncFile:GetSingleton():SetLoadCallback(onAsyncFileLoadCb)

