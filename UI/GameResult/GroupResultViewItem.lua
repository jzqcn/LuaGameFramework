module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	
end

function prototype:refresh(data)
	self.txtName:setString(Assist.String:getLimitStrByLen(data.nickName))	
	self.txtID:setString(data.playerId)

	if data.resultCoin >= 0 then
		if data.currencyType == Common_pb.Score then
			self.fntWinValue:setString(data.resultCoin)
		else
			self.fntWinValue:setString(Assist.NumberFormat:amount2TrillionText(data.resultCoin))
		end

		self.fntLoseValue:setVisible(false)

		self.txtName:setTextColor(cc.c3b(255, 255, 255))
		self.txtID:setTextColor(cc.c3b(255, 255, 255))
	else
		if data.currencyType == Common_pb.Score then
			self.fntLoseValue:setString(data.resultCoin)
		else
			self.fntLoseValue:setString(Assist.NumberFormat:amount2TrillionText(data.resultCoin))
		end

		self.fntWinValue:setVisible(false)

		self.txtName:setTextColor(cc.c3b(255, 223, 146))
		self.txtID:setTextColor(cc.c3b(255, 223, 146))
	end

	-- if StageMgr:isStage("Game") then
	-- 	local stage = StageMgr:getStage()
	-- 	local gameName = stage:getGameName()
	-- 	local playerInfo = Model:get("Games/"..gameName):getMemberInfoById(data.playerId)
	-- 	if playerInfo then
	-- 		if util:getPlatform() == "win32" then
	-- 			sdk.account:getHeadImage(data.playerId, data.nickName, self.headIcon)
	-- 		else
	-- 			sdk.account:getHeadImage(data.playerId, data.nickName, self.headIcon, playerInfo.headimage)
	-- 		end
	-- 	end
	-- end

	-- sdk.account:getHeadImage(data.playerId, data.nickName, self.headIcon, data.headImage)
	if self:existEvent('LOAD_HEAD_IMG') then
		self:cancelEvent('LOAD_HEAD_IMG')
	end
	sdk.account:loadHeadImage(data.playerId, data.nickName, data.headImage, 
		self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.headIcon)
	

	if data.isOwner then
		self.imgOwner:setVisible(true)
	else
		self.imgOwner:setVisible(false)
	end

	self.imgWinner:setVisible(data.isBigWiner)
end

function prototype:onLoadHeadImage(filename)
	self.headIcon:loadTexture(filename)
end

