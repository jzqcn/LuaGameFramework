local DynamicCells = require "TileMap.DynamicCells"

module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(map, camera, data)
    super.initialize(self)

    self.map = map
    self.dynamicCells = DynamicCells.class:new(map, camera:getViewSize())

    local node = cc.Node:create()
    self.map:getNode():addChild(node)

    self.layers = list.map(function(name)
        return self:createLayer(camera, name, data)
    end, data.layers)
end

function class:dispose()
    for _, layer in ipairs(self.layers) do
        layer:dispose()
    end
    super.dispose(self)
end

function class:viewportChanged(x, y)
    self.dynamicCells:update(x, y)
    for _, layer in ipairs(self.layers) do
        layer:viewportChanged(x, y)
    end
end

function class:isBlocked(x, y)
    for layer in list.relems(self.layers) do
        if layer:isBlocked(x, y) then
            return true
        end
    end
    return false
end

--  private  --

function class:createLayer(camera, name, data)
    return require("TileMap.Layer." .. name).class:new(self.map, camera, data, self.dynamicCells)
end

function class:getInteractiveLayer()
    return self.layers[#self.layers]
end