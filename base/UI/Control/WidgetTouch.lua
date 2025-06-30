local Widget = require "UI.Control.Widget"

module(..., package.seeall)



prototype = Widget.prototype:subclass()


function prototype:enter()
    Assist.Touch:registWidgetTouch(self.rootNode, function (...) 
                        self:execBindCall("onTouch", ...) 
                    end)
end




