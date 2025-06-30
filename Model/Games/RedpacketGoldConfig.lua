
local GameBaseConfig = require "Games.BaseConfig"

require "Protol.RedpacketGoldConfig_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_LEVEL_CONFIG_DATA",
}

class = GameBaseConfig.class:subclass()

local RedpacketGoldConfig_pb = RedpacketGoldConfig_pb
local MsgDef_pb = MsgDef_pb

--消息公告
function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_REDPACKET_GOLD_CONFIG, self:createEvent("onGoldConfigResponse"))
end

function class:requestGetLevelConfig(typeId)
	local request = RedpacketGoldConfig_pb.RedpacketGoldConfigRequest()
	request.typeId = typeId
	net.msg:send(MsgDef_pb.MSG_REDPACKET_GOLD_CONFIG, request:SerializeToString())
end

function class:onGoldConfigResponse(data)
	if not StageMgr:isStage("Hall") then
		return
	end

	self.goldTable = {}

	local response = RedpacketGoldConfig_pb.RedpacketGoldConfigResponse()
	response:ParseFromString(data)

	if response.isSuccess == true then
		local levelInfo = response.levelInfo

		for i, v in ipairs(levelInfo) do
			if v then
				local item = {}
				item.playId = v.playId
				item.typeId = v.typeId
				item.currencyType = v.currencyType
				item.name = v.name
				item.minLimit = v.minLimit --投注限制
				item.minPlayerNum = v.minPlayerNum
				item.maxPlayerNum = v.maxPlayerNum

				item.numberRanges = {}
				--红包个数范围
				local numberRanges = v.numberRanges
				for _, num in ipairs(numberRanges) do
					table.insert(item.numberRanges, tonumber(num))
				end

				table.sort(item.numberRanges, function (a, b)
			        return a < b
			    end)

				item.coinRanges = {}
				--红包金额范围
				local coinRanges = v.coinRanges
				for _, value in ipairs(coinRanges) do
					table.insert(item.coinRanges, tonumber(value))
				end

				table.sort(item.coinRanges, function (a, b)
			        return a < b
			    end)

				--倍数
				item.mutiple = v.mutiple
				
				-- log(item)

				if v.currencyType == Common_pb.Sliver then
					--银两
					-- table.insert(self.silverTable, item)
				elseif v.currencyType == Common_pb.Gold then
					--元宝
					table.insert(self.goldTable, item)
				end
			end
		end

		self:fireEvent(EVT.PUSH_LEVEL_CONFIG_DATA, self.goldTable)
	else
		local info =
		{
			content = response.tips,
		}
		ui.mgr:open("Dialog/DialogView", info)
	end
end

