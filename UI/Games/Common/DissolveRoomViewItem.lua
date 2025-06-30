module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	
end

function prototype:refresh(data)
	self.txtName:setString(Assist.String:getLimitStrByLen(data.name, 8))

	-- if util:getPlatform() == "win32" then
	-- 	sdk.account:getHeadImage(data.id, data.name, self.headIcon)
	-- else
		sdk.account:getHeadImage(data.id, data.name, self.headIcon, data.headImage)
	-- end

	if data.isAgree == 1 then
		self.txtState:setString("同意")
		self.txtState:setTextColor(cc.c3b(156, 235, 100))
	elseif data.isAgree == 0 then
		self.txtState:setString("等待中")
		self.txtState:setTextColor(cc.c3b(30, 144, 255))
	else
		self.txtState:setString("拒绝")
		self.txtState:setTextColor(cc.c3b(255, 255, 255))
	end
end

function prototype:setState(isAgree)
	if isAgree then
		self.txtState:setString("同意")
	else
		self.txtState:setString("拒绝")
	end
end