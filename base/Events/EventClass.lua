--------------------------------------------------
-- 事件发送 接收类
--
-- @author liuw
-- 2017.12.18
--------------------------------------------------

require "Events.EventCenter"
require "Events.EventTracer"

--SenderClass和ReceiveClass都属于mixin类 用于其他类来include
module("Events", package.seeall)


--Event发送器类  负责Event的注册和发送
SenderClass = objectlua.Mixin:new()

function SenderClass:initialize()
	self.evtCenter = Events.EventCenter:new()
end

function SenderClass:dispose()
	self.evtCenter:dispose()
end

function SenderClass:bindEvent(name, event)
	log4event:info("bindEvent:" .. name)
	self.evtCenter:bind(event, name)
end

--一般不需要 应该走ReceiveClass自己的cancelEvent
function SenderClass:unbindEvent(name, event)
	log4event:info("unbindEvent:" .. name)
	self.evtCenter:unbind(event, name)
end

function SenderClass:fireEvent(name, ...)
	log4event:info("fireEvent:" .. name)
	self.evtCenter:fire(name, ...)
end



--事件接收类  负责事件的创建和接收
ReceiveClass = objectlua.Mixin:new()

function ReceiveClass:initialize()
	self.evtTracer = Events.EventTracer:new()
end

function ReceiveClass:dispose()
	self.evtTracer:dispose()
end

function ReceiveClass:createEvent(name, callback)
	log4event:info("createEvent:" .. name)
	callback = callback or name
	if type(callback) == "string" then
		assert(self[callback] ~= nil)
		callback = bind(self[callback], self)
	end

	local event = self.evtTracer:createEvent(name, callback)
	return event
end

function ReceiveClass:cancelEvent(name)
	self.evtTracer:cancel(name)
end

function ReceiveClass:existEvent(name)
	return self.evtTracer:exist(name)	
end


-----------------------------------------
class = objectlua.Object:subclass()

--既能发送事件 也能自己注册监听
class:include(SenderClass)
class:include(ReceiveClass)

function class:initialize()
	super.initialize(self)
	
	SenderClass.initialize(self)
	ReceiveClass.initialize(self)
	-- log(string.format("SenderClass %p", SenderClass))
	-- log(string.format("ReceiveClass %p", ReceiveClass))
	-- log(string.format("EventClass %p", self))
	-- log(string.format("evtCenter %p", self.evtCenter))
	-- log(string.format("evtTracer %p", self.evtTracer))
end

function class:dispose()
	SenderClass.dispose(self)
	ReceiveClass.dispose(self)
	
	super.dispose(self)
end








