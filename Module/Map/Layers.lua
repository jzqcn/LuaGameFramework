module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(map, camera, data)
    super.initialize(self)

    self.map = map
    local node = cc.Node:create()
    self.map:getNode():addChild(node)

    self.layers = list.map(function(info)
        return self:createLayer(camera, info)
    end, data.layers)
end

function class:dispose()
    for _, layer in ipairs(self.layers) do
        layer:dispose()
    end
    super.dispose(self)
end

function class:viewportChanged(x, y)
    for _, layer in ipairs(self.layers) do
       if layer.layerName ~= "ControlMapLayer" and layer.layerName ~= "TileMapLayer"then
            layer:viewportChanged(x, y)
       end
    end
end

function class:controlLayerChenged(x, y)
    if self.controlLayer then
        self.controlLayer:viewportChanged(x, y)
    end
end

function class:createLayer(camera, data)
    local layer = require("Map.Layer." .. data.type).class:new(self.map, camera, data)
    layer:startCreate()

    if data.type == "TileMapLayer" then
        self.tileLayer = layer
    end 

    if data.type == "ControlMapLayer" then
        self.controlLayer = layer 
    end
    return layer
end

function class:getInteractiveLayer()
    return self.layers[#self.layers]
end

function class:getControlLayer()
    return self.controlLayer or self.layers[#self.layers]
end

function class:isBlock(cx, cy)
    return self.tileLayer:isBlock(cx, cy)
end

function class:isShade(cx, cy)
    return self.tileLayer:isShade(cx, cy)
end

function class:showCellsByList(list, img)
    self.tileLayer:showCellsByList(list, img)
end