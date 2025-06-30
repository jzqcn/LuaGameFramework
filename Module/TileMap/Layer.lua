module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(map)
    super.initialize(self)

    self.map = map

    local parent = self.map:getNode()
    self.node = cc.Node:create()
    self.node:setContentSize(parent:getContentSize())
    parent:addChild(self.node)
end

function class:dispose()
    super.dispose(self)
end

function class:getRootNode()
	return self.node
end

function class:isBlocked(x, y)
    return false
end
