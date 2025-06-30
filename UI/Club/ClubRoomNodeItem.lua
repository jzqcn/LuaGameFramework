module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

--请求加入房间
function prototype:onBtnJoinClick()
	--判断玩家是否在游戏中，房卡场游戏未开始前，可以退回大厅
	local gameName = StageMgr:getStage():getPlayingGameName()
	if gameName then
		StageMgr:chgStage("Game", gameName)
		return
	end

	Model:get("Room"):requestAddRoomById(self.cell_data.roomId)
end

---tableView cell使用 began------------
function prototype:refresh(cell_data, idx, sec_idx)
	-- log(cell_data)
	for i = 1, 6 do
		self["nodeRole_"..i]:setVisible(false)
	end

	local cardItem = Model:get("Hall"):getCardItem(cell_data.typeId)
	-- log(cardItem)
	
	local desc = cell_data.desc
	if cardItem.itemName == "Paodekuai" then
		desc = desc .. "张"
	elseif cardItem.itemName == "Paodekuai" then
		desc = desc .. "人"
	end
	self.txtGameInfo:setString(string.format("%s %s %04d", cell_data.gameName, desc, cell_data.roomId))

	local strRoomInfo = ""
	-- local strPayType = "房主付费"
	-- strRoomInfo = string.format("%s %d局", strPayType, cell_data.groupConfig)

	local dbName = cardItem.itemName.."CardConfig"
	local dbData = db.mgr:getDBById(dbName, cell_data.playId)
	local currencyType = Common_pb.Score
	if dbData then
		--底分
		currencyType = dbData.currencyType
		if currencyType == Common_pb.Gold then
			--入场限制			
			local baseChipRange = dbData["baseChipRange"]
			if cardItem.itemName == "Niuniu" then						
				if not string.find(desc, "通比") then
					baseChipRange = dbData["chipRange"]
				end
			end

			local showStrTable = string.split(baseChipRange, ";")
			local chipIndex = 1
			-- log(showStrTable)
			for i, v in ipairs(showStrTable) do
				if tonumber(v) == tonumber(cell_data.baseChip) then
					chipIndex = i
					break
				end
			end

			local strLimit = dbData["limit"]
			local showStrTable = string.split(strLimit, ";")
			-- log(showStrTable)
			local numLimit = tonumber(showStrTable[chipIndex])
			self.fntLimit:setString(Assist.NumberFormat:amount2Hundred(numLimit))
			self.fntLimit:setVisible(true)

			local baseChip = cell_data.baseChip
			if cardItem.itemName == "Niuniu" then
				--牛牛是投注上限。改成底注
				if not string.find(desc, "通比") then
					baseChip = baseChip / 100
				end
			end
			strRoomInfo = string.format("大赢家付费 %d局 底注:%s", cell_data.groupConfig, Assist.NumberFormat:amount2Hundred(baseChip))
			if cardItem.itemName == "Mushiwang" then	
				strRoomInfo = string.format("大赢家付费 %d局", cell_data.groupConfig)
			end
		else
			strRoomInfo = string.format("%d局 底分:%s", cell_data.groupConfig, cell_data.baseChip)
		end
	end

	self.txtRoomInfo:setString(strRoomInfo)

	-- local strSize = self.txtRoomInfo:getContentSize()
	-- local size = self.imgInfoBg:getContentSize()
	-- self.imgInfoBg:setContentSize(cc.size(strSize.width*0.9 + 10, size.height))

	--头像信息
	for i, v in ipairs(cell_data.members) do
		self["nodeRole_"..i]:setHeadMsg(v.userId, v.userName, v.headImage)
	end

	--重设下九宫格，不然更改图片会变形
	-- self.imgBg:setCapInsets(cc.rect(39, 39, 39, 39))

	if currencyType == Common_pb.Score then
		-- self.imgBg:loadTexture(string.format("resource/csbimages/Club/tabYellow.png"))
		-- self.imgJoin:loadTexture(string.format("resource/csbimages/Club/btnAdd_1.png"))
		self.fntLimit:setVisible(false)
		self.imgCurrencyType:loadTexture("resource/csbimages/User/scoreIcon.png")

		-- self.txtGameInfo:setTextColor(cc.c3b(173, 111, 24))
		-- self.txtRoomInfo:setTextColor(cc.c3b(173, 111, 24))
	else

		-- self.imgBg:loadTexture(string.format("resource/csbimages/Club/tabBlue.png"))
		-- self.imgJoin:loadTexture(string.format("resource/csbimages/Club/btnAdd_2.png"))
		self.imgCurrencyType:loadTexture("resource/csbimages/Common/goldIcon.png")

		-- self.txtGameInfo:setTextColor(cc.c3b(52, 60, 129))
		-- self.txtRoomInfo:setTextColor(cc.c3b(52, 60, 129))
	end

	self.cell_data = cell_data
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
