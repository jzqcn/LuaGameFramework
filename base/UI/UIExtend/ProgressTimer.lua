-------------------------------------------------
--cc.ProgressTimer
--

local ProgressTimer = cc.ProgressTimer
local old = ProgressTimer.create
ProgressTimer.create = function (self, filepath, reverse, types)
	if type(filepath) ~= "string" then
		return old(self, filepath)
	end

	local sprite = cc.Sprite:create(filepath)
	local progress = old(self, sprite)

	-- cc.PROGRESS_TIMER_TYPE_BAR  = 0x1
	-- cc.PROGRESS_TIMER_TYPE_RADIAL   = 0x0
	if types ~= nil then
		progress:setType(types)
	end

	if reverse ~= nil then
		progress:setReverseDirection(reverse)
	end
	return progress
end

local old = ProgressTimer.setPercentage
ProgressTimer.setPercentage = function (self, value, time, callback)
	if nil == time or time == 0 then
		old(self, value)
		return
	end

	local curValue = self:getPercentage()
	local diffValue = value - curValue 
	local passTime = 0
	local lastFrame = false
	local function update(delta)
		if lastFrame then
			old(self, value)
        	self:unscheduleUpdate()
        	if callback then
        		callback()
        	end
        	return
		end

		passTime = passTime + delta
		local v = curValue + (passTime / time * diffValue) 
		old(self, v)

        if passTime > time then
        	lastFrame = true
        end
    end
	self:scheduleUpdateWithPriorityLua(update, 0)
end
--
-------------------------------------------------

