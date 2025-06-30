module (..., package.seeall)

prototype = Dialog.prototype:subclass()

--玩家列表 按照玩家下注多少排行
function prototype:enter(divinerId)
	local roomMember = Model:get("Games/Longhudou"):getRoomMember()
	local memberList = table.values(roomMember)

	--富豪榜：按总下注排序
	table.sort(memberList, function (a, b)
        return a.totalBetCoin > b.totalBetCoin
    end)

    local richList = memberList

	local tableData = {}
	for i, v in ipairs(richList) do
		local item = {cell_data = v}
		if v.playerId == divinerId then
			table.insert(tableData, 1, item)
		else
			table.insert(tableData, item)
		end
	end

	self:createTableView(tableData)

	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.imgBg, actionOver)
end

function prototype:hasBgMask()
    return false
end

-----------tableView began-----------
function prototype:createTableView(playerData)
 	self.data = playerData

	local tableData = {
		size = cc.size(870, 565),
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

function prototype:getCsbName(tb, idx)
	return "Longhudou/PlayerListViewItem"
end

--设置cell大小,
function prototype:tableCellSizeForIndex(tb, idx)
	local size

	if tb == self.tableview then
		if self.data[idx].cell_size then
			size = self.data[idx].cell_size
		else
			size = cc.size(875, 102)
		end
	end
	return size
end

-----------tableView end-----------

function prototype:onBtnCloseClick()
	self:close()
end

