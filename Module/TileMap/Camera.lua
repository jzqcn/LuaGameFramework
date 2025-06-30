module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(map, viewSize)
    super.initialize(self)
    -- self.node = map:getNode()
    self.pos = { x = 0, y = 0, }
    self.lastPos = { x = -1, y = -1, }
    self.viewSize = viewSize
    self.followObj = nil
end

function class:dispose()
    super.dispose(self)
end

function class:setPos(x, y)
    self.pos.x = x
    self.pos.y = y
end

function class:getPos()
    return self.pos.x, self.pos.y
end

function class:getViewSize()
    return self.viewSize
end

function class:update()
    self:updateFollow()

    local x, y = self.pos.x, self.pos.y 
    if x == self.lastPos.x and y == self.lastPos.y then
        return false
    end

    self.lastPos.x, self.lastPos.y = x, y
    return true
end

-------------------
-- 视角跟随
function class:setFollowObj(obj)
    self.followObj = obj
end

function class:getFollowObj()
    return self.followObj
end

function class:updateFollow()
    if nil == self.followObj then
        return 
    end

    --人物居中
    local x, y = self.followObj:getPos()
    self:setPos(x - self.viewSize.width/2, y - self.viewSize.height/2)
end

