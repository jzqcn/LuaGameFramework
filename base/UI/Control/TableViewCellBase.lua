local Layout = require "UI.Control.Layout"

module(..., package.seeall)

prototype = Layout.prototype:subclass()

function prototype:initialize(...)
    super.initialize(self, ...)

    self.rootNode:setEnabled(true)
    self.rootNode:ignoreContentAdaptWithSize(false)
end

function prototype:enter()

end


