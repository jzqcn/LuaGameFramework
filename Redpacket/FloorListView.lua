module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local eglView		= cc.Director:getInstance():getOpenGLView()
local frameSize		= eglView:getFrameSize()
local scaleX = frameSize.width / 1334
local scaleY = frameSize.height / 750

function prototype:hasBgMask()
    return false
end

function prototype:enter()
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_SNATCH", "onPushSnatch")
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_SNATCH_FLOOR", "onPushSnatchFloor")

	self:bindUIEvent("Redpacket.FloorClick", "uiEvtFloorClick")

	local listData = Model:get("Games/Redpacket"):getFloorList()
	-- for i = 1, 50 do
	-- 	listData[#listData + 1] = i 
	-- end

	-- log(listData)

	local tableData = {}
	for i, v in ipairs(listData) do
		if not v.isSnatch then
			local item = {cell_data = v}
			table.insert(tableData, item)
		end
	end

	self:createTableView(tableData)

	local x, y = self.imgPop:getPosition()
	local size = self.imgPop:getContentSize()
	self.pos = cc.p(x, y)
	self.size = size

	self.imgPop:setPosition(x-size.width, y)

	self.imgBg:setEnabled(false)
	self.imgPop:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(size.width, 0)), cc.CallFunc:create(function()
		self.imgBg:setEnabled(true)
	end)))

	self.isPlayingAnim = false

	local roomInfo = Model:get("Games/Redpacket"):getRoomInfo()
	self.mutiple = roomInfo.mutiple
end

function prototype:exit()
	local itemAnimation = self.bombAnimation
	if itemAnimation then
		itemAnimation:removeFromParent()
		itemAnimation:dispose()
	end

	itemAnimation = self.snatchAnimation
	if itemAnimation then
		itemAnimation:removeFromParent()
		itemAnimation:dispose()
	end
end

function prototype:onPushSnatch(data)
	if not data.isSuccess then
		self.tableview:setEnabled(true)

		-- log(data.tips)

		if string.find(data.tips, '2次') or string.find(data.tips, '两次') or string.find(data.tips, '存在') then
			-- log("error********************")
			if self.cellData then
				self.cellData.isSnatch = true
			end

			-- log(self.cellData)
			-- local listData = Model:get("Games/Redpacket"):getFloorList()
			-- log(listData)
			self:refreshTableview()
		end
	else
		
	end
end

function prototype:refreshTableview()
	local listData = Model:get("Games/Redpacket"):getFloorList()

	local data = {}
	for i, v in ipairs(listData) do
		if not v.isSnatch then
			local item = {cell_view = "Redpacket/FloorListItem", cell_data = v}
			table.insert(data, item)
		end
	end

	self.data = data

	self.tableview:setCellData(data)
	self.tableview:reloadData(true)

	-- local index = self.selIndex and self.selIndex or 1
	-- self.tableview:scrollToIndex(0, index > 0 and index or 1)
end

function prototype:onPushSnatchFloor(data)
	local widget = self.target.rootNode
	if data.isBomb then
		self:playBombAnimation(widget)
	else
		self:playSnatchAnimation(widget)
	end

	local label
	local resultCoin = data.resultCoin
	if resultCoin >= 0 then
		label = cc.Label:createWithBMFont("resource/Redpacket/bmFonts/font_win.fnt", "+" .. Assist.NumberFormat:amount2TrillionText(resultCoin))
	else
		label = cc.Label:createWithBMFont("resource/Redpacket/bmFonts/font_lose.fnt", Assist.NumberFormat:amount2TrillionText(resultCoin))
	end

	-- local scaleX = frameSize.width / 1334
	-- local scaleY = frameSize.height / 750
	local x, y = self.imgPop:getPosition()
	local pos = widget:getWorldPosition()
	local size = widget:getContentSize()
	label:setPosition(x, pos.y + size.height/2 - 60)

	self.rootNode:addChild(label, 3, 100)

	label:runAction(cc.Sequence:create(
		cc.MoveBy:create(0.5, cc.p(0, 60)), 
		cc.DelayTime:create(1.0), 
		cc.FadeOut:create(0.5), 
		cc.CallFunc:create(function(sender)
			sender:removeFromParent()
		end)))


	local isRefresh = false
	if self.cellData then
		if self.cellData.snatchNum == nil then
			self.cellData.snatchNum = 0
		end
		self.cellData.snatchNum = self.cellData.snatchNum + 1
		if self.cellData.snatchNum == 2 then
			self.cellData.isSnatch = true

			self:refreshTableview()
			isRefresh = true
		end
	end

	if data.floorType == Redpacket_pb.Update then
		if self.selIndex then
			self.tableview:refresh(data, self.selIndex)
		end
	else
		if not isRefresh then
			self:refreshTableview()
		end
	end

	self.selIndex = nil
	self.tableview:setEnabled(true)
end

function prototype:uiEvtFloorClick(cellData, index, cellNode)
	-- if self.isPlayingAnim then
	-- 	return
	-- end

	-- log(cellData)

	local userInfo = Model:get("Account"):getUserInfo()
	local redpacketCoin = cellData.redpacketInfo.redpacketCoin
	if userInfo.gold < redpacketCoin*self.mutiple then
		local data = {
			content = "余额不足，不能抢红包"
		}
		ui.mgr:open("Dialog/DialogView", data)
		return
	end

	-- log(index)

	Model:get("Games/Redpacket"):requestSnatch(true, cellData.floorIndex)

	self.cellData = cellData
	self.target = cellNode
	self.selIndex = index

	self.tableview:setEnabled(false)
end

--播放中雷效果
function prototype:playBombAnimation(widget)
	-- if self.isPlayingAnim then
	-- 	return
	-- end

	local armatureDisplay = self.bombAnimation
	if armatureDisplay == nil then
		local factory = dragonBones.CCFactory:getFactory()
		factory:loadDragonBonesData("resource/Redpacket/anim/zhonglei_ske.dbbin", "bombAnimation")
	    factory:loadTextureAtlasData("resource/Redpacket/anim/zhonglei_tex.json", "bombAnimation")

	    armatureDisplay = factory:buildArmatureDisplay("armatureName", "bombAnimation")
	    if armatureDisplay then
	    	--监听播放完成事件
	    	local function eventCustomListener(event)
		    	armatureDisplay:retain()
		    	armatureDisplay:removeFromParent(false)

		    	-- self.isPlayingAnim = false

		    	-- self.tableview:setEnabled(true)
		    end

		    local listener = cc.EventListenerCustom:create("complete", eventCustomListener)
		    armatureDisplay:getEventDispatcher():setEnabled(true)
			armatureDisplay:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

		    self.bombAnimation = armatureDisplay
		end
	end

	local x, y = self.imgPop:getPosition()
	local pos = widget:getWorldPosition()
	local size = widget:getContentSize()
    armatureDisplay:setPosition(x, pos.y + size.height/2)
    armatureDisplay:setScale(0.8)
    --动画播放。只播放一次
    armatureDisplay:getAnimation():play("zhonglei", 1)

    if not armatureDisplay:getParent() then
		self.rootNode:addChild(armatureDisplay, 2)
	end

    -- self.isPlayingAnim = true
end

--播放抢红包特效
function prototype:playSnatchAnimation(widget)
	-- if self.isPlayingAnim then
	-- 	return
	-- end

	local armatureDisplay = self.snatchAnimation
	if armatureDisplay == nil then
		local factory = dragonBones.CCFactory:getFactory()
		factory:loadDragonBonesData("resource/Redpacket/anim/qianghongbao_ske.dbbin", "snatchAnimation")
	    factory:loadTextureAtlasData("resource/Redpacket/anim/qianghongbao_tex.json", "snatchAnimation")

	    armatureDisplay = factory:buildArmatureDisplay("armatureName", "snatchAnimation")
	    if armatureDisplay then
	    	--监听播放完成事件
	    	local function eventCustomListener(event)
		    	armatureDisplay:retain()
		    	armatureDisplay:removeFromParent(false)

		    	-- self.isPlayingAnim = false

		    	-- self.tableview:setEnabled(true)
		    end

		    local listener = cc.EventListenerCustom:create("complete", eventCustomListener)
		    armatureDisplay:getEventDispatcher():setEnabled(true)
			armatureDisplay:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

		    self.snatchAnimation = armatureDisplay
		end
	end

	-- local scaleX = frameSize.width / 1334
	-- local scaleY = frameSize.height / 750
	local x, y = self.imgPop:getPosition()
	local pos = widget:getWorldPosition()
	local size = widget:getContentSize()
	-- log(pos)
	-- log(size)
	-- log((pos.x*scaleX + size.width/2) .. ", " .. (pos.y*scaleY + size.height/2))
	-- log("scaleX : " .. scaleX .. ", scaleY : " .. scaleY)
	-- armatureDisplay:setAnchorPoint(cc.p(0.5, 0.5))
    armatureDisplay:setPosition(x, pos.y + size.height/2)
    armatureDisplay:setScale(0.8)
    --动画播放。只播放一次
    armatureDisplay:getAnimation():play("qianghongbao", 1)
    
    if not armatureDisplay:getParent() then
	    self.rootNode:addChild(armatureDisplay, 1)
	end

    -- self.isPlayingAnim = true
end

-----------tableView began-----------
function prototype:createTableView(listData)
 	self.data = listData

	local tableData = {
		size = cc.size(252, 590),
		source = self,
		csbFunc = bind(self.getCsbName, self),
		margin = 0,
		cellData = self.data,
	}

	self.tableview:createTable(tableData)
	self.tableview:reloadData()

	-- self.tableview:setEnabled(false)
	-- self.tableview:scrollToBottom(0, true)
end

function prototype:getCsbName(tb, idx)
	return "Redpacket/FloorListItem"
end

--设置cell大小,
function prototype:tableCellSizeForIndex(tb, idx)
	local size

	if tb == self.tableview then
		if self.data[idx].cell_size then
			size = self.data[idx].cell_size
		else
			size = cc.size(252, 116)
		end
	end
	return size
end

-----------tableView end-----------

function prototype:onImageCloseClick()
	if self.isPlayingAnim then
		return
	end

	self.imgPop:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(-self.size.width, 0)), cc.CallFunc:create(function()
		self:close()
	end)))
end
