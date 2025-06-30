local GameBaseConfig = require "Games.BaseConfig"

require "Protol.DantiaoGoldConfig_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_LEVEL_CONFIG_DATA",
}

class = GameBaseConfig.class:subclass()

function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_DANTIAO_GOLD_CONFIG, self:createEvent("onGoldConfigData")) 
end

function class:requestGetLevelConfig(typeId)
	local request = DantiaoGoldConfig_pb.DantiaoGoldConfigRequest()
	request.typeId = typeId
	net.msg:send(MsgDef_pb.MSG_DANTIAO_GOLD_CONFIG, request:SerializeToString())
end

function class:onGoldConfigData(data)
	if not StageMgr:isStage("Hall") then
		return
	end

	self.silverTable = {}
    self.goldTable = {}

	local response = DantiaoGoldConfig_pb.DantiaoGoldConfigResponse()
	response:ParseFromString(data)

	if response.isSuccess then
		local levelInfo = response.levelInfo
		for i, v in ipairs(levelInfo) do
			if v then 
				local item = {}
				item.playId = v.playId
				item.typeId = v.typeId
				item.currencyType = v.currencyType
				item.name = v.name
				item.minLimit = v.minLimit
				item.minPlayerNum = v.minPlayerNum
				item.maxPlayerNum = v.maxPlayerNum
				item.betRanges = {}
				local betRanges = v.betRanges
				for _, bet in ipairs(betRanges) do
					table.insert(item.betRanges, tonumber(bet))
				end

				table.sort(item.betRanges, function (a, b)
			        return a < b
			    end)

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
		ui.mgr:open("Dialog/ConfirmView", info)
	end
end

