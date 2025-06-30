module (..., package.seeall)

local CommonConfig = require "Hall/CreateRoom/CommonConfig"

prototype = CommonConfig.prototype:subclass()

function prototype:enter()
	self.size = self.rootNode:getContentSize()

	self:bindModelEvent("Games/Niuniu.EVT.PUSH_CLUB_CREATE_ROOM", "onPushClubCreateRoom")

	self:bindUIEvent("Config.ChipRange", "uiEvtChangeChipRange")
	self:bindUIEvent("Config.DealerTypeRange", "uiEvtDealerTypeRange")
	self:bindUIEvent("Config.GroupConfig", "uiEvtChangeGroupNum")
end

--获取配置信息
function prototype:getConfigInfo(lastParam)
	local configInfo = {}
	lastParam = lastParam or false
	if lastParam then
		--获取上次记录数据
		local varKey = "Room_Niuniu_"..self.data.config.currencyType.."_"..self.data.typeValue
		local varStr = db.var:getUsrVar(varKey)		
		if varStr == nil or varStr == "" then

		else
			configInfo = json.decode(varStr)
		end
		-- log(configInfo)
	end

	local configData = {
		{key = "C_groupConfig", selType = "single", txtType = "ItemShortText", default = configInfo["C_groupConfig"] or 1, event = "Config.GroupConfig"},
		-- {key = "C_scorePayType", selType = "single", txtType = "ItemRichText", default = 1},
		{key = "C_chipRange", selType = "single", txtType = "ItemShortText", default = configInfo["C_chipRange"] or 1, event = "Config.ChipRange"},
		{key = "C_baseChipRange", selType = "single", txtType = "ItemShortText", default = configInfo["C_baseChipRange"] or 1, event = "Config.ChipRange", hide = true},
		{key = "C_limit", selType = "limit", txtType = "ItemLimitText", default = configInfo["C_limit"] or 1},
		{key = "C_specialType", selType = "multi", txtType = "ItemShortText", default = configInfo["C_specialType"] or 3},
		{key = "C_multiplyRule", selType = "single", txtType = "ItemLongText", default = configInfo["C_multiplyRule"] or 1},
		{key = "C_showCardNum", selType = "single", txtType = "ItemShortText", default = configInfo["C_showCardNum"] or 1},
	}

	--俱乐部有抽水
	-- log("NiuniuConfig::clubId = " .. self.clubId)
	if self.clubId then
		table.insert(configData, 2, {key = "C_scorePayType", selType = "single", txtType = "ItemPayText", default = 1})
	end

	return configData
end

function prototype:refresh(data)
	super.refresh(self, data)

	self:uiEvtDealerTypeRange(self.data.typeValue)

	local groupTab = self.configItem["C_groupConfig"]:getValueConfig()
	self:uiEvtChangeGroupNum(tonumber(groupTab[1]))
end

--抢庄类型变化
function prototype:uiEvtDealerTypeRange(dealerType)
	dealerType = tonumber(dealerType)
	if dealerType == NiuNiu_pb.TBNN then
		--通比牛牛
		local valueConfig = self["C_baseChipRange"]:getValueConfig()
		self:uiEvtChangeChipRange(valueConfig[1])

		self["C_baseChipRange"]:setVisible(true)
		self["C_chipRange"]:setVisible(false)
		self["C_showCardNum"]:setVisible(false)
	else
		local valueConfig = self["C_chipRange"]:getValueConfig()
		self:uiEvtChangeChipRange(valueConfig[1])
		
		self["C_baseChipRange"]:setVisible(false)
		self["C_chipRange"]:setVisible(true)

		if dealerType == NiuNiu_pb.MPQZ then
			self["C_showCardNum"]:setVisible(true)
		else
			self["C_showCardNum"]:setVisible(false)
		end
	end

	self.dealerType = dealerType
end

--局数更改，对应金币修改
function prototype:uiEvtChangeGroupNum(groupIndex)
	groupIndex = tonumber(groupIndex) / 10
	local cardConfigInfo = self:getConfigInfo(true)
	-- self["C_scorePayType"]:updateConfig(cardConfigInfo[2].default, groupIndex)

	if self.data.config.currencyType == Common_pb.Gold then
		if self.dealerType == NiuNiu_pb.TBNN then
			local chipIndex = self["C_baseChipRange"]:getValueConfig()
			chipIndex = tonumber(chipIndex[1]) + 1
			self:updatePayValue(groupIndex, chipIndex)
		else 
			local chipIndex = self["C_chipRange"]:getValueConfig()
			chipIndex = tonumber(chipIndex[1]) + 1
			self:updatePayValue(groupIndex, chipIndex)
		end

	else
		local groupConfig = string.split(self.data.config.groupConfig, ";")
		local cardConfig = string.split(groupConfig[groupIndex], ",")
		local baseNum = tonumber(cardConfig[2])

		self:fireUIEvent("CreateRoom.UpdateCardNum", baseNum)
	end
end

--底注变化，对应入场限制变化
function prototype:uiEvtChangeChipRange(rangeIndex)
	rangeIndex = tonumber(rangeIndex) + 1
	if self["C_limit"] then
		self["C_limit"]:setShowLimit(rangeIndex)
	end

	if self.data.config.currencyType == Common_pb.Gold then
		local groupTab = self.configItem["C_groupConfig"]:getValueConfig()
		local groupIndex = tonumber(groupTab[1]) / 10
		self:updatePayValue(groupIndex, rangeIndex)		
	end
end

--底注修改，扣币修改
function prototype:updatePayValue(groupIndex, chipIndex)
	local showValueTab = self.configItem["C_baseChipRange"]:getShowValueTable()
	local valueTab = showValueTab[1]
	-- log(valueTab)
	-- log("groupIndex:"..groupIndex..", chipIndex:"..chipIndex)
	-- local valueStr = string.gsub(valueTab[chipIndex], "万", "0000")
	-- log(valueStr)
	local multiple = tonumber(valueTab[chipIndex]) / tonumber(valueTab[1])

	local cardConfigInfo = self:getConfigInfo(true)

	local groupConfig = string.split(self.data.config.groupConfig, ";")
	local cardConfig = string.split(groupConfig[groupIndex], ",")
	local baseNum = tonumber(cardConfig[2])

	self:fireUIEvent("CreateRoom.UpdateCardNum", baseNum * multiple)

	if self["C_scorePayType"] then
		local clubData = Model:get("Club"):getClubData(self.clubId)
		local payValue = clubData.baseDraw * multiple * groupIndex
		self["C_scorePayType"]:setPayValue(payValue)
	end
end

--创建房间
function prototype:createCardRoomByConfig(typeValue, clubId)
	local configData = self.data.config
	if configData then
		local configInfo = {}
		configInfo.playId = self.data.config.playId
		configInfo.typeId = self.data.config.typeId
		configInfo.currencyType = self.data.config.currencyType
		configInfo.maxPlayerNum = self.data.config.maxPlayerNum
		configInfo.minPlayerNum = self.data.config.minPlayerNum
		configInfo.config = {}

		local saveConfigStr = {}
		for k, v in pairs(self.configItem) do
			if k ~= "C_scorePayType" then
				configInfo.config[k] = v:getValueConfig()

				saveConfigStr[k] = v:getKeyConfig()
			end
		end

		configInfo.config["C_dealerTypeRange"] = typeValue

		saveConfigStr["C_dealerTypeRange"] = typeValue

		-----保存配置信息------
		local varKey = "Room_Niuniu_"..self.data.config.currencyType.."_"..typeValue
		local varStr = json.encode(saveConfigStr)
		db.var:setUsrVar(varKey, varStr)

		-- log(varStr)

		-- log(configInfo.config)

		Model:get("Games/Niuniu"):requestCreateCardRoom(configInfo, clubId)

		self:fireUIEvent("CreateRoomGame")
	else
		log4warn("[NiuniuConfig::createCardRoomByConfig] get table config data error !!!")
	end
end

function prototype:onPushClubCreateRoom()
	self:fireUIEvent("CreateRoom.ClubManager")
end

