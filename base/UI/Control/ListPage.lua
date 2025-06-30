local PageView = require "UI.Control.PageView"

module(..., package.seeall)

prototype = PageView.prototype:subclass()

function prototype:enter()
	super:enter()

	self.isJudge = false

	local layer = cc.Layer:create()
    self.rootNode:addChild(layer, 9999)
    Assist.Touch:registLayerTouch(layer, bind(self.onTouch, self))
end

-- info =
-- {
--     data : 存放每一页数据的数组 每一页数据存放的是 用于初始化页面内控件的数据
--     ccsName : csb文件名
--     dataCheckFunc : item检测函数 用于update函数判断是哪个item被改变 减少刷新的数量
-- }
function prototype:createPages(info)
	super.createPages(self, info)
	self:setPages()

	self.datas = info.data
end

function prototype:recreatePageView(info)
	super.recreatePageView(self, info)
	self:setPages()

	self.datas = info.data
end

function prototype:refreshPageView(data)
	super.refreshPageView(self, data)
	self:setPages()

	self.datas = data
end

function prototype:setPages()
	local pages = self.rootNode:getItems()
	for _, page in ipairs(pages) do
		local pageList = self:getListChild(page)
		pageList:setScrollBarEnabled(false)

		pageList:setSwallowTouches(false)
		self:listChildSwaFalse(pageList)
	end
end

function prototype:listChildSwaFalse(list)
	for _, item in ipairs(list.items) do
		local icon = item.node

		local children = icon:getChildren()
		self:childrenSwaFalse(children)
	end
end

function prototype:childrenSwaFalse(children)
	for _, child in ipairs(children) do
		child:setSwallowTouches(false)
		
		if child:getChildrenCount() > 0 then
			self:childrenSwaFalse(child:getChildren())
		end
	end
end

function prototype:onTouch(types, pos)
	if types == "began" then
		self.tchBeganPos = pos
		return true

	elseif types == "move" then
		if not self.isJudge then
			self.isJudge = true
			self:judgeDirec(pos)
		end

	elseif types == "end" then
		self.rootNode:setTouchEnabled(true)
		self:setHorizonMoveEnable()
		self.isJudge = false
	end
end

function prototype:judgeDirec(judgePos)
	local horizMove = math.abs(judgePos.x - self.tchBeganPos.x)
	local verticMove = math.abs(judgePos.y - self.tchBeganPos.y)

	local page = self.rootNode
	local list = self:getCurList()
	if not list then
		return
	end

	if horizMove > verticMove then
		list:setTouchEnabled(false)
		page:setTouchEnabled(true)

	else
		page:setTouchEnabled(false)
		list:setTouchEnabled(true)
	end
end

function prototype:setHorizonMoveEnable()
	local pages = self.rootNode:getItems()
	for _, page in ipairs(pages) do
		local pageList = self:getListChild(page)
		pageList:setTouchEnabled(true)
		pageList:setSwallowTouches(false)
	end
end

function prototype:getCurList()
	local curPageIdx = self.rootNode:getCurrentPageIndex()
	if curPageIdx == -1 then
		curPageIdx = 0
	end
	curPageIdx = curPageIdx + 1

	local pageData = self.datas[curPageIdx]
	local pageItem = self.rootNode:getSubItem(pageData)

	return self:getListChild(pageItem)
end

function prototype:getListChild(item)
	if item == nil then
		return nil 
	end

	local children = item:getChildren()

	for _, child in ipairs(children) do
		if child:getDescription() == "ListView" then
			return child
		end
	end

	return nil
end