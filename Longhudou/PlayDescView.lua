module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter()

end

function prototype:onPanelCloseClick()
	self:close()
end

