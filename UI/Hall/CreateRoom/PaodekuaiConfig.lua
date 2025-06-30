module (..., package.seeall)

local CommonConfig = require "Hall/CreateRoom/CommonConfig"

prototype = CommonConfig.prototype:subclass()

function prototype:enter()
	self.size = self.rootNode:getContentSize()

	self:bindModelEvent("Games/Paodekuai.EVT.PUSH_CLUB_CREATE_ROOM", "onPushClubCreateRoom")

	self:bindUIEvent("Config.GroupConfig", "uiEvtChangeGroupNum")
	self:bindUIEvent("Config.ChipRange", "uiEvtChangeChipRange")
end

--获取配置信息
function prototype:getConfigInfo(lastParam)
	local configInfo = {}
	lastParam = lastParam or false
	if lastParam then
		--获取上次记录数据
		local varKey = "Room_Paodekuai_"..self.data.config.currencyType.."_"..self.data.typeValue
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
		{key = "C_cardCountConfig", selType = "single", txtType = "ItemShortText", default = configInfo["C_cardCountConfig"] or 1},
		{key = "C_baseChipRange", selType = "single", txtType = "ItemShortText", default = configInfo["C_baseChipRange"] or 1, event = "Config.ChipRange"},
		{key = "C_limit", selType = "limit", txtType = "ItemLimitText", default = configInfo["C_limit"] or 1},
		{key = "C_isViewCount", selType = "single", txtType = "ItemShortText", default = configInfo["C_isViewCount"] or 1},
		{key = "C_is4with3", selType = "single", txtType = "ItemShortText", default = configInfo["C_is4with3"] or 1},
	}

	--俱乐部有抽水
	if self.clubId then
		table.insert(configData, 2, {key = "C_scorePayType", selType = "single", txtType = "ItemPayText", default = 1})
	end

	return configData
end

function prototype:refresh(data)
	super.refresh(self, data)

	local groupTab = self.configItem["C_groupConfig"]:getValueConfig()
	-- log(groupTab)
	self:uiEvtChangeGroupNum(tonumber(groupTab[1]))

	if self["C_baseChipRange"] then
		local chipIndex = self["C_baseChipRange"]:getValueConfig()
		chipIndex = tonumber(chipIndex[1]) + 1
		if self["C_limit"] then
			self["C_limit"]:setShowLimit(chipIndex)
		end
	end
	-- log(data)
end

--局数更改，对应金币修改
function prototype:uiEvtChangeGroupNum(groupIndex)
	groupIndex = tonumber(groupIndex) / 8

	local cardConfigInfo = self:getConfigInfo(true)

	if self["C_baseChipRange"] then
		local chipIndex = self["C_baseChipRange"]:getValueConfig()
		chipIndex = tonumber(chipIndex[1]) + 1

		self:updatePayValue(groupIndex, chipIndex)
	else
		--计分
		local groupConfig = string.split(self.data.config.groupConfig, ";")
		local cardConfig = string.split(groupConfig[groupIndex], ",")
		local baseNum = tonumber(cardConfig[2])
		self:fireUIEvent("CreateRoom.UpdateCardNum", baseNum)
		-- self["C_scorePayType"]:updateConfig(cardConfigInfo[2].default, groupIndex)
	end
end

--底注变化，对应入场限制变化
function prototype:uiEvtChangeChipRange(rangeIndex)
	rangeIndex = tonumber(rangeIndex) + 1
	if self["C_limit"] then
		self["C_limit"]:setShowLimit(rangeIndex)
	end

	-- if self["C_scorePayType"] then
		local groupTab = self.configItem["C_groupConfig"]:getValueConfig()
		-- log(groupTab)
		local groupIndex = tonumber(groupTab[1]) / 8
		self:updatePayValue(groupIndex, rangeIndex)		
	-- end
end

--底注50/100/200/500，开放扣币按50的倍数
function prototype:updatePayValue(groupIndex, chipIndex)
	local showValueTab = self.configItem["C_baseChipRange"]:getShowValueTable()
	local valueTab = showValueTab[1]
	local multiple = tonumber(valueTab[chipIndex]) / tonumber(valueTab[1])
	--50和100使用相同扣费
	if multiple >= 2 then
		multiple = multiple / 2
	end

	-- local cardConfigInfo = self:getConfigInfo(true)

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
		configInfo.config = {}

		local saveConfigStr = {}
		for k, v in pairs(self.configItem) do
			if k ~= "C_scorePayType" then
				configInfo.config[k] = v:getValueConfig()

				saveConfigStr[k] = v:getKeyConfig()
			end
		end

		-----保存配置信息------
		local varKey = "Room_Paodekuai_"..self.data.config.currencyType.."_"..typeValue
		local varStr = json.encode(saveConfigStr)
		db.var:setUsrVar(varKey, varStr)

		-- log(varStr)

		Model:get("Games/Paodekuai"):requestCreateCardRoom(configInfo, clubId)

		self:fireUIEvent("CreateRoomGame")
	else
		log4warn("[PaodekuaiConfig::createCardRoomByConfig] get table config data error !!!")
	end
end

function prototype:onPushClubCreateRoom()
	self:fireUIEvent("CreateRoom.ClubManager")
end

