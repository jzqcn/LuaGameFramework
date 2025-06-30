local ScrollView = require "UI.Control.ScrollView"

module(..., package.seeall)


prototype = ScrollView.prototype:subclass()

function prototype:enter()
    self.items = {}
end

--{ccsNameOrFunc:可以为string 也可以是函数 通过索引区分ccs
--  ccsPopupName:点击弹出操作item
--  ccsDefaultName:当ccsNameOrFunc是函数时，可以通过该参数指定默认的model item
--  interval 间隔
--  dataCheckFunc: item检测函数 用于update函数判断是哪个item被改变 减少刷新的数量
--  data 数据数组  一般只放id 具体内容到各自界面里自己获取
--}
function prototype:createItems(info)
    if type(info.ccsNameOrFunc) == "string" then
        self.ccsName = info.ccsNameOrFunc
    else
        self.ccsNameFunc = info.ccsNameOrFunc
        self.ccsDefaultName = info.ccsDefaultName
    end

    self.ccsPopupName = info.ccsPopupName

    assert(info.dataCheckFunc)
    self.dataCheckFunc = info.dataCheckFunc 

    if info.interval then
        self.rootNode:setItemsMargin(info.interval)
    end

    self:createFromData(info.data)
end

function prototype:getCcsName(data)
    if self.ccsName then
        return self.ccsName
    end
    return self.ccsNameFunc(data)
end

function prototype:getDefaultCcsName()
    return self.ccsName or self.ccsDefaultName
end

function prototype:createFromData(data)
    local ccsName = self:getDefaultCcsName()
    self:createItemModel(ccsName)

    for idx, info in ipairs(data) do
        self:insertItem(self:getCcsName(info), idx, info)
    end
end

function prototype:addDataListInTop(dataList)
    local maxCount = #dataList
	local dis = cc.p(0,0)
	local prePos = cc.p(self:getInnerContainerPosition())
	for i = maxCount, 1 , -1 do
		local info = dataList[i]
		local node = self:insertItem(self:getCcsName(info), 1, info)
	end

	self:refreshContainer(prePos, dis)	
end

function prototype:addDataInBottom(info, idx)
	local prePos = cc.p(self:getInnerContainerPosition())
    local node =  self:insertItem(self:getCcsName(info), idx, info)
    local margin = self:getItemsMargin()

    local size = node:getContentSize()
    local dis = cc.p(size.width + margin, size.height + margin)
    self:refreshContainer(prePos, dis)
end

function prototype:addDataListInBottom(dataList, minIdx, maxIdx)
	local dis = cc.p(0,0)
	local n = 1
	local prePos = cc.p(self:getInnerContainerPosition())
	local margin = self:getItemsMargin()
	for i = minIdx, maxIdx do
		local info = dataList[n]
		n = n + 1
		local node = self:insertItem(self:getCcsName(info), i, info)
		dis.x = dis.x + node:getContentSize().width + margin
		dis.y = dis.y + node:getContentSize().height + margin
	end

	self:refreshContainer(prePos, dis)
end

function prototype:refreshContainer(prePos, dis)
  local diretionType = self.rootNode:getDirection()
    if diretionType == LISTVIEW_DIR_VERTICAL then
	  	if prePos.y > -10 then
	  		self:jumpToBottom()
	  	else
	  		prePos.y = prePos.y - dis.y

	  		self:doLayout()
	  		self:setInnerContainerPosition(prePos)
	  		self:updateAutoStartPosition(cc.p(0, dis.y))
	  	end
	else 
	  	if prePos.x > -10 then
	  		self:jumpToRight()
	  	else
	  		prePos.x = prePos.x- dis.x

	  		self:doLayout()
	  		self:setInnerContainerPosition(prePos)
	  		self:updateAutoStartPosition(cc.p(dis.x, 0))
	  	end

	end	
end

function prototype:createItemModel(ccsName)
    if ccsName == nil or self.itemModel ~= nil then
        return
    end

    local node = self:getLoader():loadAsLayer(ccsName)
    self.itemModel = {ccsName = ccsName, node = node}
    self.rootNode:setItemModel(node)
end

function prototype:createItem(ccsName, idx)
    local node
    if self.itemModel and self.itemModel.ccsName == ccsName then
        local widget = self:getLoader():castWidget(self.itemModel.node)
        assert(widget, "ListView Item must use Widget class:" .. ccsName)

        node = widget:cloneWidget()
        self:getLoader():loadFromClone(ccsName, node)
    else
        node = self:getLoader():loadAsLayer(ccsName)
        node = self:getLoader():castWidget(node)
    end

    self.rootNode:insertCustomItem(node, idx - 1)
    return node
end

function prototype:insertItem(ccsName, idx, data)
	local node = self:createItem(ccsName, idx)
    if node.refresh ~= nil then
        node:refresh(data)
    end

    table.insert(self.items, idx, {node=node, data=data})
    return node
end

function prototype:getSubItem(info)
    local idx = self:getItemIndex(info)
    if idx == -1 then
        return
    end

    return self.items[idx].node
end

function prototype:deleteItem(info)
	local idx = self:getItemIndex(info)
	self:deleteItemByIdx(idx)
end

function prototype:deleteItemByIdx(idx)
    if idx ~= -1 then
        table.remove(self.items, idx)
        self.rootNode:removeItem(idx - 1)
    end
end

function prototype:getItemIndex(data, node)
	for idx, v in ipairs(self.items) do
		if (node and v.node == node) then
            if self.popupItemIdx ~= nil and self.popupItemIdx < idx then
                idx = idx - 1
            end

			return idx
		end 
	end
	return -1
end

function prototype:jumpToItem(data, alignType)
    local idx = self:getItemIndex(data)
    idx = math.min(#self.items, idx)
    local alignRate = 0
    if alignType == "MID" then
        alignRate = 0.5
    elseif alignType == "TOP" or alignType == "RIGHT" then
        alignRate = 1
    elseif alignType == "BOTTOM" or alignType == "LEFT" then
        alignRate = 0
    end

    local clipNodeSize = self:getContentSize()
    local clipNodeWidth, clipNodeHeight = clipNodeSize.width, clipNodeSize.height
    local innerContSize = self:getInnerContainer():getContentSize()
    local innerContWidth, innerContHeight = innerContSize.width,  innerContSize.height

    local node = self.items[idx].node
    local diretionType = self.rootNode:getDirection()
    if diretionType == LISTVIEW_DIR_VERTICAL then
        local posY = node:getPositionY() + (node:getContentSize().height  - clipNodeHeight) * alignRate
        local deltaY = innerContHeight - clipNodeHeight
        local percent = math.min(math.max((1 - posY / deltaY) * 100, 0), 100)
        self.rootNode:jumpToPercentVertical(percent)
    else
        local posX = node:getPositionX() + (node:getContentSize().width - clipNodeWidth) * alignRate
        local deltaX = innerContWidth - clipNodeWidth
        local percent = math.min(math.max(posX / deltaX * 100, 0), 100)
        self.rootNode:jumpToPercentHorizontal(percent)
    end
end

function prototype:showPopupItem(data)
    local lineIdx, idx = self:getItemIndex(data)
    idx = idx or lineIdx
    if self.popupItemIdx == idx then
        self:hidePopupItem()
        return
    elseif self.popupItemIdx ~= nil then
        self:hidePopupItem()
    end

    if self.ccsPopupName == nil then
        return
    end

    self:insertItem(self.ccsPopupName, lineIdx + 1, data)
    self.popupLineIdx = lineIdx
    self.popupItemIdx = idx

    self:jumpToItem(data, "MID")
end

function prototype:hidePopupItem()
    self:deleteItemByIdx(self.popupLineIdx + 1)
    self.popupLineIdx = nil
    self.popupItemIdx = nil
end

function prototype:recreateListView(info)
    self.rootNode:removeAllItems()
    self.items = {}

    if info.ccsNameOrFunc then
        if type(info.ccsNameOrFunc) == "string" then
            self.ccsName = info.ccsNameOrFunc
        else
            self.ccsNameFunc = info.ccsNameOrFunc
            self.ccsDefaultName = info.ccsDefaultName
        end
    end

    self.ccsPopupName = info.ccsPopupName or self.ccsPopupName
    self.dataCheckFunc = info.dataCheckFunc or self.dataCheckFunc

    if info.interval then
        self.rootNode:setItemsMargin(info.interval)
    end
    self:createFromData(info.data)
end

function prototype:refreshListView(data)
    if self.popupLineIdx ~= nil then
        self:hidePopupItem()
    end

    local dataSize = #data
    local itemsSize = #self.items
    if itemsSize > dataSize then
        for i=itemsSize, dataSize+1, -1 do
            self:deleteItemByIdx(i)
        end
    end
    
    for idx, v in ipairs(data) do
        local itemCell = self.items[idx]
        if itemCell ~= nil then
            itemCell.data = v
            if itemCell.node.refresh ~= nil then
                itemCell.node:refresh(v)
            end
        else
            self:insertItem(self.ccsName, idx, v)
        end
    end
end

