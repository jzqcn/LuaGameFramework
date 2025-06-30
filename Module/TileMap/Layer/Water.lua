local Layer = require "TileMap.Layer"
local Tile  = require "TileMap.Strategy.Tile"

module(..., package.seeall)

class = Layer.class:subclass()

function class:initialize(map, camera, data)
    super.initialize(self, map)

    local viewSize = camera:getViewSize()
    self.strategy = Tile.class:new(viewSize, {w=256, h=256}, self.node, function()
        return cc.Sprite:create(data.water)
    end)
end

function class:dispose()
    super.dispose(self)
end

function class:viewportChanged(x, y)
    self.strategy:update(x, y)
end
