local Pool    = require "Pool"

module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local Longhudou_pb = Longhudou_pb

local FLOOR = math.floor
local MODF = math.modf
local RANDOM = math.random
local NUMBER_MOVE_OFF = 60
local BET_RANGE = {1, 10, 100, 500, 1000}

local director = cc.Director:getInstance()

function prototype:dispose()
    super.dispose(self)
    self.pool:dispose()

    sys.sound:unloadEffects(self.soundEffs)
end

function prototype:enter()
	self.size = self.rootNode:getContentSize()
	--UI事件
	self:bindUIEvent("Longhudou.HeBet", "uiEvtHeBet")
	self:bindUIEvent("Longhudou.LongBet", "uiEvtLongBet")
	self:bindUIEvent("Longhudou.HuBet", "uiEvtHuBet")
	self:bindUIEvent("Longhudou.ContinueBet", "uiEvtContinueBet")
	self:bindUIEvent("Longhudou.ShowDetails", "uiEvtShowDetails")
	self:bindUIEvent("Longhudou.PlayerList", "uiEvtPlayerList")
	self:bindUIEvent("Longhudou.Snatch", "uiEvtSnatch")
	self:bindUIEvent("Longhudou.Abandon", "uiEvtAbandon")

	--Model消息事件
	self:bindModelEvent("Games/Longhudou.EVT.PUSH_ENTER_ROOM", "onPushRoomEnter")
	self:bindModelEvent("Games/Longhudou.EVT.PUSH_ROOM_STATE", "onPushRoomState")
	self:bindModelEvent("Games/Longhudou.EVT.PUSH_MEMBER_STATUS", "onPushMemberStatus")
	self:bindModelEvent("Games/Longhudou.EVT.PUSH_BET_RESULT", "onPushBetResult")
	self:bindModelEvent("Games/Longhudou.EVT.PUSH_BET_COIN", "onPushBetCoin")
	self:bindModelEvent("Games/Longhudou.EVT.PUSH_OPEN_RESULT", "onPushOpenResult")
	self:bindModelEvent("Games/Longhudou.EVT.PUSH_SETTLEMENT", "onPushSettlement")
	-- self:bindModelEvent("Games/Longhudou.EVT.PUSH_SNATCHQUEUE", "onPushSnatchQueue")
	--货币刷新
	self:bindModelEvent("SynData.EVT.PUSH_SYN_USER_DATA", "onPushSynUserData")

	self.soundEffs = 
	{
		CARD_1 		= "resource/Longhudou/audio/cardtype/lhb_p_1.mp3",
		CARD_2 		= "resource/Longhudou/audio/cardtype/lhb_p_2.mp3",
		CARD_3 		= "resource/Longhudou/audio/cardtype/lhb_p_3.mp3",
		CARD_4 		= "resource/Longhudou/audio/cardtype/lhb_p_4.mp3",
		CARD_5 		= "resource/Longhudou/audio/cardtype/lhb_p_5.mp3",
		CARD_6 		= "resource/Longhudou/audio/cardtype/lhb_p_6.mp3",
		CARD_7 		= "resource/Longhudou/audio/cardtype/lhb_p_7.mp3",
		CARD_8 		= "resource/Longhudou/audio/cardtype/lhb_p_8.mp3",
		CARD_9 		= "resource/Longhudou/audio/cardtype/lhb_p_9.mp3",
		CARD_10 	= "resource/Longhudou/audio/cardtype/lhb_p_10.mp3",
		CARD_11 	= "resource/Longhudou/audio/cardtype/lhb_p_11.mp3",
		CARD_12 	= "resource/Longhudou/audio/cardtype/lhb_p_12.mp3",
		CARD_13 	= "resource/Longhudou/audio/cardtype/lhb_p_13.mp3",
		HE 			= "resource/Longhudou/audio/he.mp3",
		LONG 		= "resource/Longhudou/audio/long_win.mp3",
		HU 			= "resource/Longhudou/audio/hu_win.mp3",
		BET_START 	= "resource/Longhudou/audio/bet_start.mp3",
		BET_END 	= "resource/Longhudou/audio/bet_end.mp3"
	}

	sys.sound:preloadEffects(self.soundEffs)

	self.userId = Model:get("Account"):getUserId()
	self.modelData = Model:get("Games/Longhudou")

	-- self.coinSprites = {}
	--货币对象缓存
	self.pool  = Pool.class:new()

	self:initSeatInfo()
	self.nodeLeftGroup:setGroupType(1)
	self.nodeRightGroup:setGroupType(2)
	self.userLastGameBet = {0, 0, 0}
	self:onPushRoomEnter()
	-- sys.sound:playMusicByFile("resource/Longhudou/audio/background_music.mp3")

	self.isTimeOut = false

	-- local stage = StageMgr:getStage()
	-- stage:bindEvent(GameStage.EVT.ENTER_BACKGROUND, self:createEvent("onEnterBackground"))
	-- stage:bindEvent(GameStage.EVT.ENTER_FOREGROUND, self:createEvent("onEnterForeground"))
end

function prototype:onEnterBackground()
	-- log("Longhudou onEnterBackground")
	--在游戏中，进入后台超过10s，断开连接
	util.timer:after(10 * 1000, self:createEvent('BACKGROUND_TIMEOUT_TIMER', 'onBackGroundTimeout'))
	self.isTimeOut = false
end

function prototype:onBackGroundTimeout()
	log("Longhudou on background time out !!!")
	net.mgr:disconnect()
	self.isTimeOut = true
end

function prototype:onEnterForeground()
	-- log("Longhudou onEnterForeground")

	util.timer:after(1, function()
		if self:existEvent('BACKGROUND_TIMEOUT_TIMER') then
			self:cancelEvent('BACKGROUND_TIMEOUT_TIMER')
		end

		if self.isTimeOut then
			Model:get("Account"):connect()
			self.isTimeOut = false
		end
	end)
end


--从缓存中获取
function prototype:getSpriteFromPool(fileName)
	local node = self.pool:getFromPool("Sprite", fileName)
    return node
end

--回收
function prototype:recycleSpriteToPool(node)
	if not node then
		return
	end

	local fileName = node:getName()
	self.pool:putInPool(fileName, node)

	node:removeFromParent(true)
end

--获取富豪榜、大赢家、其他人飞金币坐标位置
function prototype:initSeatInfo()
	self.seatsPos = {}	
	for i = 1, 3 do
		table.insert(self.seatsPos, self.nodeLeftGroup:getBetCoinStartPos(i))
	end

	for i = 1, 3 do
		table.insert(self.seatsPos, self.nodeRightGroup:getBetCoinStartPos(i))
	end

	table.insert(self.seatsPos, self.nodeBottomMsg:getOtherBetPos())

	local items1 = self.nodeLeftGroup:getGroupItems()
	local items2 = self.nodeRightGroup:getGroupItems()
	self.richItems = {items1[1], items1[2], items1[3], items2[2], items2[3]}
	self.divinerItem = items2[1]

	local size = self.imgPop:getContentSize()
	local x, y = self.imgPop:getPosition()
	local pos = cc.p(x - size.width/2, y - size.height/2)
	self.starsPos = {
		cc.pAdd(pos, cc.p(self.imgStar_1:getPosition())),
		cc.pAdd(pos, cc.p(self.imgStar_2:getPosition())),
		cc.pAdd(pos, cc.p(self.imgStar_3:getPosition())),
	}
end

function prototype:gameClear()
	self.imgBetCenterArea:setVisible(false)
	self.imgBetLeftArea:setVisible(false)
	self.imgBetRightArea:setVisible(false)
	self.imgBetCenterArea:stopAllActions()
	self.imgBetLeftArea:stopAllActions()
	self.imgBetRightArea:stopAllActions()

	self.imgLongStarEff:removeAllChildren()
	self.imgHuStarEff:removeAllChildren()

	-- self.nodeCountdown:setVisible(false)

	self.imgStar_1:setVisible(false)
	self.imgStar_2:setVisible(false)
	self.imgStar_3:setVisible(false)

	self.txtTotalBetNum_1:setString("总注:0")
	self.txtUserBetNum_1:setVisible(false)

	self.txtTotalBetNum_2:setString("总注:0")
	self.txtUserBetNum_2:setVisible(false)

	self.txtTotalBetNum_3:setString("总注:0")
	self.txtUserBetNum_3:setVisible(false)

	self.nodeCardLong:setCardInfo()
	self.nodeCardHu:setCardInfo()
	self.nodeCardLong:stopAction()
	self.nodeCardHu:stopAction()

	self.currentSidesDesc = -1
	self.userBetNum = {0, 0, 0}
	self.curBetSide = 0

	-- self.panelCoins:removeAllChildren()
	local i        = 0
    local pArray   = self.panelCoins:getChildren()
    local len      = table.getn(pArray)
    local pObject  = nil
    for i = 0, len-1 do
        pObject = pArray[i + 1]
        if pObject == nil then
            break
        end
        
        self:recycleSpriteToPool(pObject)
    end

	self.coinSprites = {{}, {}, {}, {}, {}}

	self.rootNode:stopAllActions()
end

function prototype:onPushRoomEnter()
	self:gameClear()
	self:onPushRoomInfo()
	self:onPushRoomState()
	self:onPushMemberStatus()

	self:updateFrontPlayerData()

	local toPos
	local totalLongCoins = 0
	local totalHuCoins = 0
	local totalHeCoins = 0
	local initBets = self.modelData:getInitBets()
	if initBets then
		local divinerId = self.divinerId
		local userId = self.userId
		for i, v in ipairs(initBets) do
			if v.sidesDesc == Longhudou_pb.LONG then
				toPos = self.nodeLeftArea:getBetPos()
				totalLongCoins = v.totalBetCoin
			elseif v.sidesDesc == Longhudou_pb.HU then
				toPos = self.nodeRightArea:getBetPos()	
				totalHuCoins = v.totalBetCoin
			else
				toPos = self.nodeCenterArea:getBetPos()		
				totalHeCoins = v.totalBetCoin
			end

			if v.playerId == divinerId then
				self["imgStar_"..v.sidesDesc]:setVisible(true)
			end

			if v.playerId == userId then
				self.userBetNum[v.sidesDesc] = self.userBetNum[v.sidesDesc] + v.coin
			end

			self:runBetCoinAction(cc.p(0, 0), toPos, v, true)
		end

		for i, v in ipairs(self.userBetNum) do
			if v > 0 then
				self["txtUserBetNum_"..i]:setString("下注:" .. FLOOR(v/100))
				self["txtUserBetNum_"..i]:setVisible(true)
			end
		end

		self.txtTotalBetNum_1:setString("总注:" .. FLOOR(totalLongCoins/100))
		self.txtTotalBetNum_2:setString("总注:" .. FLOOR(totalHuCoins/100))	
		self.txtTotalBetNum_3:setString("总注:" .. FLOOR(totalHeCoins/100))
	end

	local roomStateInfo = self.modelData:getRoomStateInfo()
	local openResult = self.modelData:getInitOpenResult()
	if openResult then
		if roomStateInfo.roomState ~= Longhudou_pb.State_Bet or roomStateInfo.isMing == true then
			self.nodeCardLong:setCardInfo(self.userId, openResult.cardLong)
			self.nodeCardLong:showCardValue()
			self.nodeCardHu:setCardInfo(self.userId, openResult.cardHu)
			self.nodeCardHu:showCardValue()

			local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5)))
			if openResult.currentSidesDesc == Longhudou_pb.LONG then
				sys.sound:playEffectByFile(self.soundEffs["LONG"])
				self.nodeCardLong:playFireEffect()

				self.imgBetLeftArea:setVisible(true)
				self.imgBetLeftArea:runAction(action)

			elseif openResult.currentSidesDesc == Longhudou_pb.HU then
				sys.sound:playEffectByFile(self.soundEffs["HU"])
				-- sys.sound:playEffectByFile("resource/Longhudou/audio/hu_win.mp3")
				self.nodeCardHu:playFireEffect()

				self.imgBetRightArea:setVisible(true)
				self.imgBetRightArea:runAction(action)
			else
				sys.sound:playEffectByFile(self.soundEffs["HE"])
				-- sys.sound:playEffectByFile("resource/Longhudou/audio/he.mp3")

				self.imgBetCenterArea:setVisible(true)
				self.imgBetCenterArea:runAction(action)
			end
		end

		--近60局开牌结果
		-- local sixtySidesDesc = {}
		-- for i, v in ipairs(openResult.sixtySidesDesc) do
		-- 	sixtySidesDesc[#sixtySidesDesc + 1] = v
		-- end

		self.nodeLineResult:initData(openResult.sixtySideResult)
		self.nodeResult:initData(openResult.sixtySideResult, roomStateInfo.isMing)
	else
		self.nodeLineResult:initData()
		self.nodeResult:initData()
	end

	if roomStateInfo.roomState ~= Longhudou_pb.State_Bet then
		-- local eff = CEffectManager:GetSingleton():getEffect("a1longwait")
		-- local size = self.panelEff:getContentSize()
		-- eff:setPosition(cc.p(size.width/2, size.height/2))
		-- self.panelEff:addChild(eff)

		--请等待效果
		local skeletonNode = sp.SkeletonAnimation:create("resource/Longhudou/csbimages/anim/Wait/Dengdai.json", "resource/Longhudou/csbimages/anim/Wait/Dengdai.atlas")
		skeletonNode:setAnimation(0, "animation", true)
		skeletonNode:setTag(101)
		self.panelEff:addChild(skeletonNode)
	end

	self.resultInfo = nil
end

function prototype:onPushRoomInfo()
	local roomInfo = self.modelData:getRoomInfo()
	BET_RANGE = roomInfo.betRanges
	if roomInfo then --更换游戏背景
		if roomInfo.playId == 115002 then
			self.nodeUpDealer.dealerTip:setString("上庄需要5千金币")
			self.nodeUpDealer:setPlayId(roomInfo.playId)
		end
		if roomInfo.playId == 115001 then
			self.nodeUpDealer.dealerTip:setString("上庄需要2千金币")
			self.nodeUpDealer:setPlayId(roomInfo.playId)
		end
	end
	if self:isGameSZ() == true then
		local dealerQueue =self.modelData:getDealerQueue()
		self:setDealerHead(dealerQueue)
	else
		self.nodeDealerHeadMsg:setVisible(false)
		self.nodeUpDealer:setVisible(false)
		self.imgPop:loadTexture("resource/Longhudou/csbimages/longhumap.png")
	end
end

function prototype:clearPlayerData(playerId)
	if not playerId then
		return
	end

	local bUpdate = false
	if playerId == self.divinerId then
		bUpdate = true		
	else
		for i, v in ipairs(self.richList) do
			if v.playerId == playerId then
				bUpdate = true
				break
			end
		end
	end

	self.modelData:removeMemberById(playerId)
	if bUpdate then
		self:updateFrontPlayerData()
	end
end

--富豪榜、神算子
function prototype:updateFrontPlayerData()
	local roomMember = self.modelData:getRoomMember()
	local memberList = table.values(roomMember)
	local memNum = #memberList
	
	if memNum > 0 then
		local divineList = table.clone(memberList)
		--神算子：按近20局输赢
		table.sort(divineList, function (a, b)
			return a.winTimes > b.winTimes
		end)

		self.divineList = divineList
    	local divinerInfo = divineList[1]
		self.divinerId = divinerInfo.playerId
		self.divinerItem:setPlayerInfo(divinerInfo)
	else
		self.divinerItem:setPlayerInfo()
	end

	--富豪榜：按总下注排序
	if memNum > 0 then
		table.sort(memberList, function (a, b)
			return a.totalBetCoin > b.totalBetCoin
		end)

		-- log(memberList)
		self.richList = {}

		-- log(self.divinerId)
		
		local index = 1
		for i, v in ipairs(memberList) do
			-- log("playerId: " .. v.playerId .. ", divinerId : " .. self.divinerId)
			if v.playerId ~= self.divinerId then
				self.richItems[index]:setPlayerInfo(v)
				table.insert(self.richList, v)

				index = index + 1
			end

			if #self.richList == 5 then
				break
			end
		end

		if #self.richList < 5 then
			for i = #self.richList + 1, 5 do
				self.richItems[i]:setPlayerInfo()
			end
		end
	else
		for k,v in pairs(self.richItems) do
			self.richItems[k]:setPlayerInfo()
		end
	end

	if memNum==0 then
		self.nodeBottomMsg:setOnlineNumber(1)
	else
		if self:systemIsDealer() then
			self.nodeBottomMsg:setOnlineNumber(memNum)
		else
			self.nodeBottomMsg:setOnlineNumber(memNum+1)
		end
	end
end

function prototype:setBetAreaVisible(isVisible)
	self.nodeCenterArea:setVisible(isVisible)
	self.nodeLeftArea:setVisible(isVisible)
	self.nodeRightArea:setVisible(isVisible)
end

function prototype:onPushRoomState()
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo then
		local roomState = roomStateInfo.roomState
		local countDown = roomStateInfo.countDown
		-- log("[LonghudouView::onPushRoomState] roomState == " .. roomState .. ", countDown == " .. countDown)
		if roomStateInfo.isMing then
			sys.sound:playMusicByFile("resource/Longhudou/audio/background_music2.mp3")
		else
			sys.sound:playMusicByFile("resource/Longhudou/audio/background_music.mp3")
		end

		if roomState == Longhudou_pb.State_Bet then
			self:gameClear()

			if self.resultInfo ~= nil then
				self.nodeLineResult:initData(self.resultInfo.sixtySideResult)
				self.nodeResult:initData(self.resultInfo.sixtySideResult, self.resultInfo.isMing)
			end

			self.nodeResult:autoHide()
			self.nodeCountdown:start(countDown, roomState)
			
			--明牌抢注禁用续注
			if roomStateInfo.isMing == true then
				self.nodeBottomMsg:setEnabledContinueBet(false)
				--特效
				-- local eff = CEffectManager:GetSingleton():getEffect("a1mingpai1")
				-- if eff then
				-- 	eff:setPosition(cc.p(585, 485))
				-- 	self.imgPop:addChild(eff, 1, 99)
				-- end
			else
				self.nodeBottomMsg:setEnabledContinueBet(true, self.userLastGameBet)

				--移除明牌特效
				-- local eff = self.imgPop:getChildByTag(99)
				-- if eff then
				-- 	eff:removeFromParent()
				-- end
			end
			if self:selfIsDealer() == true then
				self.nodeBottomMsg:unenabledBetMenu()
				self.nodeBottomMsg:setEnabledContinueBet(false)
			else
				self.nodeBottomMsg:refreshBetMenu()
			end
			-- self.panelEff:removeAllChildren()
			--删除 “请等待” spine动作
			local skeletonNode = self.panelEff:getChildByTag(101)
			if skeletonNode then
				skeletonNode:removeFromParent()
			end

			local isValid = director:isValid()
			local enableBet = true
			--开始特效 vs
			local delay = 0
			if self.roomState and self.roomState == Longhudou_pb.State_Settlement then
				self:updateFrontPlayerData()

				if isValid then
					local size = self.panelEff:getContentSize()
					skeletonNode = self.panelEff:getChildByTag(100)
					if skeletonNode == nil then
						skeletonNode = sp.SkeletonAnimation:create("resource/Longhudou/csbimages/anim/Start/skeleton.json", "resource/Longhudou/csbimages/anim/Start/skeleton.atlas")
						
						skeletonNode:setPosition(cc.p(size.width/2, size.height/2))
						skeletonNode:setTag(100)
						self.panelEff:addChild(skeletonNode)
					else
						skeletonNode:setVisible(true)
					end

					enableBet = false
					-- skeletonNode:setToSetupPose()
					skeletonNode:setAnimation(0, "animation", false)

					local eff = cc.ParticleSystemQuad:create("resource/Longhudou/csbimages/Particle/Start_particle/Start_particle.plist")
					eff:setPosition(cc.p(size.width/2, size.height/2))
					self.panelEff:addChild(eff)

					-- skeletonNode:registerSpineEventHandler(function (event)
					--  	print(string.format("[spine] %d start: %s", event.trackIndex, event.animation))
					-- end, sp.EventType.ANIMATION_START)

					-- skeletonNode:registerSpineEventHandler(function (event)
					--   print(string.format("[spine] %d end:", event.trackIndex))
					-- end, sp.EventType.ANIMATION_END)

					--动作播放完成监听
					skeletonNode:registerSpineEventHandler(function (event)
					  -- print(string.format("[spine] %d complete: %d", event.trackIndex, event.loopCount))
					  	skeletonNode:setVisible(false)
					  	--删除开始效果粒子
						eff:removeFromParent()

						--开始动画播放完后才可以下注
						local accountInfo = Model:get("Account"):getUserInfo()
						--将金币这算成人民币 1:100
						local coinValue = math.floor(accountInfo.gold / 100)
						if coinValue >= self.nodeBottomMsg:getBetMinLimit() then
							self:setBetAreaVisible(true)
						else
							self:setBetAreaVisible(false)
						end

					end, sp.EventType.ANIMATION_COMPLETE)

					-- skeletonNode:registerSpineEventHandler(function (event)
					--   print(string.format("[spine] %d event: %s, %d, %f, %s", 
					--                           event.trackIndex,
					--                           event.eventData.name,
					--                           event.eventData.intValue,
					--                           event.eventData.floatValue,
					--                           event.eventData.stringValue)) 
					-- end, sp.EventType.ANIMATION_EVENT)

					delay = 1.0
					--vs动画音效
					sys.sound:playEffectByFile("resource/Longhudou/audio/lhd_start_anim_effect.mp3")
				end
			end
			
			if enableBet then
				local accountInfo = Model:get("Account"):getUserInfo()
				--将金币这算成人民币 1:100
				local coinValue = math.floor(accountInfo.gold / 100)
				if coinValue >= self.nodeBottomMsg:getBetMinLimit() then
					self:setBetAreaVisible(true)
				else
					self:setBetAreaVisible(false)
				end
			end

			if isValid then
				--开始下注特效
				self.panelEff:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function()
					self:playBetAction(true)
				end)))
			end
			self:seeSnatchState()
		elseif roomState == Longhudou_pb.State_OpenDeal then
			self:setBetAreaVisible(false)

			self.nodeCountdown:start(-1, roomState)
			--停止下注按钮切换
			self.nodeBottomMsg:unenabledBetMenu()
			--结束下注特效
			self:playBetAction()

		elseif roomState == Longhudou_pb.State_Settlement then
			--明牌没有开牌，结算提示结束下注
			if roomStateInfo.isMing then
				self:playBetAction()

				--移除明牌特效
				-- local eff = self.imgPop:getChildByTag(99)
				-- if eff then
				-- 	eff:removeFromParent()
				-- end
			end		

			self:setBetAreaVisible(false)

			self.nodeCountdown:start(countDown, roomState)
			--停止下注按钮切换
			self.nodeBottomMsg:unenabledBetMenu()

			--记录上一局压注，方便做续注
			self.userLastGameBet = table.clone(self.userBetNum)
		end

		self.roomState = roomState
	end
end

--开始下注、结束下注动画
function prototype:playBetAction(isStart)
	if not director:isValid() then
		return
	end

	isStart = isStart or false
	local res = ""
	if isStart then
		res = "resource/Longhudou/csbimages/start_xiazhu_tips.png"
	else
		res = "resource/Longhudou/csbimages/stop_xiazhu_tips.png"
	end

	local size = self.panelEff:getContentSize()
	--开始下注动画
	local moveBy1 = cc.MoveBy:create(0.2, cc.p(self.size.width/2, 0))
	local moveBy2 = cc.MoveBy:create(0.2, cc.p(-self.size.width/2, 0))
	
	local spriteBg = cc.Sprite:create("resource/Longhudou/csbimages/tishi_bg.png")
	spriteBg:setPosition(cc.p(-self.size.width/2, size.height/2))
	self.panelEff:addChild(spriteBg)
	spriteBg:runAction(cc.Sequence:create(
		cc.EaseOut:create(moveBy1, 3.5), 
		cc.DelayTime:create(0.8), 
		cc.EaseIn:create(moveBy1:reverse(), 3.5), 
		cc.CallFunc:create(function()
			spriteBg:removeFromParent()
	end)))

	local sprite = cc.Sprite:create(res)
	sprite:setPosition(cc.p(self.size.width/2, size.height/2))
	self.panelEff:addChild(sprite)
	sprite:runAction(cc.Sequence:create(
		cc.EaseOut:create(moveBy2, 3.5), 
		cc.DelayTime:create(0.8), 
		cc.EaseIn:create(moveBy2:reverse(), 3.5), 
		cc.CallFunc:create(function()
			sprite:removeFromParent()
	end)))

	if isStart then
		--开始下注
		sys.sound:playEffectByFile(self.soundEffs["BET_START"])
		-- sys.sound:playEffectByFile("resource/Longhudou/audio/bet_start.mp3")
	else
		--下注结束
		sys.sound:playEffectByFile(self.soundEffs["BET_END"])
		-- sys.sound:playEffectByFile("resource/Longhudou/audio/bet_end.mp3")
	end
end

function prototype:onPushMemberStatus(refreshList)
	local roomMember = self.modelData:getRoomMember()
	local memNum=table.nums(roomMember)
	refreshList = refreshList or table.keys(roomMember)
	if refreshList and #refreshList > 0 then
		local bAddRole = false
		local bDelRole = false	
		for index, id in ipairs(refreshList) do
			local playerInfo = roomMember[id]
			if playerInfo then
				if playerInfo.memberType == Common_pb.Add then
					--新加入成员
					bAddRole = true
				elseif playerInfo.memberType == Common_pb.Update then
					--更新成员数据。玩家充值时，金币发生变化
					if id == self.divinerId then
						self.divinerItem:setPlayerInfo(playerInfo)
					end

					for i, v in ipairs(self.richList) do
						if v.playerId == id then
							self.richItems[i]:setPlayerInfo(playerInfo)
							break
						end
					end
				else
					--离开房间
					if self.userId == id then
						StageMgr:chgStage("Hall")
					else
						self:clearPlayerData(id)
						bDelRole = true
					end
				end
			else
				--log4ui:warn("[LonghudouView::onPushMemberStatus] get player info failed ! player id == " .. id)
			end
		end

		if self.richList then
			if #self.richList < 5 and bAddRole == true then
				self:updateFrontPlayerData()
			end

			if bAddRole or bDelRole then
				if self:systemIsDealer() then
					self.nodeBottomMsg:setOnlineNumber(memNum)
				else
					self.nodeBottomMsg:setOnlineNumber(memNum+1)
				end
			end
		end
	end
end

--同步货币数据
function prototype:onPushSynUserData(data)
	--将金币这算成人民币 1:100
	local coinValue = FLOOR((data.gold / 100))
	if coinValue >= self.nodeBottomMsg:getBetMinLimit() then
		self:setBetAreaVisible(true)
	else
		self:setBetAreaVisible(false)
	end

	-- local playerInfo = Model:get("Games/Longhudou"):getUserInfo()
	-- playerInfo.coin = accountInfo.gold

	if self:selfIsDealer() == true then
		self.nodeBottomMsg:unenabledBetMenu()
		self.nodeBottomMsg:setEnabledContinueBet(false)
	else
		self.nodeBottomMsg:refreshBetMenu(true)
	end
end

--推送玩家下注
function prototype:onPushBetCoin(betInfo)
	if not betInfo then
		return
	end

	local isValid = director:isValid() --用来判断是否切换后台，切换后台时，action不播放

	local bBreak = false
	local fromPos
	local toPos
	local seatIndex = 7	
	local roomMember = self.modelData:getRoomMember()
	local sidesDesc = betInfo.sidesDesc

	--自己
	if self.userId == betInfo.playerId then		
		fromPos = self.nodeBottomMsg:getUserBetPos()
		bBreak = true

		local sidesDesc = betInfo.sidesDesc
		self.userBetNum[sidesDesc] = self.userBetNum[sidesDesc] + betInfo.coin

		self["txtUserBetNum_"..sidesDesc]:setString("下注:" .. FLOOR(self.userBetNum[sidesDesc]/100))
		self["txtUserBetNum_"..sidesDesc]:setVisible(true)
		
		-- if sidesDesc == Longhudou_pb.LONG then
		-- 	self.txtLongBetNum:setString("下注:" .. FLOOR(self.userBetNum[sidesDesc]/100))
		-- 	self.txtLongBetNum:setVisible(true)
		-- elseif sidesDesc == Longhudou_pb.HU then
		-- 	self.txtHuBetNum:setString("下注:" .. FLOOR(self.userBetNum[sidesDesc]/100))
		-- 	self.txtHuBetNum:setVisible(true)
		-- else
		-- 	self.txtHeBetNum:setString("下注:" .. FLOOR(self.userBetNum[sidesDesc]/100))
		-- 	self.txtHeBetNum:setVisible(true)
		-- end

		local userInfo = roomMember[self.userId]
		self.nodeBottomMsg:doUserBet(userInfo, betInfo.coin)
	end

	--是否神算子下注 神算子飞星星
	if self.divinerId == betInfo.playerId then
		if isValid then
			--切换到后台时，不播放动画
			local startPos = self.seatsPos[4]
			local endPos = self.starsPos[sidesDesc]
			
			local star = cc.Sprite:create("resource/Longhudou/csbimages/img_star.png")
			star:setPosition(startPos)
			self.panelCoins:addChild(star)

			local size = star:getContentSize()
			local eff = cc.ParticleSystemQuad:create("resource/Longhudou/csbimages/Particle/Feixing/Feixing.plist")
			eff:setPosition(cc.p(size.width/2, size.height/2))
			star:addChild(eff)

			local controlPos_1 = cc.p(startPos.x + (endPos.x-startPos.x)*0.3, startPos.y + 20)
			local controlPos_2 = cc.p(startPos.x + (endPos.x-startPos.x)*0.7, startPos.y + 50)
			local bezier = {
		        controlPos_1,
		        controlPos_2,
		        endPos
		    }
		    local action = cc.BezierTo:create(1.2, bezier)
			star:runAction(cc.Sequence:create(action, cc.DelayTime:create(0.2), cc.CallFunc:create(function(sender)
				self["imgStar_"..sidesDesc]:setVisible(true)
				sender:removeFromParent()
			end)))

			local actionBy = cc.MoveBy:create(0.1, cc.p(-20, 0))
			local actionByBack = actionBy:reverse()
			self.divinerItem:runAction(cc.Sequence:create(actionBy, actionByBack))
		else
			self["imgStar_"..sidesDesc]:setVisible(true)
		end

		-- log(betInfo)
		self.divinerItem:doPlayerBet(roomMember[betInfo.playerId], betInfo.coin, betInfo.playerId == self.userId)
	else
		--是否富豪榜前5下注
		for i, v in ipairs(self.richList) do
			if v.playerId == betInfo.playerId then
				self.richItems[i]:doPlayerBet(roomMember[betInfo.playerId], betInfo.coin, betInfo.playerId==self.userId)

				if not bBreak then					
					local moveX = 20
					if i <= 3 then
						seatIndex = i					
					else
						seatIndex = i + 1				
						moveX = -20
					end
					fromPos = self.seatsPos[seatIndex]
					bBreak = true

					if isValid then
						local actionBy = cc.MoveBy:create(0.1, cc.p(moveX, 0))
						local actionByBack = actionBy:reverse()
						self.richItems[i]:runAction(cc.Sequence:create(actionBy, actionByBack))
					end
				end

				break
			end
		end
	end

	--其他人下注
	if not bBreak then		
		fromPos = self.seatsPos[seatIndex]
		bBreak = true

		if isValid then
			local widget = self.nodeBottomMsg:getOtherPlayerWidget()
			local actionBy = cc.MoveBy:create(0.1, cc.p(20, 20))
			local actionByBack = actionBy:reverse()
			widget:runAction(cc.Sequence:create(actionBy, actionByBack))
		end
	end

	if sidesDesc == Longhudou_pb.LONG then
		toPos = self.nodeLeftArea:getBetPos()
		-- self.txtLongTotalBetNum:setString("总注:" .. FLOOR(betInfo.totalBetCoin/100))
	elseif sidesDesc == Longhudou_pb.HU then
		toPos = self.nodeRightArea:getBetPos()
		-- self.txtHuTotalBetNum:setString("总注:" .. FLOOR(betInfo.totalBetCoin/100))
	else
		toPos = self.nodeCenterArea:getBetPos()
		-- self.txtHeTotalBetNum:setString("总注:" .. FLOOR(betInfo.totalBetCoin/100))
	end

	self["txtTotalBetNum_"..sidesDesc]:setString("总注:" .. FLOOR(betInfo.totalBetCoin/100))

	self:runBetCoinAction(fromPos, toPos, betInfo, not isValid)
end

--下注动画
function prototype:runBetCoinAction(fromPos, toPos, betInfo, noAction)
	noAction = noAction or false
	
	--续注时候，一次有多个筹码
	local betChips = self:getChipsNum(betInfo.coin)
	local sprite
	local index = 0
	local fileName = ""
	for i, v in ipairs(betChips) do
		if v > 0 then
			for j = 1, v do
				fileName = string.format("resource/Longhudou/csbimages/Bet/coin_%d.png", BET_RANGE[i])
				sprite = self:getSpriteFromPool(fileName)
				sprite:setName(fileName)
				sprite:setAnchorPoint(cc.p(0.5, 0.5))				
				sprite:setRotation(RANDOM(0, 360))
				-- sprite:setTag(i)
				self.panelCoins:addChild(sprite)

				if not noAction then
					sprite:setPosition(fromPos)
					sprite:runAction(cc.Sequence:create(cc.DelayTime:create(index*0.1), cc.MoveTo:create(0.25, toPos), cc.RotateBy:create(0.2 , RANDOM(0, 360))))
					local bet_jinzhuanSound =3
					if self:isGameSZ() ==true then
						local roomInfo = self.modelData:getRoomInfo()
						if roomInfo.playId == 115001 then
							bet_jinzhuanSound=4
						else
							bet_jinzhuanSound=3
						end
					end
					if i >= bet_jinzhuanSound then
						sys.sound:playEffectByFile("resource/Longhudou/audio/bet_jinzhuan.mp3")	
					else
						sys.sound:playEffectByFile("resource/Longhudou/audio/bet.mp3")
					end
				else
					sprite:setPosition(toPos)
				end

				--记录下注筹码数据（输赢时，飞筹码）
				table.insert(self.coinSprites[i], sprite)

				index = index + 1
			end
		end
	end
end

--开牌
function prototype:onPushOpenResult(resultInfo)
	local delay = 1.0
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo.isMing == false then
		self:onPushRoomState()
	else
		delay = 0
	end

	self.currentSidesDesc = resultInfo.currentSidesDesc

	self.nodeCardLong:setCardInfo(self.userId, resultInfo.cardLong)
	self.nodeCardHu:setCardInfo(self.userId, resultInfo.cardHu)

	local move = cc.Spawn:create(
		cc.MoveBy:create(0.2, cc.p(0, -20)),
		cc.ScaleTo:create(0.2, 1.1))

	local moveReverse = cc.Spawn:create(
		cc.MoveBy:create(0.2, cc.p(0, 20)),
		cc.ScaleTo:create(0.2, 1.0))

	local longAction = cc.Sequence:create(
        cc.DelayTime:create(delay),
       	move,
       	cc.DelayTime:create(0.1),
        cc.ScaleTo:create(0.2, -1.1, 1.1),
        cc.ScaleTo:create(0, 1.1, 1.1),
        cc.CallFunc:create(function() 
        	self.nodeCardLong:showCardValue()        	
        end),
        cc.DelayTime:create(0.1),
		moveReverse,
		cc.CallFunc:create(function()
			sys.sound:playEffectByFile(string.format("resource/Longhudou/audio/cardtype/lhb_p_%d.mp3", self.nodeCardLong:getCardSize()))
		end))

	self.nodeCardLong:getCardNode():runAction(longAction)

	local huAction = cc.Sequence:create(
        cc.DelayTime:create(delay + 1.0),
       	move:clone(),
       	cc.DelayTime:create(0.1),
        cc.ScaleTo:create(0.2, -1.1, 1.1),
        cc.ScaleTo:create(0, 1.1, 1.1),
        cc.CallFunc:create(function() 
        	self.nodeCardHu:showCardValue()        	
        end),
        cc.DelayTime:create(0.1),
		moveReverse:clone(),
		cc.CallFunc:create(function()
			sys.sound:playEffectByFile(string.format("resource/Longhudou/audio/cardtype/lhb_p_%d.mp3", self.nodeCardHu:getCardSize()))
		end),
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			self:showOpenResult()
		end))
	
	self.nodeCardHu:getCardNode():runAction(huAction)

	self.resultInfo = resultInfo
	self.resultInfo.isMing = roomStateInfo.isMing
	-- local node = cc.Node:create()
	-- self.rootNode:addChild(node)
	-- node:runAction(cc.Sequence:create(cc.DelayTime:create(), cc.CallFunc:create(function(sender)

	-- 	sender:removeFromParent()
	-- end)))
end

function prototype:showOpenResult()
	if not self.resultInfo then
		return
	end

	local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5)))

	local resultInfo = self.resultInfo
	if resultInfo.currentSidesDesc == Longhudou_pb.LONG then
		sys.sound:playEffectByFile(self.soundEffs["LONG"])
		-- sys.sound:playEffectByFile("resource/Longhudou/audio/long_win.mp3")
		self.nodeCardLong:playFireEffect()

		self.imgBetLeftArea:setVisible(true)
		self.imgBetLeftArea:runAction(action)

		-- local eff = CEffectManager:GetSingleton():getEffect("a1longstar")
		local particle = cc.ParticleSystemQuad:create("resource/Longhudou/csbimages/Particle/win_side/win_particle.plist")
		local size = self.imgLongStarEff:getContentSize()
		particle:setPosition(cc.p(size.width/2, size.height/2))		
		self.imgLongStarEff:addChild(particle)

		self.imgLongStarEff:runAction(cc.Sequence:create(cc.DelayTime:create(2.5), cc.CallFunc:create(function()
			self.imgLongStarEff:removeAllChildren()
		end)))

	elseif resultInfo.currentSidesDesc == Longhudou_pb.HU then
		sys.sound:playEffectByFile(self.soundEffs["HU"])
		-- sys.sound:playEffectByFile("resource/Longhudou/audio/hu_win.mp3")
		self.nodeCardHu:playFireEffect()

		self.imgBetRightArea:setVisible(true)
		self.imgBetRightArea:runAction(action)

		-- local eff = CEffectManager:GetSingleton():getEffect("a1longstar")
		local particle = cc.ParticleSystemQuad:create("resource/Longhudou/csbimages/Particle/win_side/win_particle.plist")
		local size = self.imgHuStarEff:getContentSize()
		particle:setPosition(cc.p(size.width/2, size.height/2))		
		self.imgHuStarEff:addChild(particle)

		self.imgHuStarEff:runAction(cc.Sequence:create(cc.DelayTime:create(2.5), cc.CallFunc:create(function()
			self.imgHuStarEff:removeAllChildren()
		end)))
	else
		sys.sound:playEffectByFile(self.soundEffs["HE"])
		-- sys.sound:playEffectByFile("resource/Longhudou/audio/he.mp3")

		self.imgBetCenterArea:setVisible(true)
		self.imgBetCenterArea:runAction(action)
	end

	self.nodeLineResult:refreshResultData(resultInfo.sixtySideResult)

	local roomStateInfo = self.modelData:getRoomStateInfo()
	self.nodeResult:refreshData(resultInfo.sixtySideResult, roomStateInfo.isMing)

	self.resultInfo = nil
end

--结算
function prototype:onPushSettlement(refreshList, totalWinCoin)
	self:onPushRoomState()

	local roomStateInfo = self.modelData:getRoomStateInfo()
	local delay = roomStateInfo.countDown - 2.5
	if delay < 0 then delay = 0 end
	self.rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function ()
		self:doGameSettlement(refreshList, totalWinCoin)
	end)))
	-- util.timer:after(1000, self:createEvent('DELAY_SETTLEMENT_TIMER', 'doGameSettlement'))
end

function prototype:doGameSettlement(refreshList, totalWinCoin)
	local roomMember = self.modelData:getRoomMember()
	if #refreshList > 0 then
		local userId = self.userId
		local playerInfo
		--神算子
		playerInfo = roomMember[self.divinerId]
		if playerInfo then
			self.divinerItem:doSettlement(playerInfo, self.currentSidesDesc)
			self:runWinCoinAction(playerInfo, 1, 2)

			if playerInfo.playerId ~= userId then
				totalWinCoin = totalWinCoin - playerInfo.winCoin
			end
		else
			--log4ui:warn("onPushSettlement::diviner info is nil ! id : "..self.divinerId)
		end

		--富豪榜
		for i, v in ipairs(self.richList) do
			if i > 5 then
				break
			end

			playerInfo = roomMember[v.playerId]
			if playerInfo then
				self.richItems[i]:doSettlement(playerInfo, self.currentSidesDesc)
				if i <= 3 then
					self:runWinCoinAction(playerInfo, i, 1)
				else
					self:runWinCoinAction(playerInfo, i-2, 2)
				end

				--自己或者神算子不重复算
				if playerInfo.playerId ~= userId and playerInfo.playerId ~= self.divinerId then
					totalWinCoin = totalWinCoin - playerInfo.winCoin
				end
			else
				--log4ui:warn("onPushSettlement:: richList index:"..i..", id:"..v.playerId)
			end			
		end

		--自己
		if roomMember[userId]~=nil then
			playerInfo = roomMember[userId]
		else
			playerInfo = self.modelData:getDealerInfo()
		end
		self.nodeBottomMsg:doSettlement(playerInfo, self.currentSidesDesc)

		totalWinCoin = totalWinCoin - playerInfo.winCoin
		-- log("other totalWinCoin ======= " .. totalWinCoin)
		--其他人赢了飞筹码
		if totalWinCoin > 0 then
			self:flyWinChipAction(totalWinCoin, self.seatsPos[7])
		end

		self.nodeBottomMsg:doOtherSettlement(totalWinCoin, self.currentSidesDesc)

		sys.sound:playEffectByFile("resource/Longhudou/audio/fly_coin.mp3")

		for i, v in ipairs(self.coinSprites) do
			for _, node in ipairs(v) do
				-- node:removeFromParent()
				self:recycleSpriteToPool(node)
			end
		end

		self.coinSprites = {{}, {}, {}, {}, {}}

		self.imgStar_1:setVisible(false)
		self.imgStar_2:setVisible(false)
		self.imgStar_3:setVisible(false)
	end
end

function prototype:runWinCoinAction(playerInfo, index, side)
	local isValid = director:isValid()
	if not isValid then
		return
	end

	local winCoin = playerInfo.winCoin	
	if winCoin > 0 or (winCoin == 0 and self.currentSidesDesc == Longhudou_pb.HE) then
		local strCoin = "+" .. Assist.NumberFormat:amount2TrillionText(winCoin)
		--胜利或者和，播放赢数字动画		
		local labelName = string.format("fntWin_%d_%d", side, index)
		local fntWin = self[labelName]
		if fntWin == nil then
			 fntWin = cc.Label:createWithBMFont("resource/Longhudou/csbimages/Bmfont/font_win.fnt", strCoin)
			self.panelNumber:addChild(fntWin)

			local pos
			if side == 1 then
				--左边
				pos = self.nodeLeftGroup:getBetCoinStartPos(index)
				fntWin:setAnchorPoint(cc.p(0, 0.5))
			else
				--右边
				pos = self.nodeRightGroup:getBetCoinStartPos(index)
				fntWin:setAnchorPoint(cc.p(1, 0.5))
			end
			
			fntWin:setPosition(pos)

			self[labelName] = fntWin
		else
			fntWin:setString(strCoin)
			fntWin:setOpacity(255)
			fntWin:setVisible(true)
		end

		fntWin:runAction(cc.Sequence:create(
			cc.MoveBy:create(0.5, cc.p(0, NUMBER_MOVE_OFF)), 
			cc.DelayTime:create(1.0), 
			cc.FadeOut:create(0.5), 
			cc.CallFunc:create(function(sender)
				sender:setVisible(false)
				local x, y = sender:getPosition()
				sender:setPosition(cc.p(x, y - NUMBER_MOVE_OFF))
			end)))

		--飞筹码
		if winCoin > 0 then
			local seatIndex = index + (side-1)*3
			self:flyWinChipAction(winCoin, self.seatsPos[seatIndex])
		end

	elseif winCoin < 0 then
		local strCoin = Assist.NumberFormat:amount2TrillionText(winCoin)
		local labelName = string.format("fntLose_%d_%d", side, index)
		local fntLose = self[labelName]
		if fntLose == nil then
			fntLose = cc.Label:createWithBMFont("resource/Longhudou/csbimages/Bmfont/font_lose.fnt", strCoin)
			self.panelNumber:addChild(fntLose)

			local pos
			if side == 1 then
				--左边
				pos = self.nodeLeftGroup:getBetCoinStartPos(index)
				fntLose:setAnchorPoint(cc.p(0, 0.5))
			else
				--右边
				pos = self.nodeRightGroup:getBetCoinStartPos(index)
				fntLose:setAnchorPoint(cc.p(1, 0.5))
			end
			
			fntLose:setPosition(pos)

			 self[labelName] = fntLose
		else
			fntLose:setString(strCoin)
			fntLose:setOpacity(255)
			fntLose:setVisible(true)
		end

		fntLose:runAction(cc.Sequence:create(
			cc.MoveBy:create(0.5, cc.p(0, NUMBER_MOVE_OFF)), 
			cc.DelayTime:create(1.0), 
			cc.FadeOut:create(0.5), 
			cc.CallFunc:create(function(sender)
				sender:setVisible(false)
				local x, y = sender:getPosition()
				sender:setPosition(cc.p(x, y - NUMBER_MOVE_OFF))
			end)))
	end
end

function prototype:flyWinChipAction(winCoin, toPos)
	local isValid = director:isValid()
	if not isValid then
		return
	end

	local chipsList = self:getChipsNum(winCoin)
	for i, num in ipairs(chipsList) do
		if num > 0 then
			local coins = self.coinSprites[i]
			for j = 1, num do
				-- log("flay chip num : "..j..", chips : " .. #coins)
				if #coins > 0 then
					local sprite = coins[#coins]
					sprite:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.45, toPos), 3.5), cc.CallFunc:create(function(sender)
						-- sender:removeFromParent()
						self:recycleSpriteToPool(sender)
					end)))
					table.remove(coins)
				else
					break
				end
			end
		end
	end
end

function prototype:onPushBetResult(isSuccess)
	if isSuccess then
		-- local accountInfo = Model:get("Account"):getUserInfo()
		-- --将金币这算成人民币 1:100
		-- local coinValue = math.floor(accountInfo.gold / 100)
		-- if coinValue >= 50 then
		-- 	self:setBetAreaVisible(true)
		-- else
		-- 	self:setBetAreaVisible(false)
		-- end

		-- self.nodeBottomMsg:refreshBetMenu(true)
	else
		self.curBetSide = 0
	end
end

--下注：龙
function prototype:uiEvtLongBet()
	-- log("uiEvtLongBet")
	if self:selfIsDealer() == true then
		local data = {
			content = "庄家不能下注"
		}
		ui.mgr:open("Dialog/DialogView", data)
		return
	end
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo.roomState == Longhudou_pb.State_Bet then
		if self.userBetNum[Longhudou_pb.HU] > 0 or self.curBetSide == Longhudou_pb.HU then
			local data = {
				content = "不能同时下注龙虎两个区域！"
			}
			ui.mgr:open("Dialog/DialogView", data)

			return
		end

		if roomStateInfo.isMing and self.currentSidesDesc == Longhudou_pb.HU then
			local data = {
				content = "明牌抢注时，该区域无法下注！"
			}
			ui.mgr:open("Dialog/DialogView", data)

			return
		end

		local betValue = self.nodeBottomMsg:getBetValue()
		self.modelData:requestBet(Longhudou_pb.LONG, betValue)
		self.curBetSide = Longhudou_pb.LONG

		self.imgBetLeftArea:setVisible(true)
		self.imgBetLeftArea:setOpacity(0)
		self.imgBetLeftArea:runAction(cc.Sequence:create(cc.FadeIn:create(0.15), cc.FadeOut:create(0.15)))

		self.nodeBottomMsg:setEnabledContinueBet(false)
	else
		
	end
end

--下注：虎
function prototype:uiEvtHuBet()
	-- log("uiEvtHuBet")
	if self:selfIsDealer() == true then
		local data = {
			content = "庄家不能下注"
		}
		ui.mgr:open("Dialog/DialogView", data)
		return
	end
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo.roomState == Longhudou_pb.State_Bet then
		if self.userBetNum[Longhudou_pb.LONG] > 0 or self.curBetSide == Longhudou_pb.LONG then
			local data = {
				content = "不能同时下注龙虎两个区域！"
			}
			ui.mgr:open("Dialog/DialogView", data)

			return
		end

		if roomStateInfo.isMing and self.currentSidesDesc == Longhudou_pb.LONG then
			local data = {
				content = "明牌抢注时，该区域无法下注！"
			}
			ui.mgr:open("Dialog/DialogView", data)

			return
		end

		local betValue = self.nodeBottomMsg:getBetValue()
		self.modelData:requestBet(Longhudou_pb.HU, betValue)
		self.curBetSide = Longhudou_pb.HU

		self.imgBetRightArea:setVisible(true)
		self.imgBetRightArea:setOpacity(0)
		self.imgBetRightArea:runAction(cc.Sequence:create(cc.FadeIn:create(0.15), cc.FadeOut:create(0.15)))

		self.nodeBottomMsg:setEnabledContinueBet(false)
	else

	end
end

--下注:和
function prototype:uiEvtHeBet()
	-- log("uiEvtHeBet")
	if self:selfIsDealer() == true then
		local data = {
			content = "庄家不能下注"
		}
		ui.mgr:open("Dialog/DialogView", data)
		return
	end
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo.roomState == Longhudou_pb.State_Bet then
		if roomStateInfo.isMing then
			local data = {
				content = "明牌抢注时，该区域无法下注！"
			}
			ui.mgr:open("Dialog/DialogView", data)

			return
		end

		local betValue = self.nodeBottomMsg:getBetValue()
		self.modelData:requestBet(Longhudou_pb.HE, betValue)

		self.imgBetCenterArea:setVisible(true)
		self.imgBetCenterArea:setOpacity(0)
		self.imgBetCenterArea:runAction(cc.Sequence:create(cc.FadeIn:create(0.15), cc.FadeOut:create(0.15)))

		self.nodeBottomMsg:setEnabledContinueBet(false)
	end
end

--根据下注数值获取不同等级筹码数量
function prototype:getChipsNum(betValue)
	--金币1:100兑换为人民币比例
	local coinValue = FLOOR(betValue / 100)
	--筹码等级: 1、10、100、500、1000
	local chipsNum = {0, 0, 0, 0, 0}
	chipsNum[5] = MODF(coinValue / BET_RANGE[5])
	chipsNum[4] = MODF((coinValue % BET_RANGE[5]) / BET_RANGE[4])
	chipsNum[3] = MODF((coinValue % BET_RANGE[4]) / BET_RANGE[3])
	chipsNum[2] = MODF((coinValue % BET_RANGE[3]) / BET_RANGE[2])
	chipsNum[1] = MODF((coinValue % BET_RANGE[2]) / BET_RANGE[1])

	return chipsNum
end

--续注
function prototype:uiEvtContinueBet()
	local roomState = self.modelData:getRoomState()
	if roomState == Longhudou_pb.State_Bet then
		-- log(self.userLastGameBet)
		local value = 0
		for i, v in ipairs(self.userLastGameBet) do
			if v > 0 then
				--拆分筹码
				local chipsNum = self:getChipsNum(v)
				for index, num in ipairs(chipsNum) do
					if num > 0 then
						for j = 1, num do
							value = BET_RANGE[index] * 100
							self.modelData:requestBet(i, value)
						end
					end
				end
			end
		end
		self.nodeBottomMsg:setEnabledContinueBet(false)
	end
end


function prototype:isGameSZ() --经常调用优化
	-- log("LHV:isGameSZ")
	if self.isGameSZHelp == nil then
		local roomInfo = self.modelData:getRoomInfo()
		if roomInfo.typeId ==115 then
			self.isGameSZHelp=true
			return true
		else
			self.isGameSZHelp=false
			return false
		end
	else
		return self.isGameSZHelp
	end
end

function prototype:systemIsDealer()--系统是庄家
	local dealerQueue =self.modelData:getDealerQueue()
	if  dealerQueue[1].coin == 999999 and dealerQueue[1].playerId=="1234567" then
		return true
	else
		return false
	end
end

function prototype:selfIsDealer()--自己是庄家
	--local dealerId=self.modelData:getDealerId() 不能用
	local dealerQueue =self.modelData:getDealerQueue()
	--dump(dealerQueue,"dealerQueue",5)
	if dealerQueue[1].isDealer == true and dealerQueue[1].playerId== self.userId then
		return true
	else
		return false
	end
end

function prototype:selfInDealerQueue(dealerQueue)--自己是否在上庄队列
	for k,v in ipairs(dealerQueue) do
		if v.playerId == self.userId then
			return true
		end
	end
	return false
end

function prototype:setDealerHead(dealerQueue)  
	local nodeHeadInfo=self.nodeDealerHeadMsg
	local info=dealerQueue[1]
	--dump(dealerQueue,"head",5)
	nodeHeadInfo.dealerName:setString(info.playerName)
	nodeHeadInfo.dealerID:setString(string.format("ID:%s",info.playerId))
	local winCoin=Assist.NumberFormat:amount2Hundred(info.winCoin)
	nodeHeadInfo.txtCoin:setString("上局输赢:"..winCoin)
	if info.headimage ==nil then
		nodeHeadInfo.imgFrame:loadTexture("resource/Longhudou/csbimages/systemDealer.png")
	else
		sdk.account:getHeadImage(info.playerId, info.playerName, nodeHeadInfo.imgFrame, info.headimage)
	end
	--dump(dealerQueue,"dealerQueue",5)
	if self:systemIsDealer() then
		--系统坐庄隐藏
		nodeHeadInfo.dealerCount:setString("")
		nodeHeadInfo.txtCoin:setVisible(false)
		nodeHeadInfo.dealerName:setPositionY(41.55)
		nodeHeadInfo.dealerID:setPositionY(17.28)
	else
		nodeHeadInfo.txtCoin:setVisible(true)
		nodeHeadInfo.dealerName:setPositionY(83.55)
		nodeHeadInfo.dealerID:setPositionY(59.28)
		local roomStateInfo = self.modelData:getRoomStateInfo()
		if roomStateInfo then
			--dump(roomStateInfo,"roomStateInfo",5)
			nodeHeadInfo.dealerCount:setString(string.format("%d/10",roomStateInfo.dealerCount))
			if roomStateInfo.dealerCount ==1 then
				nodeHeadInfo.txtCoin:setString("上局输赢:0")
			end
		end
	end
end

function prototype:seeSnatchState()--是否显示
	-- log("LHV:seeSnatchState" )
	if self:isGameSZ()==true then 
		self:changeSnatchState()
	end
	

end

function prototype:changeSnatchState()--内容改变
	--log("LHV:changeSnatchState" )
	local dealerQueue =self.modelData:getDealerQueue()
	if dealerQueue==nil or table.nums(dealerQueue[1])==0 then return end
--	log("changeSnatchState-dealerQueue")
	--log(dealerQueue)
	local imgBtn="resource/Longhudou/csbimages/img_upDealer.png"
	if self:selfInDealerQueue(dealerQueue) then--取消下庄
		imgBtn="resource/Longhudou/csbimages/cancleDealer.png"
	end

	if self:selfIsDealer() then--下庄
		imgBtn="resource/Longhudou/csbimages/downDealer.png"	
	end
	self.nodeUpDealer.btnSnatch:loadTextureNormal(imgBtn)
	self.nodeUpDealer.btnSnatch:loadTexturePressed(imgBtn)
	--设置头像
	self:setDealerHead(dealerQueue)
end

-- function prototype:onPushSnatchQueue()
-- 	--log("LHV: onPushSnatchQueue")
-- 	ui.mgr:transData("Longhudou/SnatchListView")
-- end

--请求上庄
function prototype:uiEvtSnatch()
	--log("DTV: uiEvtSnatch")
	Model:get("Games/Longhudou"):requestSnatch()
end
--请求下庄
function prototype:uiEvtAbandon()
	--log("DTV: uiEvtAbandon")
	Model:get("Games/Longhudou"):requestAbandon()
end

--结果详情
function prototype:uiEvtShowDetails()
	self.nodeResult:show()
end

function prototype:uiEvtPlayerList()
	ui.mgr:open("Longhudou/PlayerListView", self.divinerId)
end

--离开房间
function prototype:onBtnCloseClick()
	Model:get("Games/Longhudou"):requestLeaveGame()
end