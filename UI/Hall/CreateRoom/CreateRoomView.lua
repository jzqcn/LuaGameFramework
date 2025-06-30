module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter(data)
	self:bindUIEvent("SelectCardTabItem", "uiEvtHandleCardTabItem")
	self:bindUIEvent("CreateRoomGame", "uiEvtCreateRoomGame")

	self:bindUIEvent("CreateRoom.UpdateCardNum", "uiEvtUpdateCardNum")
	self:bindUIEvent("CreateRoom.ClubManager", "uiEvtClubManagerCreate")

	-- ui.mgr:setSceneImageBg(self.imgBg, true)

	local currencyType = data.currencyType
	local gameName = data.gameName
	local typeId = data.typeId

	self.gameName = gameName
	self.clubId = data.clubId

	local gameCardTab = {}
	local dbName = gameName.."CardConfig"
	local dbData = db.mgr:getDB(dbName, {typeId = typeId, currencyType = currencyType})
	if dbData and #dbData > 0 then
		if gameName == "Niuniu" then
			--牛牛中所有数据配置只有一行（根据抢庄类型分类）
			local roomConfig = dbData[1]
			-- log(roomConfig.C_dealerType)
			local strTable = string.split(roomConfig.C_dealerType, "#")
			local typeItems = string.split(strTable[1], ";")
			local params = string.split(strTable[2], ";")
			for i, v in ipairs(typeItems) do
				local item = {index = i, config = roomConfig, typeKey = v, typeValue = params[i], clubId = data.clubId}
				gameCardTab[#gameCardTab + 1] = item
			end
		else
			--其他游戏，根据分类配置多行数据（暂定）
			for i, v in ipairs(dbData) do
				gameCardTab[#gameCardTab + 1] = {index = i, config = v, typeKey = v.C_typeName, typeValue = i, clubId = data.clubId}
			end
		end
		-- gameCardTab[index] = item
	else
		log4ui:warn("get db dbData failed ! db name == "..dbName..", typeId == "..typeId..", currencyType == "..currencyType)
	end

	local param = 
	{
		data = gameCardTab,
		ccsNameOrFunc = "Hall/CreateRoom/CreateRoomTabItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.listviewLeft:createItems(param)
    self.listviewLeft:setScrollBarEnabled(false)
	self.listviewRight:setScrollBarEnabled(false)

    local selIndex = 1
    --读取上次选择游戏玩法
    local varKey = "Room_GAME_TAB_"..currencyType.."_"..gameName
	local varStr = db.var:getUsrVar(varKey)
	if varStr and varStr ~= "" then
		local saveIndex = tonumber(varStr)
		if saveIndex > 0 and saveIndex <= #gameCardTab then
			selIndex = saveIndex
		end
	end

    self:updateSelectTabData(gameCardTab[selIndex])
    self.currencyType = currencyType

	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))

	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.rootNode, actionOver)
end

function prototype:updateSelectTabData(data)
	if not data then
		return
	end

	if self.selectIndex and self.selectIndex > 0 then
		local node = self.listviewLeft:getSubItemByIdx(self.selectIndex)
    	node:setSelected(false)
	end

	self.selectIndex = data.index
	self.selectData = data
    local node = self.listviewLeft:getSubItemByIdx(self.selectIndex)
    node:setSelected(true)

    local param = 
    {
    	data = {data},
    	ccsNameOrFunc = string.format("Hall/CreateRoom/%sConfig", self.gameName),
    	dataCheckFunc = function (info, elem) return info == elem end,
	}
	self.listviewRight:recreateListView(param)
end

function prototype:uiEvtHandleCardTabItem(data)
	if data then
		self:updateSelectTabData(data)
	end
end

--记录上次玩法类型
function prototype:uiEvtCreateRoomGame()
	local varKey = "Room_GAME_TAB_"..self.currencyType.."_"..self.gameName
	db.var:setUsrVar(varKey, tostring(self.selectIndex))
end

--房卡数量
function prototype:uiEvtUpdateCardNum(num)
	if self.clubId then
		self.txtCardDesc:setString(string.format("X%d（俱乐部）", num))
	else
		self.txtCardDesc:setString(string.format("X%d（房主）", num))
	end

	self.userCardNum = num
end

--创建房间
function prototype:onBtnCreateClick()
	if not self.clubId then
		local accountInfo = Model:get("Account"):getUserInfo()
		if accountInfo.cardNum < self.userCardNum then
			local data = {
				content = "房卡不足，无法创建房间！",
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end
	end

	-- self.listviewRight:getSubItem(self.selectData)
	local configNode = self.listviewRight:getSubItemByIdx(1)
	if configNode then
		configNode:createCardRoomByConfig(self.selectData.typeValue, self.clubId)
	end	
end

function prototype:uiEvtClubManagerCreate()
	local data = {
		content = "俱乐部房间创建成功！",
	}
	ui.mgr:open("Dialog/DialogView", data)

	--俱乐部列表刷新
	local clubView = ui.mgr:getLayer("Club/ClubView")
	if clubView then
		clubView:refreshClubView()
	end

	self:close()
end

function prototype:onBtnCloseClick()
	self:close()
end
