
local logging = require "logging"
local json = require "json"

module(..., package.seeall)

local reporterNull = function()
end

local reporter = reporterNull
local reportInfo = {revision=0, device="", server=""}
local lastReportTime = 0
local cache = {}
local reportDailyMax = 10
local reportDaily = 0

local function buildReport(msg)
	local data = table.clone(reportInfo) or {}
	data.msg = msg
	
	local s = json.encode(data)
	s = base64.encode(s)
	s = string.gsub(s, ".", { ["+"] = "_", ["/"] = "-", })
	return s
end

local function report(msg)
	local now = TimeGetTime()
	if lastReportTime + 1000 * 60 * 60 * 24 < now then
		cache = {}
        reportDaily = 0
	end
	
    if reportDaily >= reportDailyMax then
        return 
    end

	if table.invert(cache)[msg] ~= nil then
		return
	end
	
    reportDaily = reportDaily + 1
	lastReportTime = now
	table.insert(cache, msg)
	reporter(buildReport(msg))
	
    local cacheNum = 5
	if cacheNum <= #cache then
        cache = list.slice(cache, cacheNum * -1, #cache)
	end
end

function clearReporterCache()
    cache = {}
end

--------------------------------------------------------------------------------
-- log

local function reviseLog(str)
	-- str = string.gsub(str, "\\", "/")
	str = string.gsub(str, "%.%.%.[^:]*assets/", "")
	str = string.gsub(str, "%.%.%.[^:]*%.app/", "")
	return str
end


function setupCrashReporter(new, info)
	reporter = new or reporterNull
	reportInfo = info or reportInfo

	logger.setLogHook(function (str, level)
		if level ~= "WARN" then
			return
		end
		str = reviseLog(str)
		report(str)
	end)
end