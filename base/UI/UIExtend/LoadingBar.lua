


-------------------------------------------------
--ccui.LoadingBar
--
local LoadingBar = ccui.LoadingBar
local old = LoadingBar.setPercent
LoadingBar.setPercent = function (self, value, time, callback)
	if nil == time or time == 0 then
		old(self, value)
		return
	end

	local curValue = self:getPercent()
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

