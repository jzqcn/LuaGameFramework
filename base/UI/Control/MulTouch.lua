local Base = require "UI.Control.Base"

module(..., package.seeall)


prototype = Base.prototype:subclass()

--使用方法
    --注册回调函数
--    function prototype:enter( ... )
--          self.nodeMultiTouches:bindCallback("onTouches", bind(self.mulTouches, self))
--    end

-- --回调函数
-- function prototype:mulTouches(event)
--     
--     local type = event.type --触摸类型 began , moved ,ended
--     
--     for _, touch in ipairs(event.touch) do
--         local pos = touch.pos -- 触摸点cc.p(x, y)
--         local touchId = touch.id -- 触摸点的id (0 , 1, 2, 3, ...)
--     end
-- end


function prototype:enter( ... )
    local layer = cc.Layer:create()
    self.rootNode:addChild(layer)
    self.layer = layer

    self:initMutiTouch()

    self.bTouches = false

    self.touchesPos = {}
    self.touchesCount = 0
end

--@todo
function prototype:initMutiTouch()
    --注册多点触摸listener
    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(bind(self.onTouchesBegan, self), cc.Handler.EVENT_TOUCHES_BEGAN )
    listener:registerScriptHandler(bind(self.onTouchesMoved, self), cc.Handler.EVENT_TOUCHES_MOVED )
    listener:registerScriptHandler(bind(self.onTouchesEnded, self), cc.Handler.EVENT_TOUCHES_ENDED )
    listener:registerScriptHandler(bind(self.onTouchesCancelled,self), cc.Handler.EVENT_TOUCHES_CANCELLED )

    local eventDispatcher = self.layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.layer)
end


--多点回调
function prototype:onTouchesBegan(touches, event)
    local function _touInSide(pos)
        if self.rootNode:isVisible() and self.rootNode:isEnabled() then
            local rect = self.rootNode:getContentSize()
            rect.x = 0
            rect.y = 0
            local localPos = self.rootNode:convertToNodeSpace(pos)
            if cc.rectContainsPoint(rect, localPos) then
                return true
            end
        end
        return false
    end

    for _ ,touch in ipairs(touches) do 
        local id = touch:getId()
        local pos = touch:getLocation()
        self.touchesPos[id + 1] = {id = id, pos = pos}
        self.touchesCount = self.touchesCount + 1
    end

    if self.touchesCount >= 1  then
        local bTouches = true
        for _, touch in pairs(self.touchesPos) do 
            if not _touInSide(touch.pos) then
                bTouches = false
                break
            end 
        end
        if bTouches then
            self:execBindCall("onTouches", {touch = self.touchesPos, event = event, type = "began"})
            return true
        end
    end
    return false
end

function prototype:onTouchesMoved(touches, event)
    for _ ,touch in ipairs(touches) do 
        local id = touch:getId()
        local pos = touch:getLocation()
        self.touchesPos[id + 1] = {id = id, pos = pos}
    end

    if #touches < 2 then
        return
    end
    return self:execBindCall("onTouches", {touch = self.touchesPos, event = event, type = "moved"})
end

function prototype:onTouchesEnded(touches, event)
    for _ ,touch in ipairs(touches) do 
        local id = touch:getId()
        local pos = touch:getLocation()
        self.touchesPos[id + 1] = nil
        self.touchesCount = self.touchesCount - 1

        self:execBindCall("onTouches", {touch = {{id = id, pos = pos}}, event = event, type = "ended"})
    end
end

function prototype:onTouchesCancelled(touches, event)
    self:execBindCall("onTouches", {touch = self.touchesPos, event = event, type = "cancelled"})
end

--缩放范围  bounce为拖动时新增的范围  手放开后 会回到正常范围内
function prototype:setScaleInfo(scaleMin, scaleMax, scaleBounce)
    self.scaleMin = scaleMin or self.scaleMin
    self.scaleMax = scaleMax or self.scaleMax
    self.scaleBounce = scaleBounce or self.scaleBounce
end


