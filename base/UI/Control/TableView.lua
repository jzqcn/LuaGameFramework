--tableView 使用方法
--  self.tableView:createTable(tbData) --初始化tableView
-- self.tableView:setCellMargin(10) -- 设置间隔
-- self.tableView:setCellData(self.data) --设置数据
-- data格式
--{cell_data = {name = "02"}},
-- self.tableView:reloadData(bSilent)  --重载，数据发生改变务必调用方法更改 bSlient 为true，不滑动位置，false, 移动至初始位置
-- self.tableView:removeCellAtIndex(idx, doAct) 删除指定cell ，idx 为指定的标识， doAct 是否播放删除动画，动画cell自行控制
-- self.tableView1:scrollToIndex(time, idx)  --滑动至指定位置，time, 滑动时间，idx 位置
--data_source使用方法
-- function prototype:tableCellAtIndex(tb, idx)  返回指定位置的cell
-- function prototype:numberOfCellsInTableView(tb) 返回cell的数量
-- function prototype:tableCellSizeForIndex(tb, idx) 返回cell的size
-- function prototype:removeCellData(tb, idx) 删除指定位置data
-- function prototype:addCellAtIndex(index, data, silent) 指定位置插入data

---------cell item要实现的必要方法-------
--数据刷新
--function refresh(cell_data, idx)
--  cell_data 原始数据， idx, cell所处的位置
--end

--获取cellBase 代理 需要在ccb里设定
-- function getCellBase()
--     return self.node_Cell
-- end
-----------可选方法------
--每次刷新cell前重置调用
-- function prototype:reset()
--
-- end

-- --做删除后剩余cell移动方法 
-- --time 时间
-- --size 移动的距离
-- function prototype:doMoveAction(time, size)
--     local disPos = cc.p(size.width, size.height)
--     local act = cc.MoveBy:create(time, disPos)
--     self.rootNode:runAction(act)
-- end

-- --cell删除动画
-- --actList 删除动画结束的后的操作，不需要自己设定，只需要用就可以了
-- -- table.insert(actList, 1, act)
-- function prototype:doExitAction(actList)
--     local act = cc.MoveBy:create(0.5, cc.p(600, 0))
--     table.insert(actList, 1, act)
--     local sqe = cc.Sequence:create(actList)
--     self.rootNode:runAction(sqe)
-- end



local ScrollView = require "UI.Control.ScrollView"
module(..., package.seeall)
TABLEVIEW_VERTICALFILLORDER =
{
    TOP_DOWN = 0,  -- 升序
    BOTTOM_UP = 1, -- 降序
}

local INVALID_INDEX = -1

prototype = ScrollView.prototype:subclass()

--暂时不做二级列表的支持,后续有需要再添加
function prototype:enter()
	
end

    -- local tableData = {
    --     size = cc.size(600, 200),        -- tableView大小
    --     source = self,                   -- 代理，如果想自己控制大小，
    --     csbFunc = bind(self.getCsbName2, self),  --获取csb的名字
    --     margin = 5,                      -- 间隔
    --     cellData = self.data2,           -- 源数据
    -- }
function prototype:createTable(tableData)
    self.cells_used = {}
    self.cells_freed = {}

    self.cells_positions = {}
    self.indices = {}
    self.old_direction = SCROLLVIEW_DIR_NONE
    self.is_used_cells_dirty = false
    self.vordering = TABLEVIEW_VERTICALFILLORDER.TOP_DOWN
    self.cell_size_list = {}
    self.reload_offset = nil -- 记录上一次偏移

    self.view_size = tableData.size
    self.data_source = tableData.source or self
    self.csbFunc = tableData.csbFunc
    self.cell_margin = tableData.margin or 0

    self:setViewSize(self.view_size)
    self:extendScrollView()

    self.end_offset = nil
    self.doAction = false

    self:setCellData(tableData.cellData)
end

------------------------------------------------
-- 以下为公共接口
-- 还有cocos UIScrollView的公共接口，这里不再重复提示

-- public
-- 设置列表数据
function prototype:setCellData(data)
    self.data = data
    self.originData = self.data
    self:syncViewData()
end

-- public
-- 刷新数据， 当setCellData结构改变时，需要调用该接口 
function prototype:reloadData(bSilent)
    for _, cell in ipairs(self.cells_used) do
        table.insert(self.cells_freed, cell)
        if cell.reset then
            cell:reset()
        end
        if cell:getParent() == self:getContainer() then
        	cell:retain()
            cell:removeFromParent(false)
        end
    end

    self.indices = {}
    self.cells_used = {}
    self.cells_positions = {}

    self:syncViewData()
    self:updateCellPositions()
    self:updateContentSize()
    self:updateContentOffset(bSilent)

    self.doAction = false
    if self:numberOfCellsInTableView(self) > 0 then
        self:scrollViewDidScroll(true)      
    end
end

-- public
-- 设置单元格空隙
function prototype:setCellMargin(m)
    self.cell_margin = m
end

-- public
-- 滚动到对应idx, sec_idx， 当不存在二级列表时，sec_idx可为nil
function prototype:scrollToIndex(time, idx, sec_idx)
    time = time or 0
    local find_idx = INVALID_INDEX
    for view_idx, cell in ipairs(self.data) do
        if cell._cell_idx_[1] == idx and cell._cell_idx_[2] == sec_idx then
            find_idx = view_idx
        end
    end

    if find_idx == INVALID_INDEX then return end

    local is_top_down = self.vordering == TABLEVIEW_VERTICALFILLORDER.TOP_DOWN
    local is_horizontal = self:getDirection() == SCROLLVIEW_DIR_HORIZONTAL
    local contentSize = self.cells_positions[#self.cells_positions]

    if is_horizontal then 
        local pos = self:offsetFromIndex(find_idx - 1)
        local min_x = contentSize - self.view_size.width
        local percent = pos.x / min_x
        self:scrollToPercentHorizontal(percent * 100, time, false)
        return
    end

    local step = is_top_down and -1 or 1
    find_idx = find_idx + step - 1
    if self:checkBorderAndScroll(find_idx, time) then return end

    local pos = self:offsetFromIndex(find_idx)
    local offset = pos.y - self.view_size.height - self.cell_margin
    local min_y = self.view_size.height - contentSize
    local percent = 1 + offset / min_y
    self:scrollToPercentVertical(percent * 100, time, false)
end

-- public
-- 设置垂直显示方式的item顺序，默认由上到下是升序
function prototype:setVerticalFillOrder(fillOrder)
    if self.vordering ~= fillOrder then
        self.vordering = fillOrder
        if #self.cells_used > 0 then
            self:reloadData()
        end
    end
end


-------------------------------------------------
-- private: inner datasource interface

-- self.originData 为原始数据结构，可能有二级菜单列表
-- self.data 为显示数组列表，由self.originData展开，没有嵌套结构
function prototype:syncViewData()
    self.data = self.originData

    local fitler = {}
    for _, cell_data in ipairs(self.data) do
        cell_data.second_list = cell_data.second_list or {}
        if cell_data._cell_idx_ ~= nil then
            local idx, sec_idx = unpack(cell_data._cell_idx_)
            if sec_idx == nil then
                table.insert(fitler, cell_data)
            end
        else
            table.insert(fitler, cell_data)
        end
    end

    self.data = fitler

    local second_list = {}
    for idx, cell_data in ipairs(self.data) do
        cell_data._cell_idx_ = {idx}
        if cell_data.second_list then
            second_list[idx] = cell_data.second_list
            for sec_idx, sec_data in ipairs(cell_data.second_list) do
                sec_data._cell_idx_ = {idx, sec_idx}
                sec_data._cell_parent_ = cell_data
            end
        end
    end
    for _, value in pairs(second_list) do
        for i, cell in ipairs(value) do
            local idx = self:findCell(cell._cell_parent_)
            table.insert(self.data, idx + i, cell)
        end 
    end

end

function prototype:findCell(cell_data)
    for idx, data in ipairs(self.data) do
        if data == cell_data then
            return idx
        end
    end
end

---data_source interface ---
----一下方法可在通过代理执行
--获取指定位置的cell
function prototype:tableCellAtIndex(tb, idx)
    -- log4ui:warn("tableCellAtIndex index:"..idx)
    if self.data_source ~= self and self.data_source.tableCellAtIndex then
        return self.data_source:tableCellAtIndex(tb, idx)
    end

    local cls
    if self.csbFunc then
        cls = self.csbFunc(self, idx)
    else
        cls = self.data[idx].cell_view
    end

    local cell = tb:dequeueCell(cls)
    if cell == nil then
        cell = self:getLoader():loadAsLayer(cls)
        cell:getCellBase():setTableView(tb)
        cell:setContentSize(self:getCellSize(idx))
        ccui.Helper:doLayout(cell)
    end

    return cell
end
--获取cell 数量
function prototype:numberOfCellsInTableView(tb)
    if self.data_source ~= self and  self.data_source.numberOfCellsInTableView then
        return self.data_source:numberOfCellsInTableView(tb)
    end

    return #self.originData
end

--获取cell  size 
function prototype:tableCellSizeForIndex(tb, idx)
    if self.data_source ~= self and self.data_source.tableCellSizeForIndex then
        return self.data_source:tableCellSizeForIndex(tb, idx)
    end

    local size = cc.size(0, 0)
    if self.data[idx].cell_size then
        size = self.data[idx].cell_size
    end
    return size
end

function prototype:getCellSize(idx)
    local size = self:tableCellSizeForIndex(self, idx)
    local cellSize = {width = size.width, height = size.height}
    if self:getDirection() == SCROLLVIEW_DIR_HORIZONTAL then
        cellSize.width = cellSize.width + self.cell_margin
    else
        cellSize.height = cellSize.height + self.cell_margin 
    end

    return cellSize
end
--删除指定数据
function prototype:removeCellData(tb, idx)
    if self.data_source ~= self and self.data_source.removeCellData then
        self.data_source:removeCellData(tb, idx)
        return
    end

    table.remove(self.originData, idx)
end

------------------------------------------------
---- private ----

function prototype:preCreateFreeCells()
    self.cell_size_list = {}
    local count_of_items = self:numberOfCellsInTableView(self)

    for idx = 1, count_of_items do
        local cell = self:tableCellAtIndex(self, idx)
        table.insert(self.cells_freed, cell)

        local size = cell:getCellBase():getCustomSize(idx, self.data[idx]) or cell:getCellBase():getContentSize()
        size = cc.size(size.width, size.height)
        if self.cell_margin ~= nil then
            if self:getDirection() == SCROLLVIEW_DIR_HORIZONTAL then
                size.width = size.width + self.cell_margin
            else
                size.height = size.height + self.cell_margin 
            end
        end
        table.insert(self.cell_size_list, size)
    end

end

function prototype:checkBorderAndScroll(find_idx, time)
    local counts = self:numberOfCellsInTableView(self)
    if find_idx > -1 and find_idx < counts then
        return false
    end

    local is_top_down = self.vordering == TABLEVIEW_VERTICALFILLORDER.TOP_DOWN
    local percent = find_idx < 0 and 0 or 1

    if not is_top_down then
        percent = 1 - percent
    end

    self:scrollToPercentVertical(percent * 100, time, false)

    return true
end

function prototype:scrollViewDidScroll(forceRefresh)
    if self.doAction then
        return
    end

    local count_of_items = self:numberOfCellsInTableView(self)
    if 0 == count_of_items then return end

    if self.is_used_cells_dirty then
        self.is_used_cells_dirty = false
        table.sort(self.cells_used, function(a, b)
            return a:getCellBase():getIdx() < b:getCellBase():getIdx()
        end)
    end
 
    local start_idx, end_idx, idx, max_idx = 0, 0, 0, 0
    local offset = cc.p(self:getContentOffset().x * -1, self:getContentOffset().y * -1)

    if not forceRefresh then
        if self.reload_offset ~= nil
           and offset.x == self.reload_offset.x
           and offset.y == self.reload_offset.y then
            return
       end
    end

    self.reload_offset = cc.p(offset.x, offset.y)

    max_idx = math.max(count_of_items - 1, 0)

    if self.vordering == TABLEVIEW_VERTICALFILLORDER.TOP_DOWN then
        offset.y = offset.y + self.view_size.height
    end

    start_idx = self:indexFromOffset(cc.p(offset.x, offset.y))
    if start_idx == INVALID_INDEX then
        start_idx = count_of_items - 1
    end

    if self.vordering == TABLEVIEW_VERTICALFILLORDER.TOP_DOWN then
        offset.y = offset.y - self.view_size.height
    else
        offset.y = offset.y + self.view_size.height
    end
    offset.x = offset.x + self.view_size.width

    end_idx = self:indexFromOffset(cc.p(offset.x, offset.y))
    if end_idx == INVALID_INDEX then
        end_idx = count_of_items - 1
    end

    if #self.cells_used > 0 then
        local cell = self.cells_used[1]
        idx = cell:getCellBase():getIdx()

        while(idx < start_idx) do
            self:moveCellOutOfSight(cell)
            if #self.cells_used <= 0 then
                break
            end
            cell = self.cells_used[1]
            idx = cell:getCellBase():getIdx()
        end
    end

    if #self.cells_used > 0 then
        local cell = self.cells_used[#self.cells_used]
        idx = cell:getCellBase():getIdx()
        
        while(idx <= max_idx and idx > end_idx) do
            self:moveCellOutOfSight(cell)
            if #self.cells_used <= 0 then
                break
            end
            cell = self.cells_used[#self.cells_used]
            idx = cell:getCellBase():getIdx()
        end
    end

    for i = start_idx, end_idx do
        if self.indices[i] == nil then
            self:updateCellAtIndex(i)
        end
    end
end

function prototype:indexFromOffset(offset)
    local index = 0
    local max_idx = self:numberOfCellsInTableView(self) - 1

    if self.vordering == TABLEVIEW_VERTICALFILLORDER.TOP_DOWN then
        offset.y = self:getContainer():getContentSize().height - offset.y
    end
    index = self:innerIndexFromOffset(offset)
    if index ~= INVALID_INDEX then
        index = math.max(0, index)
        if index > max_idx then
            index = INVALID_INDEX
        end
    end
    return index
end

function prototype:innerIndexFromOffset(offset)
    local low = 0
    local high = self:numberOfCellsInTableView(self) - 1
    local search
    if self:getDirection() == SCROLLVIEW_DIR_HORIZONTAL then
        search = offset.x
    else
        search = offset.y
    end

    while (high >= low) do
        local index = math.floor(low + (high - low) / 2)
        local cellStart = self.cells_positions[index + 1]
        local cellEnd = self.cells_positions[index + 1 + 1]

        if search >= cellStart and search <= cellEnd then
            return index
        elseif search < cellStart then
            high = index - 1
        else
            low = index + 1
        end
    end

    if low <= 0 then
        return 0
    end

    return INVALID_INDEX
end

--查找基于统一类型的node
function prototype:getCellByCln(clsName)
    for i, cell in ipairs(self.cells_freed) do
        if cell:getName() == clsName then -- todo
            return i
        end
    end
    return nil
end

function prototype:dequeueCell(clsName)
    if #self.cells_freed == 0 then
        return nil
    end

    if #self.cells_freed > 20 then
        print("prototype freed_cells are more than 20! now is: ", #self.cells_freed)
    end
    
    local idx = 1
    if clsName ~= nil then
        idx = self:getCellByCln(clsName)
    end

    if idx == nil then
        return nil
    end

    local cell = self.cells_freed[idx]
    table.remove(self.cells_freed, idx)
    cell:autorelease()

    return cell
end

function prototype:getFreeCells()
    return self.cells_freed
end

function prototype:getUsedCells()
    return self.cells_used
end

function prototype:removeCellAtIndex(idx, doAct)
    if self.doAction then
        return
    end

    if idx == INVALID_INDEX then
        return
    end

    local count_of_items = self:numberOfCellsInTableView(self)
    if 0 == count_of_items or idx > count_of_items then
        return
    end

    --cell删除后的移动范围确定
    local cellSize = self:getCellSize(idx)
    if self.direction == SCROLLVIEW_DIR_HORIZONTAL then
        cellSize.height = 0
    else
        cellSize.width = 0
    end

    self:removeCellData(self, idx)
    local cell = self:cellAtIndex(idx - 1)
    if cell == nil then 
        self:reloadData(true)
        return 
    end

    local new_idx = table.indexof(self.cells_used, cell)

    if not doAct  then
        self:moveCellOutOfSight(cell)
        for i = #self.cells_used, new_idx, -1 do
            cell = self.cells_used[i]
            self:setIndexForCell(cell:getCellBase():getIdx() - 1, cell)
        end
        self:reloadData(true)
        return
    end

    self.doAction = true

    local actList = {}
    local delayTime = 0.2
    local funcMoveUsed = CCCallFunc:create(function ()
            for i = #self.cells_used, new_idx+1, -1 do
                local leftcell = self.cells_used[i]
                leftcell:doMoveAction(delayTime, cellSize)

            end                                            
        end)
    local delay = cc.DelayTime:create(delayTime + 0.1)
    local moveCellEnd = CCCallFunc:create(function ()
            self:moveCellOutOfSight(cell)
            self.doAction = false
            self:reloadData(true)
        end)
    table.insert(actList, funcMoveUsed)
    table.insert(actList, delay)
    table.insert(actList, moveCellEnd)
    cell:doExitAction(actList)
end

function prototype:addCellAtIndex(index, data, silent)
    if index < 1 then
        return
    end
    index = index > #self.originData and #self.originData + 1 or index

    table.insert(self.originData, index, data)
    self:reloadData(silent)
end

function prototype:updateCellAtIndex(idx)
    if idx == INVALID_INDEX then
        return
    end
    local count_of_items = self:numberOfCellsInTableView(self)
    if (0 == count_of_items) or (idx > count_of_items-1) then
        return
    end
    local cell = self:cellAtIndex(idx)
    if cell ~= nil then
        self:moveCellOutOfSight(cell)
    end
    cell = self:tableCellAtIndex(self, idx + 1)
    self:setIndexForCell(idx, cell)
    self:addCellIfNecessary(cell)
end

function prototype:addCellIfNecessary(cell)
    if cell:getParent() ~= self:getContainer() then
        self:getContainer():addChild(cell)
    end
    table.insert(self.cells_used, cell)
    local idx = cell:getCellBase():getIdx()
    self.indices[idx] = idx
    self.is_used_cells_dirty = true
end

function prototype:cellAtIndex(idx)
    if self.indices[idx] == nil then
        return nil
    end

    for _, cell in ipairs(self.cells_used) do
        if cell:getCellBase():getIdx() == idx then
            return cell
        end
    end
   
    return nil
end

function prototype:updateContentSize()
    local size = self.view_size
    local cells_count = self:numberOfCellsInTableView(self)

    if self.reload_offset then
    	self.end_offset = {}
    	local preSize = self:getInnerContainerSize()
        self.end_offset.x = preSize.width - self.view_size.width - self.reload_offset.x
        self.end_offset.y = preSize.height - self.view_size.height - self.reload_offset.y
    end
    if cells_count > 0 then
        local maxPosition = self.cells_positions[cells_count + 1]
        if self:getDirection() == SCROLLVIEW_DIR_HORIZONTAL then
            size = cc.size(maxPosition, self.view_size.height)
        else
            size = cc.size(self.view_size.width, maxPosition)
        end
    end

    self:setInnerContainerSize(size)

end

function prototype:updateContentOffset(bSilent)

    if self.old_direction ~= self.direction then
        if self.direction == SCROLLVIEW_DIR_HORIZONTAL then
            self:setContentOffset(cc.p(0, 0))
        else
            self:setContentOffset(cc.p(0, self:minContainerOffset().y))
        end
        self.old_direction = self.direction
        return
    end

	if bSilent and self.end_offset  then
		local size = self:getInnerContainerSize()

        if self.direction == SCROLLVIEW_DIR_HORIZONTAL then
        	local offsetx = size.width - self.view_size.width - self.end_offset.x
            self:setContentOffset(cc.p(-offsetx, 0))
        else
        	local offsety = size.height - self.view_size.height - self.end_offset.y
            self:setContentOffset(cc.p(0, -offsety))
        end
		return
	end

end

function prototype:updateCellPositions()
    local cells_count = self:numberOfCellsInTableView(self)
    if not (cells_count > 0) then return end
    local current_pos = 0
    local cellSize

    for i=1, cells_count do
        self.cells_positions[i] = current_pos
        cellSize = self:getCellSize(i)
        if self:getDirection() == SCROLLVIEW_DIR_HORIZONTAL then
            current_pos = current_pos + cellSize.width
        else
            current_pos = current_pos + cellSize.height
        end
    end
    
    self.cells_positions[cells_count+1] = current_pos
end

function prototype:setIndexForCell(index, cell)
    cell:setAnchorPoint(cc.p(0, 0))
    cell:setPosition(self:offsetFromIndex(index))
    cell:getCellBase():setIdx(index, self.data[index + 1], self.data)

    cell:refresh(self.data[index + 1].cell_data, unpack(self.data[index + 1]._cell_idx_))
end

function prototype:offsetFromIndex(index)
    local offset = self:_offsetFromIndex(index)

    local cellSize = self:getCellSize(index + 1)
    if self.vordering == TABLEVIEW_VERTICALFILLORDER.TOP_DOWN then
        offset.y = self:getContainer():getContentSize().height - offset.y - cellSize.height
        offset.y = offset.y + 2 * self.cell_margin
    end
    return offset
end

function prototype:_offsetFromIndex(index)
    local offset

    if self:getDirection() == SCROLLVIEW_DIR_HORIZONTAL then
        offset = cc.p(self.cells_positions[index+1] + self.cell_margin, 0)
    else
        offset = cc.p(0, self.cells_positions[index+1] + self.cell_margin)
    end

    return offset
end

function prototype:moveCellOutOfSight(cell)
    table.insert(self.cells_freed, cell)
    for i, v in ipairs(self.cells_used) do
        if v == cell then
            table.remove(self.cells_used, i)
            break
        end
    end
    self.is_used_cells_dirty = true
    
    self.indices[cell:getCellBase():getIdx()] = nil
    if cell.reset then
        cell:reset()
    end
    
    if cell:getParent() == self:getContainer() then
    	cell:retain()
        cell:removeFromParent(false)
    end
end

------------------------------------------------------
-- scrollview extend

function prototype:extendScrollView()
	local node = cc.Node:create()
	self.rootNode:addChild(node)
	node:scheduleUpdateWithPriorityLua(bind(self.scrollViewDidScroll, self), 0)
	self:setBounceEnabled(true)
end

function prototype:setViewSize(size)
    self.rootNode:setContentSize(size)
end

function prototype:getContentOffset()
    return cc.p(self:getInnerContainerPosition())
end

function prototype:setContentOffset(offset)
    local minOffset = self:minContainerOffset()
    local maxOffset = self:maxContainerOffset()
    
    offset.x = math.max(minOffset.x, math.min(maxOffset.x, offset.x))
    offset.y = math.max(minOffset.y, math.min(maxOffset.y, offset.y))

    self:setInnerContainerPosition(offset)
end

function prototype:maxContainerOffset()
    return cc.p(0, 0)
end

function prototype:minContainerOffset()
    local container = self.rootNode:getInnerContainer()
    return cc.p(self.view_size.width - container:getContentSize().width * container:getScaleX(), 
               self.view_size.height - container:getContentSize().height * container:getScaleY())
end

function prototype:getContainer()
    local ret = self.rootNode:getInnerContainer()
    ret.setContentSize = ret.setInnerContainerSize
    return ret
end

function prototype:onExit()
    for _, cell in ipairs(self.cells_freed) do
        cell:release()
    end
    self.cells_freed = {}
end