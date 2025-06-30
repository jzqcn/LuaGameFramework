module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:setString(text)
	self.txtChat:setString(text)
	local size = self.txtChat:getContentSize()
	local bgSize = self.imgBg:getContentSize()
	self.imgBg:setContentSize(cc.size(size.width + 20, bgSize.height))
	self.rootNode:setContentSize(cc.size(size.width + 20, bgSize.height))
end
