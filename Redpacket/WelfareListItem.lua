module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()

end

function prototype:refresh(data, index)
	self.data = data
	self.index = index
end

function prototype:onImageSnatchClick()
	-- Model:get("Games/Redpacket"):requestBonusTake()
	self:fireUIEvent("Redpacket.WelfareClick", self.data, self.index, self.rootNode)
end

--[[--必要,返回继承cellBase的node
function prototype:getCellBase()
	return self.node_Cell
end

--每次刷新前重置调用
function prototype:reset()
	
end

--cell移动方法 
--time 时间
--size 移动的距离
function prototype:doMoveAction(time, size)
	local disPos = cc.p(size.width, size.height)
	local act = cc.MoveBy:create(time, disPos)
	self.rootNode:runAction(act)
end

--cell删除动画
--actList 删除动画结束的后的操作，不需要自己设定，只需要用就可以了
-- table.insert(actList, 1, act)
function prototype:doExitAction(actList)
	local act = cc.MoveBy:create(0.5, cc.p(600, 0))
	table.insert(actList, 1, act)
	local sqe = cc.Sequence:create(actList)
	self.rootNode:runAction(sqe)
end

---tableView cell使用 end--------------]]


