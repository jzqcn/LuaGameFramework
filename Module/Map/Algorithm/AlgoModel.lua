local PreLoad = require "UI.PreLoad"
local Define = require "Map.Define"

module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(map, viewSize, data)
    self.map = map
    self.viewSize = viewSize
    self.mapInfo = self.map:getInfo()

    self.blocks = {}
    self.showItems = {}
    self.showModels = {}
    self.showControls = {}

    self.lastBlockPos = {min={x=math.huge, y=math.huge}, max={x=math.huge, y=math.huge}}

    self.data = data
    self:initBlock(data)
    self:parseItemDistribute(data)
end

function class:dispose()
    super.dispose(self)
end

function class:initBlock(data)
    self.blockSize = data.blockSize  --一个块的大小
    self.blockNum = data.blockNum    --块的总数量
    self.blockExtend = data.blockExtend
    self.preloadExtend = data.preloadExtend
end

function class:block2index(x, y)  --base(0, 0)
    return y * self.blockNum.w + x
end

function class:index2block(idx)
    return idx % self.blockNum.w, math.floor(idx / self.blockNum.w)
end

function class:mapPos2block(x, y)
    local x = math.floor(x / self.blockSize.w)
    local y = math.floor(y / self.blockSize.h)
    return x, y
end

function class:rect2block(rect)
    local startx, starty = self:mapPos2block(rect.x, rect.y)
    local endx, endy = self:mapPos2block(rect.x+rect.width, rect.y+rect.height)
    local blocks = {}
    for i = startx, endx do
        for j = starty, endy do
            table.insert(blocks, {x=i, y=j})
        end
    end
    return blocks
end

function class:refBlock(x, y)
    local idx = self:block2index(x, y)
    local block = self.blocks[idx]
    if block == nil then
        block = {}
        self.blocks[idx] = block
    end

    return block
end

function class:parseItemDistribute(data)
    for idx, item in ipairs(data.models) do
        if item.type == Define.MAP_STATIC_MODEL.ITEM then
            local pos, size = item:getImgPosition()
            local blocks = self:rect2block(cc.rect(pos.x - size.width/2, pos.y - size.height/2, size.width, size.height))
            for _, info in ipairs(blocks) do
                local block = self:refBlock(info.x, info.y)
                table.insert(block, idx)
            end
        end
    end
end

function class:update(x, y)
    local size = self.viewSize
    local minx, miny = self:mapPos2block(x, y)
    local maxx, maxy = self:mapPos2block(x + size.width, y + size.height)

    minx = minx - self.blockExtend.w
    miny = miny - self.blockExtend.h
    maxx = maxx + self.blockExtend.w
    maxy = maxy + self.blockExtend.h

    local lastPos = self.lastBlockPos
    if lastPos.min.x ~= minx or lastPos.min.y ~= miny or
           lastPos.max.x  ~= maxx or lastPos.max.y  ~= maxy then
           self:preloadImage(minx, miny, maxx, maxy)
           self.showItems = self:getBlockItemsByRect(minx, miny, maxx, maxy)
    end

    lastPos.min.x, lastPos.min.y = minx, miny   
    lastPos.max.x, lastPos.max.y = maxx, maxy
    self.lastBlockPos = lastPos

    self.showControls = self:getBlockShowControlModel(minx, miny, maxx, maxy)
end

function class:getBlockItemsByRect(minx, miny, maxx, maxy)
    minx = math.max(minx, 0)
    miny = math.max(miny, 0)
    maxx = math.min(maxx, self.blockNum.w)
    maxy = math.min(maxy, self.blockNum.h)

    local blocks = {}
    for i = minx, maxx do
        for j = miny, maxy do
            local block = self:refBlock(i, j)
            table.insert(blocks, block)
        end
    end

    local block = self:getShowModels(minx, miny, maxx, maxy)
    table.insert(blocks, block)

    local items = list.concat(unpack(blocks))
    return table.indices(table.invert(items))  --排除重复
end


function class:posInRect(pos, minx, miny, maxx, maxy)
    local xMin = (minx - 1) * self.blockSize.w 
    local yMin = (miny - 1) * self.blockSize.h 
    local xMax = maxx * self.blockSize.w 
    local yMax = maxy * self.blockSize.h 

    return pos.x > xMin and pos.y > yMin and pos.x < xMax and pos.y < yMax
end

function class:getShowModels(minx, miny, maxx, maxy)
    local block = {}
    for idx, item in ipairs(self.data.models) do
        if item.type == Define.MAP_STATIC_MODEL.ROLE then
            local pos = item:getNpcPosition()
            if self:posInRect(pos, minx, miny, maxx, maxy) then
                table.insert(block, idx)
            end 
        end
    end
    return block
end

function class:getItems()
	return self.showItems
end

--筛选需要显示的模型
function class:getBlockShowControlModel(minx, miny, maxx, maxy)
     local block = {}
    for id, item in pairs(self.data.controlModel) do
        local x, y = item.node:getPosition()
        local pos = { x = x, y = y}
        if self:posInRect(pos, minx, miny, maxx, maxy) then
            --在显示范围内的
            --在此处添加条件,如显示指定的玩家,指定的物品,特效是否显示等
            item.node:setVisible(true)
            table.insert(block, id)
        else 
            item.node:setVisible(false)
        end
    end

    return block   
end

function class:getControls()
    return self.showControls
end

function class:preloadImage(minx, miny, maxx, maxy)
    minx = minx - self.preloadExtend.w
    miny = miny - self.preloadExtend.h
    maxx = maxx + self.preloadExtend.w
    maxy = maxy + self.preloadExtend.h

    local imgList = {}
    local items = self:getBlockItemsByRect(minx, miny, maxx, maxy)
    if items == nil then 
        return
    end

    for _, itemIdx in ipairs(items) do
        local item = self.data.models[itemIdx]
        if item.type == Define.MAP_STATIC_MODEL.ITEM then
            local path = item:getImgPath()
            table.insert(imgList, path)
        end
    end

    PreLoad:loadImages(imgList)
end
