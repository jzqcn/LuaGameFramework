module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

---tableView cell使用 began------------
function prototype:refresh(cell_data, idx, sec_idx)
	-- log(cell_data)
	if idx == 1 then
		self.imgRankIcon:loadTexture("resource/Longhudou/csbimages/PlayerList/icon0.png")
		self.imgRankIcon:setVisible(true)
		self.fntRank:setVisible(false)
	else
		if idx <= 4 then
			self.imgRankIcon:loadTexture(string.format("resource/Longhudou/csbimages/PlayerList/icon%d.png", idx-1))
			self.imgRankIcon:setVisible(true)
			self.fntRank:setVisible(false)
		else
			self.fntRank:setString(tostring(idx - 1))
			self.imgRankIcon:setVisible(false)
			self.fntRank:setVisible(true)
		end
	end

	self.txtName:setString(Assist.String:getLimitStrByLen(cell_data.playerName))
	self.txtID:setString("ID:" .. cell_data.playerId)
	--设置头像
	-- sdk.account:getHeadImage(cell_data.playerId, cell_data.playerName, self.imgIcon, cell_data.headimage)

	if self:existEvent('LOAD_HEAD_IMG') then
		self:cancelEvent('LOAD_HEAD_IMG')
	end
	sdk.account:loadHeadImage(cell_data.playerId, cell_data.playerName, cell_data.headimage, 
		self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.imgIcon)

	self.txtWinNum:setString(cell_data.winTimes .. "局")
	self.txtBetNum:setString(tostring(math.floor(cell_data.totalBetCoin/100)))

	self.cell_data = cell_data
end

function prototype:onLoadHeadImage(filename)
	self.imgIcon:loadTexture(filename)
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


