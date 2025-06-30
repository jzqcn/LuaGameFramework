local Layer   = require "Map.Layer"
local DynamicObj = require "Map.Strategy.DynamicObj"
local Pool    = require "Pool"

module(..., package.seeall)


class = Layer.class:subclass()

function class:initialize(map, camera, data)
    super.initialize(self, map, camera, data)
    self.layerName = "ObjectMapLayer"
    self.showAllBlocks = false

    local viewSize = camera:getViewSize()
    data.blockSize = { w = math.ceil(viewSize.width / 3), h = math.ceil(viewSize.height / 3)}
    data.blockExtend = {w = 1, h = 1}
    data.preloadExtend = {w = 3, h = 3}

    local mapInfo = map:getInfo()
    data.blockNum = {w = math.ceil(mapInfo.w / data.blockSize.w), h = math.ceil(mapInfo.h / data.blockSize.h)}
end

function class:dispose()
    --self.pool:dispose()
    super.dispose(self)
end

function class:viewportChanged(x, y)
    self.strategy:update(x, y)
end

function class:startCreate()
    self.strategy = DynamicObj.class:new(self.map, self.node, self.camera, self.data, function(index)
        local item = self.data.items[index]
        if item == nil then
            return nil
        end
        
        local imgPath, effectPath = item:getImgPath()
        local node = cc.Node:create()
        node:setScaleX(item.info.scaleX or 1)
        node:setScaleY(item.info.scaleY or 1)
        node:setRotation(item.info.rotation or 0)

        node:setPosition(cc.p(item.info.x, item.info.y))
        node:setTag(item.info.childTag or -1)
        node:setLocalZOrder(item.info.orderZ or 0)

        local sprite = cc.Sprite:create(imgPath)
        --sprite:setAnchorPoint(cc.p(0, 0))
        sprite:setOpacity(item.info.alpha or 255)
        node:addChild(sprite, 2)

        if self.showAllBlocks then
            local sprSize = sprite:getContentSize()
            local subNode = self:createBlockInfoNode(imgPath, sprSize)
            sprite:addChild(subNode)
        end

        if nil ~= effectPath then
            local order = item.info.effectUpImg and 3 or 1
            local eff = UI.EffectLoader:loadAndRun(effectPath, nil, nil, true)
            if nil == eff then
                log4map:w(eff, "effect not exist:" .. effectPath)
            else
                eff:setPosition(cc.p(item.info.effectPosX, item.info.effectPosY))
                node:addChild(eff, order)
            end
        end
        
        return node 
    end)

    if self.showAllBlocks then
        self:createAllBlocks()
    end
end

function class:createBlockInfoNode(imgPath, sprSize)
    local node = cc.Node:create()
    node:setPosition(cc.p(sprSize.width/2, sprSize.height/2))

    local subCross = cc.Sprite:create("resource/csbimages/Common/cross.png")
    node:addChild(subCross)

    local rect = cc.rect(2, 2, 50, 50)
    local subFrame = ccui.Scale9Sprite:create(rect, "resource/csbimages/Common/frame.png")
    subFrame:setPreferredSize(sprSize)
    node:addChild(subFrame)

    local label = cc.Label:create()
    label:setString(imgPath)
    label:setColor(cc.c3b(255,100,0))
    label:setSystemFontSize(20)
    node:addChild(label, 20)
    return node
end

function class:createAllBlocks()
    local mapInfo = self.map:getInfo()
    local w, h = mapInfo.w, mapInfo.h

    local blockNumW = self.data.blockNum.w
    local blockNumH = self.data.blockNum.h

    local blockSize = self.data.blockSize
    local node = cc.Node:create()

    for i = 0, blockNumW - 1 do
        for j = 0, blockNumH - 1 do
            local blockNode = cc.Node:create()
            local x = i * blockSize.w + blockSize.w/2
            local y = j * blockSize.h + blockSize.h/2

            blockNode:setPosition(cc.p(x, y))

            local rect = cc.rect(2, 2, 50, 50)
            local sprite = ccui.Scale9Sprite:create(rect, "resource/csbimages/Common/frame2.png")

            sprite:setPreferredSize(cc.size(blockSize.w, blockSize.h))
            blockNode:addChild(sprite)

            local label = cc.Label:create()
            local blockIdx = j * blockNumW + i
            label:setString(string.format("(%d,%d)\n  %d", i, j, blockIdx))
            label:setColor(cc.c3b(255,0,0))
            label:setSystemFontSize(20)
            label:setScale(1/0.7)
            blockNode:addChild(label)

            node:addChild(blockNode)
        end
    end

    self.node:addChild(node)
end
