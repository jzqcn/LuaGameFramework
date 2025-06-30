require "Protol.Ranking_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_RANK_DATA",
}

class = Model.class:subclass()

--消息公告
function class:initialize()
    super.initialize(self)

    self.goldRank = {}
    -- self.silverRank = {}

    self.requestEnable = true

    net.msg:on(MsgDef_pb.MSG_RANKING, self:createEvent("onRankData"))
end

function class:clear()
	self.goldRank = {}
    -- self.silverRank = {}

    self.requestEnable = true
end

function class:onEnableRequest()
	self.requestEnable = true
end

function class:requestGoldRankData()
	if self.requestEnable or #self.goldRank == 0 then
		local request = Ranking_pb.RankingRequest()
		request.rankType = Ranking_pb.GoldRank
		net.msg:send(MsgDef_pb.MSG_RANKING, request:SerializeToString())

		self.requestEnable = false
		util.timer:after(1000 * 60, self:createEvent("onEnableRequest"))
	else
		util.timer:after(100, function()
			self:fireEvent(EVT.PUSH_RANK_DATA, Ranking_pb.GoldRank, self.goldRank)
		end)
	end
end

--[[function class:requestSilverRankData()
	if self.requestEnable or #self.silverRank == 0 then
		local request = Ranking_pb.RankingRequest()
		request.rankType = Ranking_pb.SliverRank
		net.msg:send(MsgDef_pb.MSG_RANKING, request:SerializeToString())
	else
		util.timer:after(150, function()
			self:fireEvent(EVT.PUSH_RANK_DATA, Ranking_pb.SliverRank, self.silverRank)
		end)
	end
end--]]

function class:onRankData(data)
	local response = Ranking_pb.RankingResponse()
	response:ParseFromString(data)

	local rankType = response.rankType
	local entrys = response.entrys
	local rankData = {}
	for i, v in ipairs(entrys) do
		local item = {}
		item.playerId = v.playerId
		item.name = v.name
		item.rank = v.rank
		item.rankvalue = v.rankvalue
		item.headImage = v.headImage
		item.personalSign = v.personalSign
		item.rankType = rankType

		rankData[#rankData + 1] = item

		-- log(item)
	end

	-- log(rankData)

	if rankType == Ranking_pb.GoldRank then
		self.goldRank = rankData
	-- else
	-- 	self.silverRank = rankData

		self:fireEvent(EVT.PUSH_RANK_DATA, rankType, rankData)
	end
end

function class:getRankData(rankType)
	if rankType == Ranking_pb.GoldRank then
		return self.goldRank
	-- else
	-- 	return self.silverRank
	end

	return nil
end