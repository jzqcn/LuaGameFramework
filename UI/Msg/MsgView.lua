module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	local mailMsg = Model:get("Announce"):getMailMsg()
	-- log(mailMsg)
	-- local param = 
	-- {
	-- 	data = mailMsg,
	-- 	ccsNameOrFunc = "Msg/MsgViewItem",
	-- 	dataCheckFunc = function (info, elem) return info == elem end
	-- }
 --    self.listview:createItems(param)

    -- self.listview:setScrollBarEnabled(false)
    -- ui.mgr:setSceneImageBg(self.imgBg, true)

    -- self.listview:setVisible(false)

    local data = {}
	for i, v in ipairs(mailMsg) do
		local item = {cell_view = "Msg/MsgViewItem", cell_data = v}
		table.insert(data, item)
	end

	self:createTableView(data)

 --    local function actionOver()
	-- 	self.action:dispose()
	-- 	self.action = nil
	-- 	self.listview:setVisible(true)
	-- end
	-- self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)

	--[[local function actionOver(sender)
		sender:dispose()
	end

	local usedCells = self.tableview:getUsedCells()
	for i, v in ipairs(usedCells) do
		local action = self:createListItemBezierConfig(v, actionOver, 0.4, 0.1*(i-1))
	end]]


	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))

	self.tableview:setVisible(false)

	local function actionOver()
		self.action:dispose()
		self.action = nil

		self:itemlistAction()
	end

	self.action = self:createJumpOutBezierConfig(self.rootNode, actionOver)

	sys.sound:playEffectByFile("resource/audio/Hall/mail_enter.mp3")
	
end

function prototype:itemlistAction()
	self.isMoveAction = false

	local function actionOver(sender)
		sender:dispose()
	end

	self.tableview:setVisible(true)

	local usedCells = self.tableview:getUsedCells()
	for i, v in ipairs(usedCells) do
		local action = self:createListItemBezierConfig(v, actionOver, 0.4, 0.1*(i-1))
	end
end

-----------tableView began-----------
function prototype:createTableView(msgData)
 	self.data = msgData

 	local viewSize = self.tableview:getContentSize()

	local tableData = {
		size = viewSize, --cc.size(930, 620),
		source = self,
		csbFunc = bind(self.getCsbName, self),
		margin = 2,
		cellData = self.data,
	}

	self.tableview:createTable(tableData)
	self.tableview:reloadData()

	-- self.tableview:setEnabled(false)
	-- self.tableview:scrollToBottom(0, true)
end

function prototype:getCsbName()
	return "Msg/MsgViewItem"
end

--设置cell大小,
function prototype:tableCellSizeForIndex(tb, idx)
	local viewSize = self.tableview:getContentSize()
	local size = cc.size(0, 0)

	if tb == self.tableview then
		if self.data[idx].cell_size then
			size = self.data[idx].cell_size
		else
			size = cc.size(viewSize.width, 101)
		end
	end
	return size
end

-----------tableView end-----------

function prototype:onBtnCloseClick()
	self:close()
end