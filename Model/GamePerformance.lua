require "Protol.gamePerformance_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_GAME_PERFORMANCE",
}

class = Model.class:subclass()

--房卡场结束战绩
function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_GamePerformance, self:createEvent("onPerformanceResponse"))
end

function class:onPerformanceResponse(data)
	-- log4ui:warn(data)
	local response = gamePerformance_pb.GamePerformanceResponse()
	response:ParseFromString(data)

	local info = {}
	info.roomId = response.roomId
	info.groupConfig = response.groupConfig
	info.chipRange = response.chipRange
	info.scorePayType = response.scorePayType
	info.time = response.time
	info.ownerId = response.ownerId

	info.memberInfos = {}

	local winValue = 0
	local bigWinerId = 0

	local userId = Model:get("Account"):getUserId()
	local memberInfos = response.memberInfos
	for k, v in ipairs(memberInfos) do
		local playerInfo = {}
		playerInfo.playerId = v.playerId
		playerInfo.nickName = v.nickName
		-- playerInfo.result = v.result --结果，true-赢、false-输
		playerInfo.resultCoin = tonumber(v.resultCoin)
		if playerInfo.resultCoin >= 0 then
			playerInfo.result = true
		else
			playerInfo.result = false
		end

		if playerInfo.resultCoin > winValue then
			winValue = playerInfo.resultCoin
			bigWinerId = playerInfo.playerId
		end

		playerInfo.headImage = v.headImage

		if v.playerId == info.ownerId then
			playerInfo.isOwner = true
		else
			playerInfo.isOwner = false
		end

		if userId == v.playerId then
			info.isWin = playerInfo.result
		end

		playerInfo.isBigWiner = false

		table.insert(info.memberInfos, playerInfo)
	end

	for _, v in ipairs(info.memberInfos) do
		if v.playerId == bigWinerId then
			v.isBigWiner = true
			break
		end
	end

	-- ui.mgr:open("GameResult/GroupResultView", info)
	self:fireEvent(EVT.PUSH_GAME_PERFORMANCE, info)
end
