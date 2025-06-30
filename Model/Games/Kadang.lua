local GameBase = require "Games.Base"
require "Protol.KaDang_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_ENTER_ROOM",
	"PUSH_USER_READY",
	"PUSH_MEMBER_STATUS",
	"PUSH_ROOM_STATE",
	"PUSH_ROOM_DEAL",
	"PUSH_READY_BET",
	"PUSH_REQUEST_BET",
	"PUSH_ROOM_SETTLEMENT"
}

class = GameBase.class:subclass()

local KaDang_pb = KaDang_pb

function class:initialize()
	super.initialize(self)

	net.msg:on(MsgDef_pb.MSG_KADANG, self:createEvent("onKadangResponse"))
end

--请求加入房间
function class:requestEnterRoom(playId, typeId, roomStyle)
	local gameRequest = KaDang_pb.KaDangRequest()
	gameRequest.requestType = KaDang_pb.Request_Enter
	gameRequest.room.playId = playId
	gameRequest.room.typeId = typeId
	gameRequest.room.roomStyle = roomStyle

	net.msg:send(MsgDef_pb.MSG_KADANG, gameRequest:SerializeToString())
end

--准备
function class:requestReady()
	local gameRequest = KaDang_pb.KaDangRequest()
	gameRequest.requestType = KaDang_pb.Request_Ready
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId

	net.msg:send(MsgDef_pb.MSG_KADANG, gameRequest:SerializeToString())
end

--请求下注
function class:requestBet(betValue)
	local gameRequest = KaDang_pb.KaDangRequest()
	gameRequest.requestType = KaDang_pb.Request_Bet
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId

	if betValue == 0 then
		gameRequest.betRequest.isBet = false
	else
		gameRequest.betRequest.isBet = true
	end
	gameRequest.betRequest.betCoin = tostring(betValue)

	net.msg:send(MsgDef_pb.MSG_KADANG, gameRequest:SerializeToString())
end

--请求离开房间
function class:requestLeaveGame()
	local gameRequest = KaDang_pb.KaDangRequest()
	gameRequest.requestType = KaDang_pb.Request_Leave
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId

	net.msg:send(MsgDef_pb.MSG_KADANG, gameRequest:SerializeToString())
end

--请求换桌
function class:requestChangeRoom()
	local gameRequest = KaDang_pb.KaDangRequest()
	gameRequest.requestType = KaDang_pb.Request_Change
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId

	net.msg:send(MsgDef_pb.MSG_KADANG, gameRequest:SerializeToString())
end

function class:onKadangResponse(data)
	local response = KaDang_pb.KaDangResponse()
	response:ParseFromString(data)
	if response.requestType == nil then
		log4model:error("[Kadang::onKadangResponse] requestType is nil !!!!")
		return
	end
	
	log("Kadang::onKadangResponse:: response type:"..response.requestType)
	if response.isSuccess == true then
		-- if not StageMgr:isStage("Kadang") and response.requestType ~= KaDang_pb.Request_Enter then
		-- 	log4model:warn("[KaDang::onKadangResponse] game stage is not Kadang ! requestType == "..response.requestType)
		-- 	return
		-- end

		if response.requestType == KaDang_pb.Request_Enter then
			--进入房间
			self:clear()

			local initInfo = response.initInfo
			self:parseRoomInfo(initInfo.info)

			self:parseRoomMember(initInfo.rmem)

			self:parseRoomStateInfo(initInfo.state)

			local userId = Model:get("Account"):getUserId()
			--先初始化自己的座位下标（自己坐正面）
			self:initUserSeatIndex(userId, self.memberMap[userId].seatId)
			--初始化其他玩家座位下标
			self:initOtherSeatIndex()

			-- ui.mgr:close("Hall/GameHall")
			-- ui.mgr:open("Games/Kadang/KadangView")
			if not StageMgr:isStage("Game") then
				StageMgr:chgStage("Game", "Kadang")
			else
				self:fireEvent(EVT.PUSH_ENTER_ROOM)
			end

		elseif response.requestType == KaDang_pb.Request_Ready then
			--Request_Ready = 2;		//准备 		返回:批量推送玩家信息KaDangPushBatchMemberStatus
			self:fireEvent(EVT.PUSH_USER_READY, response.isSuccess)

		elseif response.requestType == KaDang_pb.Request_Deal then
			--Request_Deal = 3;		//发牌 	扣除台费和底注 	返回：房间状态KaDangPushStatus，批量推送玩家信息KaDangPushBatchMemberStatus
			local roomStateInfo = response.roomState
			local memStatus = response.batchMemberStatus
			self:parseRoomStateInfo(roomStateInfo.state)

			local memData = self:parseRoomMember(memStatus.roomMem)

			self:fireEvent(EVT.PUSH_ROOM_DEAL, memData)

		elseif response.requestType == KaDang_pb.Request_Bet then
			--Request_Bet = 4;		//下注 	返回下注结果 	返回：房间状态KaDangPushStatus，批量推送玩家信息KaDangPushBatchMemberStatus


		elseif response.requestType == KaDang_pb.Push_Settlement then
			--Push_Settlement = 5; 	//推送结算结果	 返回：房间状态KaDangPushStatus，批量推送玩家信息KaDangPushBatchMemberStatus
			local roomStateInfo = response.roomState
			self:parseRoomStateInfo(roomStateInfo.state)

			local memStatus = response.batchMemberStatus
			local memData = self:parseRoomMember(memStatus.roomMem)
			self:fireEvent(EVT.PUSH_ROOM_SETTLEMENT, memData)

		elseif response.requestType == KaDang_pb.Push_State then
			--Push_State = 6;			//推送房间状态
			local roomStateInfo = response.roomState
			self:parseRoomStateInfo(roomStateInfo.state)
			self:fireEvent(EVT.PUSH_ROOM_STATE)

		elseif response.requestType == KaDang_pb.Push_BetResult then
			--Push_BetResult = 7;		//推送下注		（推送玩家下注结果）

		elseif response.requestType == KaDang_pb.Push_ReadyBet then
			--Push_ReadyBet = 8;		//推送准备下注  （即推送那个玩家下注和倒计时间）
			local readyBetStatus = response.readyBetStatus
			self:fireEvent(EVT.PUSH_READY_BET, readyBetStatus)

		elseif response.requestType == KaDang_pb.Push_Member then
			--Push_Member = 9;		//推送玩家状态
			local memStatus = response.batchMemberStatus
			local memData = self:parseRoomMember(memStatus.roomMem)
			--初始化其他玩家座位下标(新加入玩家)
			self:initOtherSeatIndex()

			self:fireEvent(EVT.PUSH_MEMBER_STATUS, memData)
		elseif response.requestType == KaDang_pb.Request_Leave then
			--Request_Leave = 10;		//请求离开房间
			self:clear()
			StageMgr:chgStage("Hall")
		elseif response.requestType == KaDang_pb.Request_Change then
			--Request_Change = 11;	//请求换桌，先离开房间再进入房间
		else
			assert(false)
		end
	else
		--[[log("kadang error msg : "..response.tips)
		local info =
		{
			content = response.tips,
			color = cc.c3b(239, 17, 39),
			fontSize = 30,
		}
		ui.confirm:popup(info)--]]

		local data = {
			content = response.tips
		}
		ui.mgr:open("Dialog/ConfirmDlg", data)

		if response.requestType == KaDang_pb.Request_Ready then
			self:fireEvent(EVT.PUSH_USER_READY, response.isSuccess)
		elseif response.requestType == KaDang_pb.Request_Bet then
			self:fireEvent("EVT.PUSH_REQUEST_BET", false)
		end
	end
end

function class:parseRoomInfo(data)
	if data == nil then
		log4model:warn("Kadang :: parse room info error ! data is nil !")
		return
	end

	--self.roomInfo = {}
	if data.playId ~= nil then self.roomInfo.playId = data.playId end
	if data.typeId ~= nil then self.roomInfo.typeId = data.typeId end
	if data.dealerType ~= nil then self.roomInfo.dealerType = data.dealerType end				--抢庄类型
	if data.dealerDesc ~= nil then self.roomInfo.dealerDesc = data.dealerDesc end
	if data.maxLimit ~= nil then self.roomInfo.maxLimit = tonumber(data.maxLimit) end			--下注上限
	if data.roomId ~= nil then self.roomInfo.roomId = data.roomId end
	if data.currencyType ~= nil then self.roomInfo.currencyType = data.currencyType end
	if data.maxPlayerNum ~= nil then self.roomInfo.maxPlayerNum = data.maxPlayerNum end
	if data.minPlayerNum ~= nil then self.roomInfo.minPlayerNum = data.minPlayerNum end
	--金币、房卡、活动
	-- if data.roomStyle ~= nil then
	-- 	self.roomInfo.roomStyle = data.roomStyle
	-- 	log(data.roomStyle)
	-- else
	-- 	self.roomInfo.roomStyle = Common_pb.RsGold
	-- end
	self.roomInfo.roomStyle = Common_pb.RsGold
	
	if data.minLimit ~= nil then self.roomInfo.minLimit = tonumber(data.minLimit) end 			--下注下限
	if data.baseChip ~= nil then self.roomInfo.baseChip = tonumber(data.baseChip) end			--底注
	if data.minCoin ~= nil then self.roomInfo.minCoin = tonumber(data.minCoin) end
	-- log("Kadang::parseRoomInfo:: room info playerId:"..data.playId..", roomId:"..data.roomId..", currencyType:"..data.currencyType)
	-- log(self.roomInfo)
end

function class:parseRoomMember(data)
	if data == nil then
		log4model:warn("Kadang :: parse room member error ! data is nil !")
		return nil
	end

	local parseMemData = {}
	for k, v in ipairs(data) do
		if v.memberType ~= Common_pb.Leave then
			local info = {}
			info.playerId = v.playerId
			if v.memberType ~= nil then info.memberType = v.memberType end
			if v.playerName ~= nil then info.playerName = v.playerName end
			if v.headimage ~= nil then info.headimage = v.headimage end
			if v.coin ~= nil then info.coin = tonumber(v.coin) end		--货币数
			if v.index ~= nil then info.seatId = tonumber(v.index) end	--座位号 1开始
			info.sex = tonumber(v.sex) or 1 --性别,1-男、2-女

			-- log("Kadang::parseRoomMember:: index:"..k..", playerId:"..v.playerId..", coin:"..v.coin..", seatId:"..v.index)
			if v.playerId == nil or v.playerId == "" then
				log4model:warn("Kadang::parseRoomMember :: parse room member error ! playerId == "..v.playerId)
			end

			info.memStateInfo = {}

			local memStateInfo = v.state
			if memStateInfo then
				if memStateInfo.isSettlement ~= nil then info.memStateInfo.isSettlement = memStateInfo.isSettlement end 	--是否结算
				if memStateInfo.cardCount ~= nil then info.memStateInfo.cardCount = memStateInfo.cardCount end				--手牌数量
				if memStateInfo.result ~= nil then info.memStateInfo.result = memStateInfo.result end						--true 赢  false 输
				if memStateInfo.mutiple ~= nil then info.memStateInfo.mutiple = memStateInfo.mutiple end					--倍数
				if memStateInfo.resultDesc ~= nil then info.memStateInfo.resultDesc = memStateInfo.resultDesc end			--描述
				if memStateInfo.isOffLine ~= nil then info.memStateInfo.isOffLine = memStateInfo.isOffLine end				--是否离线
				if memStateInfo.isReady ~= nil then info.memStateInfo.isReady = memStateInfo.isReady end					--是否准备
				if memStateInfo.betCoin ~= nil then info.memStateInfo.betCoin = tonumber(memStateInfo.betCoin) end			--下注金额
				if memStateInfo.isViewer ~= nil then info.memStateInfo.isViewer = memStateInfo.isViewer end					--是否旁观
				if memStateInfo.isBeting ~= nil then info.memStateInfo.isBeting = memStateInfo.isBeting end
				if memStateInfo.kazhResult ~= nil then info.memStateInfo.kazhResult = memStateInfo.kazhResult end
				if memStateInfo.settleCoin ~= nil then info.memStateInfo.settleCoin = tonumber(memStateInfo.settleCoin) end

				--手牌信息
				local cards = {}
				for __, card in ipairs(memStateInfo.cards) do
					local node = {}
					node.color = tonumber(card.color)
					node.size = tonumber(card.size)
					node.id = card.id
					cards[#cards + 1] = node	
				end

				--非玩家自己，未结算时，其他人牌不发送结果
				if memStateInfo.cardCount>0 and #cards==0 then
					for index = 1, memStateInfo.cardCount do
						cards[#cards + 1] = false
					end					
				end
					
				info.memStateInfo.cards = cards

				-- log(info)
			else
				log4model:warn("Kadang::parseRoomMember:: parse room member state info error !")
			end

			local positionInfo = {}			
			local position = v.position
			if position then
				positionInfo.ip = position.ip or ""
				positionInfo.longitude = position.longitude or ""
				positionInfo.latitude = position.latitude or ""
			end

			info.positionInfo = positionInfo
			-- Model:get("Position"):setPlayerPosInfo(info.playerId, positionInfo)

			self.memberMap[info.playerId] = info

			parseMemData[#parseMemData + 1] = info.playerId
		else
			--离开房间不用更新数据
			local info = self.memberMap[v.playerId]
			if info ~= nil then
				info.memberType = v.memberType
				parseMemData[#parseMemData + 1] = info.playerId
			else
				log4model:warn("Kadang::parseRoomMember:: parse room member info error ! memberType=="..v.memberType..", playerId=="..v.playerId)
			end
		end
	end

	return parseMemData
end

function class:parseRoomStateInfo(data)
	if data == nil then
		log4model:warn("Kadang::parseRoomStateInfo:: parse room state info error ! data is nil !")
		return nil
	end

	if data.state ~= nil then self.roomStateInfo.roomState = data.state end
	if data.roomCoin ~= nil then self.roomStateInfo.roomCoin = tonumber(data.roomCoin) end
	if data.countDown ~= nil then self.roomStateInfo.countDown = data.countDown end
	if data.roomBetCoin ~= nil then 
		self.roomStateInfo.roomBetCoin = {}
		for i, v in ipairs(data.roomBetCoin) do
			table.insert(self.roomStateInfo.roomBetCoin, tonumber(v))
		end
	end

	-- log("Kadang::parseRoomStateInfo:: roomStateInfo state:"..self.roomStateInfo.roomState..", roomCoin:"..self.roomStateInfo.roomCoin..", countDown:"..self.roomStateInfo.countDown)
	return self.roomStateInfo
end
