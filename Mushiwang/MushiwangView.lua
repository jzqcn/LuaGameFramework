module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local MAXPLAYER = 8

local Common_pb = Common_pb


function prototype:enter()
	----log("MSV: enter")
	self.winSize = cc.Director:getInstance():getWinSize()
	self:bindUIEvent("Game.CuoCard", "uiEvtCuoCardOver")
	--UI事件
	self:bindUIEvent("Game.ChangeRoom", "uiEvtChangeRoom")
	self:bindUIEvent("Game.Ready", "uiEvtReady")
	self:bindUIEvent("Game.Start", "uiEvtStart")
	self:bindUIEvent("Game.Bet", "uiEvtBet")
	self:bindUIEvent("Game.Snatch", "uiEvtSnatch")
	self:bindUIEvent("Game.Clock", "uiEvtClockFinish")
	--self:bindUIEvent("Game.PlayerInfo", "uiEvtPlayerInfo")
	self:bindUIEvent("Game.CopyRoomId", "uiEvtCopyRoomId")
	self:bindUIEvent("Game.ReturnHall", "uiEvtReturnHall")
	self:bindUIEvent("Game.InviteFriend", "uiEvtInviteFriend")
	self:bindUIEvent("Game.Distance", "uiEvtShowDistance")

	--Model消息事件
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_ENTER_ROOM", "onPushRoomEnter")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_USER_READY", "onPushUserReady")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_MEMBER_STATUS", "onPushMemberStatus")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_ROOM_STATE", "onPushRoomState")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_ROOM_DRAW", "onPushRoomDraw")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_USER_SNATCH", "onPushUserSnatch")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_SNATCH_RESULT", "onPushSnatchResult")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_USER_BET", "onPushUserBet")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_BET_RESULT", "onPushBetResult")
	
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_DRAW_CARD", "onPushDrawCard")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_DRAW_CARD_RESULT", "onPushDrawCardResult")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_ROOM_DEAL", "onPushRoomDeal")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_OPEN_DEAL", "onPushOpenDeal")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_OPEN_DEAL_RESULT", "onPushOpenDealResult")
	self:bindModelEvent("Games/Mushiwang.EVT.PUSH_SETTLEMENT", "onPushSettlement")
	self:bindModelEvent("GamePerformance.EVT.PUSH_GAME_PERFORMANCE", "onPushGamePerformance")

	self.nodeBroadcast:setVisible(false)
	self.nodeRoomInfo:setVisible(false)
	self.nodeStart:setVisible(false)
	self.nodeInvite:setVisible(false)

	self.nodeMenu:setModelName("Games/Mushiwang")

	self.modelData = Model:get("Games/Mushiwang")
	self.nodeChat:setModelData(self.modelData)
	self.userId = Model:get("Account"):getUserId()
	self.pokerFirstPos={
		{265,7},
		{840,7},         
		{910,194},           
		{910,382},          
		{770,532},          
		{331,532},      
		{210,382},               
		{210,194}
		}
	self.pokerCards = {}
	self.sprDealResult={}
	self.betRange={}
	self.DrawCardFlag={}
	self.snatchFlag={}
	self.nodeBetLayer:setLocalZOrder(99)
	self.nodeChat:setLocalZOrder(99)
	sys.sound:playMusicByFile("resource/Mushiwang/audio/roomMusic.mp3")
	self:onPushRoomEnter()
end

function prototype:gameClear()
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	for i = 1, MAXPLAYER do
		local name1 = "nodeRole_"..tostring(i)
		self[name1]:setVisible(false)
	end
	self:clearPokerCards()
	self.nodeSnatchMp:setVisible(false)
	self.nodeBetLayer:setVisible(false)
	self.nodeClock:setVisible(false)
	self.nodeReady:hide()
	self.nodeStart:setVisible(false)
	if self.DrawCardFlag~=nil then
		for k,v in ipairs(self.DrawCardFlag)do
			v:setVisible(false)
		end
	end
	if self.snatchFlag~=nil then
		for k,v in ipairs(self.snatchFlag) do
				v:setVisible(false)
		end
	end
	if self.sprDealResult~=nil then
		for k,v in ipairs(self.sprDealResult) do
			v[1]:setVisible(false)
			v[2]:setVisible(false)
	end
	end
end

function prototype:clearPlayerData(seatIndex, id)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	self["nodeRole_"..seatIndex]:setVisible(false)
	self.modelData:removeMemberById(id)
end

function prototype:clearPokerCards(id)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	self:clearCards(id)
	--[[for i = 1, MAXPLAYER do
		local name = "nodeDealResult_"..tostring(i)
		if self[name] then
			self[name]:setVisible(false)
		end
	end]]
end

function prototype:onPushRoomEnter()--qqqqqqqqqqqqqqqqqqqq
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	self.gameState = MuShiWang_pb.State_Begin
	self:gameClear()
	self.betRange=self.modelData.betRange
	self.pokerCards={}
	self:onPushRoomInfo()
	self:onPushRoomState()
	self:onPushMemberStatus()
	local RoomState = self.modelData:getRoomState()
    local RoomMember = self.modelData:getRoomMember()
	local playerInfo = RoomMember[self.userId]
	local memStateInfo=nil
	if playerInfo~=nil then
		memStateInfo = playerInfo.memStateInfo
		self.txtViewerTip:setVisible(false)
	else
		self.txtViewerTip:setVisible(true)
		self.txtViewerTip:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.8), cc.FadeIn:create(0.8))))
	end
    if RoomState == MuShiWang_pb.State_Begin then
        --log('RBegin =========== restart')
        if memStateInfo~=nil and memStateInfo.isViewer == false and self.roomStyle == Common_pb.RsCard then
            self:checkGameStart()
		end
	elseif RoomState == MuShiWang_pb.State_Ready then
		--log('Ready ========= restart')
	elseif RoomState == MuShiWang_pb.State_Snatch then--抢庄
		--log("Snatch =========== restart")
		for id,v in pairs(RoomMember)do
			local memStateInfo=v.memStateInfo
			local seat=self.modelData:getPlayerSeatIndex(id)
			if 	memStateInfo.isRequestSnatch==true then
				self:showSnatchState(seat,memStateInfo.isSnatch, memStateInfo.mutiple)
			end
		end
	elseif RoomState == MuShiWang_pb.State_Deal then--发牌
		--log('Deal ========= restart')
	elseif RoomState == MuShiWang_pb.State_Bet then--下注
		--log('Bet ========= restart')	
		--dump(self.betRange,"self.betRange")
		for id,v in pairs(RoomMember)do
			local memStateInfo=v.memStateInfo
			if memStateInfo.isViewer==false then 
				self:dealPokerCards(id, false)
				if id==self.userId then
					if self.pokerCards[id][2]~=nil then
						self.pokerCards[id][2]:hideCardValue()
					end
				end
				local seat=self.modelData:getPlayerSeatIndex(id)
				if 	memStateInfo.isBet == true then
					if id==self.userId then
						self.pokerCards[id][2]:showCardValue()
						self.nodeBetLayer:setVisible(false)
					end
					self:onPushBetResult()
				end
				if 	memStateInfo.isDealer == true then
					if id==self.userId then
						self.nodeBetLayer:setVisible(false)
					end
					self:showSnatchState(seat,true, memStateInfo.mutiple)
				end
			end
		end
	elseif RoomState == MuShiWang_pb.State_Draw then--补牌
		--log('Draw ========= restart')
		for id,v in pairs(RoomMember)do
			local memStateInfo=v.memStateInfo
			if memStateInfo.isViewer==false then
				local seat=self.modelData:getPlayerSeatIndex(id)
				self:dealPokerCards(id, false)
				for k1,v1 in ipairs(self.pokerCards[id])do
					if id~=self.userId then
						v1:hideCardValue()
					end
				end
				if memStateInfo.isDrawed== true then
					self:createDrawCard(id)
					self:DrawCardFlagHelp(id,seat,true)
					if id==self.userId then
						self.pokerCards[id][3]:hideCardValue()
					end
				end
				local x,y=self.pokerCards[id][1]:getPosition()
				local sprDrawCardFlag=string.format("seatPokerDraw_%d",seat)
				local sprNoDrawCardFlag=string.format("seatPokerNoDraw_%d",seat)
				if self[sprDrawCardFlag]~=nil then
					self[sprDrawCardFlag]:setPosition(cc.p(x+20,y-40))
				end
				if self[sprNoDrawCardFlag]~=nil then
					self[sprNoDrawCardFlag]:setPosition(cc.p(x+20,y-40))
				end
				----log("id: "..self.userId)
				--dump(memStateInfo,"memStateInfo",5)		
				if 	memStateInfo.isDealer == true then
					self:showSnatchState(seat,true, memStateInfo.mutiple)
				end
			end
		end
		self:onPushBetResult()
	elseif RoomState == MuShiWang_pb.State_Open_Deal then
		--log('Open Deal========= restart')
		for id,v in pairs(RoomMember)do
			local memStateInfo=v.memStateInfo
			if memStateInfo.isViewer==false then
				local seat=self.modelData:getPlayerSeatIndex(id)
				if memStateInfo.isOpenDeal==false then
					self:dealPokerCards(id, false)
					for k1,v1 in ipairs(self.pokerCards[id])do
						if id~=self.userId then
							v1:hideCardValue()
						end
					end
					if memStateInfo.isDrawed== true then
						if id==self.userId then
							self.pokerCards[id][3]:hideCardValue()
						end
						self:DrawCardFlagHelp(id,seat,true)
					else
						self:DrawCardFlagHelp(id,seat,false)
					end 
				else
					self:openDealHelp(id)
				end
				if 	memStateInfo.isDealer == true then
					self:showSnatchState(seat,true, memStateInfo.mutiple)
				end
			end
		end
		self:onPushBetResult()
    elseif RoomState == MuShiWang_pb.State_Settlement then
		--log('Settlement========= restart')
		self:saveMemberInfo()
		ui.mgr:open('Mushiwang/ResultView', self.TempMemberInfo)
	end
end

function prototype:onPushRoomInfo()
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
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
end

--（房卡场）更新房间信息 :房间ID、底分、玩法等
function prototype:updateRoomInfo()
	--local tnlog=debug.getinfo(1,'n');--log("MSV: "..tnlog["name"])
	local roomInfo = self.modelData:getRoomInfo()
	self.roomStyle = roomInfo.roomStyle
	if self.roomStyle == Common_pb.RsCard then
		--房卡场
		local info = {}
		--房间号默认4位，位数不够前面补充0
		--log("===========================stopSoS==============================================")
		table.insert(info, string.format("房间:%04d", roomInfo.roomId))
		table.insert(info, string.format("局数:%d/%d", roomInfo.currentGroup, roomInfo.groupNum))
		table.insert(info, string.format("鬼牌数:%d",roomInfo.evilNum+2))--传的下标
		table.insert(info, string.format("人数:%d",roomInfo.maxPlayerNum))
		local strCurrencyType=""
		if roomInfo.clubId~=0 then
			strCurrencyType=" 俱乐部"
		else
			strCurrencyType=" 房卡场"
		end
		table.insert(info,strCurrencyType)
		self.nodeRoomInfo:setRoomInfo(info)
		self.nodeRoomInfo:setVisible(true)
	end
end

function prototype:onPushRoomState()--rrrrrrrrrrrrrrrrrrrrrrrrrrr
	--log("MSV: onPushRoomState")
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if roomStateInfo then
		local roomState = roomStateInfo.roomState
		local userInfo = self.modelData:getUserInfo()
		local memStateInfo=nil
		if userInfo~=nil then
			memStateInfo=userInfo.memStateInfo
		end
		--log("self:id "..self.userId)
		--dump(roomStateInfo,"roomStateInfo")
		if roomState == MuShiWang_pb.State_Begin then
			--log("---State_Begin")
			self.nodeClock:setVisible(false)
			self:visibleInviteNode(true)
			local menuLayer = ui.mgr:getLayer("Games/Common/MenuToolBarView")
			if menuLayer then
				menuLayer:refresh()
			end
			if self.roomStyle == Common_pb.RsCard then
				self:updateRoomInfo()
			end
		elseif roomState == MuShiWang_pb.State_Ready then
			--log("---State_Ready")
			if roomStateInfo.countDown > 0 then
				self.nodeClock:start(roomStateInfo.countDown, "准备", 1.0)
			end
			self:visibleInviteNode(true)
		elseif roomState == MuShiWang_pb.State_Snatch then--抢庄
			--log("---State_Snatch")
			self:visibleInviteNode(false)
			for i = 1, MAXPLAYER do
				self["nodeRole_"..i]:setReadyVisible(false)
			end
			self.nodeReady:hide()
			if roomStateInfo.countDown > 0 then
				self.nodeClock:start(roomStateInfo.countDown, "抢庄", 0)
			end
			if memStateInfo~=nil and memStateInfo.isViewer == false and memStateInfo.isRequestSnatch == false then
				sys.sound:playEffectByFile("resource/Mushiwang/audio/kaiju.mp3")				
				self.nodeSnatchMp:show()	
			end
		elseif roomState == MuShiWang_pb.State_Deal then
			--log("---State_Deal")

		elseif roomState == MuShiWang_pb.State_Bet then
			--log("---State_Bet")
			if roomStateInfo.countDown > 0 then
				self.nodeClock:start(roomStateInfo.countDown, "下注", 0)
			end
			self.nodeSnatchMp:setVisible(false)
			if memStateInfo~=nil then
				if  memStateInfo.isViewer == true or memStateInfo.isDealer== true then  --自己庄家不能下注,进入补牌阶段--补牌
				else
					sys.sound:playEffectByFile("resource/Mushiwang/audio/Dice_xiazhu.mp3")
					self.nodeBetLayer:show(self.betRange)
				end
			end
		elseif roomState == MuShiWang_pb.State_Draw then--补牌
			--log("---State_Draw")
			self.nodeBetLayer:setVisible(false)
			if roomStateInfo.countDown > 0 then
				self.nodeClock:start(roomStateInfo.countDown, "补牌", 0)
			end
			--log(memStateInfo)
			if memStateInfo~=nil and memStateInfo.isViewer == false and memStateInfo.isDraw==false then
				self:seeDrawCardBtn(true,true)
				local jokerNum=0
				--log(memStateInfo)
				self:dealPokerCards(self.userId, false)
				for k1,v1 in ipairs(memStateInfo.cards) do
					if v1~=false then
						if v1.size==0 or v1.size==14 then
							jokerNum=jokerNum+1
						end
					end
				end
				if jokerNum==1 then
					self.btnNoDrawCard:setVisible(false)
				elseif jokerNum==2 then
					self.btnDrawCard:setVisible(false)
				end
			end	
		elseif roomState == MuShiWang_pb.State_Open_Deal then
			--log("---State_Open_deal")
			if roomStateInfo.countDown > 0 then
				self.nodeClock:start(roomStateInfo.countDown, "亮牌", 0)	
			end
			if memStateInfo~=nil and memStateInfo.isViewer == false and memStateInfo.isOpenDeal==false then
				if memStateInfo.cardCount==3 then
					self:seeRubCardBtn(true,true,false)
					if self.pokerCards[self.userId][3]==nil then --有一张鬼牌,而又没有主动点补牌,自动补一张牌
						self:dealPokerCards(self.userId, false)
						self.pokerCards[self.userId][3]:hideCardValue()
					end

				else
					self:seeRubCardBtn(false,false,true)
				end
			end
			self.alreadyPlay={}
		elseif roomState == MuShiWang_pb.State_Settlement then
			--log("---State_Settlement")
			--[[if roomStateInfo.countDown > 0 then
				self.nodeClock:start(roomStateInfo.countDown, "结算", 0)
			end]]
			self.nodeClock:stop()
			if self.roomStyle == Common_pb.RsCard then
				self:updateRoomInfo()
			end
		end

		if memStateInfo~=nil and memStateInfo.isViewer == true and self.modelData:getRoomStyle() == Common_pb.RsGold then
			--旁观者可以换桌
			self.nodeReady:show(true, true)
		end
		--记录下roomState
		self.roomState = roomState
	else
		assert(false)
	end
end

--游戏开始，扣除台费
function prototype:onPushRoomDraw()
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	--log("MSV1: onPushRoomDraw coin")
	local roomStateInfo = self.modelData:getRoomStateInfo()
	self:onPushRoomState()
	self:onPushMemberStatus()
end

function prototype:onPushMemberStatus(data)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	--log("MSV1: onPushMemberStatus")
	local roomMember = self.modelData:getRoomMember()
	--dump(roomMember,"roomMember",5)
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
					self[headItemName]:setVisible(true)
					self[headItemName]:setHeadInfo(playerInfo, self.modelData:getCurrencyType())
					self:updatePlayerState(playerInfo)
					if playerInfo.memberType == Common_pb.Add then
						sys.sound:playEffect("ENTER")
					end
				else--离开房间
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

function prototype:updatePlayerState(playerInfo)--ppppppppppppppppp
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	local id = playerInfo.playerId
	local seatIndex = self.modelData:getPlayerSeatIndex(id)
	local roomState = self.modelData:getRoomState()
	local memStateInfo = playerInfo.memStateInfo
	if roomState==nil then return end
	--log("=================player roomState == "..roomState)
	--log("playerId == "..id)
	if roomState==MuShiWang_pb.State_Begin then
		--log("---State_State_Begin")
		if id == self.userId then
			if memStateInfo.isViewer == true and self.roomStyle == Common_pb.RsGold then
				self.nodeReady:show(memStateInfo.isReady, true)
				--log("nodeReady=================")
			else
				if memStateInfo.isViewer ~= true then
					self.nodeReady:show(memStateInfo.isReady, self.roomStyle == Common_pb.RsGold)
				else
					self.nodeReady:show(true, self.roomStyle == Common_pb.RsGold)--完全隐藏
				end
				--log("nodeReady=================")
			end
		end

		self["nodeRole_"..seatIndex]:setReadyVisible(memStateInfo.isReady)

		if self.roomStyle == Common_pb.RsCard and self.modelData:isStarter() then
			self:checkGameStart()
		end
	elseif roomState==MuShiWang_pb.State_Ready then
		--log("---State_State_Ready")
		self["nodeRole_"..seatIndex]:setReadyVisible(false)

	elseif roomState == MuShiWang_pb.State_Snatch then--抢庄
		--log("---State_State_Snatch")
		--dump(memStateInfo,"memStateInfo",5)
		if memStateInfo.isRequestSnatch==true and id ~= self.userId then
			self:showSnatchState(seatIndex, memStateInfo.isSnatch,memStateInfo.mutiple)
		end
		
	elseif roomState == MuShiWang_pb.State_Deal then--发牌
		--log("---State_State_Deal")
		

	elseif roomState == MuShiWang_pb.State_Bet then--下注
		--log("---State_State_Bet")

	elseif roomState == MuShiWang_pb.State_Draw then--补牌
		--log("---State_State_Draw")
		if memStateInfo.isDraw==true then			
			if memStateInfo.isDrawed==true then
				self:createDrawCard(id)
				self:DrawCardFlagHelp(id,seatIndex,true)
				----log("draw card")
			else
				self:DrawCardFlagHelp(id,seatIndex,false)
				--log("pass card")
			end
		else	
		end
		--
		
	elseif roomState == MuShiWang_pb.State_Open_Deal then--开牌
		--log("---State_State_Open_Deal")
		
	elseif roomState == MuShiWang_pb.State_Settlement then
		--log("---State_Settlement")
	end
end

function prototype:showSnatchState(seatIndex, isSnatch, mutiple)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	seatIndex = seatIndex or -1
	mutiple = mutiple or 0
	if self.snatchFlag==nil then
		self.snatchFlag={}
	end
	if seatIndex > 0 and self.modelData:getRoomState() >= MuShiWang_pb.State_Snatch then
		local name ="imgSnatch_"..seatIndex
		local resName = "resource/Mushiwang/csbimages/snatch.png"
		if isSnatch == false then
			resName = "resource/Mushiwang/csbimages/unsnatch.png"
		else
			resName = "resource/Mushiwang/csbimages/snatch.png"
		end
		if self[name] == nil then
			local pos = self["nodeRole_"..seatIndex]:getHeadPos()
			if seatIndex == 2 or seatIndex == 3 or seatIndex == 4 or seatIndex == 5 then
				pos.x = pos.x - 90
			else
				pos.x = pos.x + 90
			end
			pos.y=pos.y-15
			local sp = cc.Sprite:create(resName)
			sp:setPosition(pos)
			self.panelPop:addChild(sp)
			self[name] = sp
			table.insert( self.snatchFlag,self[name])
		else
			self[name]:setVisible(true)
			self[name]:setTexture(resName)
		end
		 sys.sound:playEffect("SNATCH")

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
	--log("MSV1: uiEvtReady")
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
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	--log("MSV1: onPushUserReady")
	local userInfo = self.modelData:getUserInfo()
	if userInfo == nil then
		return
	end
	local roomStateInfo = self.modelData:getRoomStateInfo()
	if isSuccess then		
		self.modelData:setMemberReadyState(true, userInfo.playerId)
		if roomStateInfo.roomState < MuShiWang_pb.State_Snatch then
			--无法保证消息顺序，可能抢庄消息先发。
			local seatIndex = self.modelData:getPlayerSeatIndex(userInfo.playerId)
			self["nodeRole_"..seatIndex]:setReadyVisible(true)
			if self.roomStyle == Common_pb.RsGold then
				self.nodeReady:show(true, true, 1)
			end
			if self.roomStyle == Common_pb.RsCard and self.modelData:isStarter() then
				self:checkGameStart()
			end
		end
		sys.sound:playEffect("READY")
	else
		self.modelData:setMemberReadyState(false, userInfo.playerId)
		if roomStateInfo.roomState < MuShiWang_pb.State_Snatch then
			self.nodeReady:show(false, self.roomStyle == Common_pb.RsGold)
			self.nodeClock:start(roomStateInfo.countDown, "准备")
			
		end
	end
end

--检查房卡场（计分场）是否可以开始游戏 房主提前开始
function prototype:checkGameStart()
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
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
				util.timer:after(450, self:createEvent("timerGameStart", function()
					self.nodeStart:setVisible(true)
				end))				
			end
		else
			-- self.modelData:requestCommonMsg(MuShiWang_pb.Request_Start)
		end
	end
end

--是否显示邀请好友
function prototype:visibleInviteNode(visible)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
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
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	self.modelData:requestCommonMsg(MuShiWang_pb.Request_Start)
	self.nodeStart:setVisible(false)
end

--倒计时结束
function prototype:uiEvtClockFinish()
	--log("MSV1: uiEvtClockFinish")
end

function prototype:uiEvtChangeRoom()
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	Model:get("Games/Mushiwang"):requestChangeRoom()
end

function prototype:uiEvtSnatch(isSnatch, mutiple)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	--log("MSV1: uiEvtSnatch")
	isSnatch = isSnatch or false
	mutiple = mutiple or 0
	--dump(isSnatch,"isSnatch")
	--dump(mutiple,"mutiple")
	self.modelData:requestSnatch(isSnatch, mutiple)
	--log("self Snatch result: "..tostring(isSnatch).." mutiple "..mutiple)
	local userInfo = self.modelData:getUserInfo()
	userInfo.memStateInfo.isRequestSnatch = true
	userInfo.memStateInfo.isSnatch = isSnatch
	userInfo.memStateInfo.mutiple = mutiple
	--self.nodeClock:showMsg("抢庄", 1)
	self.nodeSnatchMp:hide()
	
end

--抢庄返回
function prototype:onPushUserSnatch(isSuccess)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	--log("MSV1: onPushUserSnatch")
	local userInfo = self.modelData:getUserInfo()
	if isSuccess then
		local RoomState = self.modelData:getRoomState()
		if RoomState == MuShiWang_pb.State_Snatch then--抢庄
			self:showSnatchState(1, userInfo.memStateInfo.isSnatch, userInfo.memStateInfo.mutiple)
		end
	else
		userInfo.memStateInfo.isRequestSnatch = true
		userInfo.memStateInfo.isSnatch = false
		self.nodeSnatchMp:show()
	end
end

--推送抢庄结果(抢庄结束，进入发牌阶段)
function prototype:onPushSnatchResult(data)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	--log("MSV1: onPushSnatchResult")
	self.nodeSnatchMp:hide()
	self.betRange=nil
	if data ~=nil then 
		self.betRange=data 
	end
	local roomMember = self.modelData:getRoomMember()
	local snatchTab = {}
	local maxMutiple = 0
	for id, v in pairs(roomMember) do
		local memInfo = v.memStateInfo
		--dump(memInfo,"memInfo",5)
		if memInfo.isViewer == false then
			local seatIndex = self.modelData:getPlayerSeatIndex(id)
			self:showSnatchState(seatIndex, memInfo.isSnatch, memInfo.mutiple)
			if memInfo.isSnatch==true then
				maxMutiple = 1
				snatchTab[#snatchTab + 1] = {id = id, mutiple =1}
			else
				snatchTab[#snatchTab + 1] = {id = id, mutiple = 0}
			end
		end
	end
	--只在最大抢庄玩家之间闪动头像
	--dump(snatchTab,"snatchTab1")
	for i=#snatchTab,1,-1 do
		if snatchTab[i].mutiple ~= maxMutiple then
			table.remove(snatchTab,i)
		end
	end
	--dump(snatchTab,"snatchTab2")
	
	local callback = function ()
		self:showSnatchResult()
	end
	local delay = 1
	if #snatchTab > 1 then
		for i, v in ipairs(snatchTab) do
			local seatIndex = self.modelData:getPlayerSeatIndex(v.id)
			self:showPlayerFrameFlash(seatIndex, true)
		end
		self.rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(callback)))
	else
		callback()
	end
end

--显示抢庄结果
function prototype:showSnatchResult()
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	--隐藏抢庄状态
	self:showPlayerFrameFlash()
	local roomMember = self.modelData:getRoomMember()
	for id,v in pairs(roomMember)do
		local index=self.modelData:getPlayerSeatIndex(id)
		if index==nil then return end
		if v.memStateInfo.isDealer==false  then
		else
			--都不抢自动庄家
			if v.memStateInfo.isSnatch==false then
				self:showSnatchState(index, true,1)
			end
		end
		if self["imgSnatch_"..index]~=nil then--没抢庄时为空
			self["imgSnatch_"..index]:setVisible(false)
		end
	end
	self:onPushMemberStatus()--庄家头像显示
end

--演示抢庄动画
function prototype:showPlayerFrameFlash(seatIndex, var)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
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

--发牌
function prototype:onPushRoomDeal(data)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	--log("MSV1: onPushRoomDeal===============================")
	self.firstDeal=true
	--不占座围观状态，发牌的时候都是背面的
	local roomMember = self.modelData:getRoomMember()
	if roomMember[self.userId]==nil then
		for id,v in pairs(roomMember) do
			v.memStateInfo.cards = {false, false}
			self:dealPokerCards(id, true)
		end
	end
	--log(roomMember)
	local node = cc.Node:create()
	self.rootNode:addChild(node)
	node:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
		for i, id in ipairs(data) do--发牌动画
			self:dealPokerCards(id, true)
		end
		node:removeFromParent(true)
	end)))
	sys.sound:playEffectByFile("resource/audio/MuShiWang/deal.mp3")
end
function prototype:dealPokerCards(playerId, isAnimation)--fffffffffffffffffffffffffff
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	self:clearPokerCards(playerId)
	local roomMember = self.modelData:getRoomMember()
	local playerInfo = roomMember[playerId]
	--dump(playerInfo,"playerInfo",5)
	if playerInfo == nil then
		log4ui:warn("[MSV::dealPokerCards] error : get player info failed ! playerId : "..playerId)
		return
	end

	local seatIndex = self.modelData:getPlayerSeatIndex(playerId)
	local centerPos = cc.p(self.winSize.width/2, self.winSize.height/2)
	local memStateInfo = playerInfo.memStateInfo
	if memStateInfo.isViewer==true then
		return
	end

	local cards =memStateInfo.cards
	for i, v in ipairs(cards) do
		local cardNode = self:createPokerCard(playerId, i)
		if cardNode then
			local scale = 0.6
			local size = cc.size(cardNode:getContentSize().width*scale, cardNode:getContentSize().height*scale)
			local to= self:getCardDealPos(seatIndex, i, size)
			if i==2  and playerId== self.userId and self.firstDeal==true then
				v=false
				self.firstDeal=false
			end
			cardNode:setCardInfo(playerId, v)
			cardNode:runDealAction(centerPos, to, scale, (i-1)*0.1, isAnimation)
			--木虱王直到补牌时才显示第二张牌q
		else
			log4ui:warn("[MSWView::dealPokerCards] error : playerId:"..playerId..", card index:"..i)
		end
	end

	--[[if isAnimation then
		self["nodeRole_"..seatIndex]:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()self:dealActionOver(playerId)
			end)))
	elseif memStateInfo.cardCount > 0 then
		self:dealActionOver(playerId)
	end]]
end

--发牌动画结束
function prototype:dealActionOver(playerId)
	----local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	--
	--[[local playerInfo = self.modelData:getMemberInfoById(playerId)
	if playerInfo then		
		local seatIndex = self.modelData:getPlayerSeatIndex(playerId)
		if playerInfo.memStateInfo.isOpenDeal == true then
			self["nodeDealResult_"..seatIndex]:show(playerInfo.memStateInfo.resultDesc)
		else
			--self.nodePokerView:showCalcView()--下注框
		end			
	end]]
end

--下注
function prototype:uiEvtBet(betValue)
	--log("MSV:uiEvtBet")
	--dump(betValue,"betValue")
	betValue = betValue or 0
	if betValue >= 0 then
		local userInfo = self.modelData:getUserInfo()
		userInfo.memStateInfo.isBet = true
		userInfo.memStateInfo.betCoin = betValue
		self:updatePlayerState(userInfo)
		Model:get("Games/Mushiwang"):requestBet(betValue)
	else
		error("[MSV:View::uiEvtBet] bet value error ! value can't be less than 0")
	end
	self.nodeBetLayer:setVisible(false)
end
function prototype:onPushUserBet(data)--所有人推这里
	--log("MSV1: onPushUserBet")
	self:onPushBetResult()
	if data.isSuccess==true then
		sys.sound:playEffectByFile("resource/Mushiwang/audio/snatch.mp3")
		self.nodeBetLayer:setVisible(false)
	else
		--重新下注
		self.nodeBetLayer:show(self.betRange)
		--local dataTable={content=data.tips,okFunc=nil}
		--ui.mgr:open("Dialog/ConfirmView",dataTable)
	end
end
function prototype:onPushBetResult()--显示下注筹码
	--log("MSV1:onPushBetResult")
	local roomMember = self.modelData:getRoomMember()
	for id,v in pairs(roomMember) do
		local memStateInfo=v.memStateInfo
		local seatIndex=self.modelData:getPlayerSeatIndex(id)
		if memStateInfo.isBet == true and memStateInfo.betCoin > 0 then
			self["nodeRole_"..seatIndex]:setBetValue(memStateInfo.betCoin)
			self["nodeRole_"..seatIndex]:setBetVisible(true)
		else
			--self["nodeRole_"..seatIndex]:setBetVisible(false)
		end
		--dump(memStateInfo.cards,"memStateInfo.cards",5)
	end
end

function prototype:seeDrawCardBtn(visible1,visible2)
	--log("MSV1: seeDrawCardBtn")
	self.btnDrawCard:setVisible(visible1)
	self.btnNoDrawCard:setVisible(visible2)
end
function prototype:uiEvtDrawCard()
	--log("MSV1: uiEvtDrawCard")
	Model:get("Games/Mushiwang"):requestDrawCard(true)
	self.drawCard=true
	self:seeDrawCardBtn(false,false)
end
function prototype:uiEvtNoDrawCard()
	--log("MSV1: uiEvtNoDrawCard")
	Model:get("Games/Mushiwang"):requestDrawCard(false)
	self.noDrawCard=true
	self:seeDrawCardBtn(false,false)
end
function prototype:createDrawCard(id)
	local cardNode = self:createPokerCard(id,3)
	if cardNode then
		local scale = 0.6
		local size = cc.size(cardNode:getContentSize().width*scale, cardNode:getContentSize().height*scale)
		local seatIndex = self.modelData:getPlayerSeatIndex(id)
		local to= self:getCardDealPos(seatIndex,3, size)
		cardNode:setCardInfo(id,false)
		cardNode:runDealAction(to, to, scale, 0, false)
	end
end
function prototype:onPushDrawCard(data)
	--log("MSV1: onPushDrawCard")
	if data.isSuccess==true then
		--log("Draw Card isSuccess")
		local playerInfo = self.modelData:getMemberInfoById(self.userId)
		local memStateInfo=playerInfo.memStateInfo
		if self.drawCard==true then	
			self:dealPokerCards(self.userId, false)		
			if self.pokerCards[self.userId][3]==nil then
				self:createDrawCard(self.userId)
			else
				self.pokerCards[self.userId][3]:hideCardValue()
			end  
		end
		if self.noDrawCard==true then	
			--log("pass card")
		end
		self.drawCard=false
		self.noDrawCard=false
	else
		self:seeDrawCardBtn(true,true)
		self.drawCard=false
		self.noDrawCard=false
		--local dataTable={content=data.tips,okFunc=nil}
		--ui.mgr:open("Dialog/ConfirmView",dataTable)
	end
end

function prototype:onPushDrawCardResult(data)
	--log("MSV1: onPushDrawCardResult")
	self:seeDrawCardBtn(false,false)
end
function prototype:DrawCardFlagHelp(id,seatIndex,isDrawCard)
	if id==self.userId then return end
	if self.DrawCardFlag==nil then self.DrawCardFlag={} end
	if self.pokerCards[id]==nil then return end
	local x,y=self.pokerCards[id][1]:getPosition()
	local resName=nil
	local sprResult=nil
	if isDrawCard==true then
		resName="resource/Mushiwang/csbimages/sprPokerDraw.png"
		sprResult=string.format("seatPokerDraw_%d",seatIndex)
	else
		resName="resource/Mushiwang/csbimages/sprPokerNoDraw.png"
		sprResult=string.format("seatPokerNoDraw_%d",seatIndex)
	end
	if self[sprResult]==nil then
		local sp=cc.Sprite:create(resName)
		self.panelPop:addChild(sp)
		if isDrawCard==true then
			sp:setPosition(cc.p(x+45,y-40))
		else
			sp:setPosition(cc.p(x+23,y-40))
		end
		sp:setLocalZOrder(10)
		--sp:setGlobalZOrder(10)
		self[sprResult]= sp
		table.insert(self.DrawCardFlag,self[sprResult])
	else
		--self[sprResult]:setTexture(resName)
		self[sprResult]:setVisible(true)
	end
end
--搓牌
function prototype:uiEvtNoRubCard()
	--log("MSV1:uiEvtNoRubCard")
	local function godHelpSelf()
		local colorJ=self.pokerCards[self.userId][3]:getCardColor()
		local sizeJ=self.pokerCards[self.userId][3]:getCardSize()
		local data={}
		data.color=colorJ
		data.size=sizeJ
		data.needCuoCard=true
		ui.mgr:open('Mushiwang/GameCuoCardLayer',data)
	end

	if self.pokerCards[self.userId][3]~=nil then
		local colorJ=self.pokerCards[self.userId][3]:getCardColor()
		local sizeJ=self.pokerCards[self.userId][3]:getCardSize()
		if  sizeJ~=nil and  colorJ ~=nil then
			--log("test1")
			godHelpSelf()
		else
			--log("test2")
			self:dealPokerCards(self.userId,false)
			if self.pokerCards[self.userId][3]~=nil then
				self.pokerCards[self.userId][3]:hideCardValue()
			end
			godHelpSelf()
		end
	end
	self:seeRubCardBtn(false,false,false)
end
--搓完牌后,回调
function prototype:uiEvtCuoCardOver()
	--log("MSV: uiEvtCuoCardOver")
	--log("self id"..self.userId)
	if self.pokerCards[self.userId][3]~=nil then
		if self.pokerCards[self.userId][3]:getCardSize() ~=nil then
			self.pokerCards[self.userId][3]:showCardValue()
		else
			self:dealPokerCards(self.userId,false)
		end
	end
	self:seeRubCardBtn(false,false,true)
end
--翻牌
function prototype:uiEvtRubCard()
	self:uiEvtCuoCardOver()
	--log("MSV1:uiEvtRubCard")
	--[[local function godHelpSelf()
		local colorJ=self.pokerCards[self.userId][3]:getCardColor()
		local sizeJ=self.pokerCards[self.userId][3]:getCardSize()	
		local data={}
		data.color=colorJ
		data.size=sizeJ
		data.needCuoCard=false
		--log("color "..colorJ.."size "..sizeJ)
		ui.mgr:open('Mushiwang/GameCuoCardLayer',data)
	end]]

	--[[if self.pokerCards[self.userId][3]~=nil then
		local colorJ=self.pokerCards[self.userId][3]:getCardColor()
		local sizeJ=self.pokerCards[self.userId][3]:getCardSize()
		if  sizeJ~=nil and  colorJ ~=nil then
			--log("test1")
			godHelpSelf()
		else
			--log("test2")
			self:dealPokerCards(self.userId,false)
			if self.pokerCards[self.userId][3]~=nil then
				self.pokerCards[self.userId][3]:hideCardValue()
			end
			--godHelpSelf()
		end
	end
	self:seeRubCardBtn(false,false,true)]]
end

function prototype:uiEvtOpenDealCard()
	--log("MSV1:uiEvtOpenDealCard")
	self.modelData:requestOpenDeal()
end
function prototype:seeRubCardBtn(visible1,visible2,visible3)
	--log("MSV1:seeRubCardBtn")
	self.btnRubCard:setVisible(visible1)
	self.btnNoRubCard:setVisible(visible2)
	self.btnOpenDealCard:setVisible(visible3)
end
function prototype:openDealHelp(id,setMusic)
	--log("MSV1:openDealHelp")
	self:dealPokerCards(id, false)
	if self.sprDealResult==nil then
		self.sprDealResult={}
	end
	local seatResult=self.modelData:getPlayerSeatIndex(id)
	local playerInfo=self.modelData:getMemberInfoById(id)
	local resultDesc=playerInfo.memStateInfo.resultDesc
	local mutiple=playerInfo.memStateInfo.mutiple
	local x,y=self.pokerCards[id][1]:getPosition()
	for k,v in ipairs(self.pokerCards[id]) do
		if v~=nil then
			v:setPositionY(y+18)
		end
	end
	local resName=nil
	local resMutipleName=nil
	local sprResult=nil
	local musicName=nil
	if  resultDesc ~=nil then
		--log("id: "..id.." resultDesc: "..resultDesc.."seatResult: "..seatResult)
		resName=string.format( "resource/Mushiwang/csbimages/pokeType_%d.png",resultDesc)
		sprResult=string.format("seatPokeType_%d",seatResult)
		musicName=string.format("point_%d.mp3",resultDesc)
	end
	if  mutiple ~=nil then
		if resultDesc>=10 then
			resMutipleName=string.format( "resource/Mushiwang/csbimages/mumType_%d.png",mutiple)
			--dump(mutiple,"mutiple")
		else
			resMutipleName=string.format( "resource/Mushiwang/csbimages/mum2Type_%d.png",mutiple)
			--dump(mutiple,"22222mutiple")
		end
	end
	if self[sprResult]==nil then
		local sp=cc.Sprite:create(resName)
		self.panelPop:addChild(sp)
		sp:setAnchorPoint(0,0.5)
		sp:setPosition(cc.p(x-50,y))
		sp:setLocalZOrder(10)

		local smp=cc.Sprite:create(resMutipleName)
		self.panelPop:addChild(smp)
		smp:setAnchorPoint(0,0.5)
		smp:setPosition(cc.p(x+30,y))
		smp:setLocalZOrder(10)
		local allSpr={}
		table.insert(allSpr,sp)
		table.insert(allSpr,smp)
		self[sprResult]= allSpr
		table.insert(self.sprDealResult,self[sprResult])
	else
		local allSpr=self[sprResult]
		if allSpr~=nil then
			allSpr[1]:setTexture(resName)
			allSpr[2]:setTexture(resMutipleName)
			allSpr[1]:setVisible(true)
			allSpr[2]:setVisible(true)
		end
	end
	local allSpr=self[sprResult]
	if resultDesc==0 then --木虱没有倍数
		if allSpr~=nil then
			allSpr[2]:setVisible(false)
		end
	end
	if resultDesc<12 then --从设位置
		allSpr[2]:setPosition(cc.p(x+30,y))
	else
		allSpr[2]:setPosition(cc.p(x+60,y))
	end
	--最终定位
	allSpr[1]:setPositionY(y-28)
	allSpr[2]:setPositionY(y-28)
	if resultDesc ~=nil and setMusic==true then
		sys.sound:playEffectByFile("resource/MuShiWang/audio/msw/"..musicName)
	end
end
--摆牌结果--openCard
function prototype:onPushOpenDeal(data)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	if data.isSuccess then
		self:seeRubCardBtn(false,false,false)
	else
		--self:seeRubCardBtn(false,false,true)
		--local dataTable={content=data.tips,okFunc=nil}
		--ui.mgr:open("Dialog/ConfirmView",dataTable)
	end
end

--明牌结果
function prototype:onPushOpenDealResult()
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	--log("MSV1:onPushOpenDealResult")
	local roomMember = self.modelData:getRoomMember()
	for id,v in pairs(roomMember) do
		--dump( memStateInfo," memStateInfo",5)
		local canPlay=true
		for k1,v1 in pairs(self.alreadyPlay)do
			if v1==id then
				canPlay=false
			end
		end
		local memStateInfo=v.memStateInfo
		if  memStateInfo.isViewer==false and memStateInfo.isOpenDeal==true and canPlay==true then 
			self:openDealHelp(id,true)
			table.insert(self.alreadyPlay,id)
			local seatIndex=self.modelData:getPlayerSeatIndex(id)
			local sprDrawCardFlag=string.format("seatPokerDraw_%d",seatIndex)
			local sprNoDrawCardFlag=string.format("seatPokerNoDraw_%d",seatIndex)
			if self[sprDrawCardFlag]~=nil then 
				self[sprDrawCardFlag]:setVisible(false)
			else
				--log(sprDrawCardFlag)
			end
			if self[sprNoDrawCardFlag]~=nil then 
				self[sprNoDrawCardFlag]:setVisible(false)
			else
				--log(sprNoDrawCardFlag)
			end
		end
	end
end

--结算
function prototype:onPushSettlement(data)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	--log("MSV1:onPushSettlement")
	self:seeRubCardBtn(false,false,false)
	ui.mgr:close('Mushiwang/GameCuoCardLayer')
	self:onPushRoomState()
	local dealerId = self.modelData:getDealerId()
	local dealerIndex = self.modelData:getPlayerSeatIndex(dealerId)
	local dealerPos = self["nodeRole_"..dealerIndex]:getCoinPos()
	local currencyType = self.modelData:getCurrencyType()
	self:saveMemberInfo()
	--清理没清理的补牌标志
	if self.DrawCardFlag~=nil then
		for k,v in ipairs(self.DrawCardFlag) do
			v:setVisible(false)
		end
	end
	if self.snatchFlag~=nil then
		for k,v in ipairs(self.snatchFlag) do
			v:setVisible(false)
		end
	end
	for i,id in ipairs(data) do
		local canPlayMusic=true
			if self.alreadyPlay~= nil then
				for k,v in ipairs(self.alreadyPlay) do
					if id==v then
						canPlayMusic=false
					end
				end
			end
		if canPlayMusic==true then
			self:openDealHelp(id,true)
		end
	end
	local delay = 0.5
	local winNum = 0
	local settlementData = {}
	--输的人
	for i, id in ipairs(data) do
		local playerInfo = self.modelData:getMemberInfoById(id)
		if playerInfo and playerInfo.memStateInfo.isSettlement == true then
			local seatIndex = self.modelData:getPlayerSeatIndex(id)
			if playerInfo.memStateInfo.result == false and playerInfo.memStateInfo.isDealer == false then				
				local from = self["nodeRole_"..seatIndex]:getCoinPos()
				Assist.FlyCoin:create(currencyType, from, dealerPos, delay, self.panelPop)
				winNum = winNum + 1
			end
			settlementData[seatIndex] = playerInfo.memStateInfo.betResultCoin
		end
	end

	if winNum > 0 then
		local node = cc.Node:create()
		self.rootNode:addChild(node)
		node:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
			--sys.sound:playEffect("COINS_FLY")
			sys.sound:playEffectByFile("resource/MuShiWang/audio/feijinbi.mp3")
			node:removeFromParent(true)
		end)))
	end
	delay = 1
	--赢家
	for i, id in ipairs(data) do
		local playerInfo = self.modelData:getMemberInfoById(id)
		if playerInfo and playerInfo.memStateInfo.isSettlement == true then
			if playerInfo.memStateInfo.result == true and playerInfo.memStateInfo.isDealer == false then
				local seatIndex = self.modelData:getPlayerSeatIndex(id)
				local to = self["nodeRole_"..seatIndex]:getCoinPos()
				Assist.FlyCoin:create(currencyType, dealerPos, to, delay, self.panelPop)
			end
		end
	end


	local node = cc.Node:create()
	self.rootNode:addChild(node)
	node:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function()
		--sys.sound:playEffect("COINS_FLY")
		sys.sound:playEffectByFile("resource/MuShiWang/audio/feijinbi.mp3")
		node:removeFromParent(true)
	end)))


	local userInfo = self.modelData:getUserInfo()
	local roomStateInfo = self.modelData:getRoomStateInfo()
	util.timer:after((delay + 1) * 1000, function()
		for index, v in pairs(settlementData) do
			if self["nodeRole_"..index]~=nil then
				self["nodeRole_"..index]:runSettlementNumAction(v)
			end
		end
	end)
	util.timer:after((delay + 2) * 1000, function()
		self:clearAllThings()
		ui.mgr:open('Mushiwang/ResultView', self.TempMemberInfo)
	end)
	
end
function prototype:BeginSettleClear()

end
function prototype:clearAllThings()
	self.alreadyPlay=nil
	self:seeRubCardBtn(false,false,false)
	self:showSnatchState()
	self:clearPokerCards()
	local roomMember = self.modelData:getRoomMember()
	for k,v in pairs(roomMember) do
		local memStateInfo=v.memStateInfo
		local seatIndex=self.modelData:getPlayerSeatIndex(k)
		self["nodeRole_"..seatIndex]:setBetVisible(false)
	end
	for k,v in ipairs(self.sprDealResult) do
		v[1]:setVisible(false)
		v[2]:setVisible(false)
	end
end
function prototype:saveMemberInfo()
	--log("MSV1: saveMemberInfo")
	self.TempMemberInfo = {}
	local memInfo=self.modelData:getRoomMember()
	self.TempMemberInfo = table.clone(memInfo)
end
--显示总结算（单局结算关闭之后显示）
function prototype:showGroupResultView()
	if self.groupPerformance then
		ui.mgr:open("GameResult/GroupResultView", self.groupPerformance)
	end
end

function prototype:clearCards(id)
	if self.pokerCards==nil then return end
	if id ~= nil then
		local cards = self.pokerCards[id]
		if cards then
			for i, card in ipairs(cards) do
				card:removeFromParent(true)
			end
		end

		self.pokerCards[id] = nil
	else
		for k, v in pairs(self.pokerCards) do
			for i, card in ipairs(v) do
				card:removeFromParent(true)
			end
		end
		self.pokerCards = {}
	end
end

function prototype:removeCard(cardNode)
	cardNode:removeFromParent(true)
end

function prototype:createPokerCard(id, index)
	if self.pokerCards[id] == nil then
		self.pokerCards[id] = {}
	end

	local playerCards = self.pokerCards[id]
	local cardNode = playerCards[index]
	if cardNode == nil then
		cardNode = self:getLoader():loadAsLayer("Games/Common/GamePokerCard")
		self.panelPop:addChild(cardNode, index)
		table.insert(self.pokerCards[id], cardNode)
		cardNode:setCardIndex(index)
	end
	return cardNode
end



function prototype:onPushGamePerformance(info)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	local roomInfo = self.modelData:getRoomInfo()
	local strCurrencyType=""
	if roomInfo.clubId~=0 then
		strCurrencyType=" 俱乐部"
	else
		strCurrencyType=" 房卡场"
	end
	info.strCurrencyType =strCurrencyType
	info.strPayType = "大赢家付费"
	self.groupPerformance = info
	ui.mgr:open("GameResult/GroupResultView", info)
	self.nodeRoomInfo:setVisible(false)
end

function prototype:getCardDealPos(seatIndex, index, size)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	local pos = cc.p(0, 0)
	--local nodeName=string.format("nodeDealResult_%d",seatIndex)
	--local nodex,nodey=self[nodeName]:getPosition()
	local tempPos=self.pokerFirstPos[seatIndex]
	local nodex=tempPos[1]
	local nodey=tempPos[2]
	if seatIndex == 1 then
		pos.x = nodex + size.width/2 + (index - 1) *45
		pos.y = nodey + size.height/2
	elseif seatIndex == 2 then
		pos.x = nodex + size.width/2 + (index - 1)*45
		pos.y = nodey + size.height/2
	elseif seatIndex == 3 then
		pos.x = nodex + size.width/2 + (index - 1)*45
		pos.y = nodey + size.height/2
	elseif seatIndex == 4 then
		pos.x = nodex + size.width/2 + (index - 1)*45
		pos.y = nodey + size.height/2
	elseif seatIndex == 5 then
		pos.x = nodex + size.width/2 + (index - 1)*45
		pos.y = nodey + size.height/2
	elseif seatIndex == 6 then
		pos.x = nodex + size.width/2 + (index - 1)*45
		pos.y = nodey + size.height/2
	elseif seatIndex == 7 then
		pos.x = nodex + size.width/2 + (index - 1)*45
		pos.y = nodey + size.height/2
	elseif seatIndex == 8 then
		pos.x = nodex + size.width/2 + (index - 1)*45
		pos.y = nodey + size.height/2
	end
	return pos
end

function prototype:uiEvtCopyRoomId()
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	local roomInfo = self.modelData:getRoomInfo()
	util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, string.format("%04d", roomInfo.roomId))
end

--返回大厅
function prototype:uiEvtReturnHall()
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	StageMgr:chgStage("Hall", "Mushiwang")
end

--邀请好友
function prototype:uiEvtInviteFriend()
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	local shareTable = {}
	shareTable.ShareType = "Text" --内容（文本：Text， 链接：Link, 图片：Image）
	shareTable.Scene = "SceneSession"  --分享类型（朋友圈：SceneTimeline， 好友：SceneSession）

	--字符串

	local roomInfo = self.modelData:getRoomInfo()
	local roomId = roomInfo.roomId
	
	local strCurrencyType ="" 
	if roomInfo.clubId~=0 then 
		strCurrencyType="俱乐部"
	else
		strCurrencyType="房卡场"
	end
	local groupNum = string.format("局数%d",roomInfo.groupNum)
	local evilNum= string.format("鬼牌数%d",roomInfo.evilNum+2)
	local maxPlayerNum=string.format("人数%d",roomInfo.maxPlayerNum)
	shareTable.Text = string.format("【至尊木虱-%s-%04d-%s-%s-%s】(长按复制此消息后打开游戏)", strCurrencyType,roomId, groupNum,maxPlayerNum,evilNum)
	--local dataTable={content=shareTable.Text,okFunc=nil}
	--ui.mgr:open("Dialog/ConfirmView",dataTable)
	local str = json.encode(shareTable)
	local isAccountLogin = Model:get("Account"):isAccountLogin()
	if isAccountLogin == true then
		util:setClipboardString(shareTable.Text)
	else
		util:fireCoreEvent(REFLECT_EVENT_WEIXIN_SHARE, 0, 0, str)	
	end
end

function prototype:uiEvtShowDistance()
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	self.nodeDistance:showDistance("Games/Mushiwang")
end

--菜单
function prototype:onBtnMenuClick(sender)
	--local tnlog=debug.getinfo(1,'n');log("MSV: "..tnlog["name"])
	ui.mgr:open("Games/Common/MenuToolBarView", "Games/Mushiwang")
end


		