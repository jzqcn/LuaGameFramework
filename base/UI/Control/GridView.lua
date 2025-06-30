
local ListView = require "UI.Control.ListView"

module(..., package.seeall)

prototype = ListView.prototype:subclass()

function prototype:enter()
	self.items = {}
	self.cells = {}
end

-- {
-- 	data:数组
-- 	numPerLine:每行item个数
--  interval 间隔
--  ccsPopupName:点击弹出操作item
-- 	ccsName:
--  dataCheckFunc: item检测函数 用于update函数判断是哪个item被改变 减少刷新的数量
-- }
function prototype:createItems(info)
    assert(info.dataCheckFunc)
    self.dataCheckFunc = info.dataCheckFunc 
    self.ccsPopupName = info.ccsPopupName

    self.interval = info.interval or 0
    self.numPerLine = info.numPerLine

    if info.interval then
        self.rootNode:setItemsMargin(info.interval)
    end

    self:createItemModel(info.ccsName)
    self:createFromData(info.data)
end

function prototype:createFromData(data)
	for idx, cellData in ipairs(data) do
		self:insertOneCell(idx, cellData)
	end
end

function prototype:insertOneCell(idxOrData, cellData)
	local idx = nil
	if cellData then
		idx = idxOrData
	else
		idx = #self.cells + 1
		cellData = idxOrData
	end

	local cellItem = self:createCellItem(idx, cellData)
	local cellSize = cellItem:getContentSize()
	local x, y = self:getCellPos(idx, cellSize.width, cellSize.height)
	cellItem:setAnchorPoint(cc.p(0, 0))
	cellItem:setPosition(x, y)

	if self:isLedCell(idx) then
		local lineCntl = ccui.Widget:create()
		lineCntl:retain()
		local lineWidth, lineHeight = self:getLineSize(cellSize.width, cellSize.height)
		lineCntl:setContentSize(lineWidth, lineHeight)
		self:addLineItem(lineCntl)

		lineCntl:addChild(cellItem)
		lineCntl:release()
	else
		local lineNum = math.ceil(idx / self.numPerLine)
		local lineCntl = self.items[lineNum].node
		lineCntl:addChild(cellItem)
	end

	cellItem:release()
	if cellItem.refresh then
		cellItem:refresh(cellData)
	end
end

function prototype:createCellItem(idx, cellData)
	if self.itemModel then
        local node = self.itemModel.node:cloneWidget()
        node:retain()

        self:getLoader():loadFromClone(self.itemModel.ccsName, node)

        table.insert(self.cells, idx, {node = node, data = cellData})
        return node
    end
end

function prototype:removeOneCellByIdx(idx)
	local cell = self.cells[idx]
	if cell == nil then
		return
	end

	cell.node:removeFromParent(true)
	table.remove(self.cells, idx)

	self:doLineLayout()
end

function prototype:getItemIndex(data)
	if data == nil then
		return -1, -1
	end

	for idx, v in ipairs(self.cells) do
		if self.dataCheckFunc(data, v.data) then
			return math.ceil(idx / self.numPerLine), idx
		end
	end

	return -1, -1
end

function prototype:addLineItem(lineCntl)
    table.insert(self.items, {node=lineCntl})
    self.rootNode:pushBackCustomItem(lineCntl)
end

function prototype:removeLineItem(idx)
	local lineNum = math.ceil(idx / self.numPerLine)
	table.remove(self.items, lineNum)
    self.rootNode:removeItem(lineNum - 1)
end

function prototype:isLedCell(idx)
	return (idx % self.numPerLine) == 1
end

function prototype:getCellPos(idx, nodeWidth, nodeHeight)
	local dir = self.rootNode:getDirection()
	local x, y = 0, 0
	if dir == ccui.ScrollViewDir.horizontal then
		local _, lineHeight = self:getLineSize(nodeWidth, nodeHeight)
		y = ((idx - 1) % self.numPerLine + 1) * (nodeHeight + self.interval) - self.interval
		y = lineHeight - y
	else
		x = ((idx - 1) % self.numPerLine) * (nodeWidth + self.interval)
	end

	return x, y
end

function prototype:getLineSize(nodeWidth, nodeHeight)
	local dir = self.rootNode:getDirection()
	if dir == ccui.ScrollViewDir.horizontal then
		return nodeWidth, (nodeHeight + self.interval) * self.numPerLine - self.interval
	end

	return (nodeWidth + self.interval) * self.numPerLine - self.interval, nodeHeight
end

function prototype:getSubItem(data)
	for _, v in ipairs(self.cells) do
		if self.dataCheckFunc(v.data, data) then
			return v.node
		end
	end
end

function prototype:recreateGridView(info)
	self.rootNode:removeAllItems()
    self.items = {}
    self.cells = {}

	self.dataCheckFunc = info.dataCheckFunc or self.dataCheckFunc
    self.ccsPopupName = info.ccsPopupName or self.ccsPopupName

    self.interval = info.interval or self.interval
    self.numPerLine = info.numPerLine or self.numPerLine

    if info.interval then
        self.rootNode:setItemsMargin(info.interval)
    end

    if info.ccsName then
    	self.itemModel = nil
	    self:createItemModel(info.ccsName)
	end

    self:createFromData(info.data)
end

function prototype:refreshGridView(data)
	local cellSize = #self.cells
	local dataSize = #data

	if cellSize > dataSize then
		for i=cellSize, dataSize+1, -1 do
			self:removeOneCellByIdx(i)
		end
	end

	for idx, v in ipairs(data) do
		local cell = self.cells[idx]
		if cell ~= nil then
			cell.data = v
			if cell.node.refresh then
				cell.node:refresh(v)
			end
		else
			self:insertOneCell(idx, v)
		end
	end
end

function prototype:getAllItems()
	local items = {}
	for _, v in ipairs(self.cells) do
		table.insert(items, v.node)
	end
	return items
end

function prototype:getSubCellByIdx(idx)
	local cell = self.cells[idx]
	if not cell then
		return nil
	end

	return cell.node, cell.data
end

function prototype:removeOneCellByIdxAndLayout(idx)
	self:removeOneCellByIdx(idx)
	self:doLayout()
end

function prototype:doLayout()
	for idx, cell in ipairs(self.cells) do
		local cellItem = cell.node

		cellItem:retain()
		cellItem:removeFromParent(true)

		local cellSize = cellItem:getContentSize()
		local x, y = self:getCellPos(idx, cellSize.width, cellSize.height)
		cellItem:setAnchorPoint(cc.p(0, 0))
		cellItem:setPosition(x, y)

		local lineNum = math.ceil(idx / self.numPerLine)
		local lineCntl = self.items[lineNum].node
		lineCntl:addChild(cellItem)
		cellItem:release()
	end

	self:doLineLayout()
end

function prototype:doLineLayout()
	local emptyNum = nil
	for k, line in ipairs(self.items) do
		local lineCntl = line.node
		if lineCntl:getChildrenCount() == 0 then
			self.rootNode:removeItem(k - 1)
			emptyNum = k
		end
	end

	if emptyNum then
		table.remove(self.items, emptyNum)
	end
end