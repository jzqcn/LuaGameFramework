local Base = require "UI.Control.Base"

module(..., package.seeall)

prototype = Base.prototype:subclass()

function prototype:enter()
	self.rootNode:addEventListener(function () end)   --needed
end


