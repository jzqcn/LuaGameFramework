module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local PaoDeKuai_pb = PaoDeKuai_pb
local Common_pb = Common_pb

local MAXPLAYER = 3

function prototype:enter()
	Logic:load({"PaodekuaiLogic"})
	
	--UI事件
	self:bindUIEvent("Game.ChangeRoom", "uiEvtChangeRoom")
	self:bindUIEvent("Game.Ready", "uiEvtReady")
	self:bindUIEvent("Game.Clock", "uiEvtClockFinish")
	self:bindUIEvent("Game.CopyRoomId", "uiEvtCopyRoomId")
	self:bindUIEvent("Game.ReturnHall", "uiEvtReturnHall")
	self:bindUIEvent("Game.InviteFriend", "uiEvtInviteFriend")
	self:bindUIEvent("Game.ShowNotice", "uiEvtShowNotice")
	self:bindUIEvent("Game.Distance", "uiEvtShowDistance")

	self:bindUIEvent("Game.PlayBackPause", "uiEvtPlayBackPause")
	self:bindUIEvent("Game.PlayBackPlay", "uiEvtPlayBackPlay")

	--Model消息事件
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_ENTER_ROOM", "onPushRoomEnter")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_USER_READY", "onPushUserReady")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_MEMBER_STATUS", "onPushMemberStatus")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_ROOM_STATE", "onPushRoomState")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_ROOM_DEAL", "onPushRoomDeal")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_ROOM_DISCARD", "onPushRoomDiscard")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_DISCARD_READY", "onPushDiscardReady")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_DISCARD", "onPushDiscard")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_SETTLEMENT", "onPushSettlement")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_ROOM_DRAW", "onPushRoomDraw")
	self:bindModelEvent("GamePerformance.EVT.PUSH_GAME_PERFORMANCE", "onPushGamePerformance")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_PLAYBACK_SINGLE", "onPushPlayBackSingle")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_PLAYER_LACK_COIN", "onPushPlayerLackCoin")
	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_CANCEL_PLAYER_LACK_COIN", "onPushCancelPlayerLackCoin")

	self.nodeMenu:setModelName("Games/Paodekuai")
	
	self.modelData = Model:get("Games/Paodekuai")
	self.nodeChat:setModelData(self.modelData)

	self.userId = Model:get("Account"):getUserId()
	self.isShowCardValue = false

	self.nodeInvite:setVisible(false)

	self:onPushRoomEnter()

	sys.sound:playMusicByFile("resource/audio/Paodekuai/bg_music.mp3")
end

function prototype:gameClear()
	for i = 1, MAXPLAYER do
		self["nodeRole_"..i]:setVisible(false)
		self["nodeClock_"..i]:setVisible(false)
		if self["nodeWarning_"..i] then
			self["nodeWarning_"..i]:removeFromParent()
		end
		self["nodeRole_"..i]:flashHeadFrame(false)
	end

	self.nodeDiscardTip_1:setVisible(false)
	self.nodeDiscardTip_2:setVisible(false)
	self.nodeDiscardTip_3:setVisible(false)
	self.nodeNotice:setVisible(false)
	-- self.nodeStart:setVisible(false)
	self.nodeTip:setVisible(false)

	self.nodeReady:hide()

	self.nodePokerLayer:clearPokerCards()
	self.nodePokerLayer:clearPlayerDiscards()
end

function prototype:clearPlayerData(seatIndex, id)
	self["nodeRole_"..seatIndex]:setVisible(false)
	self["nodeClock_"..seatIndex]:setVisible(false)
	if self["nodeWarning_"..seatIndex] then
		self["nodeWarning_"..seatIndex]:removeFromParent()
	end

	self.modelData:removeMemberById(id)

	self.nodePokerLayer:clearPokerCards(id)
	-- self.nodePokerLayer:clearPlayerDiscards(id)
end

function prototype:clearClock()
	for i = 1, MAXPLAYER do
		self["nodeClock_"..i]:stop()
	end
end

function prototype:onPushRoomEnter()
	self:gameClear()

	local roomInfo = self.modelData:getRoomInfo()
	self.roomStyle = roomInfo.roomStyle
	
	self:onPushRoomState()
	self:onPushMemberStatus(false, true)

	if not self.modelData:getIsPlayBack() then
		--重新进入房间，游戏已经开始，显示最后一轮玩家出牌
		local roomState = self.modelData:getRoomState()
		-- log("[PaodekuaiView::onPushRoomEnter] roomState : "..roomState)
		if roomState >= PaoDeKuai_pb.State_Deal then		
			local roundData = self.modelData:getDiscardRoundData()
			-- log(roundData)
			if roundData and #roundData.discardsList > 0 then
				local roomMember = self.modelData:getRoomMember()
				local memsId = table.keys(roomMember)
				local discardsList = roundData.discardsList
				local isFirst = false
				for i = #discardsList, 1, -1 do
					if #memsId > 0 then
						local discardInfo = discardsList[i]
						local playerId = discardInfo.playerId
						local discards = discardInfo.discards
						if discardInfo.isSingle then
							self:setPlayerSingle(playerId, true)
						end

						for j, id in ipairs(memsId) do
							if playerId == id then
								table.remove(memsId, j)
								break
							end
						end

						if discardInfo.isFirst then
							isFirst = true
						end

						if not isFirst then
							if #discards > 0 then
								self.nodePokerLayer:showLastRoundDiscards(playerId, discards, discardInfo.handsDesc)
							else
								local seatIndex = self.modelData:getPlayerSeatIndex(playerId)
								self["nodeDiscardTip_"..seatIndex]:showTip("要不起", seatIndex==2)
								--删除要不起的牌型
								table.remove(discardsList, i)
							end
						end
					else
						break
					end
				end

				--开牌
				self:showUserCardValue()
			end
		end

		self.nodePlayBackMenu:setVisible(false)
		self.imgExit:setVisible(false)

	else
		--回放直接摆牌
		local roomMember = self.modelData:getRoomMember()
		for id, v in pairs(roomMember) do
			self.nodePokerLayer:dealPokerCards(id, false)
		end

		self:doPlayBackAction()

		self.nodePlayBackMenu:setVisible(true)
		self.imgExit:setVisible(true)
	end

	self:onPushRoomInfo()

	--游戏中返回大厅之后，重新加入房间
	local curReadyDiscard = self.modelData:getCurReadyDiscard()
	if curReadyDiscard then
		self:onPushDiscardReady(curReadyDiscard)
	end
end

function prototype:onPushRoomInfo()
	local roomInfo = self.modelData:getRoomInfo()
	if roomInfo.roomStyle == Common_pb.RsGold then
		self.nodeChatToolbar:setVoiceVisible(false)
		self.nodeRoomInfo:setVisible(false)
		self.nodeInvite:setVisible(false)
	elseif roomInfo.roomStyle == Common_pb.RsCard then
		self.nodeChatToolbar:setVoiceVisible(true)
		self:updateRoomInfo()
	end

	self.roomStyle = roomInfo.roomStyle

	if self.modelData:getIsPlayBack() then
		--回放隐藏按钮
		self.nodeChatToolbar:setVisible(false)
		self.nodeInvite:setVisible(false)
		self.nodeMenu:setVisible(false)
		self.nodeReady:setVisible(false)
	else
		--重连进房间显示轮到谁出牌
		if roomInfo.readyDiscard and self.modelData:getRoomState() >= PaoDeKuai_pb.State_Discard then
			self:onPushDiscardReady(roomInfo.readyDiscard)
		end
	end
end

--更新房间信息
function prototype:updateRoomInfo()
	local roomInfo = self.modelData:getRoomInfo()
	--房卡场
	local info = {}
	--房间号默认4位，位数不够前面补充0
	table.insert(info, string.format("房间:%04d", roomInfo.roomId))
	table.insert(info, string.format("局数:%d/%d", roomInfo.currentGroup, roomInfo.groupNum))

	if not self.modelData:getIsPlayBack() then
		if self.chipRangeMsg == nil then
			local data = db.mgr:getDB("PaodekuaiCardConfig", {playId = roomInfo.playId, currencyType = roomInfo.currencyType})
			if #data > 0 then
				local msg = data[1]["baseChipRange"]
				if msg then
					local showStrTable = string.split(msg, ";")
					-- self.chipRangeMsg = string.format("底分:%f", tonumber(showStrTable[roomInfo.baseChipRange+1]) / 100)
					if roomInfo.currencyType == Common_pb.Gold then
						self.chipRangeMsg = "底分:" .. Assist.NumberFormat:amount2Hundred(showStrTable[roomInfo.baseChipRange+1])
					else
						self.chipRangeMsg = "底分:" .. showStrTable[roomInfo.baseChipRange+1]
					end

					table.insert(info, self.chipRangeMsg)
				end
			end
		else
			table.insert(info, self.chipRangeMsg)
		end
	end

	self.nodeRoomInfo:setRoomInfo(info)
	self.nodeRoomInfo:setVisible(true)
end

--房间状态
function prototype:onPushRoomState()
	if self.modelData:getIsPlayBack() then
		return
	end

	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo then
		local roomState = roomStateInfo.roomState
		local userInfo = self.modelData:getUserInfo()
		-- log("[PaodekuaiView::onPushRoomState::] roomState = "..roomState..", countDown = "..roomStateInfo.countDown)

		if roomState == PaoDeKuai_pb.State_Begin then
			self.nodePokerLayer:clearPokerCards()
			self.nodePokerLayer:clearPlayerDiscards()

			self.modelData:clearSingleState()

			self.isShowCardValue = false

			if self.modelData.roomInfo.roomStyle == Common_pb.RsCard then
				self:updateRoomInfo()
			end
		elseif roomState == PaoDeKuai_pb.State_Ready then
			if roomStateInfo.countDown > 0 then
				self.nodeClock_1:start(roomStateInfo.countDown, 0.5)
				self.nodeNotice:start("准备", 0.5)
			end
		elseif roomState == PaoDeKuai_pb.State_Deal then
			for i = 1, MAXPLAYER do
				self["nodeRole_"..i]:setReadyVisible(false)
				self["nodeClock_"..i]:stop()
			end
			self.nodeNotice:finish()

			if userInfo ~= nil and userInfo.memStateInfo.isViewer == false then
				self.nodeReady:hide()
			else
				self.nodeReady:show(true, true)
			end
		elseif roomState == PaoDeKuai_pb.State_Discard  or roomState == PaoDeKuai_pb.State_NotDiscard then
			--出牌倒计时
			-- local roomMember = self.modelData:getRoomMember()
			-- for id, v in pairs(roomMember) do
			-- 	if v.memStateInfo.isDiscarder then
			-- 		local seatIndex = self.modelData:getPlayerSeatIndex(id)
			-- 		self["nodeClock_"..seatIndex]:start(roomStateInfo.countDown)
			-- 		break
			-- 	end
			-- end
			
		elseif roomState == PaoDeKuai_pb.State_Settlement then
			if self.modelData.roomInfo.roomStyle == Common_pb.RsCard then
				self:updateRoomInfo()
			end
		end

		if userInfo ~= nil and self.modelData.roomInfo.roomStyle == Common_pb.RsCard then
			if roomState > PaoDeKuai_pb.State_Begin then
				self.nodeInvite:setVisible(false)
			else
				local maxNum = self.modelData:getMaxPlayerNum()
				local playerNum = table.nums(self.modelData:getRoomMember())
				if playerNum < maxNum then
					self.nodeInvite:setVisible(true)
				else
					self.nodeInvite:setVisible(false)
				end
			end
		end
	end
end

--游戏开始，扣除台费
function prototype:onPushRoomDraw()
	self:onPushMemberStatus()
end

--成员数据
function prototype:onPushMemberStatus(data, refreshCards)
	local roomMember = self.modelData:getRoomMember()
	local memsId = data or table.keys(roomMember)
	if memsId then
		for i, id in ipairs(memsId) do
			local seatIndex = self.modelData:getPlayerSeatIndex(id)
			local playerInfo = roomMember[id]
			if playerInfo ~= nil then
				if playerInfo.memberType ~= Common_pb.Leave then
					-- local memStateInfo = playerInfo.memStateInfo
					local headItemName = "nodeRole_"..seatIndex
					--加入房间或者更新玩家数据				
					self[headItemName]:setVisible(true)
					self[headItemName]:setHeadInfo(playerInfo, self.modelData:getCurrencyType(), self.modelData:getIsPlayBack())

					self:updatePlayerState(playerInfo, refreshCards)

					if playerInfo.memberType == Common_pb.Add then
						sys.sound:playEffect("ENTER")
					end
				else
					--离开房间
					if self.userId == id then
						StageMgr:chgStage("Hall")
					else
						self:clearPlayerData(seatIndex, id)

						sys.sound:playEffect("LEAVE")
					end
				end
			end
		end
	end
end

--更新玩家状态
function prototype:updatePlayerState(playerInfo, refreshCards)
	if self.modelData:getIsPlayBack() then
		return
	end

	local id = playerInfo.playerId
	local seatIndex = self.modelData:getPlayerSeatIndex(id)
	local roomState = self.modelData:getRoomState()
	local memStateInfo = playerInfo.memStateInfo
	-- log("[PaodekuaiView::updatePlayerState] roomState == "..roomState..", playerId == "..id)
	if roomState==PaoDeKuai_pb.State_Begin or roomState==PaoDeKuai_pb.State_Ready then
		if id == self.userId then
			if memStateInfo.isViewer == true and self.roomStyle == Common_pb.RsGold then
				self.nodeReady:show(true, true)
			else
				self.nodeReady:show(memStateInfo.isReady, self.roomStyle == Common_pb.RsGold)
			end
		end

		self["nodeRole_"..seatIndex]:setReadyVisible(memStateInfo.isReady)
		-- self:checkGameStart()
	elseif roomState==PaoDeKuai_pb.State_Deal or roomState==PaoDeKuai_pb.State_Discard or roomState==PaoDeKuai_pb.State_NotDiscard then
		self["nodeRole_"..seatIndex]:setReadyVisible(false)

		--重新加入房间才需要刷新牌，其他按照出牌逻辑
		refreshCards = refreshCards or false
		if refreshCards then
			self.nodePokerLayer:dealPokerCards(id, false)
		end

		-- self.nodeStart:setVisible(false)
	else
		--结算

	end
end

--服务器推送发牌
function prototype:onPushRoomDeal(memsId)
	self:clearClock()
	self:onPushRoomState()
	
	self.nodePokerLayer:clearPokerCards()

	for i, id in ipairs(memsId) do
		--发牌动画
		self.nodePokerLayer:dealPokerCards(id, true)
	end
end

function prototype:showUserCardValue()
	if self.isShowCardValue then
		return
	end

	self.nodePokerLayer:showUserCardValue()
	self.isShowCardValue = true
end

--玩家出牌返回
function prototype:onPushRoomDiscard(isSuccess)
	self.nodePokerLayer:doDiscardResult(isSuccess)
end

--每回合开始，轮到谁出牌
function prototype:onPushDiscardReady(discardData)
	self:clearClock()
	-- self:onPushRoomState()
	if discardData then
		-- log(discardData)

		local seatIndex = self.modelData:getPlayerSeatIndex(discardData.playerId)

		for i = 1, MAXPLAYER do
			local name = "nodeRole_"..tostring(i)
			if seatIndex == i then
				self[name]:flashHeadFrame(true)
			else
				self[name]:flashHeadFrame(false)
			end
		end

		--首次轮到自己出牌，展示牌值
		if discardData.playerId == self.userId then
			self:showUserCardValue()
		end

		if discardData.isNotDiscard then
			--要不起 不显示倒计时了
			if discardData.playerId == self.userId then
				self.nodeNotice:start("没有牌大过上家", 0, 3)
			end

			self["nodeDiscardTip_"..seatIndex]:showTip("要不起")

			self.nodePokerLayer:clearPlayerDiscards(discardData.playerId)

			--要不起
			util.timer:after(500, self:createEvent("DELAY_DISCARD_TIP", function()
				local info = self.modelData:getMemberInfoById(discardData.playerId)
				if info.sex == 1 then
					sys.sound:playEffectByFile("resource/audio/Paodekuai/man/yaobuqi.mp3")
				else
					sys.sound:playEffectByFile("resource/audio/Paodekuai/woman/yaobuqi.mp3")
				end
			end))
			
			-- self.nodePokerLayer:showDiscardOption(discardData.playerId, discardData.isFirst)
		else
			if discardData.playerId == self.userId then
				self.nodeNotice:finish()
			end

			self["nodeClock_"..seatIndex]:start(discardData.countDown)

			if discardData.isFirst then
				self.nodeDiscardTip_1:setVisible(false)
				self.nodeDiscardTip_2:setVisible(false)
				self.nodeDiscardTip_3:setVisible(false)
			else
				self["nodeDiscardTip_"..seatIndex]:setVisible(false)
			end
			self.nodePokerLayer:showDiscardOption(discardData.playerId, discardData.isFirst)
		end

		self.discardPlayerId = discardData.playerId
	else
		log4ui:error("[PaodekuaiView::onPushDiscardReady] ready discard data is nil !")
	end
end

--服务器推送玩家出牌
function prototype:onPushDiscard(roundDiscardData)
	self:clearClock()

	if roundDiscardData == nil then
		log4ui:warn("[PaodekuaiView::onPushDiscard] round discard data is nil !!!")
		return
	end

	local isLast = false
	local discardsList = roundDiscardData.discardsList
	if #discardsList > 0 then
		local discardInfo = discardsList[#discardsList]
		if discardInfo.isSingle == true then
			self:setPlayerSingle(discardInfo.playerId, true)
		end

		isLast = discardInfo.isLast
	end

	if isLast then
		self.nodePokerLayer:hideDiscardOption()
		--最后一手牌，服务器自动出牌时，需要延迟1s，不然可能同时出牌会覆盖前一轮出牌
		util.timer:after(0.7 * 1000, self:createEvent("DELAY_SHOW_LAST_DISCARD", function()
	        self.nodePokerLayer:showPlayerDiscards(roundDiscardData)
	    end))
	else
		self.nodePokerLayer:showPlayerDiscards(roundDiscardData)
	end
end

function prototype:setPlayerSingle(playerId, isSingle)
	isSingle = isSingle or false
	local seatIndex = self.modelData:getPlayerSeatIndex(playerId)
	if isSingle then
		if self["nodeWarning_"..seatIndex] == nil then
			--报警动画
			local cache = cc.SpriteFrameCache:getInstance()
			local sprite = cc.Sprite:create("resource/csbimages/Games/Common/imgWarning_1.png")
			-- local animation = cc.Animation:create()
		 --    for i = 1, 4 do				
		 --        animation:addSpriteFrameWithFile(string.format("resource/csbimages/Games/Common/imgWarning_%d.png", i))
		 --    end
		 --    animation:setDelayPerUnit(0.8 / 4)

		    local animFrames = {}
		    for i = 1, 4 do 
		        local frame = cache:getSpriteFrame(string.format("resource/csbimages/Games/Common/imgWarning_%d.png", i))
		        animFrames[i] = frame
		    end
		    local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.2)

		    local showAction = cc.Animate:create(animation)
		    sprite:runAction(cc.RepeatForever:create(showAction))

			local pos = self["nodeRole_"..seatIndex]:getHeadPos()
			local anchorPos = self["nodeRole_"..seatIndex]:getLabelAnchorPoint()									
			if anchorPos.x == 0 then
				sprite:setPosition(cc.p(pos.x + 75, pos.y))
			else
				sprite:setPosition(cc.p(pos.x - 75, pos.y))
			end

			self.nodePokerLayer:addChild(sprite, 1000)
			self["nodeWarning_"..seatIndex] = sprite

			--报警音效
			local info = self.modelData:getMemberInfoById(playerId)
			if info.sex == 1 then
				sys.sound:playEffectByFile("resource/audio/Paodekuai/man/baojing1.mp3")
			else
				sys.sound:playEffectByFile("resource/audio/Paodekuai/woman/baojing1.mp3")
			end
		end
	else
		if self["nodeWarning_"..seatIndex] ~= nil then
			self["nodeWarning_"..seatIndex]:removeFromParent()
			self["nodeWarning_"..seatIndex] = nil
		end
	end

	self.modelData:setIsSingle(playerId, isSingle)
end

--服务器推送结算
function prototype:onPushSettlement()
	self:clearClock()
	self.nodeDiscardTip_1:setVisible(false)
	self.nodeDiscardTip_2:setVisible(false)
	self.nodeDiscardTip_3:setVisible(false)

	self.isShowCardValue = false

	local resultData = {}
	local members = self.modelData:getRoomMember()
	for id, v in pairs(members) do
		self:setPlayerSingle(id, false)
	end

	-- log(members)
	util.timer:after(0.5 * 1000, self:createEvent("DELAY_DO_MEM_RESULT", function()
        self.nodePokerLayer:doGameResult(members)
    end))
	

	util.timer:after(1.5 * 1000, self:createEvent("DELAY_SHOW_RESULT", function()
        ui.mgr:open("Games/Paodekuai/ResultView", members)
    end))
end

--房卡场总结算
function prototype:onPushGamePerformance(info)
	local roomInfo = self.modelData:getRoomInfo()
	if roomInfo.roomStyle == Common_pb.RsCard then
		local roomState = self.modelData:getRoomState()
		info.currencyType = roomInfo.currencyType
		info.strCurrencyType = roomInfo.currencyType==Common_pb.Score and "计分" or "金币"
		info.strCurrencyType = string.format("%s(%s)", info.strCurrencyType, self.chipRangeMsg)
		info.strPayType = "房主付费"

		if roomState == PaoDeKuai_pb.State_Settlement then
			if roomInfo.groupNum == roomInfo.currentGroup then
				--最后一局（总结算延迟，关闭了单局结算后，直接弹出总结算）
				if ui.mgr:isOpen("Games/Paodekuai/ResultView") then
					self.groupPerformance = info
				else
					ui.mgr:open("GameResult/GroupResultView", info)	
				end
			else
				--中间
				ui.mgr:open("GameResult/GroupResultView", info)
			end
		else
			ui.mgr:open("GameResult/GroupResultView", info)
		end

		self.nodeRoomInfo:setVisible(false)

		self:clearClock()
	end
end

--显示总结算（单局结算关闭之后显示）
function prototype:showGroupResultView()
	if self.groupPerformance then
		ui.mgr:open("GameResult/GroupResultView", self.groupPerformance)
	end
end

function prototype:uiEvtChangeRoom()
	Model:get("Games/Paodekuai"):requestChangeRoom()
end

function prototype:uiEvtReady()
	local userInfo = Model:get("Account"):getUserInfo()

	self.modelData:requestReady()
	self.modelData:setMemberReadyState(true, userInfo.userId)

	if self.roomStyle == Common_pb.RsGold then
		self.nodeReady:show(true, true, 1)
	else
		self.nodeReady:hide()
	end
end

--玩家准备
function prototype:onPushUserReady(isSuccess)
	local userInfo = self.modelData:getUserInfo()
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if isSuccess then		
		self.modelData:setMemberReadyState(true, userInfo.playerId)

		if roomStateInfo.roomState < PaoDeKuai_pb.State_Deal then
			--无法保证消息顺序，可能发牌消息先发。
			local seatIndex = self.modelData:getPlayerSeatIndex(userInfo.playerId)
			-- self["imgReady_"..seatIndex]:setVisible(true)
			self["nodeRole_"..seatIndex]:setReadyVisible(true)
			if self.roomStyle == Common_pb.RsGold then
				self.nodeReady:show(true, true, 1)
			end

			-- self:checkGameStart()
		end
		-- sys.sound:playEffect("READY")
	else
		self.modelData:setMemberReadyState(false, userInfo.playerId)

		if roomStateInfo.roomState < PaoDeKuai_pb.State_Deal then
			self.nodeReady:show(false, self.roomStyle == Common_pb.RsGold)
			-- self.nodeClock:start(roomStateInfo.countDown, "")
		end
	end
end

--时钟倒计时结束
function prototype:uiEvtClockFinish()
	self.nodeNotice:finish()
	if self.discardPlayerId == self.userId then
		-- self.nodePokerLayer:hideDiscardOption()
	end
end

--提示消息（没有牌大过上家）
function prototype:uiEvtShowNotice(tips, duration)
	self.nodeNotice:start(tips, 0, duration)
end

--房间内玩家缺钱消息
function prototype:onPushPlayerLackCoin(info)
	if not info then
		return
	end

	local names = ""
	for i, v in ipairs(info.playerId) do
		local playerInfo = self.modelData:getMemberInfoById(v)
		if playerInfo then
			names = names .. "【" .. playerInfo.playerName .. "】"
		end
	end

	local content = string.format("玩家%s金币不够，等待续费！", names)
	self.nodeTip:showLackCoinMsg(content, info.countDown, 1)
end

--房间内玩家缺钱状态取消消息
function prototype:onPushCancelPlayerLackCoin()
	self.nodeTip:finish()
end


------------------回放播放， 间隔3s------------------
function prototype:doPlayBackAction()
	util.timer:repeats(1.2*1000, self:createEvent("DO_PLAY_BACK_ACTION", function()
		local nextStepData = self.modelData:getNextPlayBackStep()
		if nextStepData then
			local playerId = nextStepData.userId
			local seatIndex = self.modelData:getPlayerSeatIndex(playerId)
			if nextStepData.isPlay == 0 or #(nextStepData.cards) == 0 then
				--要不起
				self["nodeDiscardTip_"..seatIndex]:showTip("要不起")

				self.nodePokerLayer:clearPlayerDiscards(playerId)

				--要不起
				local info = self.modelData:getMemberInfoById(playerId)
				if info.sex == 1 then
					sys.sound:playEffectByFile("resource/audio/Paodekuai/man/yaobuqi.mp3")
				else
					sys.sound:playEffectByFile("resource/audio/Paodekuai/woman/yaobuqi.mp3")
				end

			else
				--出牌
				if nextStepData.first == true then
					self.nodeDiscardTip_1:setVisible(false)
					self.nodeDiscardTip_2:setVisible(false)
					self.nodeDiscardTip_3:setVisible(false)
					self.nodePokerLayer:clearPlayerDiscards()
				else
					self["nodeDiscardTip_"..seatIndex]:setVisible(false)
					self.nodePokerLayer:clearPlayerDiscards(playerId)
				end

				local roundDiscardData = {}
				roundDiscardData.discardsList = {}

				local discardInfo = {}
				discardInfo.playerId = playerId
				discardInfo.discards = nextStepData.discards
				discardInfo.handsDesc = Logic:get("PaodekuaiLogic"):getCardType(nextStepData.discards)

				table.insert(roundDiscardData.discardsList, discardInfo)
				self.nodePokerLayer:showPlayerDiscards(roundDiscardData)
			end
		else
			--播放结束
			self:cancelEvent("DO_PLAY_BACK_ACTION")
			--打开结算界面
			self:onPushSettlement()

			self.nodePlayBackMenu:setVisible(false)
			self.imgExit:setVisible(false)
		end
	end))
end

--设置报单
function prototype:onPushPlayBackSingle(playerId)
	self:setPlayerSingle(playerId, true)
end

--暂停
function prototype:uiEvtPlayBackPause()
	self:cancelEvent("DO_PLAY_BACK_ACTION")
end

--播放
function prototype:uiEvtPlayBackPlay()
	self:doPlayBackAction()
end

--回放直接退出，返回回放列表界面
function prototype:onBtnExitClick()
	StageMgr:chgStage("Hall")

	ui.mgr:open("GameRecord/GamePlaybackView", Model:get("PlayBack"):getPlaybackInfo())
end

---------------------回放播放-----------------------


--复制房间号码
function prototype:uiEvtCopyRoomId()
	local roomInfo = self.modelData:getRoomInfo()
	util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, string.format("%04d", roomInfo.roomId))
end

--返回大厅
function prototype:uiEvtReturnHall()
	StageMgr:chgStage("Hall", "Paodekuai")
end

--邀请好友
function prototype:uiEvtInviteFriend()
	local shareTable = {}
	shareTable.ShareType = "Text" --内容（文本：Text， 链接：Link, 图片：Image）
	shareTable.Scene = "SceneSession"  --分享类型（朋友圈：SceneTimeline， 好友：SceneSession）

	--字符串
	local roomInfo = self.modelData:getRoomInfo()
	local roomId = roomInfo.roomId
	local groupNum = roomInfo.groupNum
	local strCurrencyType = roomInfo.currencyType==Common_pb.Score and "计分" or "金币"
	-- local chip = self.chipRangeMsg
	-- local i, j = string.find(self.chipRangeMsg, "%d+")
	-- local chipNum = tonumber(string.sub(self.chipRangeMsg, i, j))
	-- local strPayType = roomInfo.scorePayType==Common_pb.RoomOwnner and "房主付费" or "AA付费"
	local strPayType = "房主付费"
	if roomInfo.clubId and roomInfo.clubId > 0 and roomInfo.currencyType==Common_pb.Gold then
		strPayType = "大赢家付费"
	end
	shareTable.Text = string.format("【跑得快-%d张-%04d-%d-%s(%s)-%s】(长按复制此消息后打开游戏)", 
									roomInfo.handCardCount, roomId, groupNum, strCurrencyType, self.chipRangeMsg, strPayType)
	-- log(shareTable.Text)

	local str = json.encode(shareTable)
	local isAccountLogin = Model:get("Account"):isAccountLogin()
	if isAccountLogin == true then
		util:setClipboardString(shareTable.Text)
	else
		util:fireCoreEvent(REFLECT_EVENT_WEIXIN_SHARE, 0, 0, str)	
	end
end

function prototype:uiEvtShowDistance()
	self.nodeDistance:showDistance("Games/Paodekuai")
end

--菜单
function prototype:onBtnMenuClick(sender)
	ui.mgr:open("Games/Common/MenuToolBarView", "Games/Paodekuai")
end
