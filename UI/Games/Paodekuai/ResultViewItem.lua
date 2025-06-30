module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()
	
end

function prototype:refresh(info, index)
	-- log(info)
	
	local resultCoin = info.memStateInfo.resultCoin or 0

	self.txtName:setString(Assist.String:getLimitStrByLen(info.playerName))
	-- if util:getPlatform() == "win32" then
	-- 	sdk.account:getHeadImage(info.playerId, info.playerName, self.headIcon)
	-- else
		sdk.account:getHeadImage(info.playerId, info.playerName, self.headIcon, info.headimage)
	-- end

	self.txtId:setString(info.playerId)
	-- self.txtLeftNum:setString(tostring(#(info.memStateInfo.cards)))

	local currencyType = Model:get("Games/Paodekuai"):getCurrencyType()
	if currencyType == Common_pb.Score then
		self.txtResultValue:setString(tostring(resultCoin))
	else
		self.txtResultValue:setString(Assist.NumberFormat:amount2TrillionText(resultCoin))
	end

	-- self.txtBaseScore
	if not Model:get("Games/Paodekuai"):getIsPlayBack() then
		self.txtBombNum:setString(tostring(info.memStateInfo.boomNum))
	else
		self.txtBombNum:setVisible(false)
	end

	if info.memStateInfo.isStarter then
		self.imgOwner:setVisible(true)
	else
		self.imgOwner:setVisible(false)
	end

	if resultCoin >= 0 then
		self.txtName:setTextColor(cc.c3b(255, 226, 129))
		self.txtId:setTextColor(cc.c3b(255, 226, 129))
		self.txtBombNum:setTextColor(cc.c3b(255, 226, 129))
		self.txtResultValue:setTextColor(cc.c3b(255, 226, 129))
		-- self.txtBaseScore:setTextColor(cc.c3b(255, 226, 129))
		-- self.txtLeftNum:setTextColor(cc.c3b(255, 226, 129))
		
	else
		self.txtName:setTextColor(cc.c3b(217,217,217))
		self.txtId:setTextColor(cc.c3b(217,217,217))
		self.txtBombNum:setTextColor(cc.c3b(217,217,217))
		self.txtResultValue:setTextColor(cc.c3b(217,217,217))
		-- self.txtBaseScore:setTextColor(cc.c3b(124, 247, 255))
		-- self.txtLeftNum:setTextColor(cc.c3b(124, 247, 255))
	end

	local cards = info.memStateInfo.cards
	if #cards > 0 then
		local name = ""
		local x, y = self.nodeCard_1:getPosition()
		for i, v in ipairs(cards) do
			name = "nodeCard_"..i
			if self[name] == nil then
				self[name] = self:getLoader():loadAsLayer("Games/Common/GamePokerCard")
				-- self[name]:setAnchorPoint(cc.p(0.5, 0.5))
				self.rootNode:addChild(self[name])
			end

			self[name]:setCardInfo(info.playerId, v)
			self[name]:showCardValue()
			self[name]:setScale(0.4)
			self[name]:setPosition(x + (i-1)*30, y)
		end

		local roomInfo = Model:get("Games/Paodekuai"):getRoomInfo()
		if #cards == roomInfo.handCardCount then
			self.imgChuntian:setVisible(true)
			self.imgChuntian:setLocalZOrder(99)
		else
			self.imgChuntian:setVisible(false)
		end
	else
		self.nodeCard_1:setVisible(false)
		self.imgChuntian:setVisible(false)
	end

	self:playAction(index)
end

function prototype:playAction(index)
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	-- self.rootNode:setVisible(false)

	local action = self:createListItemBezierConfig(self.rootNode, actionOver, 0.5, 0.15+0.1*index)
	self.action = action
end

