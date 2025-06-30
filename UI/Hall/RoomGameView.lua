module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter(data)
	self.currencyType = data.currencyType

	local clubId = data.clubId

	-- ui.mgr:setSceneImageBg(self.imgBg, true)

	local cardItemTable = Model:get("Hall"):getCardItemTable()

	if #cardItemTable>2 then
		table.sort( cardItemTable, function(a,b)
			if a.sort>b.sort then
				return true
			else
				return false
			end
		 end )
	end

	local data = {}
	local rowItems = {currencyType = self.currencyType, clubId = clubId, items = {}}

	--每一行放4个图标
	local dbName = ""
	local dbData
	for i, v in ipairs(cardItemTable) do
		--判断是否存在对应类型玩法（部分房卡游戏没有积分或者金币）
		dbName = v.itemName .. "CardConfig"
		dbData = db.mgr:getDB(dbName, {typeId = v.typeId, currencyType = self.currencyType})
		if dbData and #dbData > 0 then
			table.insert(rowItems.items, v)
			if #rowItems.items == 4 then
				data[#data + 1] = rowItems
				rowItems = {currencyType = self.currencyType, clubId = clubId, items = {}}
			end
		end
	end

	
	if #rowItems.items > 0 then
		data[#data + 1] = rowItems
	end

	local param = 
	{
		data = data,
		ccsNameOrFunc = "Hall/RoomGameViewItem",
		dataCheckFunc = function (pageData, elem) return pageData == elem end
	}

	self.listview:createItems(param)
	self.listview:setScrollBarEnabled(false)

    -- self.pageview:createPages(param)
    -- self.pageview:addEventListener(bind(self.pageTouch, self))
    -- self:pageTouch(self.pageview, PAGEVIEW_EVENT_TURNING)

     if self.currencyType == Common_pb.Gold then
    	self.imgTypeName:loadTexture("resource/csbimages/Hall/typeRoomGold.png")
    else
    	self.imgTypeName:loadTexture("resource/csbimages/Hall/typeRoomScore.png")
    end

	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.rootNode, actionOver)

    util.timer:after(200, self:createEvent("playAction"))
end

function prototype:playAction()
	self:playActionTime(0, true)
end

--[[function prototype:pageTouch(sender, types)
	if types == PAGEVIEW_EVENT_TURNING then
		local curIdx = self.pageview:getCurrentPageIndex()
		if curIdx < 0 then
			curIdx = 0
		end

		local pages = self.pageview:getItems()
		if curIdx > 0 then
			self.btnLeft:setVisible(true)
		else
			self.btnLeft:setVisible(false)
		end

		if curIdx < (#pages-1) then
			self.btnRight:setVisible(true)
		else
			self.btnRight:setVisible(false)
		end
	end
end

function prototype:onBtnRightClick()
	local curIdx = self.pageview:getCurrentPageIndex()
	local pages = self.pageview:getItems()
	if curIdx < (#pages-1) then
		self.pageview:scrollToItem(curIdx + 1)
	end
end

function prototype:onBtnLeftClick()
	local curIdx = self.pageview:getCurrentPageIndex()
	if curIdx > 0 then
		self.pageview:scrollToItem(curIdx - 1)
	end
end
--]]

function prototype:onBtnCloseClick(sender, eventType)
	self:close()
end

