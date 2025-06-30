module(..., package.seeall)


class = objectlua.Object:subclass()

function class:initialize(...)
	super.initialize(self)

	self.isEncryptData = true

	--Android ： MySdkPlatform.java中配置 proxyId = "myDev"; IOS : info.plist中配置MyPlatformProxyId
	self.proxyId = CEnvRoot:GetSingleton():GetOperatorProxyId()
	self.proxyPath = CVariableSystem:GetSingleton():GetSysVariable(GV_OPERATORPATH) --end of '/'

	self.dataCache = {}
end

function class:dispose()
	super.dispose(self)
end

----优先级：proxyid > devmode > default
function class:getConfig(item, file)
	assert(type(item) == "string")
	file = (file or 'misc') .. '.dat'

	-- log("config:"..item..", file:"..file)

	local operator = self:getFileData(file)
	if nil == operator then 
		return nil 
	end

	local proxyId = self.proxyId
	if nil ~= operator[proxyId]	and nil ~= operator[proxyId][item] then
		return operator[proxyId][item]
	end

	-- if sdk.platform:isDevMode() then
	-- 	if nil ~= operator["devMode"] and nil ~= operator["devMode"][item] then 
	-- 		return operator["devMode"][item]
	-- 	end
	-- end
	return operator["default"][item]
end

--配置相关的平台类型
local deviceConfigMap =
{
	["win32"] = "w32",
	["ios"] = "ios",
	["android"] = "ard",
}
function class:getDeviceConfigName()
	local platName = util:getPlatform()
	assert(deviceConfigMap[platName])
	return deviceConfigMap[platName]
end

function class:getGameName()
	return self:getConfig("gameName", "config")
end



--------------private-----------------
--
function class:getDataFromCache(key)
	return self.dataCache[key]
end

function class:saveDataToCache(key, value)
	self.dataCache[key] = value
end

function class:getFileData(file)
	local filepath = self.proxyPath .. file
	local data = self:getDataFromCache(filepath) 
	if data then
		return data
	end

	data = util:openFile(filepath, self.isEncryptData)
	if nil == data then
		return nil
	end

	data = json.decode(data)
	if nil == data then 
		return nil 
	end

	-- log(data)

	self:saveDataToCache(filepath, data)
	return data
end


























