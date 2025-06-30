module (..., package.seeall)

prototype = Controller.prototype:subclass()

local AD_PAGE_NUM = 2

function prototype:enter()
	self:bindUIEvent("GoldGame.DownGameSuccess", "uiEvtDownGameSuccess")

	-- util.timer:after(200, self:createEvent("playAction"))
	self.pos = cc.p(self.rootNode:getPosition())
	self.winSize = cc.Director:getInstance():getWinSize()
	local goldItemTable = Model:get("Hall"):getGoldItemTable()
	if #goldItemTable>2 then
		table.sort( goldItemTable, function(a,b)
			if a.sort>b.sort then
				return true
			else
				if a.sort == b.sort then
					return a.typeId > b.typeId
				else
					return false
				end
			end
	 	end )
	 end

	--dump(goldItemTable,"goldItemTable")
	local data = {}
	local rowItems = {}
	--每一列放2个图标
	for i, v in ipairs(goldItemTable) do
		table.insert(rowItems, v)
		if #rowItems == 2 then
			data[#data + 1] = rowItems
			rowItems = {}
		end
	end

	if #rowItems > 0 then
		data[#data + 1] = rowItems
	end

	local param = 
	{
		data = data,
		ccsNameOrFunc = "Hall/GoldComponentItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.listview:createItems(param)
    self.listview:setScrollBarEnabled(false)
	
	local data2 = {}
	for i = 1, AD_PAGE_NUM do
		local info={}
		info[1]={i,"没有设置微信"}
		data2[i]=info
	end
	local param = 
	{
		data = data2,
		ccsName = "Hall/GoldAdPageItem",
		dataCheckFunc = function (pageData, elem) return pageData == elem end
	}

    self.pageview:createPages(param)
	self.pageview:addEventListener(bind(self.pageTouch, self))
	self.addPageIndex = 1--从0开始，第0页，第一页，第二页
	self.pageIndex = 0 
	local action=cc.Sequence:create(cc.DelayTime:create(6),
		cc.CallFunc:create(function() 
								self.pageIndex=self.pageIndex+1
								self.pageview:scrollToPage(self.pageIndex)
							end )
	)
	self.pageview:runAction(cc.RepeatForever:create(action))
	local serviceNumbers=Model:get("User"):getCustomServiceNumbers()
	if #serviceNumbers < 1 then
		Model:get("User"):requestCustomServiceNumbers()
	else
		local items = self.pageview:getItems()
		for i, v in ipairs(items) do
			v:onPushCustomServiceNumbers(serviceNumbers)
		end
	end
end

function prototype:pageTouch(sender, types)
	if types == PAGEVIEW_EVENT_TURNING then
		local curIdx = self.pageview:getCurrentPageIndex()
		if curIdx==AD_PAGE_NUM-1 then			 
			self.pageIndex=-1  --到最后一页时跳到负一页
		end
	-- else types == PAGEVIEW_TOUCHLEFT then	
	-- else types == PAGEVIEW_TOUCHRIGHT then
	end
end

function prototype:playAction()

end

function prototype:show()
	self.rootNode:setPosition(self.pos)
	self.rootNode:setVisible(true)

	local items = self.listview:getAllItems()
	for i, v in ipairs(items) do
		v:playAction((i-1) * 0.2)
	end

	self.pageview:setVisible(false)
	self.pageview:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(function()
		self.pageview:setVisible(true)
	end)))
end

function prototype:hide()
	local moveBy = cc.MoveBy:create(0.5, cc.p(-self.winSize.width, 0))
	self.rootNode:runAction(cc.Sequence:create(cc.EaseOut:create(moveBy, 2.5), cc.CallFunc:create(function()
		self.rootNode:setVisible(false)
	end)))
	
end

--相同类型游戏下载的是同一个包（例如 龙虎、上庄龙虎  单挑、上庄单挑）
function prototype:uiEvtDownGameSuccess(gameName, typeName)
	local items = self.listview:getAllItems()
	for _, v in ipairs(items) do
		local itemList = v:getGameNodeByType(typeName)
		for i, node in ipairs(itemList) do
			if gameName ~= node:getName() then
				node:removeAssertProgress()
			end
		end
	end
end
