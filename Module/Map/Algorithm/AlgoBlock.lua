local PreLoad = require "UI.PreLoad"

module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(map, viewSize, data)
    self.map = map
    self.viewSize = viewSize
    self.mapInfo = self.map:getInfo()

    self.blocks = {}
    self.showItems = {}
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
    for idx, item in ipairs(data.items) do
        local pos, size = item:getImgPosition()
        local blocks = self:rect2block(cc.rect(pos.x - size.width/2, pos.y - size.height/2, size.width, size.height))
        for _, info in ipairs(blocks) do
            local block = self:refBlock(info.x, info.y)
            table.insert(block, idx)
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
    if lastPos.min.x == minx and lastPos.min.y == miny and
           lastPos.max.x == maxx and lastPos.max.y == maxy then
        self.showItems = {}
        return
    end

    lastPos.min.x, lastPos.min.y = minx, miny   
    lastPos.max.x, lastPos.max.y = maxx, maxy
    self.lastBlockPos = lastPos

    self.showItems = self:getBlockItemsByRect(minx, miny, maxx, maxy)

    self:preloadImage(minx, miny, maxx, maxy)
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

    local items = list.concat(unpack(blocks))
    return table.indices(table.invert(items))  --排除重复
end

function class:getItems()
	return self.showItems
end

function class:preloadImage(minx, miny, maxx, maxy)
    minx = minx - self.preloadExtend.w
    miny = miny - self.preloadExtend.h
    maxx = maxx + self.preloadExtend.w
    maxy = maxy + self.preloadExtend.h

    local imgList = {}
    local items = self:getBlockItemsByRect(minx, miny, maxx, maxy)
    for _, itemIdx in ipairs(items) do
        local item = self.data.items[itemIdx]
        local path = item:getImgPath()
        table.insert(imgList, path)
    end

    PreLoad:loadImages(imgList)
end

