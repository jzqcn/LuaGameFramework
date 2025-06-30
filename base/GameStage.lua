--[[
--------------------------------------------------------------------------------
module(..., package.seeall)

class = GameStage.class:subclass()

function class:OnStageActive()
end

function class:OnStageClose()
end

--------------------------------------------------------------------------------
--]]

EVT = Enum
{
	"ENTER_BACKGROUND",
	"ENTER_FOREGROUND",
}

module(..., package.seeall)

class = Events.class:subclass()

function class:initialize(...)
	super.initialize(self)
end

function class:dispose()
	super.dispose(self)
end

function class:onStageActive()
	assert(false)
end

function class:onStageClose()
	assert(false)
end

function class:onOperateEvent(type, x, y)
	return false
end

function class:onEnterBackground()
	-- body
end

function class:onEnterForeground()
	-- body
end

function class:onKeyReleased(keyCode, event)
	return false
end

--------------------------------------------------------------------------------
-- mgr

local mgr = objectlua.Object:subclass()

function mgr:initialize(...)
	self:setup('Null')
	self.nextType = nil
	self.nextArg = nil
end

function mgr:dispose()
--	self:Teardown()
end

function mgr:chgStage(type, ...)
	if self:isStage(type) then
		return
	end
	
	self:teardown()
	self:setup(type, ...)
end

function mgr:isStage(type)
	return self.type == type
end

function mgr:getStage()
	return self.stage
end

function mgr:setNextStage(type, arg)
	self.nextType = type
	self.nextArg = arg
end

function mgr:chgNextStage()
	if self.nextType then
		self:chgStage(self.nextType, self.nextArg)
		self.nextType = nil
		self.nextArg = nil
	end
end


--------------------------------------------------------------------------------
-- mgr:private

function mgr:getType()
	return self.type
end

function mgr:setup(type, ...)
	self.type = type
	self.stage = require('GameStage' .. self.type).class:new(...)
	self.stage:onStageActive()
end

function mgr:teardown()
	self.stage:onStageClose()
	self.stage:dispose()
	self.stage = nil
	self.type = nil

	sys.sound:stopAllEffect()
end


---------------------------------------------
--
function CreateStageMgr(_)
	if rawget(_G, "StageMgr") then
		return rawget(_G, "StageMgr")
	end

	local mgr = mgr:new()
	rawset(_G, "StageMgr", mgr)
	return mgr
end

function DestroyStageMgr(_)
	rawset(_G, "StageMgr", nil)
end
---------------------------------------------
