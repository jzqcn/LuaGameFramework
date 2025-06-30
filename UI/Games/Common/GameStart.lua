module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()
end

function prototype:onBtnStartTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Start")
	end
end