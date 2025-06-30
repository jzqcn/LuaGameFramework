module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter()
	local size = self.imgContent:getContentSize()
	self.scrollview:setInnerContainerSize(cc.size(size.width + 10, size.height + 30))

	self.imgContent:setPosition(cc.p(10, size.height + 10))
	self.imgContent:setAnchorPoint(cc.p(0, 1))
end

function prototype:onBtnCloseClick()
	self:close()
end

