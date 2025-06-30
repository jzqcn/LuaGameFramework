module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(map, camera, data)
    super.initialize(self)

    self.layerName = "Layer"
    self.map = map
    self.camera = camera
    self.data = data

    local parent = self.map:getNode()
    self.node = cc.Node:create()
    self.node:setContentSize(parent:getContentSize())
    parent:addChild(self.node)
end

function class:dispose()
    super.dispose(self)
end

function class:init()
end

function class:getRootNode()
	return self.node
end

function class:getName()
    return self.layerName
end

function class:isBlocked(x, y)
    return false
end

function class:isShade(x, y)
	return false
end


