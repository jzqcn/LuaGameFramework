
local M = {}
M.loaded = {}
M.module2obj = {}

local old = require
function M:requireEx(name)
	local rst = old(name)
	if type(rst) == "table" then
		self.module2obj[name] = rst
	end
	return rst
end
rawset(_G, "require", bind(M.requireEx, M))

function M:getObject(moduleName)
	return self.module2obj[moduleName]
end

function M:moduleEx(name, mode)
	local old = self.loaded[name] 
	
	local M
	if old and type(old) == "table" then
		M = old
	else
		M = {}
		M._M = M
		M._NAME = name
		M._PACKAGE = (string.match(name, "(.*%.).*$")) or ""

		setfenv(2, M) 

		self.loaded[name] = M
	end

	if mode == package.seeall then
		setmetatable(M, {__index = _G})
	end
end

function M:loadModule(moduleName, filePath)
	filePath = filePath or string.gsub(moduleName, "%.", "/") .. ".lua"
	local loader, err = loadfile(filePath)
	if nil == loader then
        logf("loadfile '%s' failed! \nError:\n%s", moduleName, err)
		return nil
	end

	local fenv = {module = bind(self.moduleEx, self)}
	setmetatable(fenv, {__index=_G})

	local newModule = setfenv(loader, fenv)(moduleName)
	newModule = newModule or self.loaded[moduleName]
	fenv.module = nil
	self.loaded = {}

	return fenv, newModule
end


return M

