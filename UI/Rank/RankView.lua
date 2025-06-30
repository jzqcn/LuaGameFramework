module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local Ranking_pb = Ranking_pb

function prototype:enter()
	-- self:bindUIEvent("Rank.SignInfo", "uiEvtSignInfo")

	self:bindModelEvent("Rank.EVT.PUSH_RANK_DATA", "onPushRankData")
	self:bindModelEvent("User.EVT.PUSH_USER_INFO_MSG", "onPushUserInfo")

	Model:get("Rank"):requestGoldRankData()
	-- Model:get("Rank"):requestSilverRankData()

	-- local param = 
	-- {
	-- 	data = {},
	-- 	ccsNameOrFunc = "Rank/RankViewItem",
	-- 	dataCheckFunc = function (info, elem) return info == elem end
	-- }
 --    self.listview:createItems(param)

 	self:createTableView({})

    self.rankType = Ranking_pb.GoldRank
    self.goldData = {}
    -- self.silverData = {}

    -- self.btnGold:setVisible(true)
    -- self.btnSilver:setVisible(false)

    local size = self.imgPop:getContentSize()
    local x, y = self.imgPop:getPosition()
    self.imgPop:setPosition(cc.p(-size.width-5, y))
    
    local bezier ={
        cc.p(x - size.width, y),
        cc.p(x + size.width/2, y),
        cc.p(x, y)
    }

    local bezierTo = cc.BezierTo:create(0.4, bezier)
    self.imgPop:runAction(cc.Sequence:create(bezierTo, cc.CallFunc:create(bind(self.itemlistAction, self))))

    self.isMoveAction = true

    self:initUserInfo()
end

-- function prototype:uiEvtSignInfo(personalSign, pos)
-- 	local layer = ui.mgr:open("Rank/SignPopView", personalSign)
-- 	layer:setSignPos(pos)
-- end

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

function prototype:initUserInfo()
	local userInfo = Model:get("Account"):getUserInfo()
    self.txtName:setString(Assist.String:getLimitStrByLen(userInfo.nickName))    
    if self.rankType == Ranking_pb.GoldRank then
    	self.txtCoinNum:setString(Assist.NumberFormat:amount2Hundred(userInfo.gold))
		self.imgIcon:loadTexture("resource/csbimages/User/goldIcon.png")
	else
		-- self.txtCoinNum:setString(Assist.NumberFormat:amount2Hundred(userInfo.silver))
		-- self.imgIcon:loadTexture("resource/csbimages/User/moneyIcon.png")
	end
	
	-- if util:getPlatform() == "win32" then
	-- 	sdk.account:getHeadImage(userInfo.userId, userInfo.nickName, self.headIcon)
	-- else
		sdk.account:getHeadImage(userInfo.userId, userInfo.nickName, self.headIcon, userInfo.headImage)
	-- end
end

-----------tableView began-----------
function prototype:createTableView(rankData)
 	self.data = rankData

	local tableData = {
		size = cc.size(480, 550),
		source = self,
		csbFunc = bind(self.getCsbName, self),
		margin = 5,
		cellData = self.data,
	}

	self.tableview:createTable(tableData)
	self.tableview:reloadData()

	-- self.tableview:setEnabled(false)
	-- self.tableview:scrollToBottom(0, true)
end

function prototype:getCsbName(tb, idx)
	return "Rank/RankViewItem"
end

--设置cell大小,
function prototype:tableCellSizeForIndex(tb, idx)
	local size

	if tb == self.tableview then
		if self.data[idx].cell_size then
			size = self.data[idx].cell_size
		else
			size = cc.size(480, 120)
		end
	end
	return size
end

-----------tableView end-----------

function prototype:onPushRankData(rankType, rankData)
	if rankType == Ranking_pb.GoldRank then
		self.goldData = rankData
	else
		-- self.silverData = rankData
	end

	-- log(rankData)
	if self.rankType == rankType then
		self:reloadRankData(rankData)
	end
end

function prototype:reloadRankData(rankData)
	local userId = Model:get("Account"):getUserId()
	local userRank = 99
	local data = {}
	for i, v in ipairs(rankData) do
		local item = {cell_data = v}
		table.insert(data, item)

		if v.playerId == userId then
			userRank = v.rank
		end
	end

	self.fntRankNum:setString(tostring(userRank))

	self.data =data
	self.tableview:setCellData(data)
	self.tableview:reloadData()
	self.tableview:scrollToIndex(0, 1)

	if self.isMoveAction then
		self.tableview:setVisible(false)
	else
		self:itemlistAction()
	end

	-- log(#(self.tableview:getUsedCells()))
end

--[[function prototype:onImgSelectTypeClick()
	if self.rankType == Ranking_pb.GoldRank then
		self.rankType = Ranking_pb.SliverRank
		self.btnGold:setVisible(false)
    	self.btnSilver:setVisible(true)

    	self:reloadRankData(self.silverData)
    	-- self.listview:refreshListView(self.silverData)
	else
		self.rankType = Ranking_pb.GoldRank
		self.btnGold:setVisible(true)
    	self.btnSilver:setVisible(false)

    	self:reloadRankData(self.goldData)
    	-- self.listview:refreshListView(self.goldData)    	
	end

	self:initUserInfo()
end--]]

function prototype:onPushUserInfo(userInfo)
	ui.mgr:open("Rank/SignPopView", userInfo)
end

function prototype:onBtnCloseClick()
	self:close()
end


