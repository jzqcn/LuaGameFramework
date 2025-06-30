module (..., package.seeall)

prototype = Controller.prototype:subclass()

local BET_MIN_LIMIT = 1
local BET_RANGE = {1, 10, 100, 500, 1000}
local NUMBER_MOVE_OFF = 60

local Longhudou_pb = Longhudou_pb

function prototype:enter()
	local accountInfo = Model:get("Account"):getUserInfo()
	self.txtID:setString(accountInfo.userId)
	self.txtCoin:setString(Assist.NumberFormat:amount2Hundred(accountInfo.gold))
	--设置头像
	sdk.account:getHeadImage(accountInfo.userId, accountInfo.nickName, self.imgHead, accountInfo.headImage)

	self.fntOtherLose:setVisible(false)
	self.fntOtherWin:setVisible(false)
	self.fntWin:setVisible(false)
	self.fntLose:setVisible(false)

	for i = 1, 5 do
		self["btnBet_"..i]:addTouchEventListener(bind(self.onBtnBetTouch, self))
	end

	self.btnBet_6:addTouchEventListener(bind(self.onBtnBetLastTouch, self))

	local roomInfo = Model:get("Games/Longhudou"):getRoomInfo()
	BET_RANGE = roomInfo.betRanges
	self:setBtnBetBg(BET_RANGE)
	self.userInfo = Model:get("Account"):getUserInfo()
	self.imgRechargeTip:setVisible(false)

	self:refreshBetMenu()
	--续注
	self.btnBet_6:setEnabled(false)
	self:setSelectBetIndex(1)
end

function prototype:setBtnBetBg(betRangeInfo)
	if betRangeInfo==nil or table.nums(betRangeInfo)==0 then return end
	for k,v in ipairs(betRangeInfo) do
		local name = "btnBet_"..k
		self[name]:loadTextureNormal(string.format("resource/Longhudou/csbimages/Bet/b%d.png",v))
		self[name]:loadTexturePressed(string.format("resource/Longhudou/csbimages/Bet/a%d.png",v))
		self[name]:loadTextureDisabled(string.format("resource/Longhudou/csbimages/Bet/c%d.png",v))
	end
end

function prototype:setOnlineNumber(num)
	self.txtOnlineNum:setString(num .. "人")
end

function prototype:unenabledBetMenu()
	for i = 1, 6 do
		self["btnBet_"..i]:setEnabled(false)
	end

	if self.spriteEff then
		self.spriteEff:setVisible(false)
	end
end

function prototype:setEnabledContinueBet(isEnabled, lastBetRange)
	isEnabled = isEnabled or false
	if not isEnabled or not lastBetRange or self.userInfo.gold < (BET_MIN_LIMIT*100) then
		self.btnBet_6:setEnabled(false)
	else
		if lastBetRange[1] > 0 and lastBetRange[2] > 0 then
			self.btnBet_6:setEnabled(false)
			return
		end

		local lastBetValue = lastBetRange[1] + lastBetRange[2] + lastBetRange[3]
		if lastBetValue > 0  then
			-- local accountInfo = Model:get("Account"):getUserInfo()
			local playerInfo = self.userInfo --Model:get("Games/Longhudou"):getUserInfo()
			if playerInfo.gold > lastBetValue then
				self.btnBet_6:setEnabled(true)
			else
				self.btnBet_6:setEnabled(false)	
			end
		else
			self.btnBet_6:setEnabled(false)
		end
	end
end

function prototype:refreshBetMenu(showRecharge)
	showRecharge = showRecharge or false

	if showRecharge then
		self.txtCoin:setString(Assist.NumberFormat:amount2Hundred(self.userInfo.gold))
	end

	local playerInfo = self.userInfo --Model:get("Games/Longhudou"):getUserInfo()
	--将金币这算成人民币 1:100
	local coinValue = math.floor(playerInfo.gold / 100)
	for i, v in ipairs(BET_RANGE) do
		if coinValue >= BET_MIN_LIMIT then
			if coinValue >= v then
				self["btnBet_"..i]:setEnabled(true)
			else
				self["btnBet_"..i]:setEnabled(false)
				if self.selIndex == i then
					self:setSelectBetIndex(1)
				end
			end
		else
			self["btnBet_"..i]:setEnabled(false)
		end
	end

	if coinValue < BET_MIN_LIMIT then
		-- if not showRecharge then
		-- 	self.imgRechargeTip:setVisible(true)		
		-- end

		if self.spriteEff then
			self.spriteEff:setVisible(false)
		end
	else
		-- self.imgRechargeTip:setVisible(false)

		if self.spriteEff then
			self.spriteEff:setVisible(true)
		end
	end
end

--选择下注档次
function prototype:onBtnBetTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local name = sender:getName()
		local index = tonumber(string.sub(name, -1))
		self:setSelectBetIndex(index)
	end
end

function prototype:setSelectBetIndex(index)
	if self.selIndex == index then
		return
	end

	if not self.spriteEff then
		-- local sprite = cc.Sprite:create()
		-- local animation = cc.Animation:create()
	 --    for i = 1, 8 do				
	 --        animation:addSpriteFrameWithFile(string.format("resource/Longhudou/csbimages/betBtnEff/%d.png", i))
	 --    end
	 --    animation:setDelayPerUnit(1.0 / 8)
	 --    animation:setRestoreOriginalFrame(true)

	 --    local showAction = cc.RepeatForever:create(cc.Animate:create(animation))
	 --    sprite:runAction(showAction)
	 --    self.spriteEff = sprite

		local skeletonNode = sp.SkeletonAnimation:create("resource/Longhudou/csbimages/anim/BetEff/Tsitexiao.json", "resource/Longhudou/csbimages/anim/BetEff/Tsitexiao.atlas")
		skeletonNode:setAnimation(0, "animation", true)
		skeletonNode:setScale(1.1, 1.2)
		self.rootNode:addChild(skeletonNode)
		self.spriteEff = skeletonNode
	end

	local name = "btnBet_" .. index
	-- local size = self[name]:getContentSize()
	local pos = cc.p(self[name]:getPosition())
	self.spriteEff:setPosition(pos)
	-- self[name]:addChild(self.spriteEff)

	self[name]:loadTextureNormal(string.format("resource/Longhudou/csbimages/Bet/a%d.png", BET_RANGE[index]), ccui.TextureResType.plistType)

	if self.selIndex then
		local res = string.format("resource/Longhudou/csbimages/Bet/b%d.png", BET_RANGE[self.selIndex])
		self["btnBet_"..self.selIndex]:loadTextureNormal(res, ccui.TextureResType.plistType)
	end

	self.selIndex = index
end

function prototype:getBetValue()
	if self.selIndex == nil then
		self.selIndex = 1
	end

	return BET_RANGE[self.selIndex] * 100
end

--续注
function prototype:onBtnBetLastTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Longhudou.ContinueBet")
	end
end

function prototype:doUserBet(info, betValue)
	-- info.coin = info.coin - betValue
	-- self.txtCoin:setString(Assist.NumberFormat:amount2Hundred(self.userInfo.gold))

	local fntNode = self.fntLose:clone()
	fntNode:setString("-" .. Assist.NumberFormat:amount2TrillionText(betValue))
	self.rootNode:addChild(fntNode)

	fntNode:setScale(0.75)
	fntNode:runAction(cc.Sequence:create(
		cc.MoveBy:create(0.5, cc.p(0, 50)), 
		cc.DelayTime:create(1.0),
		cc.FadeOut:create(0.5), 
		cc.CallFunc:create(function(sender)
			sender:removeFromParent()
		end)))

	-- self:refreshBetMenu(true)
end

function prototype:doSettlement(info, currentSidesDesc)
	self.txtCoin:setString(Assist.NumberFormat:amount2Hundred(info.coin))

	if info.winCoin > 0 then
		--赢	
		local strCoin = Assist.NumberFormat:amount2TrillionText(info.winCoin)
		strCoin = "+"..strCoin
		self:runNumAction(self.fntWin, strCoin, 1.5)

		local size = self.imgFrame:getContentSize()
		-- local eff = CEffectManager:GetSingleton():getEffect("a1longtx")
		-- eff:setPosition(cc.p(size.width/2, size.height/2))
		-- self.imgFrame:addChild(eff)

		local skeletonNode = self.rootNode:getChildByTag(98)
		if skeletonNode == nil then
			skeletonNode = sp.SkeletonAnimation:create("resource/Longhudou/csbimages/anim/Txguangquan/Txguangquan.json", "resource/Longhudou/csbimages/anim/Txguangquan/Txguangquan.atlas")
			skeletonNode:setPosition(cc.p(size.width/2, size.height/2))
			self.imgFrame:addChild(skeletonNode, 1, 98)
		else
			skeletonNode:setVisible(true)
		end

		skeletonNode:setAnimation(0, "animation", false)

		local eff = cc.ParticleSystemQuad:create("resource/Longhudou/csbimages/Particle/guang/guang.plist")
		eff:setPosition(cc.p(size.width/2, size.height/2))
		self.imgFrame:addChild(eff, 2, 99)

		--动作播放完成监听
		skeletonNode:registerSpineEventHandler(function (event)
		  -- print(string.format("[spine] %d complete: %d", event.trackIndex, event.loopCount))
		  	skeletonNode:setVisible(false)
		  	--删除开始效果粒子
			eff:removeFromParent()

		end, sp.EventType.ANIMATION_COMPLETE)

		
	elseif info.winCoin == 0 then
		--开和的时候，输赢为0也显示动画
		-- if currentSidesDesc == Longhudou_pb.HE then
			local strCoin = Assist.NumberFormat:amount2TrillionText(info.winCoin)
			strCoin = "+"..strCoin
			self:runNumAction(self.fntWin, strCoin, 1.5)
		-- end
	else
		--输
		local strCoin = Assist.NumberFormat:amount2TrillionText(info.winCoin)
		self:runNumAction(self.fntLose, strCoin, 1.5)
	end
end

function prototype:doOtherSettlement(winCoin, currentSidesDesc)
	if winCoin > 0 or (winCoin == 0 and currentSidesDesc == Longhudou_pb.HE) then
		--赢	
		local strCoin = "+" .. Assist.NumberFormat:amount2TrillionText(winCoin)
		self:runNumAction(self.fntOtherWin, strCoin)

		local size = self.btnOnlinePlayer:getContentSize()
		--[[local eff = CEffectManager:GetSingleton():getEffect("a1longtx")
		eff:setPosition(cc.p(size.width/2, size.height/2))
		self.btnOnlinePlayer:addChild(eff)--]]

		local skeletonNode = self.rootNode:getChildByTag(100)
		if skeletonNode == nil then
			skeletonNode = sp.SkeletonAnimation:create("resource/Longhudou/csbimages/anim/Txguangquan/Txguangquan.json", "resource/Longhudou/csbimages/anim/Txguangquan/Txguangquan.atlas")
			skeletonNode:setPosition(cc.p(size.width/2, size.height/2))
			self.btnOnlinePlayer:addChild(skeletonNode, 1, 100)
		else
			skeletonNode:setVisible(true)
		end

		skeletonNode:setAnimation(0, "animation", false)

		local eff = cc.ParticleSystemQuad:create("resource/Longhudou/csbimages/Particle/guang/guang.plist")
		eff:setPosition(cc.p(size.width/2, size.height/2))
		self.btnOnlinePlayer:addChild(eff, 2, 101)

		--动作播放完成监听
		skeletonNode:registerSpineEventHandler(function (event)
		  -- print(string.format("[spine] %d complete: %d", event.trackIndex, event.loopCount))
		  	skeletonNode:setVisible(false)
		  	--删除开始效果粒子
			eff:removeFromParent()

		end, sp.EventType.ANIMATION_COMPLETE)

		-- log("run other win num action :: str == " .. strCoin)
		
	elseif winCoin < 0 then
		--输
		local strCoin = Assist.NumberFormat:amount2TrillionText(winCoin)
		-- log("run other lose num action :: str == " .. strCoin)
		self:runNumAction(self.fntOtherLose, strCoin)
	end
end

function prototype:runNumAction(fntNode, str, delayTime)
	delayTime = delayTime or 1.0
	fntNode:setOpacity(255)
	fntNode:setString(str)
	fntNode:setVisible(true)
	fntNode:runAction(cc.Sequence:create(
		cc.MoveBy:create(0.5, cc.p(0, 50)), 
		cc.DelayTime:create(delayTime),
		cc.FadeOut:create(0.5), 
		cc.CallFunc:create(function()
			fntNode:setVisible(false)
			local x, y = fntNode:getPosition()
			fntNode:setPosition(cc.p(x, y - 50))
		end)))
end

--在线玩家
function prototype:onBtnOnlinePlayerTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Longhudou.PlayerList")
	end
end

function prototype:getUserBetPos()
	return self.imgFrame:getWorldPosition()
end

function prototype:getOtherBetPos()
	local pos = self.btnOnlinePlayer:getWorldPosition()
	return pos
end

function prototype:getOtherPlayerWidget()
	return self.btnOnlinePlayer
end

function prototype:getBetMinLimit()
	return BET_MIN_LIMIT
end

--充值
function prototype:onBtnRechargeTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Shop/ShopView", 1)
	end
end


