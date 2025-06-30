module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()

end

function prototype:refresh(cell_data, idx, sec_idx)
	self.cell_data = cell_data
	self.index = idx

	local redpacketInfo = cell_data.redpacketInfo
	self.txtValue:setString(Assist.NumberFormat:amount2Hundred(redpacketInfo.redpacketCoin))
	self.txtNum:setString(redpacketInfo.redpacketRemainder)
	self.txtBombId:setString(redpacketInfo.minesNum)

	self.txtIndex:setString(cell_data.floorIndex)
	-- local countDown = cell_data.countDown
	-- self.txtTime:setString(string.format("%02d:%02d", math.floor(countDown/60), countDown%60))
end

function prototype:onImageSnatchClick()
	-- Model:get("Games/Redpacket"):requestSnatch(true)
	self:fireUIEvent("Redpacket.FloorClick", self.cell_data, self.index, self)
end

--必要,返回继承cellBase的node
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

---tableView cell使用 end------------
