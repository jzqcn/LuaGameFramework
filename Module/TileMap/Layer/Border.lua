local Layer   = require "TileMap.Layer"
local Dynamic = require "TileMap.Strategy.Dynamic"

module(..., package.seeall)

class = Layer.class:subclass()

function class:initialize(map, camera, data, dynamicCells)
    super.initialize(self, map)

    self.data = data.cells
    self.dynamicCells = dynamicCells
    local viewSize = camera:getViewSize()

    local info = map:getInfo()
    local maxCols, maxRows = info.cols, info.rows

    self.animationName = "map_border_animation"
    local animation = self:createAnimation()
    local animationCache = cc.AnimationCache:getInstance()
    animationCache:addAnimation(animation, self.animationName)

    self.strategy = Dynamic.class:new(map, self.node, self.dynamicCells, function(index)
        local cx, cy = map:index2cell(index)
        if not (cx == 0 or cy == maxRows or cy == 0 or cx == maxCols) 
            or (cx < 0 or cx > maxCols or cy < 0 or cy > maxRows)
            or (cx == maxCols and cy == maxRows) then
            return nil
        end

        local node = cc.Node:create()

        local sign = (cx == 0 or cx == maxCols) and 1 or -1
        local abondonX = (cx == 0 and cy == maxRows) and (sign == 1)
        local abondonY = (cx == maxCols and cy == 0) and (sign == -1)

        if not (abondonY or abondonX) then
            local sprite = self:createSprite(sign)
            node:addChild(sprite)
        end

        if  (cx == 0 and cy == 0) or (cx == 0 and cy == maxRows) then
            local sprite = self:createSprite(-sign)
            node:addChild(sprite)
        end
        return node
    end)
end

function class:createSprite(sign)
    local skewY, offset = 26.5, cc.p(64, 40)
    offset.x = offset.x * (-sign)

    local animationCache = cc.AnimationCache:getInstance()
    local animation = animationCache:getAnimation(self.animationName)
    local sprite = cc.Sprite:create()
    sprite:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))

    sprite:setSkewY(sign * skewY)
    sprite:setPosition(offset)
    sprite:setOpacity(128)

    return sprite
end

function class:dispose()
    super.dispose(self)
    local animationCache = cc.AnimationCache:getInstance()
    animationCache:removeAnimation(self.animationName)
end

function class:viewportChanged(x, y)
    self.strategy:update(x, y)
end


local frames =
{
    "resource/images/map/00000.png",
    "resource/images/map/00002.png",
    "resource/images/map/00004.png",
    "resource/images/map/00006.png",
    "resource/images/map/00008.png",
    "resource/images/map/00010.png",
    "resource/images/map/00012.png",
    "resource/images/map/00014.png",
}
function class:createAnimation()
    local animation = cc.Animation:create()
    for _, frame in ipairs(frames) do
        local spr = cc.Sprite:create(frame)
        animation:addSpriteFrame(spr:getSpriteFrame())
    end
    animation:setDelayPerUnit(1 / 7)
    return animation
end
