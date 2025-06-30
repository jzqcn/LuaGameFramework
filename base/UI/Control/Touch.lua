local Base = require "UI.Control.Base"

module(..., package.seeall)

prototype = Base.prototype:subclass()


function prototype:enter( ... )
    local layer = cc.Layer:create()
    self.rootNode:addChild(layer)

    Assist.Touch:registLayerTouch(layer, bind(self.onTouch, self))
end

function prototype:onTouch(types, pos)
    if self.rootNode:isVisible() and self.rootNode:isEnabled() then
        local rect = self.rootNode:getContentSize()
        rect.x = 0
        rect.y = 0
        local localPos = self.rootNode:converToNodeSpace(pos)
        if cc.rectContainsPoint(rect, localPos) then
            self:execBindCall("onTouch", types, pos)
            return true
        end
    end

    return false
end




