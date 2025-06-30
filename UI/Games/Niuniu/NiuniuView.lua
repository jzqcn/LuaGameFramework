module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local MAXPLAYER = 5

local Common_pb = Common_pb

local DealerTypeName = {
	[1] = "自由抢庄",
	[2] = "拼十上庄",
	[3] = "固定庄家",
	[4] = "通比拼十",
	[5] = "明牌抢庄",
	[6] = "轮庄拼十",
}

function prototype:enter()
	self.winSize = cc.Director:getInstance():getWinSize()

	--UI事件
	self:bindUIEvent("Game.ChangeRoom", "uiEvtChangeRoom")
	self:bindUIEvent("Game.Ready", "uiEvtReady")
	self:bindUIEvent("Game.Start", "uiEvtStart")
	self:bindUIEvent("Game.Bet", "uiEvtBet")
	self:bindUIEvent("Game.Snatch", "uiEvtSnatch")
	self:bindUIEvent("Game.CalcResult", "uiEvtCalcResult")
	self:bindUIEvent("Game.Clock", "uiEvtClockFinish")
	-- self:bindUIEvent("Game.PlayerInfo", "uiEvtPlayerInfo")
	self:bindUIEvent("Game.CopyRoomId", "uiEvtCopyRoomId")
	self:bindUIEvent("Game.ReturnHall", "uiEvtReturnHall")
	self:bindUIEvent("Game.InviteFriend", "uiEvtInviteFriend")
	self:bindUIEvent("Game.Distance", "uiEvtShowDistance")

	--Model消息事件
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_ENTER_ROOM", "onPushRoomEnter")
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_USER_READY", "onPushUserReady")
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_MEMBER_STATUS", "onPushMemberStatus")
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_ROOM_STATE", "onPushRoomState")
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_ROOM_DRAW", "onPushRoomDraw")
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_USER_SNATCH", "onPushUserSnatch")
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_SNATCH_RESULT", "onPushSnatchResult")
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_ROOM_DEAL", "onPushRoomDeal")
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_OPEN_DEAL", "onPushOpenDeal")
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_OPEN_DEAL_RESULT", "onPushOpenDealResult")
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_SETTLEMENT", "onPushSettlement")
	self:bindModelEvent("Games/Niuniu.EVT.PUSH_MP_LAST_CARDS", "onPushMpLastCards")

	self:bindModelEvent("GamePerformance.EVT.PUSH_GAME_PERFORMANCE", "onPushGamePerformance")

	self.nodeBroadcast:setVisible(false)
	self.nodeRoomInfo:setVisible(false)
	self.nodeStart:setVisible(false)
	self.nodeInvite:setVisible(false)

	self.nodeMenu:setModelName("Games/Niuniu")

	self.modelData = Model:get("Games/Niuniu")
	self.nodeChat:setModelData(self.modelData)

	self.userId = Model:get("Account"):getUserId()

	self:onPushRoomEnter()

	sys.sound:playMusicByFile("resource/audio/Niuniu/bg_music.mp3")
end

function prototype:exit()
	local armatureDisplay = self.startAnimation
	if armatureDisplay then
		armatureDisplay:removeFromParent()
		armatureDisplay:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("NiuNiuStartAnimation")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("NiuNiuStartAnimation")
	end
end

function prototype:gameClear()
	for i = 1, MAXPLAYER do
		local name1 = "nodeRole_"..tostring(i)
		-- local name2 = "imgReady_"..tostring(i)
		self[name1]:setVisible(false)
		-- self[name2]:setVisible(false)

		-- self["fontBet_"..i]:setVisible(false)
	end

	self:clearPokerCards()

	self.nodeSnatch:setVisible(false)
	self.nodeSnatchMp:setVisible(false)
	self.nodeBetLayer:setVisible(false)

	self.nodeClock:setVisible(false)
	self.nodeReady:hide()
	self.nodeStart:setVisible(false)
end

function prototype:clearPlayerData(seatIndex, id)
	self["nodeRole_"..seatIndex]:setVisible(false)
	-- self["imgReady_"..seatIndex]:setVisible(false)

	self.modelData:removeMemberById(id)
end

function prototype:clearPokerCards(id)
	self.nodePokerView:clearCards(id)

	for i = 1, MAXPLAYER do
		local name = "nodeDealResult_"..tostring(i)
		if self[name] then
			self[name]:setVisible(false)
		end
	end
end

function prototype:onPushRoomEnter()
	-- self.gameState = NiuNiu_pb.State_Begin
	self:gameClear()
	
	self:onPushRoomInfo()
	self:onPushRoomState()
	self:onPushMemberStatus()

	--玩家处于围观，没有占座时，提示
	local userInfo = self.modelData:getUserInfo()
	if userInfo == nil and self.modelData:getRoomStyle() == Common_pb.RsCard then
		self.txtViewerTip:setVisible(true)
		self.txtViewerTip:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.8), cc.FadeIn:create(0.8))))
	else
		self.txtViewerTip:setVisible(false)
	end
end

function prototype:onPushRoomInfo()
	local roomInfo = self.modelData:getRoomInfo()
	-- self:updateRoomInfo()
	if roomInfo.roomStyle == Common_pb.RsGold then
		-- self.nodeChatToolbar:setVisible(false)
		self.nodeChatToolbar:setVoiceVisible(false)
	end
end

--（房卡场）更新房间信息 :房间ID、底分、玩法等
function prototype:updateRoomInfo()
	local roomInfo = self.modelData:getRoomInfo()
	self.roomStyle = roomInfo.roomStyle
	if self.roomStyle == Common_pb.RsCard then
		--房卡场
		local info = {}
		--房间号默认4位，位数不够前面补充0
		table.insert(info, string.format("房间:%04d", roomInfo.roomId))
		-- if roomInfo.currencyType == Common_pb.Score then
			--计分场需要局数
			table.insert(info, string.format("局数:%d/%d", roomInfo.currentGroup, roomInfo.groupNum))
		-- end
		--抢庄类型
		table.insert(info, string.format("%s", DealerTypeName[roomInfo.dealerType]))
		if roomInfo.dealerType == NiuNiu_pb.TBNN then
			--通比 不需要下注，默认底分
			if self.chipRangeMsg == nil then
				local data = db.mgr:getDB("NiuniuCardConfig", {typeId = roomInfo.typeId, currencyType = roomInfo.currencyType})
				if #data > 0 then
					local msg = data[1]["baseChipRange"]
					if msg then
						local showStrTable = string.split(msg, ";")
						if roomInfo.currencyType == Common_pb.Gold then
							self.chipRangeMsg = string.format("底注:%s", Assist.NumberFormat:amount2Hundred(showStrTable[roomInfo.baseChipRange+1]))
						else
							self.chipRangeMsg = string.format("底注:%s", showStrTable[roomInfo.baseChipRange+1])
						end

						table.insert(info, self.chipRangeMsg)
					end
				end
			else
				table.insert(info, self.chipRangeMsg)
			end
			-- table.insert(info, string.format("底分：%d", roomInfo.baseChipRange))
		else
			if self.chipRangeMsg == nil then
				--从配置表中读取显示
				local data = db.mgr:getDB("NiuniuCardConfig", {typeId = roomInfo.typeId, currencyType = roomInfo.currencyType})
				if #data > 0 then
					local msg = data[1]["C_chipRange"]
					if msg then
						local beignIndex, endIndex = string.find(msg,"|")
			           	local name = string.sub(msg, 1, beignIndex - 1)
			            local param = string.sub(msg, endIndex + 1, -1)
			            beignIndex, endIndex = string.find(param, "#")

			            local showStrTable = string.split(string.sub(param, 1, beignIndex - 1), ";")
			            self.chipRangeMsg = string.format("%s:%s", name, showStrTable[roomInfo.chipRange+1])
			            table.insert(info, self.chipRangeMsg)

			            --计分场下注范围（客户端读取）
			            self.scoreBetRange = string.split(showStrTable[roomInfo.chipRange+1], "/")
			        end
			    end
			else
				 table.insert(info, self.chipRangeMsg)
			end
		end

		self.nodeRoomInfo:setRoomInfo(info)
		self.nodeRoomInfo:setVisible(true)
	end
end

function prototype:onPushRoomState()
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo then
		local roomState = roomStateInfo.roomState
		local userInfo = self.modelData:getUserInfo()
		-- log("[NiuniuView::onPushRoomState::] roomState = "..roomState..", countDown = "..roomStateInfo.countDown)

		if roomState == NiuNiu_pb.State_Begin then
			self.nodeClock:setVisible(false)
			self.nodeBetLayer:setVisible(false)

			self:clearPokerCards()

			local menuLayer = ui.mgr:getLayer("Games/Common/MenuToolBarView")
			if menuLayer then
				menuLayer:refresh()
			end

			self:showSnatchState()

		elseif roomState == NiuNiu_pb.State_Ready then
			if roomStateInfo.countDown > 0 then
				self.nodeClock:start(roomStateInfo.countDown, "准备", 1.0)
			end

		elseif roomState == NiuNiu_pb.State_Snatch then
			local roomInfo = self.modelData:getRoomInfo()
			local delay = 0
			if roomInfo.dealerType ~= NiuNiu_pb.MPQZ then
				if self.modelData:getRoomStyle() == Common_pb.RsCard and self.modelData:getCurrencyType()==Common_pb.Score then
					--房卡计分模式
					if self.roomState and self.roomState < NiuNiu_pb.State_Snatch then
						delay = 1.0
						--开始动画
						-- ui.mgr:open("Games/Niuniu/StartView")
						self:playStartAnimation()
					end
				end
			end

			for i = 1, MAXPLAYER do
				self["nodeRole_"..i]:setReadyVisible(false)
			end
			self.nodeReady:hide()

			if userInfo ~= nil and userInfo.memStateInfo.isViewer == false then				
				if userInfo.memStateInfo.isRequestSnatch == false then					
					if roomInfo.dealerType == NiuNiu_pb.MPQZ then
						self.nodeSnatchMp:show(delay)
					else
						self.nodeSnatch:show(delay)
					end
				else
					self.nodeSnatchMp:hide()
					self.nodeSnatch:hide()
				end
				
				if userInfo.memStateInfo.isRequestSnatch then
					self.nodeClock:start(roomStateInfo.countDown, "抢庄", delay)
				else
					self.nodeClock:start(roomStateInfo.countDown, "", delay)
				end
			else
				self.nodeClock:start(roomStateInfo.countDown, "抢庄", delay)
			end

		elseif roomState == NiuNiu_pb.State_Bet then
			self.nodeReady:hide()
			self.nodeSnatchMp:hide()
			self.nodeSnatch:hide()
		elseif roomState == NiuNiu_pb.State_Deal then
			self.nodeBetLayer:setVisible(false)
			self.nodeSnatchMp:hide()
			self.nodeSnatch:hide()

			local delay = 0
			local roomInfo = self.modelData:getRoomInfo()
			if roomInfo.dealerType == NiuNiu_pb.TBNN or roomInfo.dealerType == NiuNiu_pb.MPQZ then
				if self.roomState and self.roomState < NiuNiu_pb.State_Deal then
					delay = 1.0
					--开始动画
					-- ui.mgr:open("Games/Niuniu/StartView")
					self:playStartAnimation()
				end
			end

			if roomInfo.dealerType ~= NiuNiu_pb.MPQZ then
				if not userInfo or userInfo.memStateInfo.isOpenDeal==true or userInfo.memStateInfo.isViewer then
					self.nodeClock:start(roomStateInfo.countDown, "摆牌", delay)
				else
					self.nodeClock:start(roomStateInfo.countDown, "", 1.0 + delay)
				end
			else
				--明牌牛牛先发牌，再抢庄
				self.nodeClock:stop()
			end

			for i = 1, MAXPLAYER do
				self["nodeRole_"..i]:setReadyVisible(false)
			end
			self.nodeReady:hide()

		elseif roomState == NiuNiu_pb.State_Open_Deal then
			self.nodeBetLayer:setVisible(false)
			self.nodeSnatchMp:hide()
			self.nodeSnatch:hide()

			--明牌抢庄， 摆牌
			local delay = 0
			if not userInfo or userInfo.memStateInfo.isOpenDeal==true or userInfo.memStateInfo.isViewer then
				self.nodeClock:start(roomStateInfo.countDown, "摆牌", delay)
			else
				self.nodeClock:start(roomStateInfo.countDown, "", 1.0 + delay)
			end

		elseif roomState == NiuNiu_pb.State_Settlement then
			self.nodeClock:stop()
			self.nodePokerView:hideCalcView()
		else

		end

		if userInfo ~= nil and userInfo.memStateInfo.isViewer == true and self.modelData:getRoomStyle() == Common_pb.RsGold then
			--旁观者可以换桌
			self.nodeReady:show(true, true)
		end

		self:updateRoomInfo()

		if userInfo then
			if roomState >= NiuNiu_pb.State_Snatch then
				self:visibleInviteNode(false)
			else
				self:visibleInviteNode(true)
			end
		else
			self.nodeInvite:setVisible(false)
		end

		--记录下roomState
		self.roomState = roomState
	else
		assert(false)
	end
end

--播放开始动画
function prototype:playStartAnimation()
	local size = self.panelPop:getContentSize()
	--[[local skeletonNode = self.panelPop:getChildByTag(100)
	if skeletonNode == nil then
		skeletonNode = sp.SkeletonAnimation:create("resource/csbimages/Games/Niuniu/Anim/NiuNiuStartAnimation.json", 
													"resource/csbimages/Games/Niuniu/Anim/NiuNiuStartAnimation.atlas")
		skeletonNode:setPosition(cc.p(size.width/2, size.height/2))
		self.panelPop:addChild(skeletonNode, 1, 100)

		--动作播放完成监听
		skeletonNode:registerSpineEventHandler(function (event)
			print(string.format("[spine] %d complete: %d", event.trackIndex, event.loopCount))
		  	skeletonNode:setVisible(false)

		end, sp.EventType.ANIMATION_COMPLETE)
	else
		skeletonNode:setVisible(true)
	end

	skeletonNode:setAnimation(0, "Animation1", false)--]]
	

	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Games/Niuniu/Anim/NiuNiuStartAnimation_ske.dbbin", "NiuNiuStartAnimation")
    factory:loadTextureAtlasData("resource/csbimages/Games/Niuniu/Anim/NiuNiuStartAnimation_tex.json", "NiuNiuStartAnimation")
    local armatureDisplay = self.startAnimation
    if armatureDisplay == nil then
		armatureDisplay = factory:buildArmatureDisplay("armatureName", "NiuNiuStartAnimation")

		--龙虎事件监听
		-- const char* EventObject::START = "start";
		-- const char* EventObject::LOOP_COMPLETE = "loopComplete";
		-- const char* EventObject::COMPLETE = "complete";
		-- const char* EventObject::FADE_IN = "fadeIn";
		-- const char* EventObject::FADE_IN_COMPLETE = "fadeInComplete";
		-- const char* EventObject::FADE_OUT = "fadeOut";
		-- const char* EventObject::FADE_OUT_COMPLETE = "fadeOutComplete";
		-- const char* EventObject::FRAME_EVENT = "frameEvent";
		-- const char* EventObject::SOUND_EVENT = "soundEvent";		
		local function eventCustomListener(event)
	        armatureDisplay:setVisible(false)
	    end

	    local listener = cc.EventListenerCustom:create("complete", eventCustomListener)

	    armatureDisplay:getEventDispatcher():setEnabled(true)
		armatureDisplay:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

		self.panelPop:addChild(armatureDisplay, 1, 100)

		self.startAnimation = armatureDisplay
	end

    if armatureDisplay then
    	armatureDisplay:setVisible(true)
	    armatureDisplay:getAnimation():play("Animation1", 1)
	    armatureDisplay:setPosition(size.width/2, size.height/2)
	    -- armatureDisplay:setScale(0.5)
	    -- armatureDisplay:setTag(100)

	    sys.sound:playEffectByFile("resource/audio/Niuniu/start.mp3")
	end
end

--游戏开始，扣除台费
function prototype:onPushRoomDraw()
	local roomInfo = self.modelData:getRoomInfo()
	if roomInfo.dealerType ~= NiuNiu_pb.TBNN and roomInfo.dealerType ~= NiuNiu_pb.MPQZ then
		--开始动画
		-- ui.mgr:open("Games/Niuniu/StartView")
		self:playStartAnimation()

		--通比牛牛不需要抢庄
		local delay = 1.0
		local userInfo = self.modelData:getUserInfo()
		if userInfo and userInfo.memStateInfo.isViewer == false and userInfo.memStateInfo.isRequestSnatch == false then
			if self.modelData:getRoomState() <= NiuNiu_pb.State_Snatch then
				self.nodeSnatch:show(delay)
			end
		else
			self.nodeSnatch:hide()
		end


		local roomStateInfo = self.modelData:getRoomStateInfo()
		self.nodeReady:hide()
		self.nodeClock:start(roomStateInfo.countDown, "", delay)

	elseif roomInfo.dealerType == NiuNiu_pb.MPQZ then
		local delay = 1.0
		local userInfo = self.modelData:getUserInfo()
		if userInfo and userInfo.memStateInfo.isViewer == false and userInfo.memStateInfo.isRequestSnatch == false then
			if self.modelData:getRoomState() <= NiuNiu_pb.State_Snatch then
				self.nodeSnatchMp:show()
			end
		else
			self.nodeSnatchMp:hide()
		end

		local roomStateInfo = self.modelData:getRoomStateInfo()
		self.nodeReady:hide()
		self.nodeClock:start(roomStateInfo.countDown, "", delay)
	end

	self:onPushMemberStatus()
end

function prototype:onPushMemberStatus(data)
	local roomMember = self.modelData:getRoomMember()
	local memsId = data or table.keys(roomMember)
	if memsId then
		local roomStateInfo = self.modelData:getRoomStateInfo()
		local roomState = roomStateInfo.roomState

		for i, id in ipairs(memsId) do
			local playerInfo = roomMember[id]
			if playerInfo then
				local seatIndex = self.modelData:getPlayerSeatIndex(id)
				if playerInfo.memberType ~= Common_pb.Leave then
					local memStateInfo = playerInfo.memStateInfo
					local headItemName = "nodeRole_"..seatIndex
					--加入房间或者更新玩家数据				
					self[headItemName]:setVisible(true)
					self[headItemName]:setHeadInfo(playerInfo, self.modelData:getCurrencyType())
					self:updatePlayerState(playerInfo)

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

function prototype:updatePlayerState(playerInfo)
	local id = playerInfo.playerId
	local seatIndex = self.modelData:getPlayerSeatIndex(id)
	local roomState = self.modelData:getRoomState()
	local memStateInfo = playerInfo.memStateInfo
	-- log("[NiuniuView::updatePlayerState] roomState == "..roomState..", playerId == "..id)
	if roomState==NiuNiu_pb.State_Begin or roomState==NiuNiu_pb.State_Ready then
		if id == self.userId then
			if memStateInfo.isViewer == true and self.roomStyle == Common_pb.RsGold then
				self.nodeReady:show(true)
			else
				self.nodeReady:show(memStateInfo.isReady, self.roomStyle == Common_pb.RsGold)
			end
		end

		self["nodeRole_"..seatIndex]:setReadyVisible(memStateInfo.isReady)
		self["nodeRole_"..seatIndex]:setBetVisible(false)
		-- self["imgReady_"..seatIndex]:setVisible(memStateInfo.isReady)
		-- self["fontBet_"..seatIndex]:setVisible(false)

		self:checkGameStart()
	else
		self["nodeRole_"..seatIndex]:setReadyVisible(false)
		-- self["imgReady_"..seatIndex]:setVisible(false)

		local roomInfo = self.modelData:getRoomInfo()
		if roomInfo.dealerType == NiuNiu_pb.MPQZ or roomState >= NiuNiu_pb.State_Deal then
			self:dealPokerCards(id, false)
		end

		if id == self.userId and roomInfo.dealerType == NiuNiu_pb.MPQZ and roomState == NiuNiu_pb.State_Open_Deal then
			if memStateInfo.isOpenDeal == false then
				self.nodePokerView:showCalcView()
			end
		end

		self.nodeStart:setVisible(false)

		if roomInfo.dealerType == NiuNiu_pb.MPQZ then
			if memStateInfo.isDealer then
				self:showSnatchState(seatIndex, true, memStateInfo.mutiple)
			end
		end
	end

	if roomState == NiuNiu_pb.State_Snatch then
		if memStateInfo.isRequestSnatch == true then
			self:showSnatchState(seatIndex, memStateInfo.isSnatch, memStateInfo.mutiple)
		end
	end
end

function prototype:showSnatchState(seatIndex, isSnatch, mutiple)
	seatIndex = seatIndex or -1
	mutiple = mutiple or 1
	if seatIndex > 0 and self.modelData:getRoomState() >= NiuNiu_pb.State_Snatch then
		local dealerType = self.modelData:getRoomInfo().dealerType
		local name = "imgSnatch_"..seatIndex
		local resName = "resource/csbimages/Games/Niuniu/snatch.png"
		if isSnatch == false then
			resName = "resource/csbimages/Games/Niuniu/unsnatch.png"
		else
			if dealerType == NiuNiu_pb.MPQZ then
				--明牌牛牛显示抢庄倍数
				resName = string.format("resource/csbimages/Games/Niuniu/snatch_%d.png", mutiple)
			end
		end
		if self[name] == nil then
			-- local x, y = self["imgReady_"..seatIndex]:getPosition()
			-- local pos = self["nodeRole_"..seatIndex]:getReadIconPos()
			local pos = self["nodeRole_"..seatIndex]:getHeadPos()
			if seatIndex == 2 or seatIndex == 3 then
				pos.x = pos.x - 90
			else
				pos.x = pos.x + 90
			end

			local sp = cc.Sprite:create(resName)
			sp:setPosition(pos)
			self.panelPop:addChild(sp)
			self[name] = sp
		else
			self[name]:setVisible(true)
			self[name]:setTexture(resName)
		end

		-- sys.sound:playEffect("SNATCH")
	else
		for index = 1, MAXPLAYER do
			if self["imgSnatch_"..index] then
				self["imgSnatch_"..index]:setVisible(false)
			end
		end
	end
end

--UI事件：准备按钮点击
function prototype:uiEvtReady(data)
	local roomInfo = self.modelData:getRoomInfo()
	local minCoin = roomInfo.minCoin
	local currencyType = roomInfo.currencyType
	local userInfo = Model:get("Account"):getUserInfo()

	self.modelData:requestReady()
	self.modelData:setMemberReadyState(true, userInfo.userId)

	if self.roomStyle == Common_pb.RsGold then
		self.nodeReady:show(true, true, 1)
	else
		self.nodeReady:hide()
	end
end

function prototype:onPushUserReady(isSuccess)
	local userInfo = self.modelData:getUserInfo()
	if userInfo == nil then
		return
	end

	local roomStateInfo = self.modelData:getRoomStateInfo()
	if isSuccess then		
		self.modelData:setMemberReadyState(true, userInfo.playerId)

		if roomStateInfo.roomState < NiuNiu_pb.State_Snatch then
			--无法保证消息顺序，可能发牌消息先发。
			local seatIndex = self.modelData:getPlayerSeatIndex(userInfo.playerId)
			-- self["imgReady_"..seatIndex]:setVisible(true)
			self["nodeRole_"..seatIndex]:setReadyVisible(true)
			if self.roomStyle == Common_pb.RsGold then
				self.nodeReady:show(true, true, 1)
			end

			self:checkGameStart()
		end
		-- sys.sound:playEffect("READY")
	else
		self.modelData:setMemberReadyState(false, userInfo.playerId)

		if roomStateInfo.roomState < NiuNiu_pb.State_Snatch then
			self.nodeReady:show(false, self.roomStyle == Common_pb.RsGold)
			self.nodeClock:start(roomStateInfo.countDown, "")
		end
	end
end

--检查房卡场（计分场）是否可以开始游戏 房主提前开始
function prototype:checkGameStart()
	if self.roomStyle == Common_pb.RsCard and self.modelData:isStarter() then
		local roomInfo = self.modelData:getRoomInfo()
		if roomInfo.currentGroup == 1 then
			--第一局需要点击开始，后续按正常流程自动开始
			local canStart = true
			local roomMember = self.modelData:getRoomMember()
			local maxNum = self.modelData:getMaxPlayerNum()
			local minNum = self.modelData:getMinPlayerNum()
			local memNum = table.nums(roomMember)
			if memNum >= minNum and memNum < maxNum then
				for _, v in pairs(roomMember) do
					if v.memStateInfo.isReady == false then
						canStart = false
						break
					end
				end
			else
				canStart = false
			end

			if canStart then
				util.timer:after(500, self:createEvent("timerGameStart", function()
					self.nodeStart:setVisible(true)
				end))				
			end
		else
			-- self.modelData:requestCommonMsg(NiuNiu_pb.Request_Start)
		end
	end
end

--是否显示邀请好友
function prototype:visibleInviteNode(visible)
	if self.modelData:getRoomStyle() == Common_pb.RsCard and visible then
		local roomMember = self.modelData:getRoomMember()
		local maxNum = self.modelData:getMaxPlayerNum()
		local memNum = table.nums(roomMember)
		if memNum < maxNum then
			self.nodeInvite:setVisible(true)
		else
			self.nodeInvite:setVisible(false)
		end

		local roomInfo = self.modelData:getRoomInfo()
		if roomInfo.currentGroup > 1 then
			self.nodeInvite:setReturnHallVisible(false)
		else
			self.nodeInvite:setReturnHallVisible(true)
		end

	else
		self.nodeInvite:setVisible(false)
	end
end

--房卡场人未满时，玩家都准备，房主可以提前开始游戏
function prototype:uiEvtStart()
	self.modelData:requestCommonMsg(NiuNiu_pb.Request_Start)
	self.nodeStart:setVisible(false)
end

--倒计时结束
function prototype:uiEvtClockFinish()
	self.nodeBetLayer:setVisible(false)
end

function prototype:uiEvtChangeRoom()
	Model:get("Games/Niuniu"):requestChangeRoom()
end

function prototype:uiEvtSnatch(isSnatch, mutiple)
	isSnatch = isSnatch or false
	mutiple = mutiple or 1

	self.modelData:requestSnatch(isSnatch, mutiple)

	local userInfo = self.modelData:getUserInfo()
	userInfo.memStateInfo.isRequestSnatch = true
	userInfo.memStateInfo.isSnatch = isSnatch
	userInfo.memStateInfo.mutiple = mutiple

	self.nodeClock:showMsg("抢庄", 1)
end

--抢庄返回
function prototype:onPushUserSnatch(isSuccess)
	local userInfo = self.modelData:getUserInfo()
	if isSuccess then
		self:showSnatchState(1, userInfo.memStateInfo.isSnatch, userInfo.memStateInfo.mutiple)
		-- self:onPushMemberStatus({userInfo.playerId})
	else
		userInfo.memStateInfo.isRequestSnatch = true
		userInfo.memStateInfo.isSnatch = false
	end
end

--推送抢庄结果(抢庄结束，进入下注阶段)
function prototype:onPushSnatchResult(data)
	self.nodeSnatch:hide()
	self.nodeSnatchMp:hide()
	self.nodeClock:stop()

	local dealerType = self.modelData:getRoomInfo().dealerType
	local roomMember = self.modelData:getRoomMember()
	local snatchTab = {}
	local maxMutiple = 1
	for id, v in pairs(roomMember) do
		local memInfo = v.memStateInfo
		if memInfo.isViewer == false then
			local seatIndex = self.modelData:getPlayerSeatIndex(id)
			if memInfo.isSnatch == true then
				snatchTab[#snatchTab + 1] = {id = id, mutiple = memInfo.mutiple}
				if memInfo.mutiple > maxMutiple then
					maxMutiple = memInfo.mutiple
				end
			end
			
			if dealerType == NiuNiu_pb.EverySnatch or dealerType == NiuNiu_pb.MPQZ then
				--可能部分部分玩家未抢庄。或者抢庄返回时，房间状态已经为下注阶段
				self:showSnatchState(seatIndex, memInfo.isSnatch, memInfo.mutiple)
			end
		end
	end

	local callback = function ()
		self:showSnatchResult(data)
	end

	local delay = 0
	
	if dealerType == NiuNiu_pb.MPQZ then
		for i = #snatchTab, 1, -1 do
			if snatchTab[i].mutiple < maxMutiple then
				table.remove(snatchTab, i)
			end
		end
	end

	local snatchNum = #snatchTab
	if snatchNum <= 1 then
		-- callback()
		delay = 0.5
		self.rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(callback)))
	else
		for i, v in ipairs(snatchTab) do
			local seatIndex = self.modelData:getPlayerSeatIndex(v.id)
			self:showPlayerFrameFlash(seatIndex, true)
		end

		delay = 1.0
		self.rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(callback)))
	end

	local roomStateInfo = self.modelData:getRoomStateInfo()
	local dealerId = self.modelData:getDealerId()
	if self.userId ~= dealerId then
		self.nodeClock:start(roomStateInfo.countDown, "", delay)
	else
		self.nodeClock:start(roomStateInfo.countDown, "下注", delay)
	end
end

--显示抢庄结果
function prototype:showSnatchResult(betRange)
	--隐藏抢庄状态
	self:showSnatchState()
	self:showPlayerFrameFlash()

	self:onPushMemberStatus()

	-- self.nodeSnatch:hide()
	-- self.nodeSnatchMp:hide()

	local dealerId = self.modelData:getDealerId()
	if self.userId ~= dealerId and self.modelData:isViewer() == false and self.modelData:getRoomState() < NiuNiu_pb.State_Deal then
		--闲家显示下注按钮
		local currencyType = self.modelData:getCurrencyType()
		if self.roomStyle == Common_pb.RsCard and currencyType==Common_pb.Score then
			self.nodeBetLayer:show(self.scoreBetRange, currencyType)
		else
			self.nodeBetLayer:show(betRange, currencyType)
		end
	end

	sys.sound:playEffect("CHOOSE_DEALER_END")
end

--演示抢庄动画
function prototype:showPlayerFrameFlash(seatIndex, var)	
	seatIndex = seatIndex or -1
	if seatIndex > 0 and seatIndex <= MAXPLAYER then		
		local name = "nodeRole_"..tostring(seatIndex)
		self[name]:flashHeadFrame2(var)
	else
		for i = 1, MAXPLAYER do
			local name = "nodeRole_"..tostring(i)			
			self[name]:flashHeadFrame2(false)
		end
	end
end

--下注
function prototype:uiEvtBet(betValue)
	betValue = betValue or 0
	if betValue >= 0 then
		local userInfo = self.modelData:getUserInfo()
		userInfo.memStateInfo.isBet = true
		userInfo.memStateInfo.betCoin = betValue
		self:updatePlayerState(userInfo)

		Model:get("Games/Niuniu"):requestBet(betValue)
	else
		log4ui:warn("[NiuniuView::uiEvtBet] bet value error ! value can't be less than 0")
	end

	self.nodeBetLayer:setVisible(false)
	self.nodeClock:showMsg("下注", 1)
end

--发牌
function prototype:onPushRoomDeal(data)
	self:onPushRoomState()

	self:clearPokerCards()

	local function dealPokerCallback()
		if self.modelData:getUserInfo() == nil then
			local roomMember = self.modelData:getRoomMember()
			local memsId = table.keys(roomMember)
			local playerInfo
			for i, id in ipairs(memsId) do
				playerInfo = roomMember[id]
				if playerInfo then
					playerInfo.memStateInfo.cards = {false, false, false, false, false}

					self:dealPokerCards(id, true)	
				end
			end
		else
			for i, id in ipairs(data) do
				--发牌动画
				self:dealPokerCards(id, true)
			end
		end

		sys.sound:playEffectByFile("resource/audio/Niuniu/deal.mp3")
	end

	local roomInfo = self.modelData:getRoomInfo()
	if roomInfo.dealerType == NiuNiu_pb.TBNN then
		local node = cc.Node:create()
		self.rootNode:addChild(node)
		node:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
			dealPokerCallback()
			node:removeFromParent(true)
		end)))
	else
		dealPokerCallback()
	end
end

--明牌抢庄发剩余牌
function prototype:onPushMpLastCards(cards)
	if self.modelData:getRoomInfo().dealerType ~= NiuNiu_pb.MPQZ then
		return
	end

	local roomMember = self.modelData:getRoomMember()
	local userInfo = roomMember[self.userId]
	local userCards = userInfo.memStateInfo.cards
	local leftNum = #cards
	local index = 0
	for i = 5 - leftNum + 1, 5 do
		local cardNode = self.nodePokerView:createPokerCard(self.userId, i)	
		if cardNode then
			cardNode:setCardInfo(self.userId, userCards[i])
			cardNode:runAction(cc.Sequence:create(
	            cc.DelayTime:create(index*0.1),
	            cc.ScaleTo:create(0.2, -0.8, 0.8),
	            cc.ScaleTo:create(0, 0.8, 0.8),
	            cc.CallFunc:create( function() cardNode:showCardValue() end)
	        ))
		end

		index = index + 1
	end

	
	-- for k, v in ipairs(roomMember) do
	-- 	self:dealPokerCards(k, true, #cards)
	-- end

	util.timer:after(500, self:createEvent("timerPushLastCards", function()
		self.nodePokerView:showCalcView()
	end))
end

function prototype:dealPokerCards(playerId, isAnimation)
	local roomMember = self.modelData:getRoomMember()
	local playerInfo = roomMember[playerId]
	if playerInfo == nil then
		log4ui:warn("[NiuniuView::dealPokerCards] error : get player info failed ! playerId : "..playerId)
		return
	end

	local seatIndex = self.modelData:getPlayerSeatIndex(playerId)
	local centerPos = cc.p(self.winSize.width/2, self.winSize.height/2)
	local memStateInfo = playerInfo.memStateInfo

	if memStateInfo.isViewer then
		return
	end

	--显示下注筹码
	if memStateInfo.isBet == true and memStateInfo.betCoin > 0 then
		self["nodeRole_"..seatIndex]:setBetValue(memStateInfo.betCoin, self.modelData:getCurrencyType())
	end

	local x, y = self["nodeDealResult_"..seatIndex]:getPosition()
	local cards = memStateInfo.cards

	-- log4ui:warn("dealPokerCards playerId == " .. playerId)

	if memStateInfo.isOpenDeal==true and memStateInfo.resultDesc>NiuNiu_pb.NiuNone and memStateInfo.resultDesc<=NiuNiu_pb.NiuNiu then
		--已开牌并且有牛时，判断前三张是否能组成牛，不能就重新排列
		local lave = 0
		local size = 0
		for i = 1, 3 do
	    	size = cards[i].size
	    	if size > 10 then
	    		size = 10
	    	end
	        lave = lave + size
	    end

	    if lave % 10 ~= 0 then
	    	cards = Logic:get("NiuniuLogic"):getNiuOrderGroup(cards)
	    end
	end

	-- log(cards)

	for i, v in ipairs(cards) do
		local v = cards[i]
		local cardNode = self.nodePokerView:createPokerCard(playerId, i)
		if cardNode then
			local scale = 0.8
			if playerId ~= self.userId then
				scale = 0.6
			else
				if memStateInfo.isOpenDeal then
					isAnimation = false
				end
			end

			local size = cc.size(cardNode:getContentSize().width*scale, cardNode:getContentSize().height*scale)
			local to
			if memStateInfo.isOpenDeal then
				--已经明牌
				to = self:getCardResultPos(seatIndex, i, size)

				if i > 3 then
					to.x = to.x + 25
				end
			else
				to = self:getCardDealPos(seatIndex, i, size)
			end

			-- log("playerId : " .. playerId .. ", isAnimation == " .. (isAnimation==true and 1 or 0))
			
			cardNode:setCardInfo(playerId, v)
			cardNode:runDealAction(centerPos, to, scale, (i-1)*0.1, isAnimation)
		else
			log4ui:warn("[NiuniuView::dealPokerCards] error : playerId:"..playerId..", card index:"..i)
		end
	end

	if isAnimation then
		self["nodeRole_"..seatIndex]:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function ()
				self:dealActionOver(playerId)
			end)))
	elseif memStateInfo.cardCount > 0 then
		self:dealActionOver(playerId)
	end
end

--发牌动画结束
function prototype:dealActionOver(playerId)
	local playerInfo = self.modelData:getMemberInfoById(playerId)
	if playerInfo then		
		local seatIndex = self.modelData:getPlayerSeatIndex(playerId)
		if playerInfo.memStateInfo.isOpenDeal == true then
			self["nodeDealResult_"..seatIndex]:show(playerInfo.memStateInfo.resultDesc)
		else
			if playerId == self.userId and self.modelData:getRoomState() >= NiuNiu_pb.State_Deal then
				local roomInfo = self.modelData:getRoomInfo()
				if roomInfo.dealerType ~= NiuNiu_pb.MPQZ then
					--非明牌牛牛，发牌之后展示摆牌操作框
					self.nodePokerView:showCalcView()
				end
			end
		end
	end
end

--摆牌操作
function prototype:uiEvtCalcResult(data)
	if data.isSuccess then
		self.modelData:requestOpenDeal(data.preCardInfo, data.lastCardInfo)
		self.nodeClock:showMsg("摆牌", 1)
	else
		self.nodeClock:showNotice(data.msg, 2)
	end
end

--摆牌结果
function prototype:onPushOpenDeal(isSuccess)
	if isSuccess then

	else
		self.nodePokerView:showCalcView()
	end
end

--明牌结果
function prototype:onPushOpenDealResult(data)
	for i, id in ipairs(data) do
		self:dealPokerCards(id, false)
	end
end

--结算
function prototype:onPushSettlement(data)
	self:onPushRoomState()

	local dealerId = self.modelData:getDealerId()
	local dealerIndex = self.modelData:getPlayerSeatIndex(dealerId)
	local dealerPos = self["nodeRole_"..dealerIndex]:getCoinPos()
	local currencyType = self.modelData:getCurrencyType()
	-- log("[NiuniuView::onPushSettlement] dealerId:"..dealerId..", dealerIndex:"..dealerIndex)

	for i, id in ipairs(data) do
		self:dealPokerCards(id, false)
	end

	local delay = 0.5
	local winNum = 0
	local settlementData = {}
	--飞金币动画
	--飞庄家赢
	for i, id in ipairs(data) do
		local playerInfo = self.modelData:getMemberInfoById(id)
		if playerInfo and playerInfo.memStateInfo.isSettlement == true then
			local seatIndex = self.modelData:getPlayerSeatIndex(id)
			if playerInfo.memStateInfo.result == false and playerInfo.memStateInfo.isDealer == false then					
				local from = self["nodeRole_"..seatIndex]:getCoinPos()
				Assist.FlyCoin:create(currencyType, from, dealerPos, 0.5, self.panelPop)
				delay = 1.5
				winNum = winNum + 1
			end

			--所有玩家输赢值
			settlementData[seatIndex] = playerInfo.memStateInfo.betResultCoin
		end
	end

	if winNum > 0 then
		local node = cc.Node:create()
		self.rootNode:addChild(node)
		node:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
			sys.sound:playEffect("COINS_FLY")
			-- log("########################## playEffect COINS_FLY 1")
			node:removeFromParent(true)
		end)))
	end

	local isKillAll = true
	--飞闲家赢
	for i, id in ipairs(data) do
		local playerInfo = self.modelData:getMemberInfoById(id)
		if playerInfo and playerInfo.memStateInfo.isSettlement == true then
			if playerInfo.memStateInfo.result == true and playerInfo.memStateInfo.isDealer == false then
				local seatIndex = self.modelData:getPlayerSeatIndex(id)
				local to = self["nodeRole_"..seatIndex]:getCoinPos()
				Assist.FlyCoin:create(currencyType, dealerPos, to, delay, self.panelPop)

				isKillAll = false
			end
		end
	end

	if isKillAll == false then
		local node = cc.Node:create()
		self.rootNode:addChild(node)
		node:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function()
			sys.sound:playEffect("COINS_FLY")
			-- log("########################## playEffect COINS_FLY 2")
			node:removeFromParent(true)
		end)))
	end

	local userInfo = self.modelData:getUserInfo()
	if userInfo then
		util.timer:after((delay + 1.0) * 1000, self:createEvent("SHOW_SETTLEMENT_VIEW", function()
			-- log("[NiuniuView::showSettlementView] userId == "..self.userId..", dealerId == "..dealerId)			
			for index, v in pairs(settlementData) do
				self["nodeRole_"..index]:runSettlementNumAction(v)
			end

			--通杀全场
			if isKillAll and self.userId == dealerId and winNum >= 2 then
				ui.mgr:open("Games/Niuniu/KillView")
			else
				--显示输赢动画
				if userInfo.memStateInfo.isSettlement == true then
					if userInfo.memStateInfo.result == true then
						ui.mgr:open("Games/Niuniu/WinView")
					else
						ui.mgr:open("Games/Niuniu/LoseView")
					end
				end
			end

		end))
	end
end

function prototype:onPushGamePerformance(info)
	local roomInfo = self.modelData:getRoomInfo()
	info.currencyType = roomInfo.currencyType
	info.strCurrencyType = roomInfo.currencyType==Common_pb.Score and "计分" or "金币"
	info.strCurrencyType = string.format("%s(%s)", info.strCurrencyType, self.chipRangeMsg)
	-- info.strPayType = roomInfo.scorePayType==Common_pb.RoomOwnner and "房主付费" or "AA付费"
	info.strPayType = "房主付费"
	ui.mgr:open("GameResult/GroupResultView", info)

	self.nodeRoomInfo:setVisible(false)
end

function prototype:getCardDealPos(seatIndex, index, size)
	local pos = cc.p(0, 0)
	if seatIndex == 1 then
		pos.x = 270 + size.width/2 + (index - 1) * 150
		pos.y = 15 + size.height/2
	elseif seatIndex == 2 then
		pos.x = 910 + size.width/2 + (index - 1)*30
		pos.y = 275 + size.height/2
	elseif seatIndex == 3 then
		pos.x = 820 + size.width/2 + (index - 1)*30
		pos.y = 495 + size.height/2
	elseif seatIndex == 4 then
		pos.x = 280 + size.width/2 + (index - 1)*30
		pos.y = 495 + size.height/2
	elseif seatIndex == 5 then
		pos.x = 215 + size.width/2 + (index - 1)*30
		pos.y = 275 + size.height/2
	end

	return pos
end

function prototype:getCardResultPos(seatIndex, index, size)
	local pos = cc.p(0, 0)
	if seatIndex == 1 then
		pos.x = 490 + size.width/2 + (index - 1) * 50
		pos.y = 75 + size.height/2
	elseif seatIndex == 2 then
		pos.x = 825 + size.width/2 + (index - 1)*45
		pos.y = 275 + size.height/2
	elseif seatIndex == 3 then
		pos.x = 735 + size.width/2 + (index - 1)*45
		pos.y = 495 + size.height/2
	elseif seatIndex == 4 then
		pos.x = 280 + size.width/2 + (index - 1)*45
		pos.y = 495 + size.height/2
	elseif seatIndex == 5 then
		pos.x = 215 + size.width/2 + (index - 1)*45
		pos.y = 275 + size.height/2
	end

	return pos
end

-- function prototype:uiEvtPlayerInfo(playerId)
-- 	local fromIndex = self.modelData:getPlayerSeatIndex(self.userId)	
-- 	local fromPos = self["nodeRole_"..fromIndex]:getHeadPos()
-- 	local toIndex = self.modelData:getPlayerSeatIndex(playerId)
-- 	local toPos = self["nodeRole_"..toIndex]:getHeadPos()

-- 	local playerInfo = self.modelData:getMemberInfoById(playerId)

-- 	ui.mgr:open("Games/Common/PlayerInfoView", {node=self.rootNode, info=playerInfo, from=fromPos, to=toPos})
-- end

function prototype:uiEvtCopyRoomId()
	local roomInfo = self.modelData:getRoomInfo()
	util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, string.format("%04d", roomInfo.roomId))
end

--返回大厅
function prototype:uiEvtReturnHall()
	StageMgr:chgStage("Hall", "Niuniu")
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
	local dealerType = DealerTypeName[roomInfo.dealerType]
	local strCurrencyType = roomInfo.currencyType==Common_pb.Score and "计分" or "金币"
	-- local strPayType = roomInfo.scorePayType==Common_pb.RoomOwnner and "房主付费" or "AA付费"
	local strPayType = "房主付费"
	if roomInfo.clubId and roomInfo.clubId > 0 and roomInfo.currencyType==Common_pb.Gold then
		strPayType = "大赢家付费"
	end
	shareTable.Text = string.format("【拼十-%s-%04d-%d-%s(%s)-%s】(长按复制此消息后打开游戏)", 
									dealerType, roomId, groupNum, strCurrencyType, self.chipRangeMsg, strPayType)

	local str = json.encode(shareTable)
	local isAccountLogin = Model:get("Account"):isAccountLogin()
	if isAccountLogin == true then
		util:setClipboardString(shareTable.Text)
	else
		util:fireCoreEvent(REFLECT_EVENT_WEIXIN_SHARE, 0, 0, str)	
	end
end

function prototype:uiEvtShowDistance()
	self.nodeDistance:showDistance("Games/Niuniu")
end

--菜单
function prototype:onBtnMenuClick(sender)
	ui.mgr:open("Games/Common/MenuToolBarView", "Games/Niuniu")
end


