local GameBase = require "Games.Base"
require "Protol.NiuNiu_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_ENTER_ROOM",
	"PUSH_USER_READY",
	"PUSH_ROOM_DRAW",
	"PUSH_MEMBER_STATUS",
	"PUSH_ROOM_STATE",
	"PUSH_USER_SNATCH",
	"PUSH_SNATCH_RESULT",
	"PUSH_ROOM_DEAL",
	"PUSH_OPEN_DEAL",
	"PUSH_OPEN_DEAL_RESULT",
	"PUSH_SETTLEMENT",
	"PUSH_MP_LAST_CARDS",
	"PUSH_CLUB_CREATE_ROOM",
}

class = GameBase.class:subclass()

local NiuNiu_pb = NiuNiu_pb
local Common_pb = Common_pb

local bCheckClubManager = false

function class:initialize()
	super.initialize(self)

	net.msg:on(MsgDef_pb.MSG_NIUNIU, self:createEvent("onNiuniuResponse"))

	--消息协议解析
	self:bindResponse(NiuNiu_pb.Request_Enter, bind(self.responseEnterRoom, self))
	self:bindResponse(NiuNiu_pb.Request_Ready, bind(self.responseReady, self), true)
	self:bindResponse(NiuNiu_pb.Push_Draw, bind(self.responseDraw, self))
	self:bindResponse(NiuNiu_pb.Request_Snatch, bind(self.responseSnatch, self), true)
	self:bindResponse(NiuNiu_pb.Push_SnatchResult, bind(self.responseSnatchResult, self))
	self:bindResponse(NiuNiu_pb.Request_Bet, bind(self.responseBet, self), true)
	self:bindResponse(NiuNiu_pb.Push_BetResult, bind(self.responseBetResult, self))
	self:bindResponse(NiuNiu_pb.Request_Deal, bind(self.responseDeal, self))
	self:bindResponse(NiuNiu_pb.Push_State, bind(self.responseRoomState, self))
	self:bindResponse(NiuNiu_pb.Push_Member, bind(self.responseMember, self))
	self:bindResponse(NiuNiu_pb.Request_OpenDeal, bind(self.responseOpenDeal, self), true)
	self:bindResponse(NiuNiu_pb.Push_OpenDeal, bind(self.responseOpenDealResult, self))
	self:bindResponse(NiuNiu_pb.Push_Settlement, bind(self.responseSettlement, self))
	self:bindResponse(NiuNiu_pb.Request_Leave, bind(self.responseLeaveRoom, self))
	self:bindResponse(NiuNiu_pb.Request_Destroy, bind(self.responseDissolveRoom, self))
	self:bindResponse(NiuNiu_pb.Push_Destory, bind(self.responseRoomDestory, self))
	self:bindResponse(NiuNiu_pb.Push_To_Destory, bind(self.responseApplyRoomDestory, self))
	self:bindResponse(NiuNiu_pb.Push_Agree_Destroy, bind(self.responseAgreeRoomDestory, self))
	self:bindResponse(NiuNiu_pb.Request_Start, bind(self.responseStartGame, self))
	self:bindResponse(NiuNiu_pb.Push_Mp_LastCards, bind(self.responseLastCards, self))
end

function class:onNiuniuResponse(data)
	local response = NiuNiu_pb.NiuNiuResponse()
	response:ParseFromString(data)
	if response.requestType == nil then
		log4model:error("[Niuniu::onNiuniuResponse] requestType is nil !!!!")
		return
	end
	-- log("[Niuniu::onNiuniuResponse] response type == "..response.requestType)

	self:onResponse(response.requestType, response)
end

--通用请求，不需要附带其他数据(准备、请求开始游戏等)
function class:requestCommonMsg(msgType)
	local gameRequest = NiuNiu_pb.NiuNiuRequest()
	gameRequest.requestType = msgType
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	net.msg:send(MsgDef_pb.MSG_NIUNIU, gameRequest:SerializeToString())
end

--请求开始游戏返回
function class:responseStartGame(data)
	-- self:fireEvent(EVT.PUSH_START_GAME, data.isSuccess)
end

--请求加入游戏
function class:requestEnterRoom(playId, typeId, roomStyle, roomId)
	local gameRequest = NiuNiu_pb.NiuNiuRequest()
	gameRequest.requestType = NiuNiu_pb.Request_Enter
	gameRequest.room.playId = playId
	gameRequest.room.typeId = typeId
	gameRequest.room.roomStyle = roomStyle

	--房卡场请求加入房间需要添加roomID
	if roomId then
		gameRequest.room.roomId = roomId	
	end

	bCheckClubManager = false

	net.msg:send(MsgDef_pb.MSG_NIUNIU, gameRequest:SerializeToString())
end

--房卡场创建房间
function class:requestCreateCardRoom(configInfo, clubId)
	local gameRequest = NiuNiu_pb.NiuNiuRequest()
	gameRequest.requestType = NiuNiu_pb.Request_Enter
	gameRequest.room.playId = configInfo.playId
	gameRequest.room.typeId = configInfo.typeId
	gameRequest.room.maxPlayerNum = configInfo.maxPlayerNum
	gameRequest.room.minPlayerNum = configInfo.minPlayerNum
	gameRequest.room.currencyType = tonumber(configInfo.currencyType)

	gameRequest.room.roomStyle = Common_pb.RsCard
	--客户端选择相关配置
	for k, v in pairs(configInfo.config) do		
		if string.find(k, "dealerType") then
			--抢庄类型
			gameRequest.room.dealerType = tonumber(v[1])
		elseif string.find(k, "groupConfig") then
			--局数
			gameRequest.cardConfigRequest.groupConfig = tonumber(v[1])
		-- elseif string.find(k, "scorePayType") then
		-- 	--支付类型
		-- 	gameRequest.cardConfigRequest.scorePayType = tonumber(v[1])
		elseif string.find(k, "chipRange") then
			--投注范围
			gameRequest.cardConfigRequest.chipRange = tonumber(v[1])
		elseif string.find(k, "specialType") then
			--特殊牌型（多选）
			for _, value in ipairs(v) do
				table.insert(gameRequest.cardConfigRequest.specialType, tonumber(value))
			end
		elseif string.find(k, "multiplyRule") then
			--翻倍规则
			gameRequest.cardConfigRequest.multiplyRule = tonumber(v[1])
		elseif string.find(k, "baseChipRange") then
			--底注范围
			gameRequest.cardConfigRequest.baseChipRange = tonumber(v[1])
		elseif string.find(k, "showCardNum") then
			gameRequest.cardConfigRequest.mcardNum = tonumber(v[1])
		end
	end

	gameRequest.cardConfigRequest.scorePayType = Common_pb.RoomOwnner

	--俱乐部ID
	if clubId ~= nil then
		gameRequest.room.clubId = clubId
		-- log("create niuniu room :: clubId == "..clubId)
		--管理员创建俱乐部房间的时候不加入。
		bCheckClubManager = true
	end

	net.msg:send(MsgDef_pb.MSG_NIUNIU, gameRequest:SerializeToString())
end

function class:responseEnterRoom(data)
	self:clear()

	local initInfo = data.initInfo
	self:parseRoomInfo(initInfo.info)
	self:parseRoomMember(initInfo.rmem)
	self:parseRoomStateInfo(initInfo.state)
	self:parseCardConfigInfo(initInfo.cardConfigInfo)

	-- log(self.roomInfo)
	if bCheckClubManager and self.roomInfo.roomStyle == Common_pb.RsCard then
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

	local userId = Model:get("Account"):getUserId()
	--先初始化自己的座位下标（自己坐正面）
	self:initUserSeatIndex(userId)
	--初始化其他玩家座位下标
	self:initOtherSeatIndex()

	if not StageMgr:isStage("Game") then
		StageMgr:chgStage("Game", "Niuniu")
		
	else
		self:fireEvent(EVT.PUSH_ENTER_ROOM)
	end

	--有人申请解散房间
	if data.pushToDestory then
		self:responseApplyRoomDestory(data)
	end
end

--准备
function class:requestReady()
	local gameRequest = NiuNiu_pb.NiuNiuRequest()
	gameRequest.requestType = NiuNiu_pb.Request_Ready
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	net.msg:send(MsgDef_pb.MSG_NIUNIU, gameRequest:SerializeToString())
end

--玩家准备操作返回
function class:responseReady(data)
	self:fireEvent(EVT.PUSH_USER_READY, data.isSuccess)
end

--推送扣除台费、进入抢庄阶段
function class:responseDraw(data)
	self:parseRoomStateInfo(data.roomState.state)
	self:parseRoomMember(data.batchMemeberStatus.rmem)
	self:fireEvent(EVT.PUSH_ROOM_DRAW)
end

--抢庄
function class:requestSnatch(isSnatch, mutiple)
	mutiple = mutiple or 1

	local gameRequest = NiuNiu_pb.NiuNiuRequest()
	gameRequest.requestType = NiuNiu_pb.Request_Snatch
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle
	gameRequest.snatchRequest.isSnatch = isSnatch
	gameRequest.snatchRequest.mutiple = mutiple

	net.msg:send(MsgDef_pb.MSG_NIUNIU, gameRequest:SerializeToString())
end

--玩家抢庄返回
function class:responseSnatch(data)
	self:fireEvent(EVT.PUSH_USER_SNATCH, data.isSuccess)
end

--推送抢庄结果（注：抢庄完成后，直接进入下注阶段）
function class:responseSnatchResult(data)		
	self:parseRoomStateInfo(data.roomState.state)
	self:parseRoomMember(data.batchMemeberStatus.rmem, true)

	--下注筹码范围
	local betRange = {}
	for i, v in ipairs(data.betRange) do
		betRange[#betRange+1] = v
	end

	table.sort(betRange, function (a, b)
        return a < b
    end)

    -- log(betRange)

	self:fireEvent(EVT.PUSH_SNATCH_RESULT, betRange)
end

--请求下注
function class:requestBet(betValue)
	local gameRequest = NiuNiu_pb.NiuNiuRequest()
	gameRequest.requestType = NiuNiu_pb.Request_Bet
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	if betValue <= 0 then
		gameRequest.betRequest.isBet = false
	else
		gameRequest.betRequest.isBet = true
	end
	gameRequest.betRequest.betCoin = tostring(betValue)

	net.msg:send(MsgDef_pb.MSG_NIUNIU, gameRequest:SerializeToString())
end

function class:responseBet(data)

end

function class:responseBetResult(data)
	if self.roomInfo.dealerType ~= NiuNiu_pb.TBNN then
		-- self:responseMember(data)
		local memData = self:parseRoomMember(data.batchMemeberStatus.rmem, true)
		--初始化其他玩家座位下标(新加入玩家)
		self:initOtherSeatIndex()

		self:fireEvent(EVT.PUSH_MEMBER_STATUS, memData)
	end
end

--请求明牌
function class:requestOpenDeal(preCardInfo, lastCardInfo)
	local gameRequest = NiuNiu_pb.NiuNiuRequest()
	gameRequest.requestType = NiuNiu_pb.Request_OpenDeal
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	local cardInfo
	for i, v in ipairs(preCardInfo) do
		cardInfo = CardKind_pb.CardInfo()
		cardInfo.id = v.id
		cardInfo.size = v.size
		cardInfo.color = v.color
		table.insert(gameRequest.openDealRequest.preCardInfo, cardInfo)
	end

	for i, v in ipairs(lastCardInfo) do
		cardInfo = CardKind_pb.CardInfo()
		cardInfo.id = v.id
		cardInfo.size = v.size
		cardInfo.color = v.color
		table.insert(gameRequest.openDealRequest.lastCardInfo, cardInfo)
	end

	net.msg:send(MsgDef_pb.MSG_NIUNIU, gameRequest:SerializeToString())
end

--请求明牌相应
function class:responseOpenDeal(data)
	self:fireEvent(EVT.PUSH_OPEN_DEAL, data.isSuccess)
end

--明牌结果
function class:responseOpenDealResult(data)
	local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)
	self:fireEvent(EVT.PUSH_OPEN_DEAL_RESULT, memData)
end

--请求离开房间
function class:requestLeaveGame()
	local gameRequest = NiuNiu_pb.NiuNiuRequest()
	gameRequest.requestType = NiuNiu_pb.Request_Leave
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	net.msg:send(MsgDef_pb.MSG_NIUNIU, gameRequest:SerializeToString())
end

--离开房间
function class:responseLeaveRoom(data)
	self:clear()
	StageMgr:chgStage("Hall")
end

--请求换桌
function class:requestChangeRoom()
	local gameRequest = NiuNiu_pb.NiuNiuRequest()
	gameRequest.requestType = NiuNiu_pb.Request_Change
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	net.msg:send(MsgDef_pb.MSG_NIUNIU, gameRequest:SerializeToString())
end

--请求解散房间
function class:requestDissolveRoom()
	local gameRequest = NiuNiu_pb.NiuNiuRequest()
	gameRequest.requestType = NiuNiu_pb.Request_Destroy
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle

	net.msg:send(MsgDef_pb.MSG_NIUNIU, gameRequest:SerializeToString())
end

--申请解散房间返回
function class:responseDissolveRoom(data)

end

--服务器推送解散房间
function class:responseRoomDestory(data)
	ui.mgr:close("Games/Common/DissolveRoomView")
	--房卡场通过结算界面返回大厅
	-- self:clear()
	-- StageMgr:chgStage("Hall")

	local userInfo = self:getUserInfo()
	if userInfo == nil then
		--围观解散
		StageMgr:chgStage("Hall")		
	end
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
	info.modelName = "Games/Niuniu"
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

		ui.mgr:open("Games/Common/DissolveRoomView", info)
	end
end

--是否同意解散房间
function class:requestAgreeDissolve(isAgree)
	local gameRequest = NiuNiu_pb.NiuNiuRequest()
	gameRequest.requestType = NiuNiu_pb.Request_Agree_Destroy
	gameRequest.room.playId = self.roomInfo.playId
	gameRequest.room.roomId = self.roomInfo.roomId
	gameRequest.room.roomStyle = self.roomInfo.roomStyle
	
	gameRequest.agreeDestoryRequest.isAgree = isAgree

	net.msg:send(MsgDef_pb.MSG_NIUNIU, gameRequest:SerializeToString())
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

--发牌
function class:responseDeal(data)
	self:parseRoomStateInfo(data.roomState.state)

	local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)
	self:fireEvent(EVT.PUSH_ROOM_DEAL, memData)
end

function class:responseLastCards(data)
	if self.roomInfo.dealerType ~= NiuNiu_pb.MPQZ then
		return
	end

	local userId = Model:get("Account"):getUserId()
	local userInfo = self:getMemberInfoById(userId)

	local userCards = userInfo.memStateInfo.cards

	local pushMpLastCards = data.pushMpLastCards
	--手牌信息
	local cards = {}
	for __, card in ipairs(pushMpLastCards.cards) do
		local node = {}
		node.color = tonumber(card.color)
		node.size = tonumber(card.size)
		node.id = card.id
		cards[#cards + 1] = node

		-- table.insert(userInfo.memStateInfo.cards, node)
		for i, v in ipairs(userCards) do
			if i > 0 and i <= 5 then
				if not v then
					userCards[i] = node
					break
				end
			end
		end
	end

	-- log(userInfo.memStateInfo.cards)

	-- log(cards)
	self:fireEvent(EVT.PUSH_MP_LAST_CARDS, cards)
end

--结算结果
function class:responseSettlement(data)
	self:parseRoomStateInfo(data.roomState.state)
	local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)
	self:fireEvent(EVT.PUSH_SETTLEMENT, memData)
end

--更新房间状态
function class:responseRoomState(data)
	local roomStateInfo = data.roomState
	self:parseRoomStateInfo(roomStateInfo.state)
	self:fireEvent(EVT.PUSH_ROOM_STATE)
end

--更新成员状态
function class:responseMember(data)
	local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)
	--初始化其他玩家座位下标(新加入玩家)
	self:initOtherSeatIndex()

	self:fireEvent(EVT.PUSH_MEMBER_STATUS, memData)
end

function class:parseRoomInfo(data)
	if data == nil then
		log4model:warn("Niuniu :: parse room info error ! data is nil !")
		return
	end

	if data.playId ~= nil then self.roomInfo.playId = data.playId end
	if data.typeId ~= nil then self.roomInfo.typeId = data.typeId end
	if data.dealerType ~= nil then self.roomInfo.dealerType = data.dealerType end				--抢庄类型
	if data.dealerDesc ~= nil then self.roomInfo.dealerDesc = data.dealerDesc end
	if data.maxLimit ~= nil then self.roomInfo.maxLimit = tonumber(data.maxLimit) end			--下注上限
	if data.roomId ~= nil then self.roomInfo.roomId = data.roomId end
	if data.currencyType ~= nil then self.roomInfo.currencyType = data.currencyType end
	if data.maxPlayerNum ~= nil then self.roomInfo.maxPlayerNum = data.maxPlayerNum end
	if data.minPlayerNum ~= nil then self.roomInfo.minPlayerNum = data.minPlayerNum end
	if data.roomStyle ~= nil then self.roomInfo.roomStyle = data.roomStyle end 					--房卡、竞技、活动
	if data.clubId ~= nil then self.roomInfo.clubId = data.clubId end
	-- log("[Niuniu::parseRoomInfo] room indo playerId:"..data.playId..", roomId:"..data.roomId..", currencyType:"..data.currencyType)
end

function class:parseRoomMember(data, ignoreCards)
	if data == nil then
		log4model:warn("Niuniu :: parse room member error ! data is nil !")
		return nil
	end

	ignoreCards = ignoreCards or false

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

			-- log("[Niuniu::parseRoomMember] index:"..k..", playerId:"..v.playerId..", coin:"..v.coin..", seatId:"..v.index)
			if v.playerId == nil or v.playerId == "" then
				log4model:warn("[Niuniu::parseRoomMember] parse room member error ! playerId == "..v.playerId)
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
				if memStateInfo.isDealer ~= nil then info.memStateInfo.isDealer = memStateInfo.isDealer end
				if memStateInfo.betCoin ~= nil then info.memStateInfo.betCoin = tonumber(memStateInfo.betCoin) end			--下注金额
				if memStateInfo.isViewer ~= nil then info.memStateInfo.isViewer = memStateInfo.isViewer end					--是否旁观
				if memStateInfo.isSnatch ~= nil then info.memStateInfo.isSnatch = memStateInfo.isSnatch end
				if memStateInfo.isBet ~= nil then info.memStateInfo.isBet = memStateInfo.isBet end
				if memStateInfo.betResultCoin ~= nil then info.memStateInfo.betResultCoin = tonumber(memStateInfo.betResultCoin) end --输赢金币数
				if memStateInfo.isRequestSnatch ~= nil then info.memStateInfo.isRequestSnatch = memStateInfo.isRequestSnatch end
				if memStateInfo.isOpenDeal ~= nil then info.memStateInfo.isOpenDeal = memStateInfo.isOpenDeal end --是否已明牌
				if memStateInfo.isStarter ~= nil then info.memStateInfo.isStarter = memStateInfo.isStarter end --是否可选择开始游戏 （房卡场人未满开始）

				--可能某个协议服务器会忽略下发玩家手牌信息。
				if not ignoreCards then
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
					local cardNum = #cards
					if cardNum < 5 then
						for i = cardNum+1, 5 do
							cards[#cards + 1] = false
						end
					end

					-- if memStateInfo.cardCount>0 and #cards==0 then
					-- 	for index = 1, memStateInfo.cardCount do
					-- 		cards[#cards + 1] = false
					-- 	end
					-- end
						
					info.memStateInfo.cards = cards
				else
					--忽略下发手牌数据时，使用原来保存数据
					local preInfo = self.memberMap[info.playerId]
					if preInfo then
						info.memStateInfo.cards = table.clone(preInfo.memStateInfo.cards)
					else
						info.memStateInfo.cards = {}
					end
				end

				-- log(info)
			else
				log4model:warn("[Niuniu::parseRoomMember] parse room member state info error !")
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

			self:checkPlayerStateChange(self.memberMap[info.playerId], info)

			self.memberMap[info.playerId] = info

			parseMemData[#parseMemData + 1] = info.playerId
		else
			--离开房间不用更新数据
			local info = self.memberMap[v.playerId]
			if info ~= nil then
				info.memberType = v.memberType
				parseMemData[#parseMemData + 1] = info.playerId
			else
				log4model:warn("[Niuniu::parseRoomMember] parse room member info error ! memberType=="..v.memberType..", playerId=="..v.playerId)
			end

			-- log("leave room :: player id == " .. v.playerId)
		end
	end

	return parseMemData
end

function class:parseRoomStateInfo(data)
	if data == nil then
		log4model:warn("Niuniu :: parse room state info error ! data is nil !")
		return
	end

	self.roomStateInfo = {}
	self.roomStateInfo.roomState = data.state
	self.roomStateInfo.countDown = data.countDown

	--房卡场 总局数、当前局数
	if data.groupConfig then self.roomInfo.groupNum = data.groupConfig end
	if data.currentGroup then self.roomInfo.currentGroup = data.currentGroup end

	-- log("[Niuniu::parseRoomStateInfo] roomState == "..data.state..", countDown == "..data.countDown)
end

function class:parseCardConfigInfo(data)
	if data == nil then
		-- log4model:warn("Niuniu :: parse room card config info error ! data is nil !")
		return
	end

	-- if data.groupConfig then self.roomInfo.groupNum = data.groupConfig end --局数
	if data.scorePayType then self.roomInfo.scorePayType = data.scorePayType end --支付类型
	if data.chipRange then self.roomInfo.chipRange = data.chipRange end --投注范围
	if data.limit then self.roomInfo.limit = tonumber(data.limit) end --入场限制
	--特殊牌型
	if data.specialType then
		self.roomInfo.specialType = {}
		for i, v in ipairs(data.specialType) do
			table.insert(self.roomInfo.specialType, v)
		end
	end
	if data.multiplyRule then self.roomInfo.multiplyRule = data.multiplyRule end --翻倍规则
	if data.baseChipRange then self.roomInfo.baseChipRange = data.baseChipRange end --底注范围

	-- log(self.roomInfo)
end

function class:checkPlayerStateChange(preInfo, curInfo)
	if preInfo == nil then
		return
	end

	if preInfo.memStateInfo.isReady==false and curInfo.memStateInfo.isReady==true then
		sys.sound:playEffect("READY")
	end

	if preInfo.memStateInfo.isRequestSnatch==false and curInfo.memStateInfo.isRequestSnatch==true then
		sys.sound:playEffect("SNATCH")
	end

	-- if preInfo.memStateInfo.isBet==false and curInfo.memStateInfo.isBet==true then
	-- 	sys.sound:playEffect("BET_COIN")
	-- end
end
