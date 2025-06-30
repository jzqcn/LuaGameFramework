module("Events", package.seeall)

--------------------------------------------------------------------------------
-- Event

Event = objectlua.Object:subclass()

--由Tracer来创建Event
function Event:initialize(name, callback, tracer)
	self.eventName = name
	self.tracer   = tracer
	self.callback = callback
end

function Event:dispose()
	self:unbind()
end

--bind后 就会和holder关联上 bindName可以为空 
--只要holder自己unbind时能识别唯一就行
function Event:bind(holder, bindName)
	self.holder = holder
	self.bindName = bindName
	self.tracer:bind(self, self.eventName)
end

--无论是holder还是tracer来释放 都能正常在两边解绑
function Event:unbind()
	if self.holder == nil then
		return
	end
	self.tracer:unbind(self)
	self.holder:unbind(self, self.bindName)
end

function Event:fire(...)
	return self.callback(...) ~= false
end

function Event:getName()
	return self.eventName
end
