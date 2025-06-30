module (..., package.seeall)

prototype = Controller.prototype:subclass()

local totalSceneNum = 4

function prototype:enter()
	-- local index = cc.UserDefault:getInstance():getIntegerForKey("SCENE_BG_INDEX")
	local data = {}
	for i = 0, totalSceneNum do
		table.insert(data, i)
	end

	local param = 
	{
		data = data,
		ccsName = "System/SceneNodeItem",
		dataCheckFunc = function (pageData, elem) return pageData == elem end
	}

    self.pageview:createPages(param)

    self.imgUseing:setVisible(true)
	self.btnUse:setVisible(false)

	self.pageview:addEventListener(bind(self.pageTouch, self))
end

function prototype:setSelectPageIndex()
	if self.selIndex == nil then
		local index = db.var:getUsrVar("SCENE_BG_INDEX")
		if not index or index < 0 then
			index = 0
		end

		-- log("sel page index : " .. index)

		self.selIndex = index
		self.pageview:setCurrentPageIndex(self.selIndex)
	end	
end

function prototype:pageTouch(sender, types)
	if types == PAGEVIEW_EVENT_TURNING then
		local curIdx = self.pageview:getCurrentPageIndex()
		-- log("turning curIdx:"..curIdx..", selIndex:"..self.selIndex)
		if curIdx == self.selIndex then
			self.imgUseing:setVisible(true)
			self.btnUse:setVisible(false)
		else
			self.imgUseing:setVisible(false)
			self.btnUse:setVisible(true)
		end
	-- else types == PAGEVIEW_TOUCHLEFT then	
	-- else types == PAGEVIEW_TOUCHRIGHT then
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

function prototype:onBtnUseClick()
	local curIdx = self.pageview:getCurrentPageIndex()
	if self.selIndex == curIdx then
		return
	end

	if StageMgr:isStage("Hall") then
		local hallView = ui.mgr:getDialogRootNode()
		-- local hallView = ui.mgr:getLayer("Hall/HallView")
		if hallView and hallView.sceneChangeBg then
			hallView:sceneChangeBg(curIdx)
		end
	elseif StageMgr:isStage("Game") then
		local gameView = ui.mgr:getDialogRootNode()
		if gameView and gameView.imgBg then
			gameView.imgBg:loadTexture(string.format("resource/csbimages/Hall/Bg/tableBg_%d.png", curIdx))
		end
	end

	self.imgUseing:setVisible(true)
	self.btnUse:setVisible(false)

	-- self:fireUIEvent("Setting.SceneBgChange", curIdx)

	self.selIndex = curIdx

	db.var:setUsrVar("SCENE_BG_INDEX", curIdx)
	-- cc.UserDefault:getInstance():setIntegerForKey("SCENE_BG_INDEX", curIdx)
end


