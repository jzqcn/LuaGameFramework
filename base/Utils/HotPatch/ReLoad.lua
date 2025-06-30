local Spawn = require "Utils.HotPatch.ReLoad.Spawn"

local M = {}

function M:clear()
	self.loaded = {}
end

function M:exist(moduleName)
	return package.loaded[moduleName]
end

function M:reload(moduleName, filePath)
	logf("------[[reload mod:%s file:%s]]------", moduleName, filePath)
	if not self:exist(moduleName) then
		return
	end

	local oldObj = Spawn:getObject(moduleName)
	local env, mod = Spawn:loadModule(moduleName, filePath)
	self:reloadGlobal(env)
	self:reloadModule(moduleName, mod) 

	if oldObj and mod then
		self:updateModule(oldObj, mod)
	end
end

function M:getG(moduleName)
    local tempG = _G
    local result = string.split(moduleName, "%.")
    if #result == 1 then
        return tempG, moduleName, rawget(tempG, moduleName)
    end
    
    for idx, keyWord in ipairs(result) do
        if idx == #result then
            return tempG, keyWord, rawget(tempG, keyWord)
        end
        tempG = rawget(tempG, keyWord)
		if nil == tempG then
			break
		end
    end
	return nil, nil, nil
end

function M:reloadGlobal(env)
	if nil == env or table.empty(env) then
		return
	end
	self:updateModule(_G, env)
end

function M:reloadModule(moduleName, newModule)
	if nil == newModule or table.empty(newModule) then
		return
	end
	local parentG, fieldName, oldModule = self:getG(moduleName)
	if nil == parentG or nil == oldModule then
		return
	end
	self:updateModule(oldModule, newModule)
end

function M:updateModule(oldModule, newModule)
	local function _isObjectLuaClass(t)
        if type(t) ~= "table" then
            return false
        end
		if t.inheritsFrom == nil then
			return false
		end
		return t:inheritsFrom(objectlua.Object)
	end

	local function _isObjectLuaObject(t)
        if type(t) ~= "table" then
            return false
        end
		if t.isKindOf == nil then
			return false
		end
		return t:isKindOf(objectlua.Class)
	end

	for key, value in pairs(newModule) do
		if _isObjectLuaClass(value) then
			self:updateObjectLua(oldModule[key], value)
		elseif type(value) == "table" then
			if key ~= "_M" then
				self:updateTable(oldModule[key], value)
			end
		else
			local newValue = rawget(newModule, key)
			rawset(oldModule, key, newValue)
		end
	end
end

function M:updateTable(oldTable, newTable)
    for key in pairs(oldTable) do
        if nil == newTable[key] then
            oldTable[key] = nil
        end
    end

    for key in pairs(newTable) do
        oldTable[key] = newTable[key]
    end
end

function M:updateObjectLua(oldClass, newClass)
	if not oldClass.__prototype__ or not newClass.__prototype__ then
        return
	end
	for key in pairs(oldClass.__prototype__) do
        if key ~= "__index" and key ~= "__metatable" then
            local newValue = rawget(newClass.__prototype__, key)
            rawset(oldClass.__prototype__, key, newValue)
        end
    end

    for key in pairs(newClass.__prototype__) do
        if key ~= "__index" and key ~= "__metatable" then
            local newValue = rawget(newClass.__prototype__, key)
            rawset(oldClass.__prototype__, key, newValue)
        end
	end
end


return M

