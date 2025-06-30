local Layout = require "UI.Control.Layout"

module(..., package.seeall)


prototype = Layout.prototype:subclass()

function prototype:enter()
    self.pages = {}
end

-- info =
-- {
--     data : 数据
--     ccsName : csb文件名
--     dataCheckFunc : item检测函数 用于update函数判断是哪个item被改变 减少刷新的数量
-- }
function prototype:createPages(info)
    self.ccsName = info.ccsName
    self.dataCheckFunc = info.dataCheckFunc

    self:createPageFromData(info.data)
    self:setBounceEnabled(true)
end

function prototype:createPageFromData(data)
    for _, pageData in ipairs(data) do
        self:insertOnePage(pageData)
    end
end

function prototype:insertOnePage(pageData, idx)
    local node = self:getLoader():loadAsLayer(self.ccsName)

    idx = idx or #self.pages + 1
    self.rootNode:insertPage(node, idx - 1)  -- from 0
    table.insert(self.pages, idx, {node=node, data=pageData})

    if node.refresh then
        node:refresh(pageData)
    end
end

function prototype:removeOnePageByIdx(idx)
    self.rootNode:removePageAtIndex(idx - 1)
    table.remove(self.pages, idx)
end

function prototype:getSubItem(pageData)
    for _, v in ipairs(self.pages) do
        if self.dataCheckFunc 
            and self.dataCheckFunc(pageData, v.data) then
            return v.node
        end
    end
end

function prototype:recreatePageView(info)
    self.rootNode:removeAllPages()
    self.pages = {}

    self.ccsName = info.ccsName or self.ccsName
    self.dataCheckFunc = info.dataCheckFunc or self.dataCheckFunc

    self:createPageFromData(info.data)
end

function prototype:refreshPageView(data)
    local pageSize = #self.pages
    local dataSize = #data

    if pageSize > dataSize then
        for i=pageSize, dataSize+1, -1  do
            self:removeOnePageByIdx(i)
        end
    end

    for idx, v in ipairs(data) do
        local pageCell = self.pages[idx]
        if pageCell ~= nil then
            pageCell.data = v
            if pageCell.node.refresh ~= nil then
                pageCell.node:refresh(v)
            end
        else
            self:insertOnePage(v)
        end
    end
end

function prototype:jumpToPage(data)
    if self.dataCheckFunc == nil or data == nil then
        log4misc:warn("data is nil or dataCheckFunc is nil")
        return
    end

    local deltaX = nil
    local pageIdx = nil
    for idx, page in ipairs(self.pages) do
        if self.dataCheckFunc(page.data, data) then
            deltaX = page.node:getParent():getPosition()
            pageIdx = idx
            break
        end
    end

    if deltaX == nil then
        return
    end

    for _, page in ipairs(self.pages) do
        local pageNode = page.node:getParent()
        pageNode:setPositionX(pageNode:getPositionX() - deltaX)
    end

    self.rootNode:scrollToPage(pageIdx - 1)  -- set curPageIdx
end

function prototype:turnPage(offset)
    local curPageIdx = self.rootNode:getCurPageIndex()
    local size = #self.pages
    curPageIdx = curPageIdx + offset
    curPageIdx = math.min(math.max(curPageIdx, 0), size - 1)
    self.rootNode:scrollToPage(curPageIdx)
end