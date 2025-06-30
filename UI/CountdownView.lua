local Define = require "UI.Mgr.Define"

module (..., package.seeall)

prototype = Window.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:initialize(...)
	super.initialize(self, ...)

	self.windowTouchType = Define.WINDOW_TOUCH_TYPE.NO_SWALLOW
end

function prototype:enter(data)
	local content = data.content
	local countDown = tonumber(data.countDown)
	self.txtContent:setString(content)
	self.txtCountdown:setEndTime(util.time:getTime() + countDown, bind(self.onTimeEnd, self))

	local size = self.panelFrame:getContentSize()
	local strWidth = self.txtContent:getContentSize().width

	if size.width < strWidth then
		self.txtContent:setPositionX(size.width + strWidth/2 + 10)
		local time = math.ceil(strWidth/size.width) * 4
		local seq = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time, cc.p(-(size.width + strWidth + 10), 0)), cc.CallFunc:create(function()
				self.txtContent:setPositionX(size.width + strWidth/2 + 10)
			end)))

		self.txtContent:runAction(seq)
	end
end

-- function prototype:exit()
-- end

function prototype:onTimeEnd(types, name)
	self.rootNode:setVisible(false)
	-- self:close()

	util.timer:after(200, self:createEvent("close"))
end