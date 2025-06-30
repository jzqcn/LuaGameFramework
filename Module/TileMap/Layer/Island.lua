local Layer   = require "TileMap.Layer"
local Dynamic = require "TileMap.Strategy.Dynamic"
local Pool    = require "Pool"

module(..., package.seeall)

class = Layer.class:subclass()

function class:initialize(map, camera, data, dynamicCells)
    super.initialize(self, map)

    self.data = data.cells
    self.pool  = Pool.class:new()
    self.dynamicCells = dynamicCells

    local viewSize = camera:getViewSize()
    self.strategy = Dynamic.class:new(map, self.node, self.dynamicCells, function(index)
        local cell = self.data[index]
        if cell == nil or cell.island == nil then
            return nil
        end
        local sprite = self.pool:getFromPool("Sprite", cell.island.path)
        sprite:setScale(cell.island.scale)
        return sprite
        
    end, function(node, index)
        local cell = self.data[index]
        self.pool:putInPool(cell.island.path, node)
    end)
end

function class:dispose()
    super.dispose(self)
    self.pool:dispose()
end

function class:viewportChanged(x, y)
    self.strategy:update(x, y)
end

function class:isBlocked(x, y)
    local cell = self.data[self.map:cell2index(x, y)]
    return (cell ~= nil and cell.blocked)
end
