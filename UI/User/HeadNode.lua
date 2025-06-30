module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	
end

function prototype:setHeadMsg(userId, nickName, headImage)
	self.txtName:setString(Assist.String:getLimitStrByLen(nickName, 4))

	-- sdk.account:getHeadImage(userId, nickName, self.headIcon, headImage)
	if self:existEvent('LOAD_HEAD_IMG') then
		self:cancelEvent('LOAD_HEAD_IMG')
	end
	sdk.account:loadHeadImage(userId, nickName, headImage, self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.headIcon)

	self.rootNode:setVisible(true)
end

function prototype:onLoadHeadImage(filename)
	self.headIcon:loadTexture(filename)
end
