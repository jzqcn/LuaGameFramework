require "Events.Event"

module("Events", package.seeall)

EventTracer = objectlua.Object:subclass()

function EventTracer:initialize()
	self.events = {}
end

function EventTracer:dispose()
	self:clear()
end

function EventTracer:createEvent(name, callback)
	--须有标识
	assert(name and callback, debug.traceback("param error", 2))

	--标识重复 event创建后 本地不维护 放入EventCenter中自动释放 
	if self:exist(name) then
		-- WriteLog(debug.traceback('Dumplicate event name!', 2))
		-- self:cancel(name)
		return self.events[name]  --允许共享同一个event
	end
	
	local event = Events.Event:new(name, callback, self)
	return event
end

function EventTracer:clear()
	for k, v in pairs(self.events) do
		v:unbind()
	end
	self.events = {}
end

function EventTracer:exist(name)
	return self.events[name] ~= nil
end

--取消事件的注册
function EventTracer:cancel(name)
	if not self:exist(name) then
		return
	end

	self.events[name]:unbind()
end

-----所有bind和unbind 都由Event来中转
function EventTracer:bind(event, name)
	self.events[name] = event
end

function EventTracer:unbind(event)
	self.events[event:getName()] = nil
end