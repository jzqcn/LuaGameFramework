module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter(data)
	
end

function prototype:setSide(side)
	local size = self.rootNode:getContentSize()
	if side == 1 then
		--left
		self.fntLose:setPositionX(size.width + 15)
		self.fntWin:setPositionX(size.width + 15)
	else
		--right
		self.fntLose:setAnchorPoint(cc.p(1, 0.5))
		self.fntWin:setAnchorPoint(cc.p(1, 0.5))
		self.fntLose:setPositionX(-15)
		self.fntWin:setPositionX(-15)
	end
end

function prototype:setPlayerInfo(result, isSettlement)
	if result == nil then
		self.rootNode:setVisible(false)
		return
	end

	isSettlement = isSettlement or false

	self.fntLose:setVisible(false)
	self.fntWin:setVisible(false)
	self.imgBomb:setVisible(false)

	self.txtName:setString(Assist.String:getLimitStrByLen(result.member.playerName))

	local isBomb = result.isBomb --是否中雷
	self.imgBombBg:setVisible(isBomb)
	self.imgBomb:setVisible(isBomb)
	self.imgNor:setVisible(not isBomb)

	if isSettlement then
		self.txtGoldValue:setString(Assist.NumberFormat:amount2TrillionText(result.winCoin))
		self.txtGoldValue:setVisible(true)

		if isBomb then
			self.fntLose:setString(Assist.NumberFormat:amount2TrillionText(result.resultCoin))
			self.fntLose:setVisible(true)
		else
			self.fntWin:setString("+" .. Assist.NumberFormat:amount2TrillionText(result.resultCoin))
			self.fntWin:setVisible(true)
		end
	else
		self.txtGoldValue:setVisible(false)
	end

	self.rootNode:setVisible(true)

	sdk.account:loadHeadImage(result.member.playerId, result.member.playerName, result.member.headimage, 
		self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.imgHeadIcon)
end

function prototype:onLoadHeadImage(filename)
	self.imgHeadIcon:loadTexture(filename)
end

