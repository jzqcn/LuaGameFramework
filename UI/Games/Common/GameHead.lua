
module(..., package.seeall)

prototype = Controller.prototype:subclass()

local currencyIconRes = {
	"resource/csbimages/User/scoreIcon.png",
	"resource/csbimages/User/moneyIcon.png",
	"resource/csbimages/Common/goldIcon.png"
}

function prototype:enter()
	-- log("game head enter:"..self.__NAME)
	self.imgFrame:setVisible(false)
	self.imgDealer:setVisible(false)
	self.imgWifi:setVisible(false) --掉线标记
	self.imgViewer:setVisible(false)
	self.imgOwner:setVisible(false)
	self.fontBet:setVisible(false) --下注金额
	self.imgReady:setVisible(false) --准备

	self.numPos = cc.p(self.txtNum:getPosition())
end

function prototype:setHeadInfo(playerInfo, currencyType, isPlayBack)
	self.isPlayBack = isPlayBack or false
	self.currencyType = currencyType
	self.headInfo = playerInfo
	self.txtName:setString(Assist.String:getLimitStrByLen(playerInfo.playerName))
	

	-- log(playerInfo.headimage)
	--设置头像
	-- sdk.account:getHeadImage(playerInfo.playerId, playerInfo.playerName, self.imgHead, playerInfo.headimage)
	if self:existEvent('LOAD_HEAD_IMG') then
		self:cancelEvent('LOAD_HEAD_IMG')
	end
	sdk.account:loadHeadImage(playerInfo.playerId, playerInfo.playerName, playerInfo.headimage, 
		self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.imgHead)

	if currencyType == Common_pb.Score then
		self.txtNum:setString(playerInfo.coin)
		-- self.imgCoin:setVisible(false)
		self.imgCoin:loadTexture(currencyIconRes[currencyType])
		self.txtNum:setPosition(self.numPos)
	else
		self.txtNum:setString(Assist.NumberFormat:amount2Hundred(playerInfo.coin))
		-- self.imgCoin:setVisible(true)
		self.imgCoin:loadTexture(currencyIconRes[currencyType])
		self.txtNum:setPosition(self.numPos)
	end

	--掉线是图标闪烁
	if self.headInfo.memStateInfo.isOffLine == true then
		self.imgWifi:stopAllActions()

		local seq = cc.Sequence:create(cc.FadeOut:create(0.3), cc.FadeIn:create(0.3))
		self.imgWifi:runAction(cc.RepeatForever:create(seq))
		self.imgWifi:setVisible(true)

		self.imgWifi:setColor(cc.c3b(255, 0, 0))

		Assist:setNodeGray(self.imgHead)
		-- self.imgHead:setColor(cc.c3b(127,127,127))
	else
		self.imgWifi:stopAllActions()
		self.imgWifi:setVisible(false)

		Assist:setNodeColorful(self.imgHead)
		-- self.imgHead:setColor(cc.c3b(255,255,255))
	end

	if self.headInfo.memStateInfo.isViewer == true then
		self.imgViewer:setVisible(true)
		-- self.imgHead:setColor(cc.c3b(127,127,127))
	else
		self.imgViewer:setVisible(false)
		-- self.imgHead:setColor(cc.c3b(255,255,255))
	end

	--房主
	if self.headInfo.memStateInfo.isStarter then
		self.imgOwner:setVisible(true)
	else
		self.imgOwner:setVisible(false)
	end

	--庄家
	if self.headInfo.memStateInfo.isDealer then
		self.imgDealer:setVisible(true)
		self.imgFrame:setVisible(true)
	else
		self.imgDealer:setVisible(false)
		self.imgFrame:setVisible(false)
	end
end

function prototype:onLoadHeadImage(filename)
	self.imgHead:loadTexture(filename)
end

function prototype:setReadyVisible(var)
	self.imgReady:setVisible(var)
end

function prototype:setBetVisible(var)
	self.fontBet:setVisible(var)
end

function prototype:setBetValue(value, currencyType)
	if currencyType == Common_pb.Score then
		self.fontBet:setString(value)
	else
		self.fontBet:setString(Assist.NumberFormat:amount2TrillionText(value))
	end
	self.fontBet:setVisible(true)
end

--轮到谁出牌或者庄家处理牌
function prototype:flashHeadFrame(var, isDealer)
	var = var or false
	isDealer = isDealer or false
	if var then
		self.imgFrame:stopAllActions()
		self.imgFrame:setVisible(true)
		self.imgDealer:setVisible(isDealer)

		local seq = cc.Sequence:create(cc.FadeOut:create(0.3), cc.FadeIn:create(0.3))
		self.imgFrame:runAction(cc.RepeatForever:create(seq))
	else
		self.imgFrame:setVisible(false)
		self.imgDealer:setVisible(false)
		self.imgFrame:stopAllActions()
	end
end

--抢庄
function prototype:flashHeadFrame2(var)
	var = var or false
	if var then
		self.imgFrame:stopAllActions()
		self.imgFrame:setVisible(true)
		self.imgFrame:setOpacity(255)

		local seq = cc.Sequence:create(cc.FadeOut:create(0.1), cc.CallFunc:create(function()
			sys.sound:playEffect("CHOOSE_DEALER")
		end), cc.FadeIn:create(0.1))

		self.imgFrame:runAction(cc.RepeatForever:create(seq))
	else		
		self.imgFrame:setVisible(false)
		self.imgFrame:setOpacity(255)
		self.imgFrame:stopAllActions()
	end
end

function prototype:getHeadPos()
	local x1, y1 = self.rootNode:getPosition()
	local x2, y2 = self.imgFrame:getPosition()
	return cc.p(x1+x2, y1+y2)
end

function prototype:getCoinPos()
	local x1, y1 = self.rootNode:getPosition()
	local x2, y2 = self.imgCoin:getPosition()
	return cc.p(x1+x2, y1+y2)
end

function prototype:getReadIconPos()
	local x1, y1 = self.rootNode:getPosition()
	local x2, y2 = self.imgReady:getPosition()
	return cc.p(x1+x2, y1+y2)
end

function prototype:onBtnHeadClick(sender)
	if self.isPlayBack then
		return
	end
	
	-- log("head click :"..self.__NAME)
	if self.headInfo == nil then
		log4ui:warn("GameHead::onBtnHeadClick get player info error !")
		return
	end

	ui.mgr:open("Games/Common/PlayerInfoView", {info=self.headInfo, currencyType = self.currencyType})
end

function prototype:getLabelAnchorPoint()
	return cc.p(0.5, 0.5)
end

--显示输赢数字动画
function prototype:runSettlementNumAction(value)
	local numLabel = nil
	if value >= 0 then
		if self.currencyType == Common_pb.Score then
			numLabel = cc.Label:createWithBMFont("resource/csbimages/BMFont/win2.fnt", "+" .. value)
		else
			numLabel = cc.Label:createWithBMFont("resource/csbimages/BMFont/win2.fnt", "+" .. Assist.NumberFormat:amount2TrillionText(value))
		end
	else
		if self.currencyType == Common_pb.Score then
			numLabel = cc.Label:createWithBMFont("resource/csbimages/BMFont/lose2.fnt", value)
		else
			numLabel = cc.Label:createWithBMFont("resource/csbimages/BMFont/lose2.fnt", Assist.NumberFormat:amount2TrillionText(value))
		end
	end

	numLabel:setAnchorPoint(self:getLabelAnchorPoint())
	numLabel:setPosition(cc.p(self:getHeadPos()))
	self.rootNode:getParent():addChild(numLabel, 100)

	numLabel:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0,80)), cc.FadeOut:create(1.5), cc.CallFunc:create(function()
			numLabel:removeFromParent(true)
		end
	)))
end
