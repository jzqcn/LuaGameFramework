module(..., package.seeall)

class = Model.class:subclass()

EVT = Enum
{	
	"PUSH_HALL_USER_DATA",
	-- "GOLDTYPE", --金币模式
	-- "CARDTYPE",	--房卡模式
}

-- CURRENCY = Enum
-- {
-- 	"SCORE",	--计分
-- 	"SILVER",	--银两
-- 	"GOLD", 	--元宝
-- }

function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_HALL_DATA, self:createEvent("onHallData"))
    self.goldItemTable = {}
    self.cardItemTable = {}
    -- self.cardScoreIdTable = {}
    -- self.cardCoinIdTable = {}
end

function class:onHallData(data)
	local hallData = HallData_pb.HallDataResponse()
	hallData:ParseFromString(data)

	self.goldItemTable = {}
	self.cardItemTable = {}
    -- self.cardScoreIdTable = {}
    -- self.cardCoinIdTable = {}

	local playDatas = hallData.playDatas
	-- local goldOpenNum = 0
	-- local scoreOpenNum = 0
	for k, v in ipairs(playDatas) do
		if v then 
			-- log("hall data type :"..v.playType)
			if v.playType == HallData_pb.Gold then
				local goldData = v.goldData
				local item = {}
				item.typeId = goldData.typeId
				item.name = goldData.name
				item.isOpen = goldData.isOpen or false
				item.itemName = goldData.itemName
				item.sort = goldData.sort or 1

				if item.isOpen == true then					
					self.goldItemTable[#self.goldItemTable + 1]  = item
				end
				-- log("gold type id:"..goldData.typeId..", itemName:"..goldData.itemName)

			elseif v.playType == HallData_pb.Card then
				local cardData = v.cardData
				local item = {}
				item.typeId = cardData.typeId
				item.name = cardData.name
				item.isOpen = cardData.isOpen or false
				item.itemName = cardData.itemName
				item.sort = cardData.sort

				if item.isOpen == true then					
					self.cardItemTable[#self.cardItemTable + 1] = item
				end

				-- log("card type id:"..cardData.typeId..", itemName:"..cardData.itemName)
			end
		end
	end

	if StageMgr:isStage("Hall") then
		self:fireEvent(EVT.PUSH_HALL_USER_DATA)
	else
		StageMgr:chgStage("Hall")
	end

	-- if StageMgr:isStage("Login") then
	-- 	StageMgr:chgStage("Loading")
	-- else
	-- 	StageMgr:chgStage("Hall")
	-- end

	--心跳
	Model:get("HeartBeat"):startUpdateHeart()
end

function class:getGoldItemTable()
	return self.goldItemTable
end

function class:getGoldItem(typeId)
	for k, v in ipairs(self.goldItemTable) do
		if v.typeId == typeId then
			return v
		end
	end

	return nil
end

function class:getCardItemTable()
	return self.cardItemTable
end

function class:getCardItem(typeId)
	for k, v in ipairs(self.cardItemTable) do
		if v.typeId == typeId then
			return v
		end
	end

	return nil
end

function class:getCardTypeId(gameName)
	for k, v in ipairs(self.cardItemTable) do
		if v.itemName == gameName then
			return v.typeId
		end
	end

	return 0
end
