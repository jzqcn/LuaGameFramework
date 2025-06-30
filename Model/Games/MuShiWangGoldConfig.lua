local GameBaseConfig = require "Games.BaseConfig"

require "Protol.MuShiWangGoldConfig_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_LEVEL_CONFIG_DATA",
}

class = GameBaseConfig.class:subclass()

function class:initialize()
    super.initialize(self)
    -- self.gameName = "MuShiWang"

    net.msg:on(MsgDef_pb.MSG_MUSHIWANG_GOLD_CONFIG, self:createEvent("onGoldConfigData"))
end

function class:requestGetLevelConfig(typeId)
	local request = MuShiWangGoldConfig_pb.MuShiWangGoldConfigRequest()
	request.typeId = typeId
	net.msg:send(MsgDef_pb.MSG_MUSHIWANG_GOLD_CONFIG, request:SerializeToString())
end

function class:onGoldConfigData(data)
	if not StageMgr:isStage("Hall") then
		return
	end
	
	self.silverTable = {}
    self.goldTable = {}

	local response = MuShiWangGoldConfig_pb.MuShiWangGoldConfigResponse()
	response:ParseFromString(data)
	-- log("receive MuShiWang gold config data")

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
				item.dealerType = v.dealerType
				item.name = v.name
				item.roomLevel = tonumber(v.roomLevel)
				item.minLimit = v.minLimit
				item.maxLimit = v.maxLimit
				item.minCoin = v.minCoin
				item.maxCoin = v.maxCoin
				item.baseChip = v.baseChip
				item.minPlayerNum = v.minPlayerNum
				item.maxPlayerNum = v.maxPlayerNum
				item.dealerTypeCode = v.dealerTypeCode
				item.onlineNum = v.onlineNum or 0

				-- log("index : "..i..", playId:"..v.playId..", typeId:"..v.typeId..", roomLevel:"..v.roomLevel)
				-- log(item)

				if v.currencyType == Common_pb.Sliver then
					--银两
					table.insert(self.silverTable, item)
					-- if self.silverTable[item.dealerType] == nil then
					-- 	self.silverTable[item.dealerType] = {}
					-- end

					-- table.insert(self.silverTable[item.dealerType], item)
				elseif v.currencyType == Common_pb.Gold then
					--元宝
					table.insert(self.goldTable, item)
					-- if self.goldTable[item.dealerType] == nil then
					-- 	self.goldTable[item.dealerType] = {}
					-- end

					-- table.insert(self.goldTable[item.dealerType], item)
				end
			end
		end

		self:fireEvent(EVT.PUSH_LEVEL_CONFIG_DATA, self.goldTable)
		-- ui.mgr:open("Hall/RoomLevel", {self.silverTable, self.goldTable, self.gameName})
	else
		local info =
		{
			content = response.tips,
		}
		ui.mgr:open("Dialog/ConfirmView", info)
	end
end