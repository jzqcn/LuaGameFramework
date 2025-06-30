module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(map, viewSize)
    super.initialize(self)

    self.pos = { x = 0, y = 0, }
    self.lastPos = { x = -1, y = -1, }
    self.viewSize = viewSize
    self.followObj = nil

    local mapInfo = map:getInfo()
    self.invalidRect = {x = mapInfo.vx, y = mapInfo.vy, 
                w = mapInfo.vw - viewSize.width, 
                h = mapInfo.vh - viewSize.height}
end

function class:dispose()
    super.dispose(self)
end

function class:setPos(x, y)
    x, y = self:checkPos(x, y)
    self.pos.x = x
    self.pos.y = y
end

function class:checkPos(x, y)
    x = math.max(x, self.invalidRect.x)
    x = math.min(x, self.invalidRect.w)
    y = math.max(y, self.invalidRect.y)
    y = math.min(y, self.invalidRect.h)
    return x, y
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

