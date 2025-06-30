local GameBaseConfig = require "Games.BaseConfig"

require "Protol.PaoDeKuaiGoldConfig_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_LEVEL_CONFIG_DATA",
}

class = GameBaseConfig.class:subclass()

--消息公告
function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_PAODEKUAI_GOLD_CONFIG, self:createEvent("onGoldConfigResponse"))
end

function class:requestGetLevelConfig(typeId)
	local request = PaoDeKuaiGoldConfig_pb.PaoDeKuaiGoldConfigRequest()
	request.typeId = typeId
	net.msg:send(MsgDef_pb.MSG_PAODEKUAI_GOLD_CONFIG, request:SerializeToString())
end

function class:onGoldConfigResponse(data)
	if not StageMgr:isStage("Hall") then
		return
	end

	self.silverTable = {}
    self.goldTable = {}

	local response = PaoDeKuaiGoldConfig_pb.PaoDeKuaiGoldConfigResponse()
	response:ParseFromString(data)
	-- log("receive paodekuai gold config data")

	if response.isSuccess == true then
		local levelInfo = response.levelInfo

		-- table.sort(levelInfo, function (a, b)
	 --        return a.playId < b.playId
	 --    end)

		for i, v in ipairs(levelInfo) do
			if v then
				local item = {}
				item.playId = v.playId
				item.typeId = v.typeId
				item.currencyType = v.currencyType
				item.name = v.name
				item.roomLevel = tonumber(v.roomLevel)
				item.minCoin = v.minCoin --入场下限
				item.maxCoin = v.maxCoin --入场上限
				item.baseChip = v.baseChip
				item.minPlayerNum = v.minPlayerNum
				item.maxPlayerNum = v.maxPlayerNum
				item.onlineNum = v.onlineNum or 0 --在线人数

				-- log("index : "..i..", playId:"..v.playId..", typeId:"..v.typeId..", roomLevel:"..v.roomLevel)
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
		ui.mgr:open("Dialog/ConfirmView", info)
	end
end



