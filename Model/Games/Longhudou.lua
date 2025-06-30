local GameBase = require "Games.Base"
module(..., package.seeall)

require "Protol.Longhudou_pb"

EVT = Enum
{
	"PUSH_ENTER_ROOM",
	"PUSH_MEMBER_STATUS",
	"PUSH_ROOM_STATE",
	"PUSH_BET_RESULT",
	"PUSH_BET_COIN",
	"PUSH_OPEN_RESULT",
	"PUSH_SETTLEMENT",
	"PUSH_SNATCH",
	"PUSH_SNATCHQUEUE"
}

class = GameBase.class:subclass()

local Longhudou_pb = Longhudou_pb
local Common_pb = Common_pb

function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_LONGHUDOU, self:createEvent("onLonghudouResponse"))

    --消息协议解析
	self:bindResponse(Longhudou_pb.Request_Enter, bind(self.responseEnterRoom, self))
	self:bindResponse(Longhudou_pb.Request_Bet, bind(self.responseBet, self), true)
	self:bindResponse(Longhudou_pb.Push_Room_Status, bind(self.responseRoomStatus, self))
	self:bindResponse(Longhudou_pb.Push_Member, bind(self.responseMember, self))
	self:bindResponse(Longhudou_pb.Push_OpenResult, bind(self.responseOpenResult, self))
	self:bindResponse(Longhudou_pb.Push_Settlement, bind(self.responseSettlement, self))
	self:bindResponse(Longhudou_pb.Push_BetCoin, bind(self.responseBetCoin, self))
	self:bindResponse(Longhudou_pb.Request_Leave, bind(self.responseLeave, self), true)
	self:bindResponse(Longhudou_pb.Request_Snatch, bind(self.responseSnatch, self), true)
	self:bindResponse(Longhudou_pb.Request_Abandon, bind(self.responseAbandon, self), true)
	self:bindResponse(Longhudou_pb.Push_SnatchQueue, bind(self.responseSnatchQueue, self))
	self.dealerQueue = {}
	self.dealerInfo = nil
end

function class:onLonghudouResponse(data)
	local response = Longhudou_pb.LonghudouResponse()
	response:ParseFromString(data)
	if response.requestType == nil then
		log4model:error("[Longhudou::LonghudouResponse] requestType is nil !!!!")
		return
	end
	
	-- log("[Longhudou::LonghudouResponse] response type == "..response.requestType)
	self:onResponse(response.requestType, response)
end

--请求加入游戏
function class:requestEnterRoom(playId, typeId)
	local request = Longhudou_pb.LonghudouRequest()
	request.requestType = Longhudou_pb.Request_Enter
	request.room.playId = playId
	request.room.typeId = typeId

	net.msg:send(MsgDef_pb.MSG_LONGHUDOU, request:SerializeToString())
end

--请求离开房间
function class:requestLeaveGame()
	local request = Longhudou_pb.LonghudouRequest()
	request.requestType = Longhudou_pb.Request_Leave
	request.room.roomId = self.roomInfo.roomId
	request.room.playId = self.roomInfo.playId
	request.room.typeId = self.roomInfo.typeId

	net.msg:send(MsgDef_pb.MSG_LONGHUDOU, request:SerializeToString())
end

function class:responseEnterRoom(data)
	self:clear()
	self.dealerQueue={}
	local initInfo = data.initInfo
	self:parseRoomInfo(initInfo.info)
	self:parseRoomMember(initInfo.rmem)
	self:parseRoomStateInfo(initInfo.state)
	--self:parseDealerQueue(initInfo.dealerQueue)
	--玩家下注	
	local bets = initInfo.bets
	if bets then
		local initBets = {}
		local item
		for i, v in ipairs(bets) do
			item = {}
			item.playerId = v.playerId
			item.sidesDesc = v.sidesDesc
			item.coin = tonumber(v.coin)
			item.totalBetCoin = tonumber(v.totalBetCoin)
			initBets[#initBets + 1] = item
		end

		self.initBets = initBets
	end

	-- log(self.initBets)

	--开牌结果
	local openResult = initInfo.openResult
	if openResult then
		self.initOpenResult = {}
		if openResult.currentSidesDesc ~= nil then
			self.initOpenResult.currentSidesDesc = openResult.currentSidesDesc
		end

		if openResult.longCards ~= nil then
			local cardLong = {}
			cardLong.color = tonumber(openResult.longCards.color)
			cardLong.size = tonumber(openResult.longCards.size)
			cardLong.id = openResult.longCards.id
			self.initOpenResult.cardLong = cardLong
		end

		if openResult.huCards ~= nil then
			local cardHu = {}
			cardHu.color = tonumber(openResult.huCards.color)
			cardHu.size = tonumber(openResult.huCards.size)
			cardHu.id = openResult.huCards.id
			self.initOpenResult.cardHu = cardHu
		end

		if openResult.sixtySideResult ~= nil then
			local sixtySideResult = {}
			for i, v in ipairs(openResult.sixtySideResult) do
				sixtySideResult[#sixtySideResult + 1] = {v.sidesDesc, v.isMing}
			end

			self.initOpenResult.sixtySideResult = sixtySideResult
		end
	end

	-- log(self.initOpenResult)

	if not StageMgr:isStage("Game") then
		if util:getPlatform() ~= "win32" then
			--分包游戏先检测是否需要更新版本
			self:checkGameVersion("Longhudou")
		else
			StageMgr:chgStage("Game", "Longhudou")
		end
	else
		self:fireEvent(EVT.PUSH_ENTER_ROOM)
	end
end

function class:getInitBets()
	return self.initBets
end

function class:getInitOpenResult()
	return self.initOpenResult
end

--请求下注(下注选择：龙、虎、和；下注金额)
function class:requestBet(sideType, value)
	local request = Longhudou_pb.LonghudouRequest()
	request.requestType = Longhudou_pb.Request_Bet
	request.room.playId = self.roomInfo.playId
	request.room.roomId = self.roomInfo.roomId
	request.betRequest.sidesDesc = sideType
	request.betRequest.coin = tostring(value)

	net.msg:send(MsgDef_pb.MSG_LONGHUDOU, request:SerializeToString())
end

function class:responseBet(data)
	if data.isSuccess then

	else
		local content 
		local tips = data.tips
		if tips and tips ~= "" then
			content = tips
		else
			content = "该状态下不允许下注！"
		end

		local data = {
			content = content
		}
		ui.mgr:open("Dialog/DialogView", data)
	end

	self:fireEvent(EVT.PUSH_BET_RESULT, data.isSuccess)
end

function class:responseRoomStatus(data)
	local pushRoomStatus = data.pushRoomStatus
	self:parseRoomStateInfo(pushRoomStatus.state)

	self:fireEvent(EVT.PUSH_ROOM_STATE)

	self.initBets = nil
	self.initOpenResult = nil
end

function class:responseMember(data)
	local batchMemberStatus = data.batchMemberStatus
	local refreshList = self:parseRoomMember(batchMemberStatus.rmem)

	self:fireEvent(EVT.PUSH_MEMBER_STATUS, refreshList)
end

--开牌结果
function class:responseOpenResult(data)
	local pushOpenResult = data.pushOpenResult
	self:parseRoomStateInfo(pushOpenResult.roomStateInfo)

	local resultInfo = {}
	resultInfo.currentSidesDesc = pushOpenResult.currentSidesDesc

	local cardLong = {}
	cardLong.color = tonumber(pushOpenResult.longCards.color)
	cardLong.size = tonumber(pushOpenResult.longCards.size)
	cardLong.id = pushOpenResult.longCards.id
	resultInfo.cardLong = cardLong

	local cardHu = {}
	cardHu.color = tonumber(pushOpenResult.huCards.color)
	cardHu.size = tonumber(pushOpenResult.huCards.size)
	cardHu.id = pushOpenResult.huCards.id
	resultInfo.cardHu = cardHu

	--近60场开牌结果
	resultInfo.sixtySideResult = {}
	local sixtySideResult = pushOpenResult.sixtySideResult
	for i, v in ipairs(sixtySideResult) do
		table.insert(resultInfo.sixtySideResult, {v.sidesDesc, v.isMing})
	end

	-- log(resultInfo)

	self:fireEvent(EVT.PUSH_OPEN_RESULT, resultInfo)
end

--结算结果
function class:responseSettlement(data)
	local pushSettleResult = data.pushSettleResult	
	self:parseRoomStateInfo(pushSettleResult.roomStateInfo)

	local totalWinCoin = tonumber(pushSettleResult.totalWinCoin) or 0 --玩家总共输赢金额
	local refreshList = self:parseRoomMember(pushSettleResult.rmem)

	self:fireEvent(EVT.PUSH_SETTLEMENT, refreshList, totalWinCoin)
end

--推送每一注的下注结果
function class:responseBetCoin(data)
	local pushBetCoin = data.pushBetCoin
	local betInfo = {}
	betInfo.playerId = pushBetCoin.playerId
	betInfo.sidesDesc = pushBetCoin.sidesDesc
	betInfo.coin = tonumber(pushBetCoin.coin)
	betInfo.totalBetCoin = tonumber(pushBetCoin.totalBetCoin)

	-- log(betInfo)

	self:fireEvent(EVT.PUSH_BET_COIN, betInfo)
end

--请求上庄
function class:requestSnatch()
	--local tnlog=debug.getinfo(1,'n');log("DTM: "..tnlog["name"])
	local request = Longhudou_pb.LonghudouRequest()
	request.requestType = Longhudou_pb.Request_Snatch
	request.room.roomId = self.roomInfo.roomId
	request.room.playId = self.roomInfo.playId
	request.room.typeId = self.roomInfo.typeId
	--dump(self.roomInfo,"self.roomInfo.typeId",5)
	net.msg:send(MsgDef_pb.MSG_LONGHUDOU, request:SerializeToString())
end

--抢庄结果返还
function class:responseSnatch(data)
	--log("responseSnatch")
	if data.isSuccess then
		self:fireEvent(EVT.PUSH_SNATCH)
	else
		local content 
		local tips = data.tips
		if tips and tips ~= "" then
			content = tips
		else
			content = "暂时无法抢庄"
		end

		local data = {
			content = content
		}
		ui.mgr:open("Dialog/DialogView", data)
	end
end

--请求下庄
function class:requestAbandon()
	--local tnlog=debug.getinfo(1,'n');log("DTM: "..tnlog["name"])
	local request = Longhudou_pb.LonghudouRequest()
	request.requestType = Longhudou_pb.Request_Abandon
	request.room.roomId = self.roomInfo.roomId
	request.room.playId = self.roomInfo.playId
	request.room.typeId = self.roomInfo.typeId

	net.msg:send(MsgDef_pb.MSG_LONGHUDOU, request:SerializeToString())
end

function class:responseAbandon(data)
	--log("responseAbandon")
	if data.isSuccess then
		local data = {
			content = "下庄成功"
		}

		ui.mgr:open("Dialog/DialogView", data)
	else
		local content 
		local tips = data.tips
		if tips and tips ~= "" then
			content = tips
		else
			content = "暂时无法下庄"
		end

		local data = {
			content = content
		}
	end
	ui.mgr:open("Dialog/DialogView", data)	
end

--推送上庄列表
function class:responseSnatchQueue(data)
	--log("LHM: responseSnatchQueue")
	local pushSnatchQueue = data.pushSnatchQueue
	self:parseDealerQueue(pushSnatchQueue.dealerQueue)
	self:fireEvent(EVT.PUSH_SNATCHQUEUE)
end

function class:getDealerInfo()--庄家数据
	return self.dealerInfo
end

function class:getDealerQueue()--上庄队列
	--如果没有人上庄,系统上庄
	local dealerNums = #self.dealerQueue
	local dealerInfo = self:getDealerInfo()
	if dealerNums == 0 then
		if dealerInfo ~= nil then
			table.insert(self.dealerQueue, dealerInfo)
		else
			local SystemDealer={}
			SystemDealer.playerId = "1234567"
			SystemDealer.playerName = "系统坐庄"
			SystemDealer.headimage = nil
			SystemDealer.coin =999999
			SystemDealer.isDealer = true
			table.insert(self.dealerQueue, SystemDealer)
		end
	else
		--队列有数据的时候也要把庄家放在第一位
		if dealerInfo ~= nil then
			if self.dealerQueue[1].playerId ~= dealerInfo.playerId then
				table.insert(self.dealerQueue,1,dealerInfo)
			end
		end

	end
	return self.dealerQueue
end

--离开房间
function class:responseLeave(data)
	if data.isSuccess then
		self:clear()
		StageMgr:chgStage("Hall")
	else
		local content 
		local tips = data.tips
		if tips and tips ~= "" then
			content = tips
		else
			content = "游戏期间不能离开房间！"
		end

		local data = {
			content = content
		}
		ui.mgr:open("Dialog/DialogView", data)
	end
end

function class:parseRoomInfo(info)
	if info == nil then
		log4model:warn("Longhudou :: parse room info error ! data is nil !")
		return
	end

	if info.playId ~= nil then self.roomInfo.playId = info.playId end
	if info.typeId ~= nil then self.roomInfo.typeId = info.typeId end
	if info.roomId ~= nil then self.roomInfo.roomId = info.roomId end
	if info.currencyType ~= nil then self.roomInfo.currencyType = info.currencyType end
	if info.maxPlayerNum ~= nil then self.roomInfo.maxPlayerNum = info.maxPlayerNum end
	if info.minPlayerNum ~= nil then self.roomInfo.minPlayerNum = info.minPlayerNum end

	if info.betRanges then
		local betRanges = {}
		for i, v in ipairs(info.betRanges) do
			betRanges[#betRanges + 1] =  math.modf(tonumber(v) / 100)
		end

		table.sort(betRanges, function (a, b)
		   return a < b
		end)

		self.roomInfo.betRanges = betRanges
	end

	-- log(self.roomInfo)
end

function class:parseRoomMember(info)
	if info == nil then
		log4model:warn("Longhudou :: parse room member error ! data is nil !")
		return nil
	end

	local refreshList = {}
	local exitsDealer=false
	for i, v in ipairs(info) do
		if v.memberType ~= Common_pb.Leave then
			local item = {}
			item.playerId = v.playerId
			if v.memberType ~= nil then item.memberType = v.memberType end
			if v.playerName ~= nil then item.playerName = v.playerName end
			if v.headimage ~= nil then item.headimage = v.headimage end
			if v.coin ~= nil then item.coin = tonumber(v.coin) or 0 end
			if v.totalBetCoin ~= nil then item.totalBetCoin  = tonumber(v.totalBetCoin) or 0 end
			if v.winTimes ~= nil then item.winTimes = v.winTimes end --近20局获胜次数
			if v.winCoin ~= nil then item.winCoin = tonumber(v.winCoin) or 0 end --本次输赢
			if v.isAlreadyBet ~= nil then item.isAlreadyBet = v.isAlreadyBet end

			if v.isDealer ~= nil then item.isDealer = v.isDealer end
			if item.isDealer == true then				
				self.dealerInfo = item				
				self.memberMap[v.playerId] = nil

				exitsDealer = true
			else
				self.memberMap[v.playerId] = item

				if self.dealerInfo and self.dealerInfo.playerId == v.playerId then
					self.dealerInfo = nil
				end

				exitsDealer = false
			end

			-- log("parseRoomMember:: memberType == " .. item.memberType)
		else
			--离开房间不用更新数据
			local item = self.memberMap[v.playerId]
			if item ~= nil then
				item.memberType = v.memberType
			else
				log("[Longhudou::parseRoomMember] parse room member item error ! memberType=="..v.memberType..", playerId=="..v.playerId)
			end
		end

		if exitsDealer == false then
			refreshList[#refreshList + 1] = v.playerId
		end
	end

	-- log(self.memberMap)

	return refreshList
end

--解析上庄列表
function class:parseDealerQueue(info)
	--log("LHM: parseDealerQueue")
	if info == nil then
		log4model:warn("longhudou :: parse room member error ! data is nil !")
		return nil
	end
	self.dealerQueue=nil
	self.dealerQueue={}
	for i, v in ipairs(info) do
		local item = {}
		item.playerId = v.playerId
		if v.playerName ~= nil then item.playerName = v.playerName end
		if v.headimage ~= nil then item.headimage = v.headimage end
		if v.coin ~= nil then item.coin = tonumber(v.coin) or 0 end
		if v.isDealer ~= nil then item.isDealer = v.isDealer end
		table.insert(self.dealerQueue,item)
	end
end

function class:parseRoomStateInfo(info)
	if info == nil then
		log4model:warn("Longhudou :: parse room state info error ! data is nil !")
		return nil
	end

	self.roomStateInfo.roomState = info.state
	self.roomStateInfo.countDown = info.countDown
	self.roomStateInfo.isMing = info.isMing
	self.roomStateInfo.dealerCount=info.dealerCount
	-- log(self.roomStateInfo)
end

function class:isMingPai()
	return self.roomStateInfo.isMing
end
