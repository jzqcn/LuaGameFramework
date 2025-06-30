module("Assist.Perform", package.seeall)

local internal = {}

function open(_, printTextrue, printStack)
	internal:init(printTextrue, printStack)
	internal:openTest()
end

function close(_)
	internal:closeTest()
end

------------
function internal:init(printTextrue, printStack)
	self.updateCbkHandle = nil
	self.printTextrue 	= printTextrue == nil and true or printTextrue
	self.printStack 	= printStack == nil and true or printStack
end

function internal:print()
	if self.printTextrue then
		local director = cc.Director:getInstance()
		local cach = director:getTextureCache():getCachedTextureInfo()
		local i, j = string.find(cach, "TextureCache")
		if i and j then
			local len = string.len(cach)
			local str = string.sub(cach, i, len)
			log4temp:debug(str)
		end
	end

	if self.printStack then
		local luaMem = collectgarbage("count")
		local len = string.len(luaMem)
		local luaStr = string.sub(luaMem, 1, len - 6)
		log4temp:debug("lua Mem : "..luaStr)
	end
end

function internal:openTest(_)
	if self.updateCbkHandle then
		return
	end

	local defaultScheduler =  cc.Director:getInstance():getScheduler()
	local updateCbk = bind(self.print, self)
    self.updateCbkHandle = defaultScheduler:scheduleScriptFunc(updateCbk, 0, false)
end

function internal:closeTest(_)
	if self.updateCbkHandle ~= nil then
		local defaultScheduler =  cc.Director:getInstance():getScheduler()
		defaultScheduler:unscheduleScriptEntry(self.updateCbkHandle)
		self.updateCbkHandle = nil
	end
end