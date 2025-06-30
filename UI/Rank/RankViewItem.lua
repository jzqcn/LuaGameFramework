module (..., package.seeall)

prototype = Controller.prototype:subclass()

local NmeColor = 
{
	cc.c3b(189, 91, 98),
	cc.c3b(113, 102, 192),
	cc.c3b(77, 151, 173),
	cc.c3b(125, 125, 125),
}

function prototype:enter()
	self.size = self.rootNode:getContentSize()
end

function prototype:onRankItemClick()
	-- local pos = self.rootNode:getWorldPosition()
	-- pos.x = pos.x + self.size.width - 50
	-- pos.y = pos.y
	-- self:fireUIEvent("Rank.SignInfo", self.cell_data.personalSign, pos)
	Model:get("User"):requestRoleMsg(self.cell_data.playerId)

	-- log(self.rootNode:getWorldPosition())
end

---tableView cell使用 began------------
function prototype:refresh(cell_data, idx, sec_idx)
	-- log(cell_data)
	if cell_data.rank <= 3 then
		self.imgRank_1:loadTexture(string.format("resource/csbimages/Rank/icon_%d.png", cell_data.rank))
		self.imgRank_1:setVisible(true)
		self.imgRank_2:setVisible(false)
	else
		self.fntRankNum:setString(tostring(cell_data.rank))
		self.imgRank_1:setVisible(false)
		self.imgRank_2:setVisible(true)
	end


	-- sdk.account:getHeadImage(cell_data.playerId, cell_data.name, self.headIcon, cell_data.headImage)
	if self:existEvent('LOAD_HEAD_IMG') then
		self:cancelEvent('LOAD_HEAD_IMG')
	end
	sdk.account:loadHeadImage(cell_data.playerId, cell_data.name, cell_data.headImage, 
		self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.headIcon)

	self.txtName:setString(Assist.String:getLimitStrByLen(cell_data.name))
	self.txtCoinNum:setString(Assist.NumberFormat:amount2TrillionText(cell_data.rankvalue))

	if cell_data.rankType == Ranking_pb.GoldRank then
		self.imgIcon:loadTexture("resource/csbimages/Common/goldIcon.png")
	else
		self.imgIcon:loadTexture("resource/csbimages/User/moneyIcon.png")
	end

	-- if self.index == nil then
		-- local index = cell_data.rank % 4
		-- if index == 0 then
		-- 	index = 4
		-- end
		-- self.index = index
		local index = cell_data.rank
		if cell_data.rank >= 4 then
			index = 4
		end

		--重设下九宫格，不然更改图片会变形
		self.imgBg:setCapInsets(cc.rect(17, 17, 39, 39))
		self.imgNumBg:setCapInsets(cc.rect(30, 30, 29, 29))
		self.imgBg:loadTexture(string.format("resource/csbimages/Rank/itemBg_%d.png", index))
		self.imgNumBg:loadTexture(string.format("resource/csbimages/Rank/itemNumBg_%d.png", index))
		
		-- log(self.imgBg:isIgnoreContentAdaptWithSize())
		-- log(self.imgNumBg:isIgnoreContentAdaptWithSize())
		

		self.txtName:setTextColor(NmeColor[index])
	-- end

	self.cell_data = cell_data
end

function prototype:onLoadHeadImage(filename)
	self.headIcon:loadTexture(filename)
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
