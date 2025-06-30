module("Assist.Touch", package.seeall)


function registWidgetTouch(_, widget, callback)
    widget:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began  then
            local pos = sender:getTouchBeganPosition()
            return callback("began", pos)

        elseif  eventType == ccui.TouchEventType.moved then
            local pos = sender:getTouchMovePosition()
            return callback("move", pos)

        elseif eventType == ccui.TouchEventType.ended then
            local pos = sender:getTouchEndPosition()
            return callback("end", pos)

        elseif eventType == ccui.TouchEventType.canceled then 
            return callback("cancel")
        end
    end)
end

function registLayerTouch(_, layer, callback)
    local function onTouch(types, touch, event)
        local pos = touch:getLocation()
        return callback(types, pos, event)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(bind(onTouch, "began"), cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(bind(onTouch, "move"), cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(bind(onTouch, "end"), cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(bind(onTouch, "cancel"), cc.Handler.EVENT_TOUCH_CANCELLED )

    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end




