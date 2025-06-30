--------------------------------------------------
-- 定时器
--------------------------------------------------

module(..., package.seeall)

class = objectlua.Object:subclass()


local singleton
function getSingleton(_)
	assert(singleton ~= nil)
	return singleton
end


function class:initialize()
	super.initialize(self)
	self.events = {}

	assert(nil == singleton)
	singleton = self
end

function class:dispose()
	--assert(table.empty(self.events))
	super.dispose(self)
end

function class:unbind(callOrevent, bindName)
	for i, v in ipairs(self.events) do
		if v.event == callOrevent or v.call == callOrevent then
			table.remove(self.events, i)
			break
		end
	end
end

function class:process()
	local clock = TimeGetTime()
	while self.events[1] and self.events[1].clock <= clock do
		local item = self.events[1]
		table.remove(self.events, 1)

		local dt = (clock - item.clock) / 1000

		if item.times == 1 then
			if item.event then
				item.event:unbind() 
			end
		elseif item.times > 1 then
			item.times = item.times - 1
			self:queue(item)
		elseif item.times == 0 then
			self:queue(item)
		else
			assert(false)
		end
		
		if item.call then
			item.call(dt)
		elseif item.event then
			item.event:fire(dt)
		end
	end
end

function class:after(time, callOrevent)
	return self:repeats(time, callOrevent, 1)
end

--同时支持function和event两种回调方式
--interval:毫秒
function class:repeats(interval, callOrevent, times)
	local call = type(callOrevent) == "function" and callOrevent or nil
	local event = call == nil and callOrevent or nil
	if event then
		event:bind(self)
	end

	local item =
	{
		call 	= call,
		event	= event, 
		interval= interval, 
		times	= times or 0, 
	}
	
	self:queue(item)
	return event
end

function class:queue(item)
	item.clock = TimeGetTime() + item.interval
	
	local index = 1
	for i, v in ipairs(self.events) do
		if v.clock > item.clock then
			break
		end
		index = i + 1
	end
	
	table.insert(self.events, index, item)
end
