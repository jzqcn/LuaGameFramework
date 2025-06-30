module (..., package.seeall)

prototype = Controller.prototype:subclass()

local COLOR_WHITE = cc.c3b(0xff,0xff,0xff)
local COLOR_GRAY = cc.c3b(0x99,0x8e,0x8e)

function prototype:enter()
	self:bindUIEvent("Game.Calc", "uiEvtCalc")

	self.pokerCards = {}
	self.selectedCards = {}
	self.nodeCalc:setVisible(false)
	self.nodeCalc:setLocalZOrder(9999)

	self.userId = Model:get("Account"):getUserId()
	self.cardType = 0
	self.touchEnabled = false
end

function prototype:clearCards(id)
	if id ~= nil then
		local cards = self.pokerCards[id]
		if cards then
			for i, card in ipairs(cards) do
				card:removeFromParent(true)
			end
		end

		self.pokerCards[id] = nil
	else
		for k, v in pairs(self.pokerCards) do
			for i, card in ipairs(v) do
				card:removeFromParent(true)
			end
		end

		self.pokerCards = {}
		self.selectedCards = {}

		self:hideCalcView()
	end

	self.touchEnabled = false
	self.cardType = 0
end

function prototype:removeCard(cardNode)
	cardNode:removeFromParent(true)
end

function prototype:showCalcView()
	self.nodeCalc:show()
	self.touchEnabled = true
	self.cardType = self:checkExistNiu()
end

function prototype:hideCalcView()
	self.nodeCalc:setVisible(false)
	self.touchEnabled = false
	self.cardType = 0
end

function prototype:createPokerCard(id, index)
	if self.pokerCards[id] == nil then
		self.pokerCards[id] = {}
	end

	local playerCards = self.pokerCards[id]
	local cardNode = playerCards[index]
	if cardNode == nil then
		cardNode = self:getLoader():loadAsLayer("Games/Common/GamePokerCard")
		self.rootNode:addChild(cardNode, index)
		table.insert(self.pokerCards[id], cardNode)

		cardNode:setCardIndex(index)

		if id == self.userId then
			cardNode:addCardTouchEvent(bind(self.onTouch, self))
		end
	end

	return cardNode
end

--扑克牌点击事件
function prototype:onTouch(cardNode, sender, event)
	if self.touchEnabled == false then
		return
	end

	if event == ccui.TouchEventType.began then
		-- local pos = sender:getTouchBeganPosition()
		self:onTouchBegan(cardNode)

	elseif event == ccui.TouchEventType.moved then
		-- local pos = sender:getTouchMovePosition()
		self:onTouchMove(cardNode)

	elseif event == ccui.TouchEventType.ended then
		-- local pos = sender:getTouchEndPosition()
		self:onTouchEnd(cardNode)

	elseif event == ccui.TouchEventType.canceled then
		self:onTouchCancel(cardNode)
	end
end

function prototype:onTouchBegan(sender)
	-- log("[PokerCardView:onTouch began] sender : value = "..sender:getCardSize()..", color = "..sender:getCardColor())
	-- log("[PokerCardView:onTouch began] pos : x == "..pos.x..", y == "..pos.y)
	sender:setCardColor(COLOR_GRAY)

	sys.sound:playEffect("CLICK_CARD")
end

function prototype:onTouchMove(sender)

end

function prototype:onTouchEnd(sender)
	-- log("[PokerCardView:onTouch end] sender : value = "..sender:getCardSize()..", color = "..sender:getCardColor())
	-- log("[PokerCardView:onTouch end] pos : x == "..pos.x..", y == "..pos.y)
	sender:setCardColor(COLOR_WHITE)

	if sender:getIsSelected() == false then
		if table.nums(self.selectedCards) < 3 then
			sender:setIsSelected(true, cc.p(0, 25))
			self.nodeCalc:setValue(sender:getCardIndex(), sender:getCardSize())

			self.selectedCards[sender:getCardId()] = sender
		end
	else
		sender:setIsSelected(false)
		self.nodeCalc:setValue(sender:getCardIndex(), -1)
		self.selectedCards[sender:getCardId()] = nil
	end
end

function prototype:onTouchCancel(sender)
	-- log("[PokerCardView:onTouch cancel] sender : value = "..sender:getCardSize()..", color = "..sender:getCardColor())
	sender:setCardColor(COLOR_WHITE)
end

function prototype:uiEvtCalc(isNiu)
	-- log(isNiu)
	-- log("uiEvtCalc:: self.cardType == " .. self.cardType)
	
	local resultMsg = {}
	if isNiu == true then
		if self.cardType > 10 then
			--特殊牌型：五小牛、五花牛、炸弹
			resultMsg.isSuccess = true
			resultMsg.preCardInfo, resultMsg.lastCardInfo = self:getCardGroup(false)
		else
			-- log(self.selectedCards)
			if table.nums(self.selectedCards) < 3 then
				resultMsg.isSuccess = false
				resultMsg.msg = "无牛"
			else
				local addValue = self.nodeCalc:getAddValue()
				log("addValue:"..addValue)
				if math.fmod(addValue, 10) == 0 then
					resultMsg.isSuccess = true
					resultMsg.preCardInfo, resultMsg.lastCardInfo = self:getCardGroup(true)
				else
					if self.cardType == 0 then
						resultMsg.isSuccess = false
						resultMsg.msg = "无牛"
					else
						resultMsg.isSuccess = false
						resultMsg.msg = "有牛"
					end
				end
			end
		end
	else
		if self.cardType > 10 then
			--特殊牌型：五小牛、五花牛、炸弹
			resultMsg.isSuccess = true
			resultMsg.preCardInfo, resultMsg.lastCardInfo = self:getCardGroup(false)
		elseif self.cardType > 0 then
			resultMsg.isSuccess = false
			resultMsg.msg = "有牛"
		else
			resultMsg.isSuccess = true
			resultMsg.preCardInfo, resultMsg.lastCardInfo = self:getCardGroup(false)
		end
	end

	-- log(resultMsg)

	self:fireUIEvent("Game.CalcResult", resultMsg)
	--操作完成
	if resultMsg.isSuccess then
		self:hideCalcView()
	end
end

function prototype:getCardGroup(isCalc)
	isCalc = isCalc or false
	local preCardInfo = {}
	local lastCardInfo = {}

	local userInfo = Model:get("Games/Niuniu"):getUserInfo()
	local cards = userInfo.memStateInfo.cards
	if isCalc then
		for i, v in ipairs(cards) do
			if self.selectedCards[v.id] then
				preCardInfo[#preCardInfo + 1] = v
			else
				lastCardInfo[#lastCardInfo + 1] = v
			end
		end
	else
		for i, v in ipairs(cards) do
			if i <= 3 then
				preCardInfo[#preCardInfo + 1] = v
			else
				lastCardInfo[#lastCardInfo + 1] = v
			end
		end
	end

	return preCardInfo, lastCardInfo
end

function prototype:checkExistNiu()
	local userInfo = Model:get("Games/Niuniu"):getUserInfo()
	-- log(userInfo.memStateInfo.cards)
	
	local cardType = Logic:get("NiuniuLogic"):getTypeByCards(table.clone(userInfo.memStateInfo.cards))
	-- log("[PokerCardView::checkExistNiu] type niu ======== "..cardType)
	return cardType
end