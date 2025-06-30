local Layer   = require "Map.Layer"
local DynamicCell = require "Map.Strategy.DynamicCell"
local Pool    = require "Pool"

module(..., package.seeall)


local SHOW_ALL_TILES = false
local SHOW_BLOCK_AND_SHADE = false 

class = Layer.class:subclass()

function class:initialize(map, camera, data)
    super.initialize(self, map, camera, data)

    self.layerName = "TileMapLayer"
    self.pool  = Pool.class:new()
    self.coordinate = self.map:getCoordinate()
end

function class:dispose()
    super.dispose(self)
    self.pool:dispose()
end

function class:viewportChanged(x, y)
    self.strategy:update(x, y)
end

function class:isBlock(cx, cy)

    return false
end

function class:isShade(cx, cy)
    return false
end

function class:startCreate()
    self.strategy = DynamicCell.class:new(self.map, self.node, self.camera, function(index)
        local cell = self.data.cells[index]
        if cell == nil then
            return nil
        end

        local node = self.pool:getFromPool("Sprite", cell:getImgPath())
        return node

    end, function(node, index)
        local cell = self.data.cells[index]
        self.pool:putInPool(cell:getImgPath(), node)
    end)

    if SHOW_ALL_TILES then
        self:showAllTiles()
    end

    if SHOW_BLOCK_AND_SHADE then
        self:showBlockAndShade()
    end
end

function class:showCellsByList(list, imgPath)
    imgPath = imgPath or "resource/map/resource/other/block.png"
    local mapInfo = self.map:getInfo()
    local scaleX = mapInfo.cw / 256
    local scaleY = mapInfo.ch / 128

    if self.lastShowNode then
        self.lastShowNode:removeFromParent(true)
        self.lastShowNode = nil
    end

    local coordinate = self.coordinate
    local node = cc.Node:create()
    for _, cellIdx in ipairs(list) do
        local cx, cy = coordinate:index2cell(cellIdx)
        local x, y = coordinate:cell2world(cx, cy)

        local cellNode = cc.Node:create()
        cellNode:setPosition(cc.p(x, y))
        node:addChild(cellNode)

        local sprite = cc.Sprite:create(imgPath)
        --sprite:setScale(0.5)  --原始图256*128
        sprite:setScaleX(scaleX)
        sprite:setScaleY(scaleY)
        sprite:setOpacity(160)
        cellNode:addChild(sprite)

        local label = cc.Label:create()
        local cellIdx = coordinate:cell2index(cx, cy)
        label:setString(string.format("(%d,%d)\n  %d", cx, cy, cellIdx))
        label:setColor(cc.c3b(255,0,0))
        label:setSystemFontSize(16)
        cellNode:addChild(label)
    end

    self.lastShowNode = node
    self.node:addChild(node)
end


---------------private--------------------

function class:showBlockAndShade()
    self:showCellsByList(self.data.blockList, "resource/map/resource/other/block.png")
    self.lastShowNode = nil
    self:showCellsByList(self.data.shadeList, "resource/map/resource/other/shade.png")
    self.lastShowNode = nil
end


function class:showAllTiles()
    local mapInfo = self.map:getInfo()
    local coordinate = self.coordinate

    local node = cc.Node:create()
    local cells = {}

    local halfSizeX = math.ceil(mapInfo.rows / 2)
    local halfSizeY = math.ceil(mapInfo.cols/ 2)

    local xbegin = -1 * halfSizeX  --0
    local ybegin = -1 * halfSizeY  --0
    local xend = mapInfo.rows + halfSizeX  --mapInfo.rows - 1
    local yend = mapInfo.cols + halfSizeY  --mapInfo.cols - 1

    local onlyPositive = true
    if onlyPositive then
        xbegin = 0
        ybegin = 0
        xend = mapInfo.rows - 1
        yend = mapInfo.cols - 1
    end

    local list = {}
    for i = xbegin, xend do
        for j = ybegin, yend do
            table.insert(list, coordinate:cell2index(i, j))
        end
    end

    self:showCellsByList(list, "resource/map/resource/other/shade.png")
    self.lastShowNode = nil
end