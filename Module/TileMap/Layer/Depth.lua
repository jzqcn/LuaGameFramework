local Layer   = require "TileMap.Layer"
local Dynamic = require "TileMap.Strategy.Dynamic"
local Pool    = require "Pool"

module(..., package.seeall)

class = Layer.class:subclass()

function class:initialize(map, camera, data, dynamicCells)
    super.initialize(self, map)

    self.data = data.cells
    self.dynamicCells = dynamicCells
    self.pool  = Pool.class:new()

    local viewSize = camera:getViewSize()
    self.strategy = Dynamic.class:new(map, self.node, self.dynamicCells, function(index)
        local cell = self.data[index]
        if cell == nil or cell.depth == nil then
            return nil
        end

        local node = self.pool:getFromPool("Sprite", cell.depth.image)
        node:setTextureRect(cell.depth.rect)
        return node

    end, function(node, index)
        local cell = self.data[index]
        self.pool:putInPool(cell.depth.image, node)
    end)
end

function class:dispose()
    super.dispose(self)
    self.pool:dispose()
end

function class:viewportChanged(x, y)
    self.strategy:update(x, y)
end
