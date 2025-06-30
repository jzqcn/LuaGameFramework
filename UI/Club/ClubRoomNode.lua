module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:createTableView({})

	self.btnCreateGold:setVisible(false)
	self.btnCreateScore:setVisible(false)

	local HallView = require "Hall.HallView"
	self.sceneTypeEnabled = HallView.SCENE_TYPE_ENABLED
end

function prototype:setClubInfo(data)
	self.clubData = data
	if data then
		if self.sceneTypeEnabled[2] then
			self.btnCreateGold:setVisible(true)
		end

		if self.sceneTypeEnabled[1] then
			self.btnCreateScore:setVisible(true)
		end

	else
		self.btnCreateGold:setVisible(false)
		self.btnCreateScore:setVisible(false)
	end
end

function prototype:refreshRoomData(roomData)
	roomData = roomData or {}

	local data = {}
	for i, v in ipairs(roomData) do
		local item = {cell_view = "Club/ClubRoomNodeItem", cell_data = v}
		table.insert(data, item)
	end

	self.data = data

	self.roomTableview:setCellData(data)
	self.roomTableview:reloadData()
	self.roomTableview:scrollToIndex(0, 1)

	local function actionOver(sender)
		sender:dispose()
	end

	local usedCells = self.roomTableview:getUsedCells()
	for i, v in ipairs(usedCells) do
		self:createListItemBezierConfig(v, actionOver, 0.5, 0.15*(i-1))
	end
end

-----------tableView began-----------
function prototype:createTableView(roomData)
 	self.data = roomData

 	local viewSize = self.rootNode:getContentSize()
	local tableData = {
		size = cc.size(viewSize.width, 550),
		source = self,
		csbFunc = bind(self.getCsbName, self),
		margin = 5,
		cellData = self.data,
	}

	self.roomTableview:createTable(tableData)
	self.roomTableview:reloadData()

	-- self.roomTableview:setEnabled(false)
	-- self.roomTableview:scrollToBottom(0, true)
end

function prototype:getCsbName()
	return "Club/ClubRoomNodeItem"
end

--设置cell大小,
function prototype:tableCellSizeForIndex(tb, idx)
	local size = cc.size(0, 0)

	local viewSize = self.rootNode:getContentSize()
	if tb == self.roomTableview then
		if self.data[idx].cell_size then
			size = self.data[idx].cell_size
		else
			size = cc.size(viewSize.width, 110)
		end
	end
	return size
end

-----------tableView end-----------

function prototype:onBtnCreateGoldRoomClick(sender)
	if not self.sceneTypeEnabled[2] then
		return
	end

	-- if eventType == ccui.TouchEventType.ended then
		local gameName = StageMgr:getStage():getPlayingGameName()
		if gameName then
			StageMgr:chgStage("Game", gameName)
			return
		end

		ui.mgr:open("Hall/RoomGameView", {currencyType = Common_pb.Gold, clubId = self.clubData.id})
	-- end
end

function prototype:onBtnCreateScoreRoomClick(sender)
	if not self.sceneTypeEnabled[1] then
		return
	end

	-- if eventType == ccui.TouchEventType.ended then
		local gameName = StageMgr:getStage():getPlayingGameName()
		if gameName then
			StageMgr:chgStage("Game", gameName)
			return
		end

		ui.mgr:open("Hall/RoomGameView", {currencyType = Common_pb.Score, clubId = self.clubData.id})
	-- end
end
