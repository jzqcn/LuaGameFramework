local Pool    = require "Pool"

module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local Dantiao_pb = Dantiao_pb

local FLOOR = math.floor
local MODF = math.modf
local RANDOM = math.random
local NUMBER_MOVE_OFF = 60
local BET_RANGE = {1, 10, 100, 500, 1000}
local director = cc.Director:getInstance()
local SidesDescSound={
	"resource/Dantiao/audio/Diamond.wav",
	"resource/Dantiao/audio/Club.wav",
	"resource/Dantiao/audio/Heart.wav",
	"resource/Dantiao/audio/Spade.wav",
	"resource/Dantiao/audio/SmallJoker.wav",
	"resource/Dantiao/audio/BigJoker.wav",
	"resource/Dantiao/audio/bet.mp3",
	"resource/Dantiao/audio/bet_end.mp3",
	"resource/Dantiao/audio/bet_jinzhuan.mp3",
	"resource/Dantiao/audio/fapai.mp3",
	"resource/Dantiao/audio/flipcard.mp3",
	"resource/Dantiao/audio/fly_coin.mp3",
	}
function prototype:dispose()
    super.dispose(self)
	self.pool:dispose()
	sys.sound:unloadEffects(SidesDescSound)
end

function prototype:enter()
	--log("DTV:enter")
	self.size = self.rootNode:getContentSize()
	--UI事件
	self:bindUIEvent("Dantiao.SpadeBet", "uiEvtSpadeBet")--HEART红心 diamond方块    SPADE 黑桃    CLUB梅花big joker small
	self:bindUIEvent("Dantiao.HeartBet", "uiEvtHeartBet")
	self:bindUIEvent("Dantiao.ClubBet", "uiEvtClubBet")
	self:bindUIEvent("Dantiao.DiamondBet", "uiEvtDiamondBet")
	self:bindUIEvent("Dantiao.JokerBet", "uiEvtJokerBet")
	self:bindUIEvent("Dantiao.ContinueBet", "uiEvtContinueBet")
	self:bindUIEvent("Dantiao.ShowDetails", "uiEvtShowDetails")
	self:bindUIEvent("Dantiao.PlayerList", "uiEvtPlayerList")
	self:bindUIEvent("Dantiao.Snatch", "uiEvtSnatch")
	self:bindUIEvent("Dantiao.Abandon", "uiEvtAbandon")

	--Model消息事件
	self:bindModelEvent("Games/Dantiao.EVT.PUSH_ENTER_ROOM", "onPushRoomEnter")
	self:bindModelEvent("Games/Dantiao.EVT.PUSH_ROOM_STATE", "onPushRoomState")
	self:bindModelEvent("Games/Dantiao.EVT.PUSH_MEMBER_STATUS", "onPushMemberStatus")
	self:bindModelEvent("Games/Dantiao.EVT.PUSH_BET_RESULT", "onPushBetResult")
	self:bindModelEvent("Games/Dantiao.EVT.PUSH_BET_COIN", "onPushBetCoin")
	self:bindModelEvent("Games/Dantiao.EVT.PUSH_OPEN_RESULT", "onPushOpenResult")
	self:bindModelEvent("Games/Dantiao.EVT.PUSH_SETTLEMENT", "onPushSettlement")
	-- self:bindModelEvent("Games/Dantiao.EVT.PUSH_SNATCHQUEUE", "onPushSnatchQueue")
	
	--货币刷新
	self:bindModelEvent("SynData.EVT.PUSH_SYN_USER_DATA", "onPushSynUserData")

	self.userId = Model:get("Account"):getUserId()
	self.modelData = Model:get("Games/Dantiao")

	-- self.coinSprites = {}
	--货币对象缓存
	self.pool  = Pool.class:new()

	self:initSeatInfo()
	self.nodeLeftGroup:setGroupType(1)
	self.nodeRightGroup:setGroupType(2)
	self.userLastGameBet = {0, 0, 0}
	self:onPushRoomEnter()
	
	sys.sound:preloadEffects(SidesDescSound)
	AudioEngine.stopMusic()
	-- sys.sound:playMusicByFile("resource/Dantiao/audio/background_music.mp3")

	self.isTimeOut = false
end

function prototype:onEnterBackground()
	-- log("Dantiao onEnterBackground")
	--在游戏中，进入后台超过10s，断开连接
	util.timer:after(10 * 1000, self:createEvent('BACKGROUND_TIMEOUT_TIMER', 'onBackGroundTimeout'))
	self.isTimeOut = false
end

function prototype:onBackGroundTimeout()
	log("Dantiao on background time out !!!")
	net.mgr:disconnect()
	self.isTimeOut = true
end

function prototype:onEnterForeground()
	-- log("Dantiao onEnterForeground")

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
--	local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	local node = self.pool:getFromPool("Sprite", fileName)
    return node
end

--回收
function prototype:recycleSpriteToPool(node)
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	if not node then
		return
	end

	local fileName = node:getName()
	self.pool:putInPool(fileName, node)

	node:removeFromParent(true)
end

--获取富豪榜、大赢家、其他人飞金币坐标位置
function prototype:initSeatInfo()
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
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
	self.imgStar={
		self.imgStar_1,self.imgStar_2,self.imgStar_3,self.imgStar_4,self.imgStar_5,
	}

	self.starsPos={}
	for k,v in ipairs(self.imgStar) do
		table.insert(self.starsPos,	cc.pAdd(pos, cc.p(v:getPosition())))
	end

	self.imgBetArea={
		self.imgBetDiamondArea,
		self.imgBetClubArea,
		self.imgBetHeartArea,
		self.imgBetSpadeArea,
		self.imgBetJokerArea
	}

	self.imgStarEff={
		self.imgDiamondStarEff,
		self.imgClubStarEff,
		self.imgHeartStarEff,
		self.imgSpadeStarEff,
		self.imgJokerStarEff
	}

	self.nodeArea={
		self.nodeDiamondArea,
		self.nodeClubArea,
		self.nodeHeartArea,
		self.nodeSpadeArea,
		self.nodeJokerArea
	}

	self.txtTotalBetNum={
		self.txtTotalBetNum_1,
		self.txtTotalBetNum_2,	
		self.txtTotalBetNum_3,
		self.txtTotalBetNum_4,
		self.txtTotalBetNum_5
	}

	self.txtUserBetNum={
		self.txtUserBetNum_1,
		self.txtUserBetNum_2,
		self.txtUserBetNum_3,
		self.txtUserBetNum_4,
		self.txtUserBetNum_5
	}

end

function prototype:gameClear()
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	for k,v in ipairs(self.imgBetArea) do
		v:setVisible(false)
		v:stopAllActions()
	end

	for k,v in ipairs(self.imgStarEff) do
		v:removeAllChildren()
	end
	
	for k,v in ipairs(self.imgStar) do
		v:setVisible(false)
	end

	self.nodeCard:stopAction()
	self.nodeCard:setCardInfo()
	self:seeImgIcon()

	for k,v in ipairs(self.txtTotalBetNum) do
		v:setString("总注:0")
	end

	for k,v in ipairs(self.txtUserBetNum) do
		v:setVisible(false)
	end

	self.currentSidesDesc = -1
	self.userBetNum = {0, 0, 0,0,0}


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
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	self:gameClear()
	self:onPushRoomInfo()
	self:onPushRoomState()
	self:onPushMemberStatus()

	self:updateFrontPlayerData()

	local toPos
	local totalCoins = 0

	local initBets = self.modelData:getInitBets()
	if initBets then
		local divinerId = self.divinerId
		local userId = self.userId
		for i, v in ipairs(initBets) do
			toPos=self.nodeArea[v.sidesDesc]:getBetPos()
			totalCoins = v.totalBetCoin
			if v.playerId == divinerId then
				self.imgStar[v.sidesDesc]:setVisible(true)
			end

			if v.playerId == userId then
				self.userBetNum[v.sidesDesc] = self.userBetNum[v.sidesDesc] + v.coin
			end
			self:runBetCoinAction(cc.p(0, 0), toPos, v, true)
			self.txtTotalBetNum[v.sidesDesc]:setString("总注:" .. FLOOR(totalCoins/100))
		end

		for i, v in ipairs(self.userBetNum) do
			if v > 0 then
				self.userBetNum[i]:setString(FLOOR(v/100))
				self.userBetNum[i]:setVisible(true)
			end
		end

	end

	local roomStateInfo = self.modelData:getRoomStateInfo()
	local openResult = self.modelData:getInitOpenResult()
	if openResult then
		if roomStateInfo.roomState ~= Dantiao_pb.State_Bet or roomStateInfo.isMing == true 
		or roomStateInfo.isBanMing==true then
			if roomStateInfo.isBanMing==true then
				local card={}
				card.size=openResult.cardSize
				card.color=openResult.banMingColor
				card.id=0
				openResult.card=card
			end
			self.nodeCard:setCardInfo(self.userId, openResult.card)
			self.nodeCard:showCardValue()
			if roomStateInfo.isBanMing==true then
				self.nodeCard:hideCardIcon()			
			end
			local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5)))
			local sidesDesc=openResult.currentSidesDesc
			if sidesDesc ~=Dantiao_pb.Evil then
				sys.sound:playEffectByFile(SidesDescSound[sidesDesc])
				self:seeImgIcon(sidesDesc)	
			elseif openResult.currentSidesDesc == Dantiao_pb.Evil then
				local cardSize=self.nodeCard:getCardSize()
				if cardSize==14 then
					sys.sound:playEffectByFile(SidesDescSound[6])
				else
					sys.sound:playEffectByFile(SidesDescSound[5])
				end
				self.nodeCard:playFireEffect()
			end
			self.imgBetArea[sidesDesc]:setVisible(true)
			self.imgBetArea[sidesDesc]:runAction(action)
		end

		self.nodeLineResult:initData(openResult.sixtySideResult)
		self.nodeResult:initData(openResult.sixtySideResult)
	else
		self.nodeLineResult:initData()
		self.nodeResult:initData()
	end

	if roomStateInfo.roomState ~= Dantiao_pb.State_Bet then
		-- local eff = CEffectManager:GetSingleton():getEffect("a1longwait")
		-- local size = self.panelEff:getContentSize()
		-- eff:setPosition(cc.p(size.width/2, size.height/2))
		-- self.panelEff:addChild(eff)
		self:seeSnatchState(false)
		--请等待效果
		local skeletonNode = sp.SkeletonAnimation:create("resource/Dantiao/csbimages/anim/Wait/Dengdai.json", "resource/Dantiao/csbimages/anim/Wait/Dengdai.atlas")
		skeletonNode:setAnimation(0, "animation", true)
		skeletonNode:setTag(101)
		self.panelEff:addChild(skeletonNode)
	end
end

function prototype:onPushRoomInfo()
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	local roomInfo = self.modelData:getRoomInfo()
	BET_RANGE = roomInfo.betRanges
	if roomInfo then --更换游戏背景
		if roomInfo.playId == 114002 then
			self.nodeUpDealer.dealerTip:setString("上庄需要5千金币")
			self.nodeUpDealer:setPlayId(roomInfo.playId)
		end
		if roomInfo.playId == 114001 then
			self.nodeUpDealer.dealerTip:setString("上庄需要2千金币")
			self.nodeUpDealer:setPlayId(roomInfo.playId)
		end
		if roomInfo.typeId ==113 then
			self.nodeDealerHeadMsg:setVisible(false)
			self.nodeUpDealer:setVisible(false)
			self.imgPop:loadTexture("resource/Dantiao/csbimages/dantiaomap1.png")
			self:quickSetPosition(self.nodeCard,12,-12)
			self:quickSetPosition(self.nodeLineResult, 0, -22)
			self:quickSetPosition(self.imgSpadeIcon,-41,-6)
			self:quickSetPosition(self.imgHeartIcon,-31,6)
			self:quickSetPosition(self.imgClubIcon,16,-3)
			self:quickSetPosition(self.imgDiamondIcon,24,-3)

			self:quickSetPosition(self.imgStar_4,0,-20)
			self:quickSetPosition(self.txtTotalBetNum_4,0,-20)
			self:quickSetPosition(self.txtUserBetNum_4,0,-20)

			self:quickSetPosition(self.imgStar_5,0,-17)
			self:quickSetPosition(self.txtTotalBetNum_5,0,-17)
			self:quickSetPosition(self.txtUserBetNum_5,0,-17)

			self:quickSetPosition(self.imgStar_1,0,-20)
			self:quickSetPosition(self.txtTotalBetNum_1,0,-20)
			self:quickSetPosition(self.txtUserBetNum_1,0,-20)

		else
			self.imgBetSpadeArea:loadTexture("resource/Dantiao/csbimages/bet_area_21.png")
			self.imgBetDiamondArea:loadTexture("resource/Dantiao/csbimages/bet_area_21.png")
			self.imgBetJokerArea:loadTexture("resource/Dantiao/csbimages/bet_area_23.png")
			self:quickSetPosition(self.imgBetSpadeArea,0,11)
			self:quickSetPosition(self.imgBetDiamondArea,0,11)
			self:quickSetPosition(self.imgBetJokerArea,0,11)
		end
	end
end

function prototype:quickSetPosition(node,xx,yy)
	local x,y=node:getPosition()
	node:setPosition(cc.p(x+xx,y+yy))
end
function prototype:clearPlayerData(playerId)
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
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
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	local roomMember = self.modelData:getRoomMember()
	local memberList = table.values(roomMember)
	local memNum = #memberList
    
	if memNum > 0 then
		local divineList = table.clone(memberList)--神算子：按近20局输赢
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
		self.richList = {}
		
		local index = 1
		for i, v in ipairs(memberList) do
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
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	for k,v in ipairs(self.nodeArea) do
		v:setVisible(isVisible)
	end
end

function prototype:onPushRoomState()
	--log("DTV: onPushRoomState")
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo then
		local roomState = roomStateInfo.roomState
		local countDown = roomStateInfo.countDown

		if roomStateInfo.isMing == true or roomStateInfo.isBanMing then
			sys.sound:playMusicByFile("resource/Longhudou/audio/background_music2.mp3")
		else
			sys.sound:playMusicByFile("resource/Longhudou/audio/background_music.mp3")
		end

		if roomState == Dantiao_pb.State_Bet then
			--log("DTV:State_Bet=====")
			self:gameClear()

			self.nodeResult:autoHide()
			self.nodeCountdown:start(countDown, roomState)
			
			--明牌抢注禁用续注
			if roomStateInfo.isMing == true or roomStateInfo.isBanMing then
				self.nodeBottomMsg:setEnabledContinueBet(false)
			else
				self.nodeBottomMsg:setEnabledContinueBet(true, self.userLastGameBet)
			end

			-- self.panelEff:removeAllChildren()
			--删除 “请等待” spine动作
			local skeletonNode = self.panelEff:getChildByTag(101)
			if skeletonNode then
				skeletonNode:removeFromParent()
			end
			
			if self:selfIsDealer() == true then
				self.nodeBottomMsg:unenabledBetMenu()
				self.nodeBottomMsg:setEnabledContinueBet(false)
			else
				self.nodeBottomMsg:refreshBetMenu()
			end

			local isValid = director:isValid()
			local enableBet = true
			--开始特效 vs
			local delay = 0
			if self.roomState and self.roomState == Dantiao_pb.State_Settlement then
				--log("DTV:State_Settlement=====")
				self:updateFrontPlayerData()

				if isValid then
					local size = self.panelEff:getContentSize()
					skeletonNode = self.panelEff:getChildByTag(100)
					if skeletonNode == nil then
						-- log("create start skeleton animation !!!!!!!!!!!!!!!!!!!!!!!!")
						skeletonNode = sp.SkeletonAnimation:create("resource/Dantiao/csbimages/anim/Start/Hhdz_Start.json", "resource/Dantiao/csbimages/anim/Start/Hhdz_Start.atlas")
						
						skeletonNode:setPosition(cc.p(size.width/2, size.height/2))
						skeletonNode:setTag(100)
						self.panelEff:addChild(skeletonNode)
					else
						skeletonNode:setVisible(true)
					end
					enableBet = false
					-- skeletonNode:setToSetupPose()
					skeletonNode:setAnimation(0, "animation", false)

					local eff = cc.ParticleSystemQuad:create("resource/Dantiao/csbimages/Particle/Start_particle/Start_particle.plist")
					eff:setPosition(cc.p(size.width/2, size.height/2))
					self.panelEff:addChild(eff)
					--动作播放完成监听
					skeletonNode:registerSpineEventHandler(function (event)
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
					delay = 1.0
					--vs动画音效
					sys.sound:playEffectByFile("resource/Dantiao/audio/lhd_start_anim_effect.mp3")
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
			self:seeSnatchState(true)
		elseif roomState == Dantiao_pb.State_OpenDeal then
			--log("DTV:State_OpenDeal=====")
			self:setBetAreaVisible(false)

			self.nodeCountdown:start(-1, roomState)
			--停止下注按钮切换
			self.nodeBottomMsg:unenabledBetMenu()
			--结束下注特效
			self:playBetAction()

		elseif roomState == Dantiao_pb.State_Settlement then
			--log("DTV:State_Settlement2=====")
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
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	if not director:isValid() then
		return
	end
	isStart = isStart or false
	local res = ""
	if isStart then
		res = "resource/Dantiao/csbimages/start_xiazhu_tips.png"
	else
		res = "resource/Dantiao/csbimages/stop_xiazhu_tips.png"
	end

	local size = self.panelEff:getContentSize()
	--开始下注动画
	local moveBy1 = cc.MoveBy:create(0.2, cc.p(self.size.width/2, 0))
	local moveBy2 = cc.MoveBy:create(0.2, cc.p(-self.size.width/2, 0))
	
	local spriteBg = cc.Sprite:create("resource/Dantiao/csbimages/tishi_bg.png")
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
		sys.sound:playEffectByFile("resource/Dantiao/audio/bet_start.mp3")
	else
		--下注结束
		sys.sound:playEffectByFile("resource/Dantiao/audio/bet_end.mp3")
	end
end

function prototype:onPushMemberStatus(refreshList)
	--log("DTV: onPushMemberStatus")
	local roomMember = self.modelData:getRoomMember()
	local memNum=table.nums(roomMember)
	--dump(roomMember,"roomMember",5)
	refreshList = refreshList or table.keys(roomMember)
	--dump(refreshList,"refreshList",5)
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
				log4ui:warn("[DantiaoView::onPushMemberStatus] get player info failed ! player id == " .. id)
			end
		end
		self:updateFrontPlayerData()
		if self.richList then
			--[[if #self.richList < 5 and bAddRole == true then
				self:updateFrontPlayerData()
			end]]

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
	--log("DTV: onPushSynUserData")
	--将金币这算成人民币 1:100
	local coinValue = FLOOR((data.gold / 100))
	if coinValue >= self.nodeBottomMsg:getBetMinLimit() then
		self:setBetAreaVisible(true)
	else
		self:setBetAreaVisible(false)
	end

	-- local playerInfo = Model:get("Games/Dantiao"):getUserInfo()
	-- playerInfo.coin = accountInfo.gold
	if self:selfIsDealer() == true then
		self.nodeBottomMsg:unenabledBetMenu()
		self.nodeBottomMsg:setEnabledContinueBet(false)
	else
		self.nodeBottomMsg:refreshBetMenu(true)
	end
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo then--最后一局,没钱了,下注按钮变灰,又赢钱了,变红,又不处在下注阶段,变灰,形成闪红
		if roomStateInfo.roomState ~= Dantiao_pb.State_Bet then
			self.nodeBottomMsg:unenabledBetMenu()
		end
	end
end

--推送玩家下注
function prototype:onPushBetCoin(betInfo)
--	log("DTV: onPushBetCoin")
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
		self.txtUserBetNum[sidesDesc]:setString(FLOOR(self.userBetNum[sidesDesc]/100))
		self.txtUserBetNum[sidesDesc]:setVisible(true)
		local userInfo = roomMember[self.userId]
		self.nodeBottomMsg:doUserBet(userInfo, betInfo.coin)
	end

	--是否神算子下注 神算子飞星星
	if self.divinerId == betInfo.playerId then
		if isValid then
			local startPos = self.seatsPos[4]
			local endPos = self.starsPos[sidesDesc]
			local star = cc.Sprite:create("resource/Dantiao/csbimages/img_star.png")
			star:setPosition(startPos)
			self.panelCoins:addChild(star)
			local size = star:getContentSize()
			local eff = cc.ParticleSystemQuad:create("resource/Dantiao/csbimages/Particle/Feixing/Feixing.plist")
			eff:setPosition(cc.p(size.width/2, size.height/2))
			star:addChild(eff)

			local pos = cc.p(startPos.x + (endPos.x-startPos.x)*0.7, startPos.y + 50)
			local bezier = {
				startPos,
				pos,
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


	toPos=self.nodeArea[sidesDesc]:getBetPos()
	self.txtTotalBetNum[sidesDesc]:setString("总注:" .. FLOOR(betInfo.totalBetCoin/100))
	--dump(betInfo,"betInfo",5)    --totalBetCoin==0
	self:runBetCoinAction(fromPos, toPos, betInfo,not isValid)
end

--下注动画
function prototype:runBetCoinAction(fromPos, toPos, betInfo, noAction)
--	local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	noAction = noAction or false
	
	--续注时候，一次有多个筹码
	local betChips = self:getChipsNum(betInfo.coin)
	local sprite
	local index = 0
	local fileName = ""
	for i, v in ipairs(betChips) do
		if v > 0 then
			for j = 1, v do
				-- sprite = cc.Sprite:create(string.format("resource/Dantiao/csbimages/Bet/coin_%d.png", i))
				fileName = string.format("resource/Dantiao/csbimages/Bet/coin_%d.png", BET_RANGE[i])
				sprite = self:getSpriteFromPool(fileName)
				sprite:setName(fileName)
				sprite:setAnchorPoint(cc.p(0.5, 0.5))				
				sprite:setRotation(RANDOM(0, 360))
				-- sprite:setTag(i)
				self.panelCoins:addChild(sprite)

				if not noAction then
					sprite:setPosition(fromPos)
					sprite:runAction(cc.Sequence:create(cc.DelayTime:create(index*0.1), cc.MoveTo:create(0.25, toPos), cc.RotateBy:create(0.2 , RANDOM(0, 360))))
					local bet_jinzhuanSound =4
					if self:isGameSZ() ==true then
						local roomInfo = self.modelData:getRoomInfo()
						if roomInfo.playId == 114001 then
							bet_jinzhuanSound=5
						else
							bet_jinzhuanSound=4
						end
					end
					if i >= bet_jinzhuanSound then
						sys.sound:playEffectByFile("resource/Dantiao/audio/bet_jinzhuan.mp3")
					else
						sys.sound:playEffectByFile("resource/Dantiao/audio/bet.mp3")
						
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
	--log("DTV: onPushOpenResult")
	local delay = 1.0
	local roomStateInfo = self.modelData:getRoomStateInfo()
	--如果半明牌,,
	if roomStateInfo.isBanMing == true then--半明牌--看前一句有没有下注
		--dump(resultInfo.banMingCard,"resultInfo.banMingCard",5)
		if resultInfo.banMingCard~=nil then
			--下注阶段
			self.nodeCard:setCardInfo(self.userId, resultInfo.banMingCard)
			self.nodeCard:showCardValue()
			self.nodeCard:hideCardIcon()
		else
			self.nodeCard:fadeCardIcon(5)--开牌阶段
			self.currentSidesDesc = resultInfo.currentSidesDesc
			self.nodeCard:setCardInfo(self.userId, resultInfo.card)

			--[[local cardSize=self.nodeCard:getCardSize()--取消报点
			if cardSize==0 or cardSize==14 then
			else
				sys.sound:playEffectByFile(string.format("resource/Dantiao/audio/cardtype/lhb_p_%d.mp3", cardSize))
			end]]
			self.nodeCard:showCardValue()
			self:showOpenResult(resultInfo)
		end
		return
	end

	if roomStateInfo.isMing == false then--普通
		self:onPushRoomState()
	else
		delay = 0
	end

	--明牌
	self.currentSidesDesc = resultInfo.currentSidesDesc
	
	self.nodeCard:setCardInfo(self.userId, resultInfo.card)
	local move = cc.Spawn:create(
		cc.MoveBy:create(0.2, cc.p(0, -20)),
		cc.ScaleTo:create(0.2, 1.1))

	local moveReverse = cc.Spawn:create(
		cc.MoveBy:create(0.2, cc.p(0, 20)),
		cc.ScaleTo:create(0.2, 1.0))

	local cardAction = cc.Sequence:create(
        cc.DelayTime:create(delay),
       	move,
       	cc.DelayTime:create(0.1),
        cc.ScaleTo:create(0.2, -1.1, 1.1),
        cc.ScaleTo:create(0, 1.1, 1.1),
        cc.CallFunc:create(function() 
			self.nodeCard:showCardValue()
        end),
        cc.DelayTime:create(0.1),
		moveReverse,

		--取消报点
		cc.CallFunc:create(function()
				self:showOpenResult(resultInfo)
		end))

	self.nodeCard:getCardNode():runAction(cardAction)

end

function prototype:seeImgIcon(index)
	index=index or 0
	local imgIcon={
	"imgDiamondIcon",
	"imgClubIcon",
	"imgHeartIcon",
	"imgSpadeIcon",
 	}
	 local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5)))
	if index==0 then
		for i=1,4 do
			self[imgIcon[i]]:setVisible(false)
			self[imgIcon[i]]:stopAllActions()
		end
	else
		self[imgIcon[index]]:setVisible(true)
		self[imgIcon[index]]:runAction(action)
	end

end

function prototype:showOpenResult(resultInfo)
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5)))
	local actionFadeOut = cc.FadeOut:create(0.5)
	self:seeSnatchState(false)
	local sidesDesc=resultInfo.currentSidesDesc
	if sidesDesc ~=Dantiao_pb.Evil then
		sys.sound:playEffectByFile(SidesDescSound[sidesDesc])
		self:seeImgIcon(sidesDesc)
	elseif sidesDesc == Dantiao_pb.Evil then
		local cardSize=self.nodeCard:getCardSize()
		if cardSize~=nil then
			if cardSize==0 then
				sys.sound:playEffectByFile(SidesDescSound[5])
			else
				sys.sound:playEffectByFile(SidesDescSound[6])
			end
		end
		self.nodeCard:playFireEffect()
	end
	self.imgBetArea[sidesDesc]:setVisible(true)
	self.imgBetArea[sidesDesc]:runAction(action)
	local particle=self.imgStarEff[sidesDesc]:getChildByTag(99)
	if particle == nil then
		particle = cc.ParticleSystemQuad:create("resource/Dantiao/csbimages/Particle/win_side/win_particle.plist")
		local size = self.imgStarEff[sidesDesc]:getContentSize()
		particle:setPosition(cc.p(size.width/2, size.height/2))	
		self.imgStarEff[sidesDesc]:addChild(particle,1,99)
		self.imgStarEff[sidesDesc]:runAction(cc.Sequence:create(cc.DelayTime:create(2.5), cc.CallFunc:create(function()
		self.imgStarEff[sidesDesc]:setVisible(false)
		end)))
	else
		self.imgStarEff[sidesDesc]:setVisible(true)
		self.imgStarEff[sidesDesc]:runAction(cc.Sequence:create(cc.DelayTime:create(2.5), cc.CallFunc:create(function()
			self.imgStarEff[sidesDesc]:setVisible(false)
			end)))
	end

	self.nodeLineResult:refreshResultData(resultInfo.sixtySideResult)
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo.isMing == false then	
		self.nodeResult:refreshData(resultInfo.sixtySideResult,roomStateInfo.isMing)
	end
end

--结算
function prototype:onPushSettlement(refreshList, totalWinCoin)
	--log("DTV: onPushSettlement")
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
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
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
			--self.nodeDealerHeadMsg:doSettlement(playerInfo.winCoin)
		end
		self.nodeBottomMsg:doSettlement(playerInfo, self.currentSidesDesc)
		totalWinCoin = totalWinCoin - playerInfo.winCoin
		-- log("other totalWinCoin ======= " .. totalWinCoin)
		--其他人赢了飞筹码
		if totalWinCoin > 0 then
			self:flyWinChipAction(totalWinCoin, self.seatsPos[7])
		end
		self.nodeBottomMsg:doOtherSettlement(totalWinCoin, self.currentSidesDesc)
		

		sys.sound:playEffectByFile("resource/Dantiao/audio/fly_coin.mp3")

		for i, v in ipairs(self.coinSprites) do
			for _, node in ipairs(v) do
				-- node:removeFromParent()
				self:recycleSpriteToPool(node)
			end
		end

		self.coinSprites = {{}, {}, {}, {}, {}}
	end
end

function prototype:runWinCoinAction(playerInfo, index, side)
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	local isValid = director:isValid()
	if not isValid then
		return
	end
	local winCoin = playerInfo.winCoin	
	if winCoin >= 0  then
		local strCoin = "+" .. Assist.NumberFormat:amount2TrillionText(winCoin)
		--胜利或者和，播放赢数字动画		
		local labelName = string.format("fntWin_%d_%d", side, index)
		local fntWin = self[labelName]
		if fntWin == nil then
			 fntWin = cc.Label:createWithBMFont("resource/Dantiao/csbimages/Bmfont/font_win.fnt", strCoin)
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
			fntLose = cc.Label:createWithBMFont("resource/Dantiao/csbimages/Bmfont/font_lose.fnt", strCoin)
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
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
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
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
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
	end
end

function prototype:isGameSZ()
	if self.isGameSZHelp == nil then
		local roomInfo = self.modelData:getRoomInfo()
		if roomInfo.typeId ==114 then
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
	if  dealerQueue[1].coin == 999999  and dealerQueue[1].playerId=="1234567" then
		return true
	else
		return false
	end
end

function prototype:selfIsDealer()--自己是庄家
	--local dealerId=self.modelData:getDealerId() 不能用
	local dealerQueue =self.modelData:getDealerQueue()
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
	nodeHeadInfo.dealerName:setString(info.playerName)
	nodeHeadInfo.dealerID:setString(string.format("ID:%s",info.playerId))
	local winCoin=Assist.NumberFormat:amount2Hundred(info.winCoin)
	nodeHeadInfo.txtCoin:setString("上局输赢:"..winCoin)
	if info.headimage ==nil then
		nodeHeadInfo.imgFrame:loadTexture("resource/Dantiao/csbimages/systemDealer.png")
	else
		sdk.account:getHeadImage(info.playerId, info.playerName, nodeHeadInfo.imgFrame, info.headimage)
	end
	if self:systemIsDealer() then
		--系统坐庄隐藏
		nodeHeadInfo.dealerCount:setString("")
		nodeHeadInfo.txtCoin:setVisible(false)
		--nodeHeadInfo.imgDealerGold:setVisible(false)
		nodeHeadInfo.dealerName:setPositionY(41.55)
		nodeHeadInfo.dealerID:setPositionY(17.28)
	else
		nodeHeadInfo.txtCoin:setVisible(true)
		--nodeHeadInfo.imgDealerGold:setVisible(true)
		nodeHeadInfo.dealerName:setPositionY(83.55)
		nodeHeadInfo.dealerID:setPositionY(59.28)
		local roomStateInfo = self.modelData:getRoomStateInfo()
		if roomStateInfo then
			nodeHeadInfo.dealerCount:setString(string.format("%d/10",roomStateInfo.dealerCount))
			if roomStateInfo.dealerCount ==1 then
				nodeHeadInfo.txtCoin:setString("上局输赢:0")
			end
		end
	end
end

function prototype:seeSnatchState(visible)--是否显示
	--log("DTV:seeSnatchState" )
	visible= visible or false
	if self:isGameSZ()==false then 
		visible=false
	end
	self.nodeDealerHeadMsg:setVisible(visible)
	self.nodeUpDealer:setVisible(visible)
	if visible == true then
		self:changeSnatchState()
	end
end

function prototype:changeSnatchState()--内容改变
	--log("DTV:changeSnatchState" )
	local dealerQueue =self.modelData:getDealerQueue()
	if dealerQueue==nil or table.nums(dealerQueue[1])==0 then return end
--	log("changeSnatchState-dealerQueue")
	--log(dealerQueue)
	local imgBtn="resource/Dantiao/csbimages/img_upDealer.png"
	if self:selfInDealerQueue(dealerQueue) then--取消下庄
		imgBtn="resource/Dantiao/csbimages/cancleDealer.png"
	end

	if self:selfIsDealer() then--下庄
		imgBtn="resource/Dantiao/csbimages/downDealer.png"	
	end
	self.nodeUpDealer.btnSnatch:loadTextureNormal(imgBtn)
	self.nodeUpDealer.btnSnatch:loadTexturePressed(imgBtn)
	--设置头像
	self:setDealerHead(dealerQueue)
end

-- function prototype:onPushSnatchQueue()
-- 	--log("DTV: onPushSnatchQueue")
-- 	--ui.mgr:open("Dantiao/SnatchListView")
-- 	--self:changeSnatchState()
-- 	ui.mgr:transData("Dantiao/SnatchListView")
-- end

function prototype:uiEvtJokerBet()
	--log("DTV: uiEvtJokerBet")
	self:uiEvtHelpBet(Dantiao_pb.Evil)
end
function prototype:uiEvtHeartBet()
	--log("DTV: uiEvtHeartBet")
	self:uiEvtHelpBet(Dantiao_pb.Red)
end
function prototype:uiEvtClubBet()
	--log("DTV uiEvtClubBet")
	self:uiEvtHelpBet(Dantiao_pb.Plum)
end
function prototype:uiEvtDiamondBet()
	--log("DTV: uiEvtDiamondBet")
	self:uiEvtHelpBet(Dantiao_pb.Block)
	
end
--下注：黑桃
function prototype:uiEvtSpadeBet()
	--log("DTV: uiEvtSpadeBet")
	self:uiEvtHelpBet(Dantiao_pb.Spade)
end
function prototype:uiEvtHelpBet(SidesDesc)
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo.roomState == Dantiao_pb.State_Bet then
		if roomStateInfo.isMing and self.currentSidesDesc ~= SidesDesc then
			local data = {
				content = "明牌抢注时，该区域无法下注！"
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end
		self.imgBetArea[SidesDesc]:setVisible(true)
		self.imgBetArea[SidesDesc]:setOpacity(0)
		self.imgBetArea[SidesDesc]:runAction(cc.Sequence:create(cc.FadeIn:create(0.15),cc.FadeOut:create(0.15)))
		local betValue = self.nodeBottomMsg:getBetValue()
		self.modelData:requestBet(SidesDesc, betValue)
		self.nodeBottomMsg:setEnabledContinueBet(false)
	end
end
--根据下注数值获取不同等级筹码数量
function prototype:getChipsNum(betValue)
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	--金币1:100兑换为人民币比例
	local coinValue = FLOOR(betValue / 100)
	--筹码等级: 1、10、100、500、1000
	--dump(BET_RANGE,"BET_RANGE",5)
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
	--local tnlog=debug.getinfo(1,'n');log("DTV: "..tnlog["name"])
	local roomState = self.modelData:getRoomState()
	if roomState == Dantiao_pb.State_Bet then
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

--请求上庄
function prototype:uiEvtSnatch()
	--log("DTV: uiEvtSnatch")
	Model:get("Games/Dantiao"):requestSnatch()
end
--请求下庄
function prototype:uiEvtAbandon()
	--log("DTV: uiEvtAbandon")
	Model:get("Games/Dantiao"):requestAbandon()
end
--结果详情
function prototype:uiEvtShowDetails()
	--log("DTV: uiEvtShowDetails")
	self.nodeResult:show()
end

function prototype:uiEvtPlayerList()
	--log("DTV: uiEvtPlayerList")
	ui.mgr:open("Dantiao/PlayerListView", self.divinerId)
end

--离开房间
function prototype:onBtnCloseClick()
	--log("DTV: onBtnCloseClick")
	Model:get("Games/Dantiao"):requestLeaveGame()
end