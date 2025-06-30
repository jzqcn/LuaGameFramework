module("Events", package.seeall)


EventCenter = objectlua.Object:subclass()

function EventCenter:initialize()
	self.events = {}
end

function EventCenter:dispose()
	for name, subevents in pairs(self.events) do
		for event in pairs(subevents) do
			event:dispose()
		end
	end
	self.events = {}
end

--支持一个name对应多个event
function EventCenter:bind(event, name)
	self.events[name] = self.events[name] or {}
	self.events[name][event] = event
	event:bind(self, name)
end

function EventCenter:unbind(event, name)
	assert(name and event, debug.traceback("unbind must has event!"), 2)
	if self.events[name] == nil then
		return
	end

	self.events[name][event] = nil
	if table.empty(self.events[name]) then
		self.events[name] = nil
	end
end

function EventCenter:fire(name, ...)
	if not self.events[name] then
		return false
	end
	
	local ret = false
	--fire的过程中 可能改到events的内容 所以clone一份
	-- log(self.events[name])
	for k, v in pairs(table.clone(self.events[name])) do
		ret = v:fire(...) or ret
	end
	return ret
end
