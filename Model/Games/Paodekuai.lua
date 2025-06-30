local GameBase = require "Games.Base"
require "Protol.PaoDeKuai_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_ENTER_ROOM",
	"PUSH_USER_READY",
	"PUSH_ROOM_DRAW",
	"PUSH_MEMBER_STATUS",
	"PUSH_ROOM_STATE",
	"PUSH_ROOM_DEAL",
	"PUSH_ROOM_DISCARD",
	"PUSH_DISCARD_READY",
	"PUSH_DISCARD",
	"PUSH_SETTLEMENT",
	"PUSH_PLAYBACK_SINGLE",
	"PUSH_PLAYER_LACK_COIN",
	"PUSH_CANCEL_PLAYER_LACK_COIN",
	"PUSH_CLUB_CREATE_ROOM",
}

class = GameBase.class:subclass()

local PaoDeKuai_pb = PaoDeKuai_pb
local Common_pb = Common_pb

local bCheckClubManager = false

--消息公告
function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_PAODEKUAI, self:createEvent("onPaodekuaiResponse"))

    --消息协议解析
	self:bindResponse(PaoDeKuai_pb.Request_Enter, bind(self.responseEnterRoom, self))
	self:bindResponse(PaoDeKuai_pb.Request_Leave, bind(self.responseLeaveRoom, self))
	self:bindResponse(PaoDeKuai_pb.Push_Draw, bind(self.responseDraw, self))
	self:bindResponse(PaoDeKuai_pb.Request_Ready, bind(self.responseReady, self), true)
	self:bindResponse(PaoDeKuai_pb.Request_Deal, bind(self.responseDeal, self))
	self:bindResponse(PaoDeKuai_pb.Request_Discard, bind(self.responseDiscard, self), true)
	self:bindResponse(PaoDeKuai_pb.Push_Settlement, bind(self.responseSettlement, self))
	self:bindResponse(PaoDeKuai_pb.Push_Destory, bind(self.responseRoomDestory, self))
	self:bindResponse(PaoDeKuai_pb.Push_To_Destory, bind(self.responseApplyRoomDestory, self))
	self:bindResponse(PaoDeKuai_pb.Push_Agree_Destroy, bind(self.responseAgreeRoomDestory, self))
	self:bindResponse(PaoDeKuai_pb.Push_Ready_Discard, bind(self.responseReadyDiscard, self))
	self:bindResponse(PaoDeKuai_pb.Push_Discard, bind(self.responseRoundDiscard, self))
	self:bindResponse(PaoDeKuai_pb.Push_NotDiscard, bind(self.responseNotDiscard, self))
	self:bindResponse(PaoDeKuai_pb.Push_Player_Lack_Coin, bind(self.responsePlayerLackCoin, self))
	self:bindResponse(PaoDeKuai_pb.Push_Cancel_Player_Lack_Coin, bind(self.responseCancelPlayerLackCoin, self))

	self:bindResponse(PaoDeKuai_pb.Push_State, bind(self.responseRoomState, self))
	self:bindResponse(PaoDeKuai_pb.Push_Member, bind(self.responseMember, self))

	self.discardRoundData = {}
	self.delayReadyDiscardList = {}
end

function class:isEnabledDiatance()
	return true
end

function class:onPaodekuaiResponse(data)
	local response = PaoDeKuai_pb.PaoDeKuaiResponse()
	response:ParseFromString(data)
	if response.requestType == nil then
		log4model:error("[Paodekuai::onPaodekuaiResponse] requestType is nil !!!!")
		return
	end
	-- log("[Paodekuai::onPaodekuaiResponse] response type == "..response.requestType)

	self:onResponse(response.requestType, response)
end

--请求加入游戏
function class:requestEnterRoom(playId, typeId, roomStyle, roomId)
	local request = PaoDeKuai_pb.PaoDeKuaiRequest()
	request.requestType = PaoDeKuai_pb.Request_Enter
	request.room.playId = playId
	request.room.typeId = typeId
	request.room.roomStyle = roomStyle

	--房卡场请求加入房间需要添加roomID
	if roomId then
		request.room.roomId = roomId	
	end

	bCheckClubManager = false

	net.msg:send(MsgDef_pb.MSG_PAODEKUAI, request:SerializeToString())
end

--请求房卡场创建房间
function class:requestCreateCardRoom(configInfo, clubId)
	local gameRequest = PaoDeKuai_pb.PaoDeKuaiRequest()
	gameRequest.requestType = PaoDeKuai_pb.Request_Enter
	gameRequest.room.playId = configInfo.playId
	gameRequest.room.typeId = configInfo.typeId
	gameRequest.room.currencyType = tonumber(configInfo.currencyType)
	gameRequest.room.roomStyle = Common_pb.RsCard

	gameRequest.cardConfigRequest.baseChipRange = 0 --跑得快计分场默认底分为1（传索引）

	for k, v in pairs(configInfo.config) do
		if string.find(k, "groupConfig") then
			--局数
			gameRequest.cardConfigRequest.groupConfig = tonumber(v[1])
		-- elseif string.find(k, "scorePayType") then
		-- 	--支付类型
		-- 	gameRequest.cardConfigRequest.scorePayType = tonumber(v[1])
		elseif string.find(k, "cardCountConfig") then
			--开局牌数	15张/16张
			gameRequest.cardConfigRequest.handCardCount = tonumber(v[1])
		elseif string.find(k, "is4with3") then
			--是否四带三
			gameRequest.cardConfigRequest.isFourWithThree = tonumber(v[1])
		elseif string.find(k, "isViewCount") then
			--是否显示手牌剩余张数
			gameRequest.cardConfigRequest.viewCount = tonumber(v[1])
		elseif string.find(k, "baseChipRange") then
			--底注范围
			gameRequest.cardConfigRequest.baseChipRange = tonumber(v[1])
		end
	end

	gameRequest.cardConfigRequest.scorePayType = Common_pb.RoomOwnner

	--俱乐部ID
	if clubId then
		gameRequest.room.clubId = clubId
		-- log("create paodekuai room :: clubId == "..clubId)
		--管理员创建俱乐部房间的时候不加入。
		bCheckClubManager = true
	end

	net.msg:send(MsgDef_pb.MSG_PAODEKUAI, gameRequest:SerializeToString())
end

--进入房间
function class:responseEnterRoom(data)
	self:clear()

	self.curReadyDiscard = nil
	
	local initInfo = data.initInfo
	self:parseRoomInfo(initInfo.info)
	self:parseRoomMember(initInfo.rmem)
	self:parseRoomStateInfo(initInfo.state)
	self:parseCardConfigInfo(initInfo.cardConfigInfo)

	if self.roomInfo.handCardCount <= 0 then
		self.roomInfo.handCardCount = 16
	end

	--金币场默认显示剩余牌数
	if self.roomInfo.roomStyle == Common_pb.RsGold then
		self.roomInfo.viewCount = 1
	else
		if bCheckClubManager then
			--用来判断是否是在创建的时候，否则后面点加入也会被处理掉
			bCheckClubManager = false
			--俱乐部主、管理员创建房间不进入游戏
			if self.roomInfo.clubId then
				local clubData = Model:get("Club"):getClubData(self.roomInfo.clubId)
				-- log(clubData)
				if clubData ~= nil then
					if clubData.isOwner == true or clubData.isManager == true then				
						self:clear()
						self:fireEvent(EVT.PUSH_CLUB_CREATE_ROOM)
						return
					end
				end
			end
		end
	end
	
	self.discardRoundData = self:parseRoundDiscardInfo(initInfo.currentRdInfo)

	--轮到谁出牌
	local pushreadyDiscard = initInfo.readyDiscard
	if pushreadyDiscard then
		local readyDiscard = {}
		readyDiscard.playerId = pushreadyDiscard.playerId
		readyDiscard.countDown = pushreadyDiscard.countDown
		readyDiscard.isFirst = pushreadyDiscard.isFirst
		readyDiscard.isNotDiscard = false

		if readyDiscard.playerId and readyDiscard.playerId ~= "" then
			self.roomInfo.readyDiscard = readyDiscard
		end

		-- log(readyDiscard)
	else
		log("[Paodekuai::requestEnterRoom] no ready discard data")
	end

	local userId = Model:get("Account"):getUserId()
	--先初始化自己的座位下标（自己坐正面）
	-- log(self.memberMap)
	-- local userInfo = self.memberMap[userId]
	-- if userInfo then
		self:initUserSeatIndex(userId)
		--初始化其他玩家座位下标
		self:initOtherSeatIndex()
	-- end

	if not StageMgr:isStage("Game") then
		StageMgr:chgStage("Game", "Paodekuai")
		-- if StageMgr:isStage("Loading") then
		-- 	StageMgr:setNextStage("Game", "Paodekuai")
		-- else
		-- 	StageMgr:chgStage("Game", "Paodekuai")
		-- end
	else
		self:fireEvent(EVT.PUSH_ENTER_ROOM)
	end

	--有人申请解散房间
	if data.pushToDestory then
		self:responseApplyRoomDestory(data)
	end
end

--请求换桌
function class:requestChangeRoom()
	local gameRequest = PaoDeKuai_pb.PaoDeKuaiRequest()
	gameRequest.requestType = PaoDeKuai_pb.Request_Change
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	net.msg:send(MsgDef_pb.MSG_PAODEKUAI, gameRequest:SerializeToString())
end

--请求离开房间
function class:requestLeaveGame()
	local gameRequest = PaoDeKuai_pb.PaoDeKuaiRequest()
	gameRequest.requestType = PaoDeKuai_pb.Request_Leave
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	net.msg:send(MsgDef_pb.MSG_PAODEKUAI, gameRequest:SerializeToString())
end

--离开
function class:responseLeaveRoom(data)
	self:clear()
	StageMgr:chgStage("Hall")
end

--扣除台费
function class:responseDraw(data)
	self:parseRoomStateInfo(data.roomState.state)
	self:parseRoomMember(data.batchMemeberStatus.rmem)
	self:fireEvent(EVT.PUSH_ROOM_DRAW)
end

--客户端请求准备
function class:requestReady()
	local gameRequest = PaoDeKuai_pb.PaoDeKuaiRequest()
	gameRequest.requestType = PaoDeKuai_pb.Request_Ready
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	net.msg:send(MsgDef_pb.MSG_PAODEKUAI, gameRequest:SerializeToString())
end

--准备
function class:responseReady(data)
	self:fireEvent(EVT.PUSH_USER_READY, data.isSuccess)
end

--服务器推送发牌
function class:responseDeal(data)
	self:parseRoomStateInfo(data.roomState.state)

	local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)
	-- log(memData)
	self:fireEvent(EVT.PUSH_ROOM_DEAL, memData)
end

--请求出牌(牌型、出牌数据、是否先出)
function class:requestDiscard(handsDesc, cards)
	local gameRequest = PaoDeKuai_pb.PaoDeKuaiRequest()
	gameRequest.requestType = PaoDeKuai_pb.Request_Discard
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	gameRequest.discardRequest.handsDesc = handsDesc

	local cardInfo
	for i, v in ipairs(cards) do
		cardInfo = CardKind_pb.CardInfo()
		cardInfo.id = v.id
		cardInfo.size = v.size
		cardInfo.color = v.color
		table.insert(gameRequest.discardRequest.discards, cardInfo)
	end
	
	net.msg:send(MsgDef_pb.MSG_PAODEKUAI, gameRequest:SerializeToString())
end

--推送谁出牌
function class:responseReadyDiscard(data)
	-- self:parseRoomStateInfo(data.roomState.state)

	-- local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)
	if data.pushreadyDiscard == nil then
		log4model:error("[Paodekuai::responseReadyDiscard] ready discard data is nil !")
	end

	local pushreadyDiscard = data.pushreadyDiscard

	local readyDiscard = {}
	readyDiscard.playerId = pushreadyDiscard.playerId
	readyDiscard.countDown = pushreadyDiscard.countDown
	readyDiscard.isFirst = pushreadyDiscard.isFirst
	readyDiscard.isNotDiscard = false

	-- log(readyDiscard)
	if StageMgr:isStage("Game") then
		if self:existEvent('timerPushNotDiscard') then
			table.insert(self.delayReadyDiscardList, readyDiscard)
		else
			self:fireEvent(EVT.PUSH_DISCARD_READY, readyDiscard)
		end

		self.curReadyDiscard = nil
	else
		--返回大厅后，游戏开始了，需要知道轮到谁出牌
		self.curReadyDiscard = readyDiscard
	end
end

function class:getCurReadyDiscard()
	return self.curReadyDiscard
end

function class:onNotDiscardTimeout()
	local delayNum = #(self.delayReadyDiscardList)
	if delayNum > 0 then
		for i, v in ipairs(self.delayReadyDiscardList) do
			local readyDiscard = self.delayReadyDiscardList[i]
			self:fireEvent(EVT.PUSH_DISCARD_READY, readyDiscard)
		end
		
		self.delayReadyDiscardList = {}
	end
end

--出牌结果（是否出牌成功)
function class:responseDiscard(data)
	self:fireEvent(EVT.PUSH_ROOM_DISCARD, data.isSuccess)
end

--回合出牌信息
function class:responseRoundDiscard(data)
	-- self:parseRoomStateInfo(data.roomState.state)
	-- local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)
	local info = data.roundDiscardInfo
	local roundData = self:parseRoundDiscardInfo(info)
	
	-- log(roundData)
	self.discardRoundData = roundData

	if self:existEvent("timerPushNotDiscard") then
		self:onNotDiscardTimeout()
		self:cancelEvent("timerPushNotDiscard")
	end

	self:fireEvent(EVT.PUSH_DISCARD, roundData)
end

--要不起
function class:responseNotDiscard(data)
	if data.pushreadyDiscard == nil then
		log4model:error("[Paodekuai::responseReadyDiscard] ready discard data is nil !")
	end

	local pushreadyDiscard = data.pushreadyDiscard
	local readyDiscard = {}
	readyDiscard.playerId = pushreadyDiscard.playerId
	readyDiscard.countDown = pushreadyDiscard.countDown
	readyDiscard.isFirst = pushreadyDiscard.isFirst
	readyDiscard.isNotDiscard = true
	self:fireEvent(EVT.PUSH_DISCARD_READY, readyDiscard)

	if self:existEvent('timerPushNotDiscard') then
		self:cancelEvent('timerPushNotDiscard')
	end

	util.timer:after(1000, self:createEvent("timerPushNotDiscard", "onNotDiscardTimeout"))
end

function class:parseRoundDiscardInfo(data)
	if data == nil then
		return nil
	end

	local roundData = {}
	roundData.discardsList = {}

	local discardInfo = data.discardInfo
	local item
	for i, v in ipairs(discardInfo) do
		item = {}
		item.playerId = v.playerId
		item.isFirst = v.isFirst
		item.handsDesc = v.handsDesc 	--牌型
		item.isSingle = v.isSingle 		--是否报单
		item.isLast = v.isLast or false --是否最后一手牌

		local discards = v.discards
		local cards = {}
		for __, card in ipairs(discards) do
			local node = {}
			node.id = card.id
			node.color = tonumber(card.color)
			node.size = tonumber(card.size)
			node.value = tonumber(card.size)
			--A变成14，2变成15
			if node.value == 1 then
				node.value = 14
			elseif node.value == 2 then
				node.value = 15
			end

			cards[#cards + 1] = node
		end

		item.discards = cards

		table.insert(roundData.discardsList, item)
	end

	return roundData
end

function class:getDiscardRoundData()
	return self.discardRoundData
end

--结算结果
function class:responseSettlement(data)
	self:parseRoomStateInfo(data.roomState.state)
	local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)

	-- if self:existEvent("timerPushNotDiscard") then
		self:cancelEvent("timerPushNotDiscard")

		util.timer:after(500, self:createEvent("timerPushSettlement", function()
			self:fireEvent(EVT.PUSH_SETTLEMENT, memData)
		end))
	-- else
	-- 	self:fireEvent(EVT.PUSH_SETTLEMENT, memData)
	-- end
end

--请求解散房间
function class:requestDissolveRoom()
	local gameRequest = PaoDeKuai_pb.PaoDeKuaiRequest()
	gameRequest.requestType = PaoDeKuai_pb.Request_Destroy
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	net.msg:send(MsgDef_pb.MSG_PAODEKUAI, gameRequest:SerializeToString())
end

--服务器推送解散房间
function class:responseRoomDestory(data)
	ui.mgr:close("Games/Common/DissolveRoomView")
end

--服务器推送 有人申请解散房间
function class:responseApplyRoomDestory(data)
	local agreeInfo = data.pushToDestory
	if not agreeInfo.requestPlayerId or agreeInfo.requestPlayerId == "" then
		return
	end

	local userInfo = self:getUserInfo()
    if userInfo == nil then
    	--围观玩家忽略
    	return
    end

	local info = {}
	info.modelName = "Games/Paodekuai"
	info.countDown = agreeInfo.countDown
	info.requestPlayerId = agreeInfo.requestPlayerId

	local playerInfo = self:getMemberInfoById(info.requestPlayerId)
	if playerInfo then
		info.requestPlayerName = playerInfo.playerName

		local agreeTab = {}
		local agreePlayerIdTab = agreeInfo.agreePlayerId
		for _, v in ipairs(agreePlayerIdTab) do
			local playerInfo = self:getMemberInfoById(v)
			agreeTab[v] = {id = v, name = playerInfo.playerName, headImage = playerInfo.headimage, isAgree = 1}
		end

		for k, v in pairs(self.memberMap) do
			if agreeTab[k] == nil then
				agreeTab[k] = {id = k, name = v.playerName, headImage = playerInfo.headimage, isAgree = 0}
			end
		end

		info.agreeTab = agreeTab

		if not StageMgr:isStage("Game") then
			util.timer:after(2.0*1000, self:createEvent("DELAY_SHOW_DISSOLVE_VIEW", function()
				ui.mgr:open("Games/Common/DissolveRoomView", info)	
			end))
		else
			ui.mgr:open("Games/Common/DissolveRoomView", info)
		end
	end
end

--申请是否同意解散房间
function class:requestAgreeDissolve(isAgree)
	local gameRequest = PaoDeKuai_pb.PaoDeKuaiRequest()
	gameRequest.requestType = PaoDeKuai_pb.Request_Agree_Destroy
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle
	
	gameRequest.agreeDestoryRequest.isAgree = isAgree

	net.msg:send(MsgDef_pb.MSG_PAODEKUAI, gameRequest:SerializeToString())
end

--推送用户是否同意解散房间请求
function class:responseAgreeRoomDestory(data)
	local agreeInfo = data.pushArgeeDestroy
	local isAgree = agreeInfo.isAgree
	local playerId = agreeInfo.playerId
	local countDown = agreeInfo.countDown
	
	if isAgree == false then
		ui.mgr:close("Games/Common/DissolveRoomView")

		local playerInfo = self:getMemberInfoById(playerId)
		if playerInfo then
			local data = {
				content = "玩家【"..playerInfo.playerName.."】 拒绝解散组局！"
			}
			ui.mgr:open("Dialog/ConfirmView", data)
		end
	else
		local layer = ui.mgr:getLayer("Games/Common/DissolveRoomView")
		if layer then
			layer:refreshAgreeState(playerId, countDown)
		end
	end
end

--更新房间状态
function class:responseRoomState(data)
	local roomStateInfo = data.roomState
	self:parseRoomStateInfo(roomStateInfo.state)
	self:fireEvent(EVT.PUSH_ROOM_STATE)
end

--更新成员数据
function class:responseMember(data)
	local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)
	--初始化其他玩家座位下标(新加入玩家)
	self:initOtherSeatIndex()

	self:fireEvent(EVT.PUSH_MEMBER_STATUS, memData)
end

function class:parseRoomInfo(data)
	if data == nil then
		log4model:warn("Paodekuai :: parse room info error ! data is nil !")
		return
	end

	if data.playId ~= nil then self.roomInfo.playId = data.playId end
	if data.typeId ~= nil then self.roomInfo.typeId = data.typeId end
	if data.roomId ~= nil then self.roomInfo.roomId = data.roomId end
	if data.currencyType ~= nil then self.roomInfo.currencyType = data.currencyType end
	if data.maxPlayerNum ~= nil then self.roomInfo.maxPlayerNum = data.maxPlayerNum end
	if data.minPlayerNum ~= nil then self.roomInfo.minPlayerNum = data.minPlayerNum end
	if data.roomStyle ~= nil then self.roomInfo.roomStyle = data.roomStyle end			--房卡、竞技、活动
	if data.baseChip ~= nil then self.roomInfo.baseChip = data.baseChip end
	if data.clubId ~= nil then self.roomInfo.clubId = data.clubId end

	self.singleState = {}

	local maxPlayerNum = data.maxPlayerNum or 3
	for i = 1, data.maxPlayerNum do
		self.singleState[i] = false
	end

	-- log(self.roomInfo)
	-- log("[Paodekuai::parseRoomInfo] room indo playerId:"..data.playId..", roomId:"..data.roomId..", currencyType:"..data.currencyType)
end

function class:parseRoomStateInfo(data)
	if data == nil then
		log4model:warn("Paodekuai :: parse room state info error ! data is nil !")
		return
	end

	self.roomStateInfo = {}
	self.roomStateInfo.roomState = data.state
	self.roomStateInfo.countDown = data.countDown

	--房卡场 总局数、当前局数
	if data.groupConfig then self.roomInfo.groupNum = data.groupConfig end
	if data.currentGroup then self.roomInfo.currentGroup = data.currentGroup end

	-- log(self.roomStateInfo)
	-- log("[Paodekuai::parseRoomStateInfo] roomState == "..data.state..", countDown == "..data.countDown)
end

function class:parseRoomMember(data)
	if data == nil then
		log4model:warn("Paodekuai :: parse room member error ! data is nil !")
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

			-- log("[Paodekuai::parseRoomMember] index:"..k..", playerId:"..v.playerId..", coin:"..v.coin..", seatId:"..v.index)
			info.memStateInfo = {}

			local memStateInfo = v.state
			if memStateInfo then
				info.memStateInfo.isSettlement = memStateInfo.isSettlement or false 	--是否结算
				if memStateInfo.cardCount ~= nil then info.memStateInfo.cardCount = memStateInfo.cardCount end				--手牌数量
				if memStateInfo.result ~= nil then info.memStateInfo.result = memStateInfo.result end						--true 赢  false 输
				if memStateInfo.mutiple ~= nil then info.memStateInfo.mutiple = memStateInfo.mutiple end					--倍数

				info.memStateInfo.isOffLine = memStateInfo.isOffLine or false				--是否离线
				info.memStateInfo.isReady = memStateInfo.isReady or false					--是否准备
				info.memStateInfo.isViewer = memStateInfo.isViewer or false					--是否旁观

				if memStateInfo.resultCoin ~= nil then info.memStateInfo.resultCoin = tonumber(memStateInfo.resultCoin) end --输赢金币数

				info.memStateInfo.isStarter = memStateInfo.isStarter or false --是否可选择开始游戏 （房卡场人未满开始）
				info.memStateInfo.isDiscarder = memStateInfo.isDiscarder or false --是否轮到出牌
				info.memStateInfo.isFirst = memStateInfo.isFirst or false --是否先出

				info.memStateInfo.isReportSingle = memStateInfo.isReportSingle or false --是否报单
				info.memStateInfo.isTrusteeship = memStateInfo.isTrusteeship or false --是否托管
				info.memStateInfo.boomNum = memStateInfo.boomNum --炸弹数量

				--手牌信息
				local cards = {}
				for __, card in ipairs(memStateInfo.cards) do
					local node = {}
					node.id = card.id
					node.color = tonumber(card.color)
					node.size = tonumber(card.size)
					node.value = tonumber(card.size)
					
					--A变成14，2变成15
					if node.value == 1 then
						node.value = 14
					elseif node.value == 2 then
						node.value = 15
					end

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
				log4model:warn("[Paodekuai::parseRoomMember] parse room member state info error !")
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

			-- self:checkPlayerStateChange(self.memberMap[info.playerId], info)

			self.memberMap[info.playerId] = info

			parseMemData[#parseMemData + 1] = info.playerId
		else
			--离开房间不用更新数据
			local info = self.memberMap[v.playerId]
			if info ~= nil then
				info.memberType = v.memberType
				parseMemData[#parseMemData + 1] = info.playerId
			else
				log4model:warn("[Paodekuai::parseRoomMember] parse room member info error ! memberType=="..v.memberType..", playerId=="..v.playerId)
			end
		end
	end

	return parseMemData
end

--房卡场配置信息
function class:parseCardConfigInfo(data)
	if data == nil then
		-- log4model:warn("Paodekuai :: parse room card config info error ! data is nil !")
		return
	end

	if data.groupConfig ~= nil then self.roomInfo.groupNum = data.groupConfig end --局数
	if data.scorePayType ~= nil then self.roomInfo.scorePayType = data.scorePayType end --支付类型
	if data.limit ~= nil then self.roomInfo.limit = tonumber(data.limit) end --入场限制
	if data.viewCount ~= nil then self.roomInfo.viewCount = data.viewCount end --是否显示牌数 0/1
	if data.handCardCount ~= nil then self.roomInfo.handCardCount = data.handCardCount end --开局牌数	15张/16张
	if data.baseChipRange ~= nil then self.roomInfo.baseChipRange = data.baseChipRange end --底注范围
	if data.isFourWithThree ~= nil then self.roomInfo.isFourWithThree = data.isFourWithThree end --是否允许四带三

	-- log(self.roomInfo)
end

function class:isEnabledFourWithThree()
	if self.roomInfo.roomStyle == Common_pb.RsGold then
		return false
	else
		if self.roomInfo.isFourWithThree == 1 then
			return true
		end 
	end

	return false
end

function class:clearSingleState()
	if self.singleState then
		for i = 1, #self.singleState do
			self.singleState[i] = false
		end
	end
end

function class:setIsSingle(playerId, isSingle)
	local seatIndex = self:getPlayerSeatIndex(playerId)
	self.singleState[seatIndex] = isSingle
end

function class:getIsSingle(seatIndex)
	return self.singleState[seatIndex]
end

--房间内玩家缺钱消息
function class:responsePlayerLackCoin(data)
	local playerLackCoinPush = data.playerLackCoinPush
	local info = {}
	info.playerId = {}
	for i, v in ipairs(playerLackCoinPush.playerId) do
		table.insert(info.playerId, v)
	end
	
	info.roomId = playerLackCoinPush.roomId
	info.countDown = playerLackCoinPush.countdown
	-- log(info)
	
	self:fireEvent(EVT.PUSH_PLAYER_LACK_COIN, info)
end

--房间内玩家缺钱状态取消消息
function class:responseCancelPlayerLackCoin(data)
	self:fireEvent(EVT.PUSH_CANCEL_PLAYER_LACK_COIN)
end

-------------------------------------跑得快回放处理----------------------------------------------
--获取下一步回放数据
function class:getNextPlayBackStep()
	if not self.playBackDetail then
		log4model:warn("get next play back step data error ! details is nil !")
		return nil
	end

	--坑爹！！！ 跑得快，如果某玩家在该轮要不起，该轮后续出牌数据，该玩家自动为要不起，服务器没有加入保存队列，客户端需要做判断
	local stepsData = self.playBackDetail.steps

	local curStepData
	if self.playBackStep > 0 and self.lastStepData then
		local lastStepData = self.lastStepData
		local lastSeatIndex = self:getPlayerSeatIndex(lastStepData.userId)
		local nextStepData = stepsData[self.playBackStep + 1]
		if nextStepData then
			--还未结束
			local nextSeatIndex = self:getPlayerSeatIndex(nextStepData.userId)
			if (nextSeatIndex-lastSeatIndex == 1) or (lastSeatIndex==3 and nextSeatIndex==1) then
				self.playBackStep = self.playBackStep + 1
				curStepData = nextStepData
			else
				--跳过了某个要不起的玩家
				curStepData = {}
				nextSeatIndex = lastSeatIndex + 1
				if nextSeatIndex > 3 then
					nextSeatIndex = 1
				end

				local playerInfo = self:getMemberInfoByIndex(nextSeatIndex)
				curStepData.userId = playerInfo.playerId
				curStepData.isPlay = 0
				curStepData.first = false
				curStepData.cards = {}
				-- log("skip player id : "..playerInfo.playerId..", seatIndex : "..nextSeatIndex)	
			end
		else
			self.playBackStep = self.playBackStep + 1
			curStepData = nextStepData
		end
	else
		self.playBackStep = self.playBackStep + 1
		curStepData = stepsData[self.playBackStep]
	end

	-- log("step index : "..self.playBackStep)

	
	if self.playBackStep > #stepsData then
		log("play back over !")
		return nil
	else
		-- log(curStepData)
		local discards = {}
		for i, card in ipairs(curStepData.cards) do
			local node = {}
			node.id = card.id
			node.color = self:getPokerCardColor(card.color)
			node.size = self:getPokerCardSize(card.size)
			node.value = node.size
			
			--A变成14，2变成15
			if node.value == 1 then
				node.value = 14
			elseif node.value == 2 then
				node.value = 15
			end

			discards[#discards + 1] = node
		end

		curStepData.discards = discards

		self.lastStepData = curStepData
		--从手牌中删除已出牌数据
		local playerInfo = self:getMemberInfoById(curStepData.userId)
		local cards = playerInfo.memStateInfo.cards
		local discards = curStepData.discards
		if #discards > 0 then
			for _, v in ipairs(discards) do
				for i, card in ipairs(cards) do
					if v.id == card.id then
						table.remove(cards, i)
						break
					end
				end
			end

			local function sortFunc(a, b)
				if a.value == b.value then
					return a.color > b.color
				else
					return a.value > b.value
				end
			end

			table.sort(cards, sortFunc)

			if #cards == 1 then
				self:fireEvent(EVT.PUSH_PLAYBACK_SINGLE, curStepData.userId)
			end
		end

		return curStepData
	end
end


