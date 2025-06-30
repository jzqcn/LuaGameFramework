local Tile  = require "TileMap.Strategy.Tile"
local Layer = require "TileMap.Layer"

module(..., package.seeall)

class = Layer.class:subclass()

function class:initialize(map, camera, data)
    super.initialize(self, map)

    local viewSize = camera:getViewSize()
    local animation = self:createAnimation()
    self.strategy = Tile.class:new(viewSize, {w = 256, h = 256}, self.node, function()
        local sprite = cc.Sprite:create()
        sprite:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
        return sprite
    end)
end

function class:dispose()
    super.dispose(self)
end

function class:viewportChanged(x, y)
    self.strategy:update(x, y)
end

--  private  --
local frames =
{
    "resource/unconvert/haimian/00000.png",
    "resource/unconvert/haimian/00001.png",
    "resource/unconvert/haimian/00002.png",
    "resource/unconvert/haimian/00003.png",
    "resource/unconvert/haimian/00004.png",
    "resource/unconvert/haimian/00005.png",
    "resource/unconvert/haimian/00006.png",
    "resource/unconvert/haimian/00007.png",
    "resource/unconvert/haimian/00008.png",
    "resource/unconvert/haimian/00009.png",
}
function class:createAnimation()
    local animation = cc.Animation:create()
    for _, frame in ipairs(frames) do
        local spr = cc.Sprite:create(frame)
        animation:addSpriteFrame(spr:getSpriteFrame())
    end
    animation:setDelayPerUnit(1 / 15)
    return animation
end
