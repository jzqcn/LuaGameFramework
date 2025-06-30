module (..., package.seeall)

prototype = Controller.prototype:subclass()

local SHOW_TIPS = {
	["要不起"] = "resource/csbimages/Games/Common/txtNotAfford.png",
	["不出"] = "resource/csbimages/Games/Common/txtUndiscard.png",
}

function prototype:enter()

end

function prototype:showTip(msg)
	local imgRes = SHOW_TIPS[msg]
	if imgRes then
		self.imgTip:loadTexture(imgRes)
		self.imgTip:ignoreContentAdaptWithSize(true)
	end

	self.rootNode:setVisible(true)
	-- util.timer:after(2*1000, self:createEvent('SHOW_TIMEOUT_TIMER', 'onShowTimeOut'))
end

function prototype:onShowTimeOut()
	self.rootNode:setVisible(false)
end

