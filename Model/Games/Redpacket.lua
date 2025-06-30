local GameBase = require "Games.Base"

module(..., package.seeall)

require "Protol.Redpacket_pb"

EVT = Enum
{
	"PUSH_ENTER_ROOM",
	"PUSH_ROOM_STATE",
	"PUSH_MEMBER_STATUS",
	"PUSH_SNATCH",
	"PUSH_SNATCH_RESULT",
	"PUSH_SNATCH_FLOOR",
	"PUSH_LAYMINES",
	"PUSH_LAYMINES_LIST",
	"PUSH_SETTLEMENT",
	"PUSH_FLOOR",
	"PUSH_BONUS",
	"PUSH_BONUS_TAKE",
}

class = GameBase.class:subclass()

local PaoDeKuai_pb = Redpacket_pb
local Common_pb = Common_pb
local MsgDef_pb = MsgDef_pb

--消息公告
function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_REDPACKET, self:createEvent("onRedpacketResponse"))

    --消息协议解析
	self:bindResponse(Redpacket_pb.Request_Enter, bind(self.responseEnterRoom, self))
	self:bindResponse(Redpacket_pb.Request_Snatch, bind(self.responseSnatch, self), true)
	self:bindResponse(Redpacket_pb.Push_SnatchResult, bind(self.responseSnatchResult, self), true)
	self:bindResponse(Redpacket_pb.Request_Laymines, bind(self.responseLaymines, self), true)
	self:bindResponse(Redpacket_pb.Request_Leave, bind(self.responseLeaveRoom, self), true)
	self:bindResponse(Redpacket_pb.Push_Room_Status, bind(self.responseRoomStatus, self))
	self:bindResponse(Redpacket_pb.Push_Member, bind(self.responseMember, self))
	self:bindResponse(Redpacket_pb.Push_LayminesList, bind(self.responseLayminesList, self))
	self:bindResponse(Redpacket_pb.Push_Settlement, bind(self.responseSettlement, self))
	self:bindResponse(Redpacket_pb.Push_Floor, bind(self.responseFloor, self))
	self:bindResponse(Redpacket_pb.Push_Bonus, bind(self.responseBonus, self))
	self:bindResponse(Redpacket_pb.Request_Bonus_Take, bind(self.responseBonusTake, self), true)

end

function class:clear()
	super.clear(self)

	self.floorList = {}
	self.snatchResultList = {}
	self.bonusList = {}
	self.layminesList = {}
end

--抢红包结果
function class:getSnatchResult()
	return self.snatchResultList
end

--埋雷列表
function class:getLayminesList()
	return self.layminesList
end

--爬楼列表
function class:getFloorList()
	return self.floorList
end

--福利列表
function class:getWelfareList()
	return self.bonusList
end

function class:clearPlayerWincoin()
	for id, v in pairs(self.memberMap) do
		v.winCoin = 0
	end
end

function class:onRedpacketResponse(data)
	local response = Redpacket_pb.RedpacketResponse()
	response:ParseFromString(data)
	if response.requestType == nil then
		log4model:error("[Redpacket::onRedpacketResponse] requestType is nil !!!!")
		return
	end
	-- log("[Redpacket::onRedpacketResponse] response type == "..response.requestType)

	self:onResponse(response.requestType, response)
end

--请求加入游戏
function class:requestEnterRoom(playId, typeId)
	local request = Redpacket_pb.RedpacketRequest()
	request.requestType = Redpacket_pb.Request_Enter
	request.room.playId = playId
	request.room.typeId = typeId

	net.msg:send(MsgDef_pb.MSG_REDPACKET, request:SerializeToString())
end

--请求离开房间
function class:requestLeaveGame()
	local request = Redpacket_pb.RedpacketRequest()
	request.requestType = Redpacket_pb.Request_Leave
	request.room.roomId = self.roomInfo.roomId
	request.room.playId = self.roomInfo.playId
	request.room.typeId = self.roomInfo.typeId

	net.msg:send(MsgDef_pb.MSG_REDPACKET, request:SerializeToString())
end

function class:responseEnterRoom(data)
	self:clear()

	local initInfo = data.initInfo
	self:parseRoomInfo(initInfo.info)
	self:parseRoomMember(initInfo.rmem)
	self:parseRoomStateInfo(initInfo.state)
	self:parseLayminesList(initInfo.layminesList)
	self:parseFloorInfo(initInfo.floorInfo)

	local snatchResult = initInfo.snatchResult
	for i, v in ipairs(snatchResult) do
		local result = self:parseSnatchResult(v)
		if result and result.isFloor == false then
			table.insert(self.snatchResultList, result)
		end
	end

	-- log(self.snatchResultList)

	self.bonusList = {}
	
	local pushBonus = data.pushBonus
	if pushBonus then
		for i, v in ipairs(pushBonus.bonus) do
			table.insert(self.bonusList, tonumber(v))
		end
	end

	if not StageMgr:isStage("Game") then
		if util:getPlatform() ~= "win32" then
			--分包游戏先检测是否需要更新版本
			self:checkGameVersion("Redpacket")
		else
			StageMgr:chgStage("Game", "Redpacket")
		end
	else
		self:fireEvent(EVT.PUSH_ENTER_ROOM)
	end
end

function class:requestSnatch(isFloor, floorIndex)
	local request = Redpacket_pb.RedpacketRequest()
	request.requestType = Redpacket_pb.Request_Snatch
	request.room.roomId = self.roomInfo.roomId
	request.room.playId = self.roomInfo.playId
	request.room.typeId = self.roomInfo.typeId

	request.snatchRequest.isFloor = isFloor or false
	if isFloor then
		request.snatchRequest.floorIndex = floorIndex
		-- log("request floor snatch : index ===== " .. floorIndex)
	end

	net.msg:send(MsgDef_pb.MSG_REDPACKET, request:SerializeToString())
end

--抢红包返回
function class:responseSnatch(data)
	if data.isSuccess then

	else
		local content 
		local tips = data.tips
		if tips and tips ~= "" then
			content = tips
		else
			content = "未抢到红包！"
		end

		local data = {
			content = content
		}
		ui.mgr:open("Dialog/DialogView", data)
	end

	self:fireEvent(EVT.PUSH_SNATCH, data)
end

function class:responseSnatchResult(data)
	local pushSnatchResult = data.pushSnatchResult
	local result = self:parseSnatchResult(pushSnatchResult)
	if result.isFloor == false then
		table.insert(self.snatchResultList, result)

		self:fireEvent(EVT.PUSH_SNATCH_RESULT, result)
	else
		-- log(result)

		self:responseFloor(data)

		local member = result.member
		local playerInfo = self.memberMap[member.playerId]
		if playerInfo then
			playerInfo.coin = member.coin
		end
		self:fireEvent(EVT.PUSH_SNATCH_FLOOR, result)
	end
end

--申请埋雷 金额、个数、雷号
function class:requestLaymines(value, num, bombId)
	local request = Redpacket_pb.RedpacketRequest()
	request.requestType = Redpacket_pb.Request_Laymines
	request.room.roomId = self.roomInfo.roomId
	request.room.playId = self.roomInfo.playId
	request.room.typeId = self.roomInfo.typeId

	-- request.layminesRequest.redpacket.playerId
	request.layminesRequest.redpacket.redpacketCoin = value
	request.layminesRequest.redpacket.redpacketNum = num
	request.layminesRequest.redpacket.minesNum = bombId

	net.msg:send(MsgDef_pb.MSG_REDPACKET, request:SerializeToString())
end

--申请埋雷返回
function class:responseLaymines(data)
	if data.isSuccess then

	else
		local content 
		local tips = data.tips
		if tips and tips ~= "" then
			content = tips
		else
			content = "请求埋雷失败！"
		end

		local data = {
			content = content
		}
		ui.mgr:open("Dialog/DialogView", data)
	end

	self:fireEvent(EVT.PUSH_LAYMINES, data.isSuccess)
end

function class:responseLeaveRoom(data)
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

function class:responseRoomStatus(data)
	local pushStatus = data.pushStatus
	self:parseRoomStateInfo(pushStatus.state)

	if self.roomStateInfo.roomState == Redpacket_pb.State_Snatch then
		self.snatchResult = {}
	end

	self:fireEvent(EVT.PUSH_ROOM_STATE)
end

function class:responseMember(data)
	local batchMemberStatus = data.batchMemberStatus
	local refreshList = self:parseRoomMember(batchMemberStatus.rmem)

	self:fireEvent(EVT.PUSH_MEMBER_STATUS, refreshList)
end

--服务器推送埋雷列表
function class:responseLayminesList(data)
	--更新房间状态
	self:responseRoomStatus(data)

	local pushLayminesList = data.pushLayminesList
	self:parseLayminesList(pushLayminesList.layminesList)

	-- log("*****************")
	-- log(self.layminesList)
	-- log("*****************")

	local batchMemberStatus = data.batchMemberStatus
	local refreshList = self:parseRoomMember(batchMemberStatus.rmem)

	self:fireEvent(EVT.PUSH_LAYMINES_LIST, self.layminesList)
end

function class:responseSettlement(data)
	local pushSettleResult = data.pushSettleResult
	local pushSnatchResult = pushSettleResult.pushSnatchResult

	local settlementData = {}
	for i, v in ipairs(pushSnatchResult) do
		local result = self:parseSnatchResult(v)
		settlementData[#settlementData + 1] = result
	end

	table.sort(settlementData, function (a, b)
        return a.index < b.index
    end)

	--更新玩家身上货币
    for i, v in ipairs(settlementData) do
    	local playerInfo = self.memberMap[v.member.playerId]
    	if playerInfo then
    		playerInfo.coin = v.member.coin
    	end
    end

	self:parseRoomStateInfo(pushSettleResult.roomStateInfo)
	self:parseRoomMember(data.batchMemberStatus.rmem)

	self:fireEvent(EVT.PUSH_SETTLEMENT, settlementData)
end

function class:responseFloor(data, isFire)
	local pushFloorInfo = data.pushFloorInfo
	if pushFloorInfo == nil then
		return
	end

	isFire = isFire or false

	local redpacket = pushFloorInfo.redpacket
	local redpacketInfo = {}
	redpacketInfo.playerId = redpacket.playerId
	redpacketInfo.redpacketCoin = redpacket.redpacketCoin
	redpacketInfo.redpacketNum = redpacket.redpacketNum
	redpacketInfo.redpacketRemainder = redpacket.redpacketRemainder
	redpacketInfo.minesNum = redpacket.minesNum

	local item = {}
	item.countDown = pushFloorInfo.countDown
	item.floorIndex = pushFloorInfo.floorIndex
	item.floorType = pushFloorInfo.floorType
	item.redpacketInfo = redpacketInfo

	-- log(item)

	if item.floorType == Redpacket_pb.Add then
		table.insert(self.floorList, item)
	elseif item.floorType == Redpacket_pb.Delete then
		for i, v in ipairs(self.floorList) do
			if v.floorIndex == item.floorIndex then
				table.remove(self.floorList, i)
				break
			end
		end
	else
		for i, v in ipairs(self.floorList) do
			if v.floorIndex == item.floorIndex then
				v.countDown = item.countDown
				v.redpacketInfo = item.redpacketInfo
				break
			end
		end
	end

	self:fireEvent(EVT.PUSH_FLOOR, item)
end

--奖励金
function class:responseBonus(data)
	self.bonusList = {}

	local pushBonus = data.pushBonus
	if pushBonus then
		for i, v in ipairs(pushBonus.bonus) do
			table.insert(self.bonusList, tonumber(v))
		end
	end

	-- log(self.bonusList)

	self:fireEvent(EVT.PUSH_BONUS, self.bonusList)
end

--申请领取奖励金
function class:requestBonusTake(bonusIndex)
	local request = Redpacket_pb.RedpacketRequest()
	request.requestType = Redpacket_pb.Request_Bonus_Take
	request.room.roomId = self.roomInfo.roomId
	request.room.playId = self.roomInfo.playId
	request.room.typeId = self.roomInfo.typeId

	request.bonusTakeRequest.bonusIndex = bonusIndex

	net.msg:send(MsgDef_pb.MSG_REDPACKET, request:SerializeToString())
end

--奖励金领取
function class:responseBonusTake(data)
	if data.isSuccess then

	else
		local content 
		local tips = data.tips
		if tips and tips ~= "" then
			content = tips
		else
			content = "奖励金领取失败！"
		end

		local data = {
			content = content
		}
		ui.mgr:open("Dialog/DialogView", data)
	end

	self:fireEvent(EVT.PUSH_BONUS_TAKE, data.isSuccess)
end

function class:parseRoomInfo(info)
	if info == nil then
		log4model:warn("Redpacket :: parse room info error ! data is nil !")
		return
	end

	if info.playId ~= nil then self.roomInfo.playId = info.playId end
	if info.typeId ~= nil then self.roomInfo.typeId = info.typeId end
	if info.roomId ~= nil then self.roomInfo.roomId = info.roomId end
	if info.currencyType ~= nil then self.roomInfo.currencyType = info.currencyType end
	if info.maxPlayerNum ~= nil then self.roomInfo.maxPlayerNum = info.maxPlayerNum end
	if info.minPlayerNum ~= nil then self.roomInfo.minPlayerNum = info.minPlayerNum end

	self.roomInfo.numberRanges = {}
	--红包个数范围
	local numberRanges = info.numberRanges
	for _, num in ipairs(numberRanges) do
		table.insert(self.roomInfo.numberRanges, tonumber(num))
	end

	table.sort(self.roomInfo.numberRanges, function (a, b)
        return a < b
    end)

	self.roomInfo.coinRanges = {}
	--红包金额范围
	local coinRanges = info.coinRanges
	for _, value in ipairs(coinRanges) do
		table.insert(self.roomInfo.coinRanges, tonumber(value))
	end

	table.sort(self.roomInfo.coinRanges, function (a, b)
        return a < b
    end)

	--倍数
	self.roomInfo.mutiple = info.mutiple
end

function class:parseRoomMember(info)
	if info == nil then
		log4model:warn("Redpacket :: parse room member error ! data is nil !")
		return nil
	end

	local refreshList = {}

	for i, v in ipairs(info) do
		if v.memberType ~= Common_pb.Leave then
			local item = {}
			item.playerId = v.playerId
			if v.memberType ~= nil then item.memberType = v.memberType end
			if v.playerName ~= nil then item.playerName = v.playerName end
			if v.headimage ~= nil then item.headimage = v.headimage end
			if v.coin ~= nil then item.coin = tonumber(v.coin) or 0 end
			-- if v.isDealer ~= nil then item.isDealer  = v.isDealer end
			-- if v.isLaymines ~= nil then item.isLaymines = v.isLaymines end
			if v.isBonus ~= nil then item.isBonus = v.isBonus end --是否有奖励
			if v.winCoin ~= nil then item.winCoin = tonumber(v.winCoin) end
		
			self.memberMap[v.playerId] = item

			-- log("parseRoomMember:: memberType == " .. item.memberType)
		else
			--离开房间不用更新数据
			local item = self.memberMap[v.playerId]
			if item ~= nil then
				item.memberType = v.memberType
			else
				log("[Redpacket::parseRoomMember] parse room member info error ! memberType=="..v.memberType..", playerId=="..v.playerId)
			end
		end

		refreshList[#refreshList + 1] = v.playerId
	end

	-- log(self.memberMap)

	return refreshList
end

--埋雷列表
function class:parseLayminesList(info)
	if info == nil then
		log4model:warn("Redpacket :: parse laymines list error ! data is nil !")
		return
	end

	self.layminesList = {}

	for i, v in ipairs(info) do
		local item = {}
		item.playerId = v.playerId
		if v.memberType ~= nil then item.memberType = v.memberType end
		if v.playerName ~= nil then item.playerName = v.playerName end
		if v.headimage ~= nil then item.headimage = v.headimage end
		if v.coin ~= nil then item.coin = tonumber(v.coin) or 0 end
		if v.isBonus ~= nil then item.isBonus = v.isBonus end --是否有奖励
		if v.winCoin ~= nil then item.winCoin = tonumber(v.winCoin) or 0 end

		local redpacketInfo = {}
		local redpacket = v.redpacket
		redpacketInfo.playerId = redpacket.playerId
		redpacketInfo.redpacketCoin = redpacket.redpacketCoin
		redpacketInfo.redpacketNum = redpacket.redpacketNum
		redpacketInfo.redpacketRemainder = redpacket.redpacketRemainder
		redpacketInfo.minesNum = redpacket.minesNum
		redpacketInfo.isBlessing = redpacket.isBlessing
		item.redpacketInfo = redpacketInfo

		if not redpacketInfo.isBlessing then
			table.insert(self.layminesList, item)
		end
	end
end

function class:parseFloorInfo(info)
	if info == nil then
		log4model:warn("Redpacket :: parse floor list error ! data is nil !")
		return
	end

	self.floorList = {}
	for i, v in ipairs(info) do			
		local redpacket = v.redpacket
		local redpacketInfo = {}		
		redpacketInfo.playerId = redpacket.playerId
		redpacketInfo.redpacketCoin = redpacket.redpacketCoin
		redpacketInfo.redpacketNum = redpacket.redpacketNum
		redpacketInfo.redpacketRemainder = redpacket.redpacketRemainder
		redpacketInfo.minesNum = redpacket.minesNum

		local item = {}	
		item.countDown = v.countDown
		item.floorIndex = v.floorIndex
		item.floorType = v.floorType
		item.redpacketInfo = redpacketInfo

		if redpacketInfo.redpacketRemainder > 0 then
			table.insert(self.floorList, item)
		end
	end	

	-- log(self.floorList)
end

function class:parseSnatchResult(info)
	if info == nil then
		log4model:warn("Redpacket :: parse snatch result error ! data is nil !")
		return nil
	end

	local result  = {}
	local item = {}
	local member = info.member
	item.playerId = member.playerId
	if member.memberType ~= nil then item.memberType = member.memberType end
	if member.playerName ~= nil then item.playerName = member.playerName end
	if member.headimage ~= nil then item.headimage = member.headimage end
	if member.coin ~= nil then item.coin = tonumber(member.coin) or 0 end
	-- if member.isDealer ~= nil then item.isDealer  = member.isDealer end
	-- if member.isLaymines ~= nil then item.isLaymines = member.isLaymines end
	if member.isBonus ~= nil then item.isBonus = member.isBonus end --是否有奖励
	if member.winCoin ~= nil then item.winCoin = tonumber(member.winCoin) or 0 end

	result.member = item
	result.isBomb = info.isBomb
	result.winCoin = tonumber(info.winCoin) --抢红包所得
	result.resultCoin = tonumber(info.resultCoin) --结算结果(中雷扣除后
	result.index = info.index --序号
	result.isFloor = info.isFloor --是否爬楼红包
	return result
end

function class:parseRoomStateInfo(info)
	if info == nil then
		log4model:warn("Redpacket :: parse room state error ! data is nil !")
		return
	end

	self.roomStateInfo.roomState = info.state
	self.roomStateInfo.countDown = info.countDown
	self.roomStateInfo.isBlessing = info.isBlessing --是否金猪送福

	--红包信息
	local redpacketInfo = {}
	local redpacket = info.redpacket
	redpacketInfo.playerId = redpacket.playerId
	redpacketInfo.redpacketCoin = redpacket.redpacketCoin
	redpacketInfo.redpacketNum = redpacket.redpacketNum
	redpacketInfo.redpacketRemainder = redpacket.redpacketRemainder
	redpacketInfo.minesNum = redpacket.minesNum
	redpacketInfo.isBlessing = redpacket.isBlessing

	self.roomStateInfo.redpacketInfo = redpacketInfo

	-- log(self.roomStateInfo)
end

