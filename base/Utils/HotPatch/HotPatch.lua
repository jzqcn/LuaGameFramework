--------------------------------------------------
-- lua代码热更 
--
-- 2017.02.10
--------------------------------------------------
local HotPatchUI = require "Utils.HotPatch.HotPatchUI"
local ReLoad = require "Utils.HotPatch.ReLoad"


module (..., package.seeall)


class = objectlua.Object:subclass()
class:include(Events.ReceiveClass)

function class:initialize(...)
	super.initialize(self)
	Events.ReceiveClass.initialize(self)

	self.canUse = util:getPlatform() == "win32"
	if not self.canUse then
		return
	end

	self.patchUI = HotPatchUI.class:new(self)
	self.filesInfo = self:getFilesInfo()
end

function class:dispose()
	if self.patchUI then
		self.patchUI:dispose()
	end

	Events.ReceiveClass.dispose(self)
	super.dispose(self)
end

function class:sceneChange(scene)
	if not self.canUse then
		return
	end
	self.patchUI:sceneChange(scene)
end

function class:startWork()
	ui.confirm:popup("start hotpatch!")

	StopStrictCheck()
	if self.watchEvt then
		return
	end
	self.watchEvt = util.timer:repeats(3000, self:createEvent("watch"))
end

function class:stopWork()
	ui.confirm:popup("stop hotpatch!")
	StartStrickCheck()
	if nil == self.watchEvt then
		return
	end
	self.watchEvt:unbind()
	self.watchEvt = nil
end


-----------internal---------------
function class:getFilesInfo()
	local files = os.files(".", ".lua$")
	local filesInfo = {}
	for _, path in ipairs(files) do
		filesInfo[path] = os.filetime(path)
	end
	return filesInfo
end

function class:findFilePath(moduleName)
	local filename = string.gsub(moduleName, "%.", "/") .. ".lua"
    for path in pairs(self.filesInfo) do
        if string.match(path, filename) then
            return path
        end
    end
    return nil
end

function class:refreshChangedFiles()
	local filesInfo = self:getFilesInfo()
	local _filter = function (e)
		return filesInfo[e] ~= self.filesInfo[e]
	end

	local changed = filter(_filter, pairs, filesInfo)
	self.filesInfo = filesInfo
	return changed
end


function class:watch()
	ReLoad:clear()
	self:refreshLoadedModule()

	local changed = self:refreshChangedFiles()
	for _, path in ipairs(changed) do
		self:reload(self.loadedM.file2module[path], path)
	end
end

function class:refreshLoadedModule()
	local module2file = {}
	local file2module = {}
	for name, value in pairs(package.loaded) do
		local path = self:findFilePath(name)
		if path then
			file2module[path] = name
			module2file[name] = path
		end
	end
	self.loadedM = 
	{
		file2module = file2module,
		module2file = module2file,
	}
end

function class:reload(moduleName, path)
	if nil == moduleName then
		return
	end

	local _reload = function (name, path)
		ReLoad:reload(name, path)
	end

	local status, result = pcall(_reload, moduleName, path)
	if not status then
		logf("----reload[%s] failed! error:%s----", moduleName, result or "")
	end
end




