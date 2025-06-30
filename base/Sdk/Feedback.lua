
module(..., package.seeall)

EVT = Enum
{
	'ERROR',				-- 错误提示 	
}

class = Events.class:subclass()

function class:initialize()
	super.initialize(self)

	-- setupCrashReporter(function(msg)
	-- 	self:AddCrashLog(msg)
	-- end)
end

function class:dispose()
	super.dispose(self)
end

----第一次激活
function class:active()
    if util:getPlatform() == "win32" then
        return
    end

	if db.var:getSysVar("actived") then
		return
	end
 -- feadback.dat
 --    "active": {
 --     "open": false,
	-- 	"host": "owadv.gogogame.com",
	-- 	"key": "oweyugamesjfiwfajx2s&sksm*ufns",
	-- 	"install": "/install.php",
	-- 	"register": "/register.php",
	-- 	"login": "/login.php"
	-- }
	local config = sdk.config:getConfig("active", "feedback")
	if nil == config or not config.open then
		return
	end

	local data = self:getActivePostData()
   	local url = string.format("http://%s%s", config.host, config.install or "/")

   	self:cancelEvent("onActive")
    local content = net.http:getUri(data)

    local info = {}
	info.ip = config.host
	info.uri = (config.install or "/") .. content
	info.method = "POST"
	net.http:send(info, self:createEvent("onActive"))
end

function class:getActivePostData()
    local data = 
    {
        platformId      = sdk.platform:getInfo("platformId"),
        identifier 		= sdk.platform:getInfo("identifier"),
        deviceName      = sdk.platform:getInfo("deviceName"),
        idfa            = sdk.platform:getInfo("idfa"),
        uniqueId 		= sdk.platform:getInfo("uniqueid"),
        platformTypes   = util:getPlatform()  --win32 ios android
    }

    local index = table.indices(data)
    table.sort(index)

    local sign = {}
    for _, name in ipairs(index) do
    	table.insert(sign, data[name])
    end

    data.sign = util.md5(table.concat(sign))
    return data
end


function class:onActive(code, data)
	if code ~= 0 then
		return
	end
	db.var:setSysVar("actived", true)
end



function class:contactGM()
    --gmUrl": "https://owfaq.gogogame.com/index.html?action=custom",
    local gmUrl = sdk.config:getConfig("gmUrl", "config")
    --游戏内 可以多传一些数据
    util:openUrl(gmUrl)
end


--[[  @todo
function class:addCrashLog(text)
	local data = 
	{
		userid 		= Singleton(Account):Get('userId') or '00000000',
		username	= Singleton(Account):Get('nickName') or '00000000',
		ptName 		= KFDBGetRecordByPT('deviceName'),
	}

    local co = coroutine.create(function()
        self:Request( function(data, code)
	        local isErr, info, tip = self:OnError(data, code)
	        if isErr then 
                tip = "### report fail ###\n" .. tip .. (data or '')
                WriteLog(tip)
            end
        end, data, 'buglog', text, false)
    end)

    coroutine.resume(co)
end


function class:QueryServerLst()
	local data = {
		version = Singleton(ComLogic):GetVersion(),
	}

	local ret, tip = true, ''
	self:Request( function(data, code)
		ret, tip = self:OnQueryServerLst(data, code)
	end, data, 'online', '', false)

	return ret, tip
end

function class:OnQueryServerLst(data, code)
	local isErr, info, tip = self:OnError(data, code)
	if isErr then return false, tip end

    local servers = list.enpair(info.data)
    servers = list.map(function(t) 
        return table.merge({server = t[1]}, t[2]) 
    end, servers)

    if not Singleton(Server):InitServerLst(servers) then
		return false, "获取服务器列表失败，数据内容错误"
    end
	
	return true
end


--]]
