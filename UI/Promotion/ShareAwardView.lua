module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local AWARD_TYPE = {
	[1] = "resource/csbimages/Promotion/award_register.png", 	--注册
	[2] = "resource/csbimages/Promotion/award_bind.png", 		--绑定
	[3] = "resource/csbimages/Promotion/arard_firstRecharge.png", --首充
	[99] = "resource/csbimages/Promotion/award_recharge.png", --充值
	[100] = "resource/csbimages/Promotion/award_normal.png", --恭喜获得
}

function prototype:hasBgMask()
	return false
end

--获得奖励界面
function prototype:enter(config)
	local size = self.rootNode:getContentSize()
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	self.rootNode:setPosition(cc.p(size.width/2, size.height/2))

	local function actionOver()
		self.action:dispose()
		self.action = nil

		self:playAction()
	end

	self.action = self:createJumpOutBezierConfig(self.rootNode, actionOver)

	self.fntValue:setString(Assist.NumberFormat:amount2Hundred(tonumber(config.value)))
	self.currencyType = config.type
	-- if self.currencyType == Common_pb.Sliver then
	-- 	self.imgSilver:setVisible(true)
	-- 	self.imgGold:setVisible(false)
	-- else
		-- self.imgSilver:setVisible(false)
		self.imgGold:setVisible(true)
	-- end

	local awardType = config.desc or 100
	-- if awardType == User_pb.Register then
	-- 	--注册

	-- elseif awardType == User_pb.BindRedeemCode then
	-- 	--绑定推广码

	-- elseif awardType == User_pb.FirstCharge then
	-- 	--首冲
		
	-- else

	-- end

	self.imgTitle:loadTexture(AWARD_TYPE[awardType])
end

function prototype:playAction()
	self:playActionTime(0, true)

	self.btnConfirm:setVisible(true)

	self:showParticle()
end

--撒金币银币特效
function prototype:showParticle()
	local particle
	if self.currencyType == Common_pb.Sliver then
		particle = cc.ParticleSystemQuad:create("resource/particle/silverAward.plist")
	else
		particle = cc.ParticleSystemQuad:create("resource/particle/goldAward.plist")
	end
    self.rootNode:addChild(particle)

    local pos = cc.p(self.fntValue:getPosition())
    particle:setPosition(pos)
end

function prototype:onBtnCloseTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:close()
	end
end
