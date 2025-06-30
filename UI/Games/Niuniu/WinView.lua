module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter()
	self.loopNum = 0
	-- util.timer:after(50, self:createEvent("playAction"))

	local eff = CEffectManager:GetSingleton():getEffect("a1sl2", true)
	local size = self.panelEff:getContentSize()
	eff:setPosition(cc.p(size.width/2, size.height/2))
	self.panelEff:addChild(eff)

	-- self:setLastFrameCallFunc(function ()
	-- 	self.loopNum = self.loopNum + 1
	-- 	if self.loopNum == 2 then
	-- 		self:close()
	-- 	end
	--  end)

	util.timer:after(1.8*1000, self:createEvent("close"))

	sys.sound:playEffect("COMMON_WIN")
end

-- function prototype:closeView()
-- 	log("closeView")
-- 	self:close()
-- end

function prototype:playAction()
	self:playActionTime(0, true)	
end