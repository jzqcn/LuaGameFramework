module (..., package.seeall)


prototype = Controller.prototype:subclass()

function prototype:isFullWinodwMode()
	return true
end

function prototype:enter()
	local layer = ui.loader:loadAsLayer("Hall/HallView")
	self.rootNode:addChild(layer)
end