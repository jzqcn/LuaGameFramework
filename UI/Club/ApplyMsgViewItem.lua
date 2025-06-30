module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	
end

function prototype:refresh(data, index)
	-- log(data)
	self.data = data

	self.txtName:setString(Assist.String:getLimitStrByLen(data.userName))
	self.txtId:setString(data.userId)

	if util:getPlatform() == "win32" then
		sdk.account:getHeadImage(data.userId, data.userName, self.imgHead)
	else
		-- sdk.account:getHeadImage(data.userId, data.userName, self.imgHead, data.headImage)
		-- if self:existEvent('LOAD_HEAD_IMG') then
		-- 	self:cancelEvent('LOAD_HEAD_IMG')
		-- end
		sdk.account:loadHeadImage(data.userId, data.userName, data.headImage, 
			self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.imgHead)
	end

	self.txtClubName:setString(data.clubName)

	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.rootNode:setVisible(false)
	
	local action = self:createListItemBezierConfig(self.rootNode, actionOver, 0.5, 0.15+0.1*index)
	self.action = action
end

function prototype:onLoadHeadImage(filename)
	self.imgHead:loadTexture(filename)
end

function prototype:onBtnAgreeClick()
	self:fireUIEvent("Club.ClubHandleApply", self.data.clubId, self.data.userId, true)
	-- Model:get("Club"):requestHandleApply(self.data.clubId, self.data.userId, true)
end

function prototype:onBtnRefuseClick()
	-- Model:get("Club"):requestHandleApply(self.data.clubId, self.data.userId, false)
	self:fireUIEvent("Club.ClubHandleApply", self.data.clubId, self.data.userId, false)
end
