module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	
end

function prototype:onBtnCloseTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then 
		self:close()
	end
end

