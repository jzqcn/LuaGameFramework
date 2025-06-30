module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local MAXPLAYER = 6

function prototype:enter()
	self.winSize = cc.Director:getInstance():getWinSize()

	--UI事件
	self:bindUIEvent("Game.ChangeRoom", "uiEvtChangeRoom")
	self:bindUIEvent("Game.Ready", "uiEvtReady")
	self:bindUIEvent("Game.Bet", "uiEvtBet")

	self:bindUIEvent("Game.Clock", "uiEvtClockFinish")
	self:bindUIEvent("Game.Distance", "uiEvtShowDistance")
	
	--Model消息事件
	self:bindModelEvent("Games/Kadang.EVT.PUSH_ENTER_ROOM", "onPushRoomEnter")
	self:bindModelEvent("Games/Kadang.EVT.PUSH_USER_READY", "onPushUserReady")
	self:bindModelEvent("Games/Kadang.EVT.PUSH_MEMBER_STATUS", "onPushMemberStatus")
	self:bindModelEvent("Games/Kadang.EVT.PUSH_ROOM_STATE", "onPushRoomState")
	self:bindModelEvent("Games/Kadang.EVT.PUSH_ROOM_DEAL", "onPushRoomDeal")
	self:bindModelEvent("Games/Kadang.EVT.PUSH_READY_BET", "onPushReadyBet")
	self:bindModelEvent("Games/Kadang.EVT.PUSH_ROOM_SETTLEMENT", "onPushSettlement")
	self:bindModelEvent("Games/Kadang.EVT.PUSH_REQUEST_BET", "onPushRequestBet")

	self.nodeMenu:setModelName("Games/Kadang")

	self.nodeBroadcast:setVisible(false)
	self.nodeRoomInfo:setVisible(false)

	self:onPushRoomEnter()

	sys.sound:playMusicByFile("resource/audio/Kadang/bg_music.mp3")
end

function prototype:gameClear()
	for i = 1, MAXPLAYER do
		local name1 = "nodeRole_"..tostring(i)
		-- local name2 = "imgReady_"..tostring(i)
		local name3 = "nodeSettlement_"..tostring(i)
		self[name1]:setVisible(false)
		-- self[name2]:setVisible(false)
		self[name3]:setVisible(false)
	end

	self.nodeNotice:setVisible(false)
	self.nodeReady:hide()
	self.nodeBetLayer:setVisible(false)

	self.nodeClock:setVisible(false)

	self:clearPokerCards()
end

function prototype:clearPokerCards(id)
	if not id then
		self.nodePoker:removeAllChildren()
		self.pokerCards = {}
	else
		local cardTab = self.pokerCards[id]
		if cardTab then
			for i, v in ipairs(cardTab) do
				v:removeFromParent(true)	
			end
			self.pokerCards[id] = nil
		end
	end
end

function prototype:clearPlayerData(seatIndex, id)
	self["nodeRole_"..seatIndex]:setVisible(false)
	-- self["imgReady_"..seatIndex]:setVisible(false)
	self["nodeSettlement_"..seatIndex]:setVisible(false)
	self:clearPokerCards(id)

	Model:get("Games/Kadang"):removeMemberById(id)
end

function prototype:showPlayerFrameFlash(seatIndex)
	for i = 1, MAXPLAYER do
		local name = "nodeRole_"..tostring(i)
		if seatIndex == i then
			self[name]:flashHeadFrame(true, true)
		else
			self[name]:flashHeadFrame(false)
		end
	end
end

function prototype:onPushRoomEnter()
	self:gameClear()
	
	self:onPushRoomInfo()
	self:onPushRoomState()
	self:onPushMemberStatus()
end

function prototype:onPushRoomInfo()
	local kaDangModel = Model:get("Games/Kadang")
	local roomInfo = kaDangModel:getRoomInfo()
	-- log(roomInfo)
	-- MAXPLAYER = roomInfo.maxPlayerNum
	self.nodeChip:setCurrencyType(roomInfo.currencyType, roomInfo.baseChip)

	if roomInfo.roomStyle == Common_pb.RsGold then
		-- self.nodeChatToolbar:setVisible(false)
		self.nodeChatToolbar:setVoiceVisible(false)
	end

	self.nodeChat:setModelData(kaDangModel)
end

function prototype:onPushMemberStatus(data)
	local kaDangModel = Model:get("Games/Kadang")
	local roomMember = kaDangModel:getRoomMember()
	local memsId = data or table.keys(roomMember)
	local roomStateInfo = kaDangModel:getRoomStateInfo()
	local roomState = roomStateInfo.roomState
	local userId = Model:get("Account"):getUserId()
	-- log(memsId)

	if memsId then
		for k, id in ipairs(memsId) do
			local seatIndex = kaDangModel:getPlayerSeatIndex(id)			
			local playerInfo = roomMember[id]
			-- log(playerInfo)
			if playerInfo.memberType ~= Common_pb.Leave then
				local headItemName = "nodeRole_"..seatIndex
				--加入房间或者更新玩家数据				
				self[headItemName]:setVisible(true)
				self[headItemName]:setHeadInfo(playerInfo, Model:get("Games/Kadang"):getCurrencyType())

				local memStateInfo = playerInfo.memStateInfo 
				if roomState == KaDang_pb.State_Begin or roomState == KaDang_pb.State_Ready then
					self[headItemName]:setReadyVisible(memStateInfo.isReady)
					-- self["imgReady_"..seatIndex]:setVisible(memStateInfo.isReady)

					if id == userId then
						self.nodeReady:show(memStateInfo.isReady, true)
					end

					if roomStateInfo.countDown > 0 then
						self.nodeClock:start(roomStateInfo.countDown)
						self.nodeNotice:start("准备")
					end

					self["nodeSettlement_"..seatIndex]:setVisible(false)
					self:clearPokerCards()
				else
					self:dealPokerCards(id, seatIndex, memStateInfo.cards, false)
					self.nodeChip:setChipValue(roomStateInfo.roomCoin, true)
				end

				if playerInfo.memberType == Common_pb.Add then
					sys.sound:playEffect("ENTER")
				end
			else
				--离开房间
				if userId == id then
					StageMgr:chgStage("Hall")
				else
					self:clearPlayerData(seatIndex, id)

					sys.sound:playEffect("LEAVE")
				end
			end
		end
	end
end

function prototype:onPushRoomState()
	local kaDangModel = Model:get("Games/Kadang")
	local roomStateInfo = kaDangModel:getRoomStateInfo()
	if roomStateInfo then
		local roomState = roomStateInfo.roomState
		log("Kadang::onPushRoomState:: roomState = "..roomState)
		if roomState == KaDang_pb.State_Begin or roomState == KaDang_pb.State_Ready then
			local userInfo = kaDangModel:getUserInfo()

			self.nodeReady:show(userInfo.memStateInfo.isReady, true)
			if roomStateInfo.countDown > 0 then
				self.nodeClock:start(roomStateInfo.countDown, 0.5)
				self.nodeNotice:start("准备", 0.5)
			end

			self.nodeChip:setChipValue(roomStateInfo.roomCoin, true)

			--隐藏下注头像框动画
			self:showPlayerFrameFlash()
			if roomState == KaDang_pb.State_Begin then
				self.nodeClock:finish(true)
				self.nodeNotice:finish()
			end

			self.nodeBetLayer:setVisible(false)

			local menuLayer = ui.mgr:getLayer("Games/Common/MenuToolBarView")
			if menuLayer then
				menuLayer:refresh()
			end
			
		elseif roomState == KaDang_pb.State_Deal then
			--发牌
			self.nodeClock:finish(true)
			self.nodeNotice:finish()

			for i = 1, MAXPLAYER do
				-- local name = "imgReady_"..tostring(i)
				-- self[name]:setVisible(false)
				self["nodeRole_"..i]:setReadyVisible(false)
			end

			local userInfo = kaDangModel:getUserInfo()
			if userInfo.memStateInfo.isViewer == true then
				--旁观者可以换桌
				self.nodeReady:show(true, true)
			else
				self.nodeReady:hide()
			end

			self.nodeChip:setChipValue(roomStateInfo.roomCoin)

		elseif roomState == KaDang_pb.State_Bet then
			--下注
		elseif roomState == KaDang_pb.State_ShowBet then
			--显示下注
			self.nodeClock:finish(true)
			self.nodeNotice:finish()
			-- self.nodeNotice:finish()
		elseif roomState == KaDang_pb.State_Settlement then
			--结算
			self.nodeClock:finish(true)
			self.nodeNotice:finish()
			-- self.nodeNotice:finish()
			self.nodeChip:setChipValue(roomStateInfo.roomCoin)
			--隐藏下注头像框flash动画
			self:showPlayerFrameFlash()
		end

	else
		assert(false)
	end
end

function prototype:uiEvtChangeRoom(data)
	Model:get("Games/Kadang"):requestChangeRoom()
end

--UI事件：准备按钮点击
function prototype:uiEvtReady()
	local kaDangModel = Model:get("Games/Kadang")
	local roomInfo = kaDangModel:getRoomInfo()
	local minCoin = roomInfo.minCoin or roomInfo.minLimit
	local currencyType = roomInfo.currencyType
	local userInfo = Model:get("Account"):getUserInfo()
	if currencyType==Common_pb.Sliver and userInfo.silver < minCoin then
		-- local function openShop()
		-- 	ui.mgr:open("Shop/ShopView", 3)
		-- end

		-- local data = {
		-- 	content = "您的银币余额不足，无法参与游戏！",
		-- 	okFunc = openShop
		-- }
		-- ui.mgr:open("Dialog/ConfirmDlg", data)
		return
	elseif currencyType == Common_pb.Gold and userInfo.gold < minCoin then		
		local function openShop()
			ui.mgr:open("Shop/ShopView", 1)
		end

		local data = {
			content = "您的金币余额不足，无法参与游戏！",
			okFunc = openShop
		}
		ui.mgr:open("Dialog/ConfirmDlg", data)
		return
	end
	
	kaDangModel:requestReady()
	self.nodeReady:show(true, true, 1)

	kaDangModel:setMemberReadyState(true, userInfo.userId)

	for i = 1, MAXPLAYER do
		local name3 = "nodeSettlement_"..tostring(i)
		self[name3]:setVisible(false)
	end

	self:clearPokerCards()
end

function prototype:uiEvtClockFinish()
	self.nodeReady:hide()
	self.nodeBetLayer:setVisible(false)

	self.nodeNotice:finish()
end

--Model事件：服务器返回玩家准备结果
function prototype:onPushUserReady(isSuccess)
	local kaDangModel = Model:get("Games/Kadang")
	local userId = Model:get("Account"):getUserId()

	if isSuccess then
		local userSeatIndex = kaDangModel:getPlayerSeatIndex(userId)
		kaDangModel:setMemberReadyState(true, userId)
		if kaDangModel:getRoomStateInfo().roomState < KaDang_pb.State_Deal then
			--无法保证消息顺序，可能发牌消息先发。
			-- self["imgReady_"..userSeatIndex]:setVisible(true)
			self["nodeRole_"..userSeatIndex]:setReadyVisible(true)
			self.nodeReady:show(true, true, 1)
		end

		sys.sound:playEffect("READY")
	else
		kaDangModel:setMemberReadyState(false, userId)
		if kaDangModel:getRoomStateInfo().roomState < KaDang_pb.State_Deal then
			self.nodeReady:show(false)
			self.nodeClock:start(roomStateInfo.countDown)
		end
	end
end

--Model事件：处理发牌
function prototype:onPushRoomDeal(data)
	--发牌时更新房间状态（上底注、状态更改）
	self:onPushRoomState()

	self:clearPokerCards()

	local kaDangModel = Model:get("Games/Kadang")
	local roomMember = kaDangModel:getRoomMember()
	for i, id in ipairs(data) do
		local seatIndex = kaDangModel:getPlayerSeatIndex(id)
		local playerInfo = roomMember[id]
		--更新玩家货币
		self["nodeRole_"..seatIndex]:setHeadInfo(playerInfo, kaDangModel:getCurrencyType())

		--添加筹码动画
		self:playerChipAction(kaDangModel:getRoomInfo().baseChip, seatIndex, true)

		self.pokerCards[id] = {}
		if playerInfo then
			--发牌动画
			self:dealPokerCards(id, seatIndex, playerInfo.memStateInfo.cards)
		else
			log4ui:warn("KadangView :: onPushRoomDeal :: can not find player info by id ! id : "..id)
		end
	end
end

--UI事件：点击下注
function prototype:uiEvtBet(betValue)
	betValue = betValue or 0
	if betValue >= 0 then
		Model:get("Games/Kadang"):requestBet(betValue)
	else
		log4ui:warn("KadangView::uiEvtBet:: bet value error ! value can't be less than 0")
	end
	self.nodeBetLayer:setVisible(false)
end

--Model事件：推送玩家下注
function prototype:onPushReadyBet(data)
	local kaDangModel = Model:get("Games/Kadang")
	local playerId = data.playerId
	local countDown = tonumber(data.countDown)
	local userId = Model:get("Account"):getUserId()
	local seatIndex = kaDangModel:getPlayerSeatIndex(playerId)
	-- log("KadangView::onPushReadyBet:: playerId:"..playerId..", userId:"..userId)
	self:showPlayerFrameFlash(seatIndex)

	if playerId == userId then
		--自己下注
		local roomInfo = kaDangModel:getRoomInfo()
		local roomStateInfo = kaDangModel:getRoomStateInfo()
		local userInfo = kaDangModel:getMemberInfoById(userId)

		local betRange = {}
		if data.betRange then			
			for k, v in ipairs(data.betRange) do
				betRange[#betRange + 1] = v
			end
			self.nodeBetLayer:showBetRange(betRange, userInfo.coin)
		else
			local roomCoin = roomStateInfo.roomCoin
			local minLimit = roomInfo.minLimit

			local mutiple = 1
			local cards = userInfo.memStateInfo.cards
			local size1 = cards[1].size
			local size2 = cards[2].size
			if size1 == size2 then
				--卡豹子20倍
				mutiple = 20
			elseif math.abs(size1 - size2) == 1 then
				--卡边顺子5倍
				mutiple = 5
			elseif math.abs(size1 - size2) == 2 then
				--卡中顺子
				mutiple = 10
			else
				mutiple = 1
			end

			local chipValue = math.floor(roomCoin/mutiple)
			local maxLimit = math.ceil(chipValue / minLimit) * minLimit
			if maxLimit > userInfo.coin then
				maxLimit = math.floor(userInfo.coin / minLimit) * minLimit
			end

			-- log("roomCoin:"..roomCoin..", mutiple:"..mutiple..", maxLimit:"..maxLimit..", minLimit:"..minLimit)

			self.nodeBetLayer:showBetData(minLimit, maxLimit)
		end
		
		self.nodeBetLayer:setVisible(true)

		self.nodeClock:start(countDown)
	else
		--提示等待玩家下注
		self.nodeClock:start(countDown)
		self.nodeNotice:start("下注")
	end	

	sys.sound:playEffect("CHOOSE_DEALER_END")
end

function prototype:onPushRequestBet(isSuccess)
	if not isSuccess then
		if self.nodeClock:isVisible() then
			self.nodeBetLayer:setVisible(true)
		end
	end
end

--Model事件：结算
function prototype:onPushSettlement(data)
	local kaDangModel = Model:get("Games/Kadang")
	local roomStateInfo = kaDangModel:getRoomStateInfo()
	local roomMember = kaDangModel:getRoomMember()
	local userId = Model:get("Account"):getUserId()
	local centerPos = cc.p(self.winSize.width/2, self.winSize.height/2)

	self:onPushRoomState()

	self.nodeChip:setChipValue(roomStateInfo.roomCoin)

	local showResultDelay = 0.8
	for index, id in ipairs(data) do
		local seatIndex = kaDangModel:getPlayerSeatIndex(id)
		local playerInfo = roomMember[id]
		if playerInfo then
			--更新玩家货币
			self["nodeRole_"..seatIndex]:setHeadInfo(playerInfo, kaDangModel:getCurrencyType())

			local cards = playerInfo.memStateInfo.cards			
			if self.pokerCards[id] == nil then
				self.pokerCards[id] = {}
			end

			local playerCards = self.pokerCards[id]
			for i, v in ipairs(cards) do
				local cardNode = playerCards[i]
				if cardNode == nil then
					cardNode = self:getLoader():loadAsLayer("Games/Common/GamePokerCard")
					self.nodePoker:addChild(cardNode, i)

					table.insert(self.pokerCards[id], cardNode)

					local scale = 0.65
					-- if id ~= Model:get("Account"):getUserId() then
					-- 	scale = 0.6
					-- end
					-- local x, y = self["imgReady_"..seatIndex]:getPosition()
					local x, y = self["nodeSettlement_"..seatIndex]:getPosition()
					-- local x = pos.x
					-- local y = pos.y
					-- local size = cc.size(cardNode:getContentSize().width*scale, cardNode:getContentSize().height*scale)
					local to = cc.p(x + i*45, y + 80) --cc.p(x+(i-1)*size.width/2.4, y)
					local showAction = false
					if i == 3 then
						to.x = to.x + 65 --size.width*0.7
						showAction = true
					end
					
					cardNode:setCardInfo(id, v)
					cardNode:runDealAction(centerPos, to, scale, 0, showAction, showAction)
				else
					cardNode:setCardInfo(id, v)
				end
			end

			if playerInfo.memStateInfo.result == KaDang_pb.Abandon then
				showResultDelay = 0
			end
		else
			log4ui:warn("KadangView :: onPushSettlement :: can not find player info by id ! id : "..id)
		end
	end

	self.rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(showResultDelay), cc.CallFunc:create(function ()
	    			self:showSettlement(data)
	    	end)))
end

function prototype:showSettlement(data)
	for index, id in ipairs(data) do
		-- log("[KadangView::showSettlement] playerId == "..id)
		local kaDangModel = Model:get("Games/Kadang")
		local roomMember = kaDangModel:getRoomMember()
		local userId = Model:get("Account"):getUserId()
		local seatIndex = kaDangModel:getPlayerSeatIndex(id)
		local playerInfo = roomMember[id]
		local playerCards = self.pokerCards[id]

		if not playerCards or not playerInfo then
			assert(false)
		end

		for i, v in ipairs(playerCards) do
			v:showCardValue()
		end

		local result = playerInfo.memStateInfo.result
		local value = playerInfo.memStateInfo.settleCoin

		local name = "nodeSettlement_"..seatIndex
		self[name]:showResult(result, value, playerInfo.memStateInfo.mutiple, playerInfo.memStateInfo.kazhResult)
		
		local function updateRoleInfo()
			self["nodeRole_"..seatIndex]:setHeadInfo(playerInfo, kaDangModel:getCurrencyType())
		end

		if result == KaDang_pb.Win then
			self["nodeRole_"..seatIndex]:runSettlementNumAction(value)
			self:playerChipAction(value, seatIndex, false, updateRoleInfo)
		elseif result == KaDang_pb.Lose then
			self["nodeRole_"..seatIndex]:runSettlementNumAction(-value)
			self:playerChipAction(value, seatIndex, true, updateRoleInfo)
		end
	end
end

function prototype:dealPokerCards(playerId, seatIndex, cards, isAnimation)
	-- local x, y = self["imgReady_"..seatIndex]:getPosition()
	local pos = self["nodeRole_"..seatIndex]:getReadIconPos()
	local x = pos.x
	local y = pos.y
	local centerPos = cc.p(self.winSize.width/2, self.winSize.height/2)

	if self.pokerCards[playerId] == nil then
		self.pokerCards[playerId] = {}
	end

	local playerCards = self.pokerCards[playerId]
	for i, v in ipairs(cards) do
		local cardNode = playerCards[i]
		if cardNode == nil then
			cardNode = self:getLoader():loadAsLayer("Games/Common/GamePokerCard")
			self.nodePoker:addChild(cardNode, i)
			table.insert(self.pokerCards[playerId], cardNode)
		else
			isAnimation = false
		end

		if cardNode then
			local scale = 0.65
			-- if playerId ~= Model:get("Account"):getUserId() then
			-- 	scale = 0.6
			-- end

			local x, y = self["nodeSettlement_"..seatIndex]:getPosition()
			-- local x = pos.x
			-- local y = pos.y
			-- local size = cc.size(cardNode:getContentSize().width*scale, cardNode:getContentSize().height*scale)
			local to = cc.p(x + i*45, y + 80) --cc.p(x+(i-1)*size.width/2.4, y)
			if i == 3 then
				to.x = to.x + 65 --size.width*0.7
				showAction = true
			end
			
			cardNode:setCardInfo(playerId, v)
			cardNode:runDealAction(centerPos, to, scale, (i-1)*0.1, isAnimation, isAnimation)
		else
			log4ui:warn("dealPokerCards::error!! playerId:"..playerId..", card index:"..i)
		end
	end
end

function prototype:playerChipAction(chipValue, seatIndex, inOrOut, callback)
	if seatIndex > 0 and seatIndex <= MAXPLAYER then
		local pos = self["nodeRole_"..seatIndex]:getCoinPos()
		if inOrOut == true then
			self.nodeChip:uploadChip(chipValue, pos, callback)
		else
			self.nodeChip:downloadChip(chipValue, pos, callback)
		end
	else
		assert(false)
	end
end

function prototype:onBtnCardTypeClick(sender)

end

-- function prototype:onBtnMenuClick(sender)
-- 	ui.mgr:open("Games/Common/MenuToolBarView", "Games/Kadang")
-- end

function prototype:uiEvtShowDistance()
	self.nodeDistance:showDistance("Games/Kadang")
end

