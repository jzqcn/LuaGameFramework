require "logging"

local SHOW_LOG_FILE_POS = true

local function _any2str(value)
	if type(value) == "string" then
		return '"' .. value .. '"'
	elseif type(value) == "table" then
		return table.tostring(value)
	elseif type(value) == "number" then
		return numbertostring(value)
	else
		local str = tostring(value) or "Unknown object!"
		return str
	end
end

local function _writeLog(value) 
	local str = _any2str(value)

	if SHOW_LOG_FILE_POS then
		local what = debug.getinfo(3)
		local strPosInfo = string.format("%s line:%d", what.short_src, what.currentline)
		str = string.format("%-30s \t\t %s", str, strPosInfo)
	end

	str = string.gsub(str, "%%", "$")
	WriteLog(str)
end

-------------extend-------------------
local old = logging.tostring
logging.tostring = function (value)
	return _any2str(value)
end
-------------extend-------------------



module(..., package.seeall)

debug = false

local LEVEL_ABBR =
{
	["DEBUG"] = "D", 
	["INFO"	] = "I", 
	["WARN"	] = "W", 
	["ERROR"] = "E", 
	["FATAL"] = "F", 
}

local sn = 0

local function format(chan, level, log, uniq)
	local L = LEVEL_ABBR[level]
	
	if not uniq then
		return string.format("[%s-%s]# %s", L, chan, log)
	end
	
	sn = sn + 1
	return string.format("[%04d-%s-%s]# %s", sn, L, chan, log)
end

local _logHook = nil
function setLogHook(hook)
	_logHook = hook
end

local function writeHookLog(value, level)
	if _logHook then
		_logHook(value, level)
	end
end

local function appender(chan, uniq)
	chan = string.upper(chan)
	
	local appender_new = function(logger, level, str)
		if logging["WARN"] <= logging[level] then
			str = _G.debug.traceback(str, 2)
		end
		
		local text = format(chan, level, str, uniq)
		_writeLog(text)
		writeHookLog(text, level)
		return text
	end

	return appender_new
end

local function shortName( logger )
	for k, v in pairs(LEVEL_ABBR) do
		logger[string.lower(v)] = logger[string.lower(k)]
	end
end

function category(chan, level)
	local uniq = (level == "DEBUG" or level == "INFO")
	
	local logger = logging.new(appender(chan, uniq))
	
	local setLevel = logger.setLevel
	logger.setLevel = function(self, level)
		debug = debug or (level == logging.DEBUG)
		return setLevel(self, level)
	end
	
	logger:setLevel(logging[level or "WARN"])
	
	shortName(logger)
	rawset(_G, "log4" .. chan, logger)
end


--------------global---------------------
--
rawset(_G, "log", function (...)
	for _, v in ipairs({...}) do
		_writeLog(v)
	end
end)

rawset(_G, "logf", function (fmt, ...)
	WriteLog(fmt, ...)
end)

-- local oldprint = rawget(_G, "print")
-- rawset(_G, "print", log)


