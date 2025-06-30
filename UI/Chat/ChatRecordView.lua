local Define = require "UI.Mgr.Define"

module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:initialize(...)
	super.initialize(self, ...)

	self.windowTouchType = Define.WINDOW_TOUCH_TYPE.NO_SWALLOW
end

function prototype:enter()
	local x, y = self.imgBg:getPosition()
	local volumePro = cc.ProgressTimer:create(cc.Sprite:create("resource/csbimages/Chat/microphone_full.png"))
    volumePro:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    volumePro:setMidpoint(cc.p(0, 0))
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    volumePro:setBarChangeRate(cc.p(0, 1))
    volumePro:setAnchorPoint(cc.p(0.5, 0.5))
    volumePro:setPosition(x, y)
    self.rootNode:addChild(volumePro)

    self.volumePro = volumePro
end

function prototype:onPanelChatClick()
	self:close()
end

function prototype:updateVolume(volume)
	if volume < 0 then
		volume = 0
	end

	if volume > 100 then
		volume = 100
	end

	if self.volumePro then
		self.volumePro:setPercentage(volume)
	end
end