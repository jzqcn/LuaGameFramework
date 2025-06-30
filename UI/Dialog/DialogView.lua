local Define = require "UI.Mgr.Define"

module (..., package.seeall)


prototype = Window.prototype:subclass()

function prototype:onBtnBgOutside()
	self:close()
end

-- function prototype:addBgMask()

-- end

function prototype:hasBgMask()
    return false
end

function prototype:initialize(...)
    super.initialize(self, ...)

    self.windowTouchType = Define.WINDOW_TOUCH_TYPE.NO_SWALLOW
end

function prototype:enter(data)
	self.txtContent:setString(data.content or "")

    local time = data.time or 2
    if time > 0 then
        local delayAction = cc.DelayTime:create(time)
        local callFunc = cc.CallFunc:create(function() 
                                self:runCloseAction()
                            end)

        local seq = cc.Sequence:create(delayAction, callFunc)
        self.rootNode:runAction(seq)
    end

    self:runOpenAction()

    sys.sound:playEffect("NOTICE")
end

function prototype:runOpenAction()
    self.imgBg:setScale(0.2)
    self.imgBg:setOpacity(5)
    
    local arrAction = {}
    table.insert(arrAction, cc.Spawn:create(cc.EaseSineOut:create(CCScaleTo:create(0.2, 1)), 
                                           cc.FadeTo:create(0.21, 255)))
    -- table.insert(arrAction, CCCallFunc:create(function ()
    --                                         self:callback()                                     
    --                                     end))

    self.imgBg:runAction(CCSequence:create(arrAction))
end

function prototype:runCloseAction()
    local arrAction = {}
    
    table.insert(arrAction, CCSpawn:create(CCScaleTo:create(0.1, 0.5), 
                                           CCFadeTo:create(0.22, 0)))
    table.insert(arrAction, CCCallFunc:create(function ()
                                self:close()
                            end))
    self.imgBg:runAction(CCSequence:create(arrAction))
end

-- function prototype:addToParent(parentNode, zOrder)
-- 	log4ui:i("[=UI:Controller:addToParent") 
-- 	parentNode:addChild(self.rootNode, zOrder)
-- 	Assist:centerNode(self.rootNode, parentNode)
-- end