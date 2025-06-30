require 'Time'
require 'Timer'
require 'GameStage'

module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(...)
	super.initialize(self)
end

function class:dispose()
	super.dispose(self)
end

function class:onStartup()
end

function class:onShutdown()
end

function class:onTick()
end


--------------------------------------------------------------------------------
-- root

local root = objectlua.Object:subclass()

function root:initialize(...)
	super.initialize(self)
	self.tick = TimeGetTime()

	self.gameSage = GameStage:CreateStageMgr()
	
	self:initModuleGu()
	self.shell = require('GameShell').class:new()
end

function root:dispose()
	StageMgr:dispose()
	
	self:disposeModuleGu()	
	self.shell:dispose()
	
	self.gameSage:dispose()
	GameStage:DestroyStageMgr()
	
	Model:reset()
	Logic:reset()
	super.dispose(self)
end

function root:onSysStartup()
	self.shell:onStartup()
end

function root:onSysShutdown()
	self.shell:onShutdown()
end

function root:onTick()
	local tick = TimeGetTime()
	local elapsed = tick - self.tick 
	self.tick = tick
	
	self.timer:process(elapsed)
	self.shell:onTick(elapsed)
end

function root:initModuleGu()
	self.timer = Timer.class:new()
	self.time = Time.class:new()
	util:registModule("time", self.time)
	util:registModule("timer", self.timer)
end

function root:disposeModuleGu()
	util:unregistModule("time")
	util:unregistModule("timer")
	self.time:dispose()
	self.timer:dispose()
end

function root:onMemoryLow()
	--内存警告
	-- cc.Director:getInstance():purgeCachedData()
end

---------------------------------------------
--
function CreateGameRootMgr(_)
	if rawget(_G, "GameRootMgr") then
		return rawget(_G, "GameRootMgr")
	end

	local mgr = root:new()
	rawset(_G, "GameRootMgr", mgr)
	return mgr
end

function DestroyGameRootMgr(_)
	rawset(_G, "GameRootMgr", nil)
end
---------------------------------------------


