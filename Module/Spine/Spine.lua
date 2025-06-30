local Define = require "Spine.Define"

module (..., package.seeall)

local DEBUG_MODE = false 

class = objectlua.Object:subclass()


function create(_, name, parentNode, callback)
    local skeleton = class:new(name, callback)
    if parentNode then
        parentNode:addChild(skeleton:getViewNode())
    end
    return skeleton
end


function class:initialize(name, callback)
    super.initialize(self)

    self.callback = callback
    self.rootNode = cc.Node:create()
    self.rootNode:setCascadeOpacityEnabled(true)
    self.rootNode:setContentSize(cc.size(50, 50))
    --添加标识线，方便测试
    local subCross = cc.Sprite:create("resource/csbimages/Common/cross.png")
    self.rootNode:addChild(subCross)
    
    self.dir = "right"
    self.actionName = "idle"

    self:createSpine(name)
    self:setCallBack()
end

function class:dispose()
    super.dispose(self)
end

function class:getViewNode()
    return self.rootNode
end

function class:getSpine()
    return self.spine
end


function class:setCallBack()
    self.spine:registerSpineEventHandler(function (event)
        self.actionName = event.animation

        self:actionCallback("start", event)
        -- print(string.format("[spine] %d start: %s", 
        --                       event.trackIndex,
        --                       event.animation))
    end, sp.EventType.ANIMATION_START)

    self.spine:registerSpineEventHandler(function (event)
        self:actionCallback("end", event)
        -- print(string.format("[spine] %d end:", 
        --                         event.trackIndex))
    end, sp.EventType.ANIMATION_END)
    
    self.spine:registerSpineEventHandler(function (event)
        self:actionCallback("complete", event)
        -- print(string.format("[spine] %d complete: %d", 
        --                       event.trackIndex, 
        --                       event.loopCount))
    end, sp.EventType.ANIMATION_COMPLETE)

    self.spine:registerSpineEventHandler(function (event)
        self:actionCallback("event", event)
        -- print(string.format("[spine] %d event: %s, %d, %f, %s", 
        --                       event.trackIndex,
        --                       event.eventData.name,
        --                       event.eventData.intValue,
        --                       event.eventData.floatValue,
        --                       event.eventData.stringValue)) 
    end, sp.EventType.ANIMATION_EVENT)
end

function class:actionCallback(...)
    if self.callback then
        self.callback(...)
    end
end

function class:setDir(dir)
    if self.dir == dir then
        return
    end
    
    self.dir = dir
    if self.dir == "left" then
        self.spine:setFlipX(true)
    elseif self.dir == "right" then
        self.spine:setFlipX(false)
    end
end

function class:createSpine(name)
    self.spine = CSpineManager:GetSingleton():getSkeleton(name)
    self.rootNode:addChild(self.spine)
end

function class:delayPlay(index, actionName, loop, delay)
    self.spine:addPlay(index or 0, actionName, loop == nil and false or loop, delay or 0)
end

function class:play(index, actionName, loop)
    self.spine:play(index or 0, actionName, loop == nil and false or loop)
end

function class:setCurveInfo(curvelist)
    self.spine:clearCurveInfo()
    for name, info in pairs(curvelist) do
        if name == "loopCurve" then
            self.spine:setCurveBaseAttr(Define.SpineCurveType.CURVE_LOOP, info.lineType, info.tension)
            if info.pArr then
                for _, p in ipairs(info.pArr) do
                    self.spine:addCurvePoint(Define.SpineCurveType.CURVE_LOOP, cc.p(p.x, p.y))
                end
            end
        elseif  name == "scaleCurve" then
            self.spine:setCurveBaseAttr(Define.SpineCurveType.CURVE_SCALE, info.lineType, info.tension)
            if info.pArr then
                for _, p in ipairs(info.pArr) do
                    self.spine:addCurvePoint(Define.SpineCurveType.CURVE_SCALE, cc.p(p.x, p.y))
                end
            end
        elseif  name == "speedCurve" then
            self.spine:setCurveBaseAttr(Define.SpineCurveType.CURVE_SPEED, info.lineType, info.tension)
            if info.pArr then
                for _, p in ipairs(info.pArr) do
                    self.spine:addCurvePoint(Define.SpineCurveType.CURVE_SPEED, cc.p(p.x, p.y))
                end
            end
        end
    end
end

function class:stand()
    self:play(Define.SpineActionIndex.AA_IDLE, "idle",true)
end

function class:run()
    self:play(Define.SpineActionIndex.AA_MOVE, "move", true)
end

function class:setSkin(skinName)
    self.spine:setSkin(skinName)
end

function class:setScale(scale)
    self.spine:setDefaultScale(scale)
    self.spine:setScale(scale)
end

function class:getBindPos(bindPoint)
    local pos = self.spine:getOffsetByBandingName(bindPoint)
    return pos
end

--------------node----------------------
function class:removeFromParent(flag)
    self.rootNode:removeFromParent(flag)
end

function class:runAction(action)
    self.rootNode:runAction(action)
end

function class:stopAction(action)
    self.rootNode:stopAction(action)
end

function class:stopAllActions()
    self.rootNode:stopAllActions()
end

function class:setPosition(pos)
    self.rootNode:setPosition(pos)
end

function class:setNormalizedPosition(pos)
    self.rootNode:setNormalizedPosition(pos)
end

function class:getPosition()
    return self.rootNode:getPosition()
end

function class:setOpacity(value)
    self.rootNode:setOpacity(value)
end

function class:setLocalZOrder(order)
    self.rootNode:setLocalZOrder(order)
end

function class:getLocalZOrder( ... )
    return self.rootNode:getLocalZOrder()
end

function class:setVisible(visible)
    self.rootNode:setVisible(visible)
end

function class:isVisible()
    return self.rootNode:isVisible()
end

function class:getContentSize()
    local rect = self.spine:getBoundingBox()
    return cc.Size(rect.width, rect.heiht)
end

----------------compoent private-----------------

function class:showBlock()
    local node = cc.LayerColor:create(cc.c4b(255, 0, 0, 100))
    node:setContentSize(self.rootNode:getContentSize())
    -- node:setColor(cc.c3b(255, 0, 0))
    -- node:setOpacity(100)
    self.rootNode:addChild(node, 999)
end
--











