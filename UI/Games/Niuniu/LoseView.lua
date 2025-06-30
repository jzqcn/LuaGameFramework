module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter()
	-- self:setFrameEventCallFunc(bind(self.frameEventCallback, self))
	self:setLastFrameCallFunc(function ()
		self:close()
	 end)

	local eff = CEffectManager:GetSingleton():getEffect("a1sb2", true)
	local size = self.panelEff:getContentSize()
	eff:setPosition(cc.p(size.width/2, size.height/2))
	self.panelEff:addChild(eff)
	-- util.timer:after(50, self:createEvent("playAction"))

	util.timer:after(1.8*1000, self:createEvent("close"))

	sys.sound:playEffect("COMMON_LOSE")
end

-- function prototype:closeView()
-- 	log("closeView")
-- 	self:close()
-- end

function prototype:playAction()
	self:playActionTime(0, false)
end

function prototype:frameEventCallback(frame)
	local name = frame:getEvent()
	-- log("NiuniuLose framecallback:" .. name)

	self:close()
end