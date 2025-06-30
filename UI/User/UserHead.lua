module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_CHANGE_NICK_NAME", "onPushModifyNickName")
	self:bindModelEvent("User.EVT.PUSH_CHANGE_HEAD_IMG", "onPushChangeHeadImg")

	local accountInfo = Model:get("Account"):getUserInfo()
	if accountInfo then
		self.txtName:setString(Assist.String:getLimitStrByLen(accountInfo.nickName))
		self.txtId:setString("ID:"..accountInfo.userId)
		if Model:get("Account"):isAccountLogin() then
			local headImageIndex = tonumber(accountInfo.headImage) or 1
			self.headIcon:loadTexture(string.format("resource/csbimages/User/headImages/touxiang_%d.png", headImageIndex))
		else
			-- sdk.account:getHeadImage(accountInfo.userId, accountInfo.nickName, self.headIcon, accountInfo.headImage)
			sdk.account:loadHeadImage(accountInfo.userId, accountInfo.nickName, accountInfo.headImage, 
				self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.headIcon)
		end
	end
end

function prototype:onLoadHeadImage(filename)
	self.headIcon:loadTexture(filename)
end

function prototype:onPushModifyNickName()
	local accountInfo = Model:get("Account"):getUserInfo()
	if accountInfo.newNickName then
		self.txtName:setString(Assist.String:getLimitStrByLen(accountInfo.newNickName))
	else
		self.txtName:setString(Assist.String:getLimitStrByLen(accountInfo.nickName))
	end
end

function prototype:onPushChangeHeadImg()
	local accountInfo = Model:get("Account"):getUserInfo()
	self.headIcon:loadTexture(string.format("resource/csbimages/User/headImages/touxiang_%d.png", accountInfo.headImageIndex))
end

function prototype:onBtnHeadClick()
	ui.mgr:open("User/UserMsgView")
end
