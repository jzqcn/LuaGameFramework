module('Utils', package.seeall)

Synchroniser = objectlua.Object:subclass()

function Synchroniser:initialize()
	super.initialize(self)
	
	local thread = coroutine.running()
	assert(thread ~= nil)
	
	self.thread = thread
	self.traped = false
	self.points = {}
end

function Synchroniser:Sync()
	assert(coroutine.running() == self.thread)
	
	if table.empty(self.points) then
		return false
	end
	
	self.traped = true
	
	while not table.empty(self.points) do
		coroutine.yield()
	end
	
	self.traped = false
	
	return true
end

function Synchroniser:Join()
	local tag = {}
	
	self:Wait(tag)
	
	return function()
		self:Done(tag)
	end
end

function Synchroniser:Wait(point)
	self.points[point] = point
end

function Synchroniser:Done(point)
	self.points[point] = nil
	
	if not self.traped or not table.empty(self.points) then
		return
	end
	
	assert(coroutine.status(self.thread) == "suspended")
	
	local succ, msg = coroutine.resume(self.thread)
	if not succ then
		error(debug.traceback(self.thread, msg))
	end
	
	return
end

