local TableViewBase = require "UI.Control.TableViewCellBase"

module(..., package.seeall)

prototype = TableViewBase.prototype:subclass()

function prototype:initialize(...)
    super.initialize(self, ...)
end

function prototype:enter()

end

function prototype:setTableView(_tableView)
    self.table_view = _tableView
end

----------------------------------------------
-- table view interface
function prototype:getIdx()
	return self.view_idx and self.view_idx - 1 or -1
end

function prototype:setIdx(view_idx)
    self.view_idx = view_idx + 1
end

function prototype:setBaseCellData(view_idx, inner_data)
	self.view_idx = view_idx + 1
	self.cell_data = inner_data.cell_data
	self.inner_data = inner_data
	self:refresh(self.cell_data, unpack(inner_data._cell_idx_))
end

function prototype:reset()
end

function prototype:removeItem(doAct)
    self.table_view:removeCellAtIndex(self.view_idx, doAct)
end

------------------------------
-- 可选方法，自定义大小时使用
function prototype:getCustomSize(idx, inner_data)
    return inner_data.cell_size
end

-- sec_idx 为二级下标，当前不是二级列表，sec_idx为nil
function prototype:refresh(cell_data, idx, sec_idx)

end
----------------------------------------------

function prototype:reloadData()
	self.table_view:reloadData()
end

function prototype:isHorizontal()
	return self.table_view:getDirection() == SCROLLVIEW_DIR_HORIZONTAL
end

-- 设置间隔，只对改类型的Cell的有效，向上增长
function prototype:setCellMargin(v)
	local size = self.rootNode:getContentSize()
	if not self:isHorizontal() then
	    size = cc.size(size.width, size.height + v)
	else
		size = cc.size(size.width + v, size.height)
	end
    self:setContentSize(size)
end

-- 默认锚点左下角，大小是往向上右增加的，这里提供一个左上角对齐Cell的方法
function prototype:alignTop()
    local size_custom = self:getCustomSize(self.view_idx, self.inner_data)
    size_custom = size_custom or self:getContentSize()

    local size_root = self.rootNode:getContentSize()
    local pos = ccp(0, 0)
    if size_custom ~= nil then
    	if not self:isHorizontal() then
    	    pos = ccp(0, size_custom.height - size_root.height)
    	else
    		pos = ccp(size_custom.width - size_custom.width, 0)
    	end
    end

    self.rootNode:setPosition(pos)
end
