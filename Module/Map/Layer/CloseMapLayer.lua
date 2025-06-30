local ObjectMapLayer = require "Map.Layer.ObjectMapLayer"

module(..., package.seeall)

class = ObjectMapLayer.class:subclass()

function class:initialize(map, camera, data)
    super.initialize(self, map, camera, data)
    
    self.layerName = "CloseMapLayer"
    self.showAllBlocks = false
end

function class:dispose()
    super.dispose(self)
end

