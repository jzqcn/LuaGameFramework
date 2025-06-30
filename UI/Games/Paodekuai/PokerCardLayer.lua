module (..., package.seeall)

prototype = Controller.prototype:subclass()

local MAX = math.max
local MIN = math.min
local ABS = math.abs
local COLOR_WHITE = cc.c3b(0xff,0xff,0xff)
local COLOR_GRAY = cc.c3b(0x99,0x8e,0x8e)

local PaoDeKuai_pb = PaoDeKuai_pb

function prototype:enter()
	--UI事件
	self:bindUIEvent("Game.DiscardTip", "uiEvtDiscardTip")
	self:bindUIEvent("Game.DiscardOut", "uiEvtDiscardOut")
	self:bindUIEvent("Game.DiscardReset", "uiEvtDiscardReset")

	self.pokerData = {}
	self.discardData = {}
	self.nodeDiscard:setVisible(false)

	self.userId = Model:get("Account"):getUserId()
	self.touchEnabled = false
	-- self.isDealingCards = false

	-- local winSize = cc.Director:getInstance():getWinSize()
	local eglView = cc.Director:getInstance():getOpenGLView()
	local frameSize = eglView:getFrameSize()
	local scale = frameSize.width / frameSize.height
	-- log(frameSize)
	-- log("scale : "..scale)

	-- self.frameSize = frameSize
	self.screenScale = scale
	self.winSize = self.rootNode:getContentSize()

	self.roundData = {}
	self.selectedCards = {}
	-- self.userCardData = {}
	self.outDiscards = {}
	self.tipDiscardIndex = 1

	self.isDiscarder = false
	self.isFirst = false
	self.discardType = -1
end

--清除扑克
function prototype:clearPokerCards(playerId)
	if not playerId then
		for k, v in pairs(self.pokerData) do
			for _, data in ipairs(v) do
				data:removeFromParent(true)
			end
		end

		self.pokerData = {}
		return
	end

	local cardData = self.pokerData[playerId]
	if cardData then
		for _, v in ipairs(cardData) do
			v:removeFromParent(true)
		end
		self.pokerData[playerId] = {}
	end
end

function prototype:clearSelectedCards()
	local cardData = self.pokerData[self.userId]
	if cardData then
		for _, v in ipairs(cardData) do
			v:setIsSelected(false)
		end
		self.selectedCards = {}
	end
end

function prototype:deleteCardByIdx(playerId, index)
	local cardData = self.pokerData[playerId]
	if cardData then
        if index ~= -1 then
        	local item = cardData[index]
	        table.remove(cardData, index)

	        item:removeFromParent(true)
	    end
	end
end

function prototype:clearPlayerDiscards(playerId)
	if playerId ~= nil then
		local discards = self.discardData[playerId]
		if discards and #discards > 0 then
			for i, v in ipairs(discards) do
				v:removeFromParent(true)
			end
		end

		self.discardData[playerId] = {}
		return
	end

	for k, v in pairs(self.discardData) do
		if v then
			for _, card in ipairs(v) do 
				card:removeFromParent(true)
			end
		end
	end

	self.discardData = {}
end

--创建扑克
function prototype:createPokerCard(playerId, index)
	if self.pokerData[playerId] == nil then
		self.pokerData[playerId] = {}
	end

	local playerCards = self.pokerData[playerId]
	local cardNode = playerCards[index]
	if cardNode == nil then
		cardNode = self:getLoader():loadAsLayer("Games/Common/GamePokerCard")
		cardNode:setAnchorPoint(cc.p(0.5, 0.5))

		self.rootNode:addChild(cardNode, index)
		table.insert(self.pokerData[playerId], cardNode)

		cardNode:setCardIndex(index)

		if playerId == self.userId then
			cardNode:addCardTouchEvent(bind(self.onTouch, self))
		end
	end

	return cardNode
end

local function sortFunc(a, b)
	if a.value == b.value then
		return a.color > b.color
	else
		return a.value > b.value
	end
end

function prototype:sortDealCards(cards)	 
	table.sort(cards, sortFunc)

	local cardNum = #cards
	for i, v in ipairs(cards) do
		v:setCardIndex(i)
		v:setLocalZOrder(i)
		v:setIsSelected(false)
		v:setEnabled(true)
		v:setScale(1.0)
		
		local pos = self:getDealCardPos(1, i, cardNum, v:getContentSize())
		v:setPosition(pos)
	end

	self.touchEnabled = true
end

--处理发牌(玩家ID， 是否播放动画)
function prototype:dealPokerCards(playerId, isAnimation)
	local modelData = Model:get("Games/Paodekuai")
	local roomMember = modelData:getRoomMember()
	local playerInfo = roomMember[playerId]
	local isPlayBack = modelData:getIsPlayBack()
	if playerInfo == nil then
		log4ui:warn("[PokerCardLayer::dealPokerCards] error : get player info failed ! playerId : "..playerId)
		return
	end

	local seatIndex = modelData:getPlayerSeatIndex(playerId)
	local centerPos = cc.p(self.winSize.width/2, self.winSize.height/2)

	local memStateInfo = playerInfo.memStateInfo
	local cards = memStateInfo.cards
	local cardNum = #cards
	if isPlayBack == true or (isAnimation == false and playerId == self.userId) then
		table.sort(cards, sortFunc)
	end

	local function dealActionFunc(cardIndex)
		if cardIndex == cardNum then
			util.timer:after(500, function()
				self:sortDealCards(self.pokerData[playerId])	
			end)
		end
	end

	if self.pokerData[playerId] == nil then
		self.pokerData[playerId] = {}
	end

	local curPokerData = self.pokerData[playerId]
	local itemsSize = #curPokerData
    if itemsSize > cardNum then
        for i=itemsSize, cardNum+1, -1 do
            self:deleteCardByIdx(playerId, i)
        end
    end

    if playerId == self.userId then
		if isAnimation == false then
			self.touchEnabled = true
		else
			sys.sound:playEffect("DEAL_LONG")
		end
	end

	for i, v in ipairs(cards) do
		local cardNode = self:createPokerCard(playerId, i)
		if cardNode then
			local scale = 1
			local to
			if playerId ~= self.userId then
				scale = 0.4
			end

			if isPlayBack then
				to = self:getPlayBackDealCardPos(seatIndex, i, cardNum, cardNode:getContentSize())
			else
				to = self:getDealCardPos(seatIndex, i, cardNum, cardNode:getContentSize())
			end

			cardNode:setCardInfo(playerId, v)
			if playerId == self.userId then
				cardNode:runDealAction2(centerPos, to, scale, (i-1)*0.05, isAnimation, dealActionFunc)
				if isPlayBack then
					--回放不播放发牌动画 isAnimation为false
					cardNode:setEnabled(false)
					cardNode:showCardValue()
				end
			else
				cardNode:setPosition(to)
				cardNode:setScale(scale)
				cardNode:setEnabled(false)
				if isPlayBack then
					cardNode:showCardValue()
				end
			end
		else
			log4ui:warn("[PokerCardLayer::dealPokerCards] error : playerId:"..playerId..", card index:"..i)
		end
	end

	if playerId ~= self.userId then
		self:updateLeftHandCardCount(seatIndex, cardNum)
	else
		self:clearSelectedCards()
	end
end

function prototype:showUserCardValue()	
	local cards = self.pokerData[self.userId]
	for i, v in ipairs(cards) do
		v:showCardValue()
	end
end

--显示剩余牌数
function prototype:updateLeftHandCardCount(seatIndex, num)
	local roomInfo = Model:get("Games/Paodekuai"):getRoomInfo()
	if roomInfo.viewCount == 1 then
		local widget = self["strViewCount_"..seatIndex]
		if widget then
			widget:setString(tostring(num))
		else
			local pos = self:getDealCardPos(seatIndex)
			widget = cc.Label:createWithBMFont("resource/csbimages/BMFont/bankNum.fnt", tostring(num))
			widget:setPosition(pos)
			self.rootNode:addChild(widget, 100)

			self["strViewCount_"..seatIndex] = widget
		end

		if widget then
			if num == 0 then
				widget:setVisible(false)
			else
				widget:setVisible(true)
			end
		end
	end
end

function prototype:removeCard(removeList, cardData)
	if removeList == nil or cardData == nil then
		return false
	end
	
	local iRemoveCount = #removeList
	local iCardCount = #cardData

	local iDeleteCount = 0
	for i = 1, iRemoveCount do
		for j = 1, #cardData do
			if removeList[i] == cardData[j] then
				iDeleteCount = iDeleteCount + 1
				table.remove(cardData, j)
				break
			end
		end
	end

	-- log("iDeleteCount:"..iDeleteCount..", iRemoveCount:"..iRemoveCount)
	if iDeleteCount ~= iRemoveCount then
		return false
	end

	return true
end

--添加出牌数据
function prototype:addDiscardData(playerId, discards, handsDesc, bLastRound)
	if discards == nil then
		return false
	end

	local modelData = Model:get("Games/Paodekuai")
	local seatIndex = modelData:getPlayerSeatIndex(playerId)

	bLastRound = bLastRound or false
	if not bLastRound then
		local cardData = self.pokerData[playerId]
		local iRemoveCount = #discards
		local iCardCount = #cardData
		if iRemoveCount > iCardCount then
			return false
		end

		local isPlayBack = modelData:getIsPlayBack()
		if playerId == self.userId or isPlayBack then
			for i = 1, iRemoveCount do
				for j = 1, #cardData do
					if discards[i].id == cardData[j].id then
						table.remove(cardData, j)
						break
					end
				end
			end

			--更新剩余牌位置
			local pos
			iCardCount = #cardData
			for i, v in ipairs(cardData) do
				if isPlayBack then
					pos = self:getPlayBackDealCardPos(seatIndex, i, iCardCount, v:getContentSize())
				else
					pos = self:getDealCardPos(seatIndex, i, iCardCount, v:getContentSize())
				end
				v:setCardIndex(i)
				v:setPosition(pos)
			end
		else
			for i = 1, iRemoveCount do
				table.remove(cardData, 1)
			end
		end
	end

	self.discardData[playerId] = {}
	local discardData = self.discardData[playerId]
	for i, v in ipairs(discards) do
		discardData[#discardData + 1] = v
	end

	table.sort(discardData, sortFunc)

	if handsDesc==PaoDeKuai_pb.FULLHOUSE or handsDesc==PaoDeKuai_pb.PLANE or handsDesc==PaoDeKuai_pb.ONEHOUSE then
		--先排三张相同的牌（可能有炸弹拆成飞机或者三带二出）
		local PaodekuaiLogic = Logic:get("PaodekuaiLogic")
		local analyseResult = PaodekuaiLogic:analyseCardData(discardData, true)
		self:removeCard(analyseResult.threeCardDatas, discardData)
		for i, v in ipairs(analyseResult.threeCardDatas) do
			if v then
				table.insert(discardData, i, v)
			else
				break
			end
		end

	elseif handsDesc==PaoDeKuai_pb.FOURWITHTHREE then
		local PaodekuaiLogic = Logic:get("PaodekuaiLogic")
		local analyseResult = PaodekuaiLogic:analyseCardData(discardData)

		self:removeCard(analyseResult.fourCardDatas, discardData)

		for i, v in ipairs(analyseResult.fourCardDatas) do
			if v then
				table.insert(discardData, i, v)
			else
				break
			end
		end
	end

	for i, v in ipairs(discardData) do
		local size = v:getContentSize()
		local scale = v:getScale()
		local toPos = self:getDiscardPos(seatIndex, i, #discardData, cc.size(size.width*scale, size.height*scale))
		v:setLocalZOrder(i)
		v:setPosition(toPos)
	end

	if not bLastRound then
		--出牌音效
		sys.sound:playEffect("OUT_CARD")

		log("[PokerCardLayer::addDiscardData] handsDesc ==== "..handsDesc..", seatIndex ==== "..seatIndex)

		local info = modelData:getMemberInfoById(playerId)
		self:playEffectSound(handsDesc, info.sex, discardData[1].size, #discardData)
		self:playEffectAction(handsDesc, seatIndex, #discardData)

		if playerId ~= self.userId then
			local cardData = self.pokerData[playerId]
			self:updateLeftHandCardCount(seatIndex, #cardData)
		end
	end
end

function prototype:showLastRoundDiscards(playerId, discards, handsDesc)
	local cardNum = #discards
	if cardNum > 0 then
		local discardsList = {}
		for i, v in ipairs(discards) do
			local cardNode = self:getLoader():loadAsLayer("Games/Common/GamePokerCard")
			cardNode:setAnchorPoint(cc.p(0.5, 0.5))
			cardNode:setCardInfo(playerId, v)
			cardNode:showCardValue()
			cardNode:setScale(0.6)
			self.rootNode:addChild(cardNode, i)

			discardsList[#discardsList + 1] = cardNode
		end

		self:addDiscardData(playerId, discardsList, handsDesc, true)
	end
end

function prototype:showPlayerDiscards(roundDiscardData)
	local discardsList = roundDiscardData.discardsList
	if #discardsList > 0 then
		local discardInfo = discardsList[#discardsList]
		local playerId = discardInfo.playerId
		local discards = discardInfo.discards
		local cardNum = #discards
		if cardNum > 0 then
			if playerId ~= self.userId then
				local modelData = Model:get("Games/Paodekuai")
				local seatIndex = modelData:getPlayerSeatIndex(playerId)
				--自己的牌通过出牌直接展示
				local otherDiscards = {}
				if modelData:getIsPlayBack() then
					local playerCards = self.pokerData[playerId]
					for i, data in ipairs(discards) do
						for _, cardNode in ipairs(playerCards) do
							if cardNode.id == data.id then
								cardNode:setScale(0.6)
								otherDiscards[#otherDiscards + 1] = cardNode
								break
							end
						end
					end
				else
					for i, v in ipairs(discards) do
						local cardNode = self:createPokerCard(playerId, i)
						if cardNode then
							cardNode:setCardInfo(playerId, v)
							cardNode:showCardValue()
							cardNode:setLocalZOrder(i)
							cardNode:setEnabled(false)
							cardNode:setScale(0.6)

							otherDiscards[#otherDiscards + 1] = cardNode
						end
					end
				end

				self:addDiscardData(playerId, otherDiscards, discardInfo.handsDesc)
			else
				--倒计时到了，服务器自动出牌
				self:hideDiscardOption()
				self:clearSelectedCards()

				local userCards = self.pokerData[playerId]
				self.selectedCards = {}
				for i, data in ipairs(discards) do
					for _, cardNode in ipairs(userCards) do
						if cardNode.id == data.id then
							cardNode:setScale(0.6)
							cardNode:setEnabled(false)
							cardNode:setCardColor(COLOR_WHITE)
							table.insert(self.selectedCards, cardNode)
							break
						end
					end
				end

				if #self.selectedCards > 0 then
					self:addDiscardData(self.userId, self.selectedCards, discardInfo.handsDesc)
				end
				self.selectedCards = {}
			end
		end
	end
end

--显示出牌选项(是否第一个出牌)
function prototype:showDiscardOption(playerId, isFirst)
	isFirst = isFirst or false
	if playerId == self.userId then
		self.isFirst = isFirst		
		
		if isFirst == false then
			local modelData = Model:get("Games/Paodekuai")
			self.roundData = modelData:getDiscardRoundData()
			
			local discardsList = self.roundData.discardsList
			local lastDiscardsInfo = discardsList[#discardsList]
			local discards = lastDiscardsInfo.discards

			self.discardType = lastDiscardsInfo.handsDesc
			--搜出能出的牌型
			local cardData = self.pokerData[self.userId]

			local logicData = {}
			for i, v in ipairs(cardData) do
				logicData[#logicData + 1] = {id = v.id , size = v.size, value = v.value, color = v.color}
			end

			local PaodekuaiLogic = Logic:get("PaodekuaiLogic")
			local outDiscards = PaodekuaiLogic:searchOutCardList(logicData, table.clone(discards), self.roundData.handsDesc)
			self.outDiscards = outDiscards
			self.tipDiscardIndex = 1
			-- log("outDiscards num : " .. #outDiscards)

			self.isDiscarder = true
			self.nodeDiscard:show(isFirst)
			self.nodeDiscard:checkEnabledButton(false, false)

			--自己可能提前把牌选好，判断能否符合出牌条件
			self:analyseSelectedCardData()

			-- if #outDiscards > 0 then
			-- 	self.isDiscarder = true
			-- 	self.nodeDiscard:show(isFirst)
			-- 	self.nodeDiscard:checkEnabledButton(false, false)

			-- 	--自己可能提前把牌选好，判断能否符合出牌条件
			-- 	self:analyseSelectedCardData()
			-- else
			-- 	self:fireUIEvent("Game.ShowNotice", "没有牌大过上家", 3)
			-- end
		else
			self.isDiscarder = true
			self.nodeDiscard:show(isFirst)
			self.nodeDiscard:checkEnabledButton(false, false)

			--自己可能提前把牌选好，判断能否符合出牌条件
			self:analyseSelectedCardData()

			
		end
	end

	if isFirst then
		self:clearPlayerDiscards()
	else
		self:clearPlayerDiscards(playerId)
	end
end

function prototype:hideDiscardOption()
	self.nodeDiscard:setVisible(false)
	self.isDiscarder = false
end

--出牌失败处理
function prototype:doDiscardResult(isSuccess)
	-- log("[PokerCardLayer::doDiscardResult] result state is : "..tostring(isSuccess))
	if isSuccess then
		--在手牌中扣除出牌数据
		local modelData = Model:get("Games/Paodekuai")
		local userInfo = modelData:getUserInfo()
		if userInfo then
			local userCards = userInfo.memStateInfo.cards
			local discards = self.discardData[self.userId]
			if discards and #discards > 0 then
				for _, v in ipairs(discards) do
					for i, card in ipairs(userCards) do
						if v.id == card.id then
							table.remove(userCards, i)
							break
						end
					end
				end

				table.sort(userCards, sortFunc)
			end
		end
	else
		local discards = self.discardData[self.userId]
		local pokerCards = self.pokerData[self.userId]
		if discards and #discards > 0 then
			for i, v in ipairs(discards) do
				pokerCards[#pokerCards + 1] = v				
			end

			self:sortDealCards(pokerCards)
		end

		self.discardData[self.userId] = {}

		--重新出牌
		self:showDiscardOption(self.userId, self.isFirst)
	end
end

--牌局结束 
function prototype:doGameResult(roomMember)
	self.nodeDiscard:setVisible(false)

	--显示玩家剩余牌
	local bSpringEff = false
	for id, v in pairs(roomMember) do
		local seatIndex = Model:get("Games/Paodekuai"):getPlayerSeatIndex(id)
		local leftCards = v.memStateInfo.cards
		if #leftCards > 0 then
			self:clearPlayerDiscards(id)

			self.discardData[id] = {}
			local discardData = self.discardData[id]
			
			for i, card in ipairs(leftCards) do
				local cardNode = self:createPokerCard(id, i)
				if cardNode then
					cardNode:setCardInfo(id, card)
					cardNode:showCardValue()
					cardNode:setLocalZOrder(i)
					cardNode:setEnabled(false)
					cardNode:setScale(0.6)
					cardNode:setCardColor(COLOR_WHITE)

					local size = cardNode:getContentSize()
					local toPos = self:getResultPos(seatIndex, i, #leftCards, cc.size(size.width*0.6, size.height*0.6))
					cardNode:setPosition(toPos)

					discardData[#discardData + 1] = cardNode
				end
			end

			self.pokerData[id] = {}

			local roomInfo = Model:get("Games/Paodekuai"):getRoomInfo()
			if #leftCards == roomInfo.handCardCount then
				--春天
				bSpringEff = true				
			end
		else
			local discards = self.discardData[id]
			if discards and #discards > 0 then
				for i, v in ipairs(discards) do
					v:setScale(0.6)

					local size = v:getContentSize()
					local toPos = self:getResultPos(seatIndex, i, #discards, cc.size(size.width*0.6, size.height*0.6))
					v:setPosition(toPos)
				end
			end
		end

		if id ~= self.userId then
			self:updateLeftHandCardCount(seatIndex, 0)
		end
	end

	if bSpringEff then
		self:playEffectAction(100)
	end	
end

--提示
function prototype:uiEvtDiscardTip()
	self:clearSelectedCards()

	if self.outDiscards and #self.outDiscards > 0 then
		local selectedData = self.outDiscards[self.tipDiscardIndex]
		local cardData = self.pokerData[self.userId]
		for i, v in ipairs(selectedData) do
			for _, card in ipairs(cardData) do
				if v.id == card.id then
					card:setIsSelected(true, cc.p(0, 25))
					table.insert(self.selectedCards, card)
					break
				end
			end
		end

		self.nodeDiscard:checkEnabledButton(true, true)

		self.tipDiscardIndex = self.tipDiscardIndex + 1
		if self.tipDiscardIndex > #self.outDiscards then
			self.tipDiscardIndex = 1
		end

		-- if #self.selectedCards == 4 then
		-- 	--炸弹压非炸弹会改变出牌牌型
		-- 	local selCardData = {}
		-- 	for i, v in ipairs(self.selectedCards) do
		-- 		selCardData[#selCardData + 1] = {id = v.id , size = v.size, value = v.value, color = v.color}
		-- 	end

		-- 	local cardType = Logic:get("PaodekuaiLogic"):getCardType(selCardData)
		-- 	self.discardType = cardType
		-- end
	end
end

--出牌
function prototype:uiEvtDiscardOut()
	local selectedNum = #self.selectedCards
	if self.discardType >= PaoDeKuai_pb.SINGLE and selectedNum > 0 then
		local modelData = Model:get("Games/Paodekuai")
		--房卡场，第一局第一个人首次出牌，必须带黑桃3
		if modelData:getRoomStyle() == Common_pb.RsCard and modelData.roomInfo.currentGroup==1 and self.isFirst then
			local userCards = self.pokerData[self.userId]
			if #userCards == modelData.roomInfo.handCardCount then
				--还没有出牌
				local bWithSpade3 = false
				for i, v in ipairs(self.selectedCards) do
					if v.color == CardKind_pb.Spade and v.value == 3 then
						bWithSpade3 = true
						break
					end
				end

				if bWithSpade3 == false then
					local data = {
						content = "第一局首次出牌，牌型中必须包含黑桃3！"
					}
					ui.mgr:open("Dialog/DialogView", data)
					return
				end
			end
		end

		if self.discardType == PaoDeKuai_pb.SINGLE and modelData:getIsSingle(2) then
			--单张判断下家是否报单。报单时，有非单张牌型或者2先出，出单牌必须出最大
			local userCards = self.pokerData[self.userId]
			local discardValue = self.selectedCards[1].value
			if self.isFirst then
				if discardValue ~= 15 and #userCards > 1 then
					if discardValue ~= userCards[1].value then
						local data = {
							content = "下家已报单，必须选择最大牌值出牌！"
						}
						ui.mgr:open("Dialog/DialogView", data)
						return
					end
					
					--[[local logicData = {}
					for i, v in ipairs(userCards) do
						logicData[#logicData + 1] = {id = v.id , size = v.size, value = v.value, color = v.color}
					end

					local PaodekuaiLogic = Logic:get("PaodekuaiLogic")
					local analyseResult = PaodekuaiLogic:analyseCardData(logicData)
					if analyseResult.iSingleCount == #userCards then
						local flushResult = PaodekuaiLogic:seekOutFlush(logicData)
						if #flushResult > 0 then
							local data = {
								content = "下家已报单，请选择其他牌型出牌！"
							}
							ui.mgr:open("Dialog/DialogView", data)
							return
						else
							if discardValue ~= userCards[1].value then
								local data = {
									content = "下家已报单，必须选择最大牌值出牌！"
								}
								ui.mgr:open("Dialog/DialogView", data)
								return
							end
						end
					else
						local data = {
							content = "下家已报单，请选择其他牌型出牌！"
						}
						ui.mgr:open("Dialog/DialogView", data)
						return
					end--]]
				end
			else
				if discardValue ~= userCards[1].value then
					local data = {
						content = "下家已报单，必须选择最大牌值出牌！"
					}
					ui.mgr:open("Dialog/DialogView", data)
					return
				end
			end
		end

		if selectedNum == 4 then
			--炸弹压非炸弹会改变出牌牌型
			local selCardData = {}
			for i, v in ipairs(self.selectedCards) do
				selCardData[#selCardData + 1] = {id = v.id , size = v.size, value = v.value, color = v.color}
			end

			local cardType = Logic:get("PaodekuaiLogic"):getCardType(selCardData)
			self.discardType = cardType
		end

		modelData:requestDiscard(self.discardType, self.selectedCards)
		self:hideDiscardOption()

		for i, v in ipairs(self.selectedCards) do
			v:setScale(0.6)
			v:setEnabled(false)
		end

		self:addDiscardData(self.userId, self.selectedCards, self.discardType)
		self.selectedCards = {}
	else
		self:clearSelectedCards()
		log4ui:warn("[PokerCardLayer::uiEvtDiscardOut] discard error ! discardType : "..self.discardType..", selected card num : "..#self.selectedCards)
	end
end

--重选
function prototype:uiEvtDiscardReset()
	self:clearSelectedCards()

	self.tipDiscardIndex = 1

	self.nodeDiscard:checkEnabledButton(false, false)
end

--分析选中扑克
function prototype:analyseSelectedCardData(bAddSel)
	bAddSel = bAddSel or false

	if #self.selectedCards == 0 then
		self.nodeDiscard:checkEnabledButton(false, false)
		return -1
	end

	if self.isDiscarder then
		local selCardData = {}
		for i, v in ipairs(self.selectedCards) do
			selCardData[#selCardData + 1] = {id = v.id , size = v.size, value = v.value, color = v.color or 1}
		end

		-- log(self.selectedCards)

		local bEnableDiscard = false
		local PaodekuaiLogic = Logic:get("PaodekuaiLogic")
		local cardType = PaodekuaiLogic:getCardType(selCardData)
		-- log("analyse selected card data :: type ==== "..cardType)
		if self.isFirst then
			if cardType ~= -1 then
				local selectedNum = #selCardData
				local cardNum = #(self.pokerData[self.userId])
				if cardType == PaoDeKuai_pb.ONEHOUSE or cardType == PaoDeKuai_pb.HOUSE then
					if selectedNum == cardNum then
						bEnableDiscard = true
					else
						bEnableDiscard = false
					end
				elseif cardType == PaoDeKuai_pb.FOURWITHTHREE then
					--金币场不支持四带三
					if Model:get("Games/Paodekuai"):isEnabledFourWithThree() then
						if selectedNum == 7 or (selectedNum == cardNum) then
							bEnableDiscard = true
						else
							bEnableDiscard = false
						end
					end
				elseif cardType == PaoDeKuai_pb.PLANE then
					if math.fmod(selectedNum, 5)==0 or (selectedNum == cardNum) then
						bEnableDiscard = true
					else
						bEnableDiscard = false
					end
				else
					bEnableDiscard = true
				end
			else
				--检查选中扑克是否有顺子
				if not bAddSel then
					local flushResult = PaodekuaiLogic:seekOutFlush(selCardData)
					if #flushResult == 0 then
						--是否有连对
						flushResult = PaodekuaiLogic:seekOutPairFlush(selCardData)
					end

					if #flushResult > 0 then
						self:clearSelectedCards()

						local cardData = self.pokerData[self.userId]
						for i, v in ipairs(flushResult) do
							for _, card in ipairs(cardData) do
								if v.id == card.id then
									card:setIsSelected(true, cc.p(0, 25))
									table.insert(self.selectedCards, card)
									break
								end
							end
						end

						if flushResult[1].value == flushResult[2].value then
							cardType = PaoDeKuai_pb.CONTINUOUSPAIR
						else
							cardType = PaoDeKuai_pb.FLUSH
						end
						bEnableDiscard = true
					end
				end
			end

			self.discardType = cardType
		else
			local discardsList = self.roundData.discardsList
			local lastDiscardsInfo = discardsList[#discardsList]

			local targetType = lastDiscardsInfo.handsDesc
			self.discardType = targetType
			-- log("select card type : ".. cardType ..", discard type : " .. targetType)
			if targetType ~= nil and targetType >= 0 then
				if cardType == targetType or cardType == PaoDeKuai_pb.BOOM then
					local lastCardData = lastDiscardsInfo.discards
					if PaodekuaiLogic:compareCards(selCardData, table.clone(lastCardData), cardType, targetType) then
						bEnableDiscard = true
						--炸弹压非炸弹，牌型更改
						self.discardType = cardType
					end
				else
					if targetType > 1 then
						local lastCardData = lastDiscardsInfo.discards
						local flushResult, cardType = PaodekuaiLogic:searchOutCard(selCardData, table.clone(lastCardData), targetType)
						if #flushResult > 0 then
							self:clearSelectedCards()

							local cardData = self.pokerData[self.userId]
							for i, v in ipairs(flushResult) do
								for _, card in ipairs(cardData) do
									if v.id == card.id then
										card:setIsSelected(true, cc.p(0, 25))
										table.insert(self.selectedCards, card)
										break
									end
								end
							end

							bEnableDiscard = true
							self.discardType = cardType
						end
					end
				end
			else				
				log4ui:warn("Paodekuai:: get round data error ! ")
			end
		end

		self.nodeDiscard:checkEnabledButton(bEnableDiscard, true)

		return cardType
	end

	return -1
end

--扑克牌点击事件
function prototype:onTouch(cardNode, sender, event)
	if self.touchEnabled == false then
		return
	end

	-- log("touch event : "..event)
	if event == ccui.TouchEventType.began then
		local pos = sender:getTouchBeganPosition()
		self:onTouchBegan(cardNode, pos.x, pos.y)

	elseif event == ccui.TouchEventType.moved then
		local pos = sender:getTouchMovePosition()
		self:onTouchMove(cardNode, pos.x, pos.y)

	elseif event == ccui.TouchEventType.ended then
		local pos = sender:getTouchEndPosition()
		self:onTouchEnd(cardNode, pos.x, pos.y)

	elseif event == ccui.TouchEventType.canceled then
		self:onTouchCancel(cardNode)
	end
end

function prototype:onTouchBegan(sender, touchX, touchY)
	sender:setCardColor(COLOR_GRAY)
	local cardIndex = sender:getCardIndex()
	-- log("onTouchBegan cardIndex:"..cardIndex..", touchX:"..touchX..", touchY:"..touchY)
	self.moveData = {}
	self.moveData.startIndex = 0
	self.moveData.moveIndex = 0
	if cardIndex > 0 then
		self.moveData.startIndex = cardIndex
		self.moveData.startPos = {x=touchX, y=touchY}
		self.moveData.contentSize = sender:getContentSize()
		self.moveData.movePos = {x=0, y=0}
		-- self.moveData.lastMoveIndex = cardIndex
	end

	sys.sound:playEffect("CLICK_CARD")
end

function prototype:onTouchMove(sender, touchX, touchY)
	local cardIndex = sender:getCardIndex()
	-- log("onTouchMove cardIndex:"..cardIndex..", touchX:"..touchX..", touchY:"..touchY)
	if self.moveData and self.moveData.startIndex > 0 then
		self.moveData.moveIndex = 0

		local offsetX = touchX - self.moveData.startPos.x --计算拖动偏移
		local offsetY = touchY - self.moveData.startPos.y --计算拖动偏移
		if ABS(offsetX) >= 5 or ABS(offsetY) >= 5 then
			local userCardData = self.pokerData[self.userId]
			--处理拖动选中卡牌
			local moveIndex = self:isCardContainsPoint(touchX, touchY)
			if moveIndex > 0 then
				-- log("last move index : "..self.moveData.lastMoveIndex..", move index : "..moveIndex)
				-- if self.moveData.lastMoveIndex ~= moveIndex then
				-- 	sys.sound:playEffect("CLICK_CARD")
				-- 	self.moveData.lastMoveIndex = moveIndex
				-- end

				local startIndex = MIN(self.moveData.startIndex, moveIndex)
				local endIndex = MAX(self.moveData.startIndex, moveIndex)
				
				for i, v in ipairs(userCardData) do
					if i >= startIndex and i <= endIndex then
						v:setCardColor(COLOR_GRAY)
					else
						v:setCardColor(COLOR_WHITE)
					end					
				end
			else
				for i, v in ipairs(userCardData) do
					v:setCardColor(COLOR_WHITE)
				end
			end

			self.moveData.moveIndex = moveIndex
		end
	end
end

function prototype:onTouchEnd(sender, touchX, touchY)
	local cardIndex = sender:getCardIndex()
	-- log("onTouchEnd cardIndex:"..cardIndex..", touchX:"..touchX..", touchY:"..touchY)
	if self.moveData and self.moveData.startIndex > 0 then
		local startIndex = MIN(self.moveData.startIndex, self.moveData.moveIndex)
		local endIndex = MAX(self.moveData.startIndex, self.moveData.moveIndex)
		-- log("startIndex:"..startIndex..", endIndex:"..endIndex)
		-- log(self.moveData)

		local userCardData = self.pokerData[self.userId]
		if cardIndex > 0 then
			if startIndex > 0 then
				for i, v in ipairs(userCardData) do
					if i >= startIndex and i <= endIndex then
						if v then
							v.isSelected = not v.isSelected
							if v.isSelected == true then
								v:setIsSelected(true, cc.p(0, 25))
							else
								v:setIsSelected(false)
							end
						end
					end
				end
			else
				local itemData = userCardData[cardIndex]
				if itemData then
					itemData.isSelected = not itemData.isSelected
					if itemData.isSelected == true then
						itemData:setIsSelected(true, cc.p(0, 25))
					else
						itemData:setIsSelected(false)
					end
				end
			end
		end

		local bAddSel = false
		if #(self.selectedCards) > 0 then
			bAddSel = true
		end

		self.selectedCards = {}
		for i, v in ipairs(userCardData) do
			v:setCardColor(COLOR_WHITE)

			if v.isSelected then				
				table.insert(self.selectedCards, v)
			end
		end

		self:analyseSelectedCardData(bAddSel)
	end

	self.moveData = nil
end

--取消拖动后，判断是否选中了扑克
function prototype:onTouchCancel(sender)
	if self.moveData and self.moveData.startIndex>0 and self.moveData.moveIndex>0 then
		-- log(self.moveData)
		local startIndex = MIN(self.moveData.startIndex, self.moveData.moveIndex)
		local endIndex = MAX(self.moveData.startIndex, self.moveData.moveIndex)
		-- log("startIndex:"..startIndex..", endIndex:"..endIndex)
		local userCardData = self.pokerData[self.userId]
		if userCardData then
			for i, v in ipairs(userCardData) do
				if i >= startIndex and i <= endIndex then
					if v then
						v.isSelected = not v.isSelected
						if v.isSelected == true then
							v:setIsSelected(true, cc.p(0, 25))
						else
							v:setIsSelected(false)
						end
					end
				end
			end

			self.selectedCards = {}
			for i, v in ipairs(userCardData) do
				v:setCardColor(COLOR_WHITE)

				if v.isSelected then
					table.insert(self.selectedCards, v)
				end
			end

			self:analyseSelectedCardData()
		end
	else
		if userCardData then
			for i, v in ipairs(userCardData) do
				v:setCardColor(COLOR_WHITE)
			end
		end
	end
	self.moveData = nil		
end

--判断是否点击在卡牌上
function prototype:isCardContainsPoint(x, y)
	local item = nil
	local userCardData = self.pokerData[self.userId]
	local w = self.moveData.contentSize.width
	local h = self.moveData.contentSize.height
	local num = #userCardData
	local startPos = cc.p(0, 0)
	local endPos = cc.p(0, 0)
	for index = num, 1, -1 do
		item = userCardData[index]
		if item then
			local pos = item:getWorldPosition()
			local rect = cc.rect(pos.x - w/2, pos.y - h/2, w, h)
			if cc.rectContainsPoint(rect, cc.p(x, y)) then
				return index
			end

			if index == 1 then
				startPos = cc.p(rect.x, rect.y)
			elseif index == num then
				endPos = cc.p(rect.x, rect.y)
			end
		end
	end

	if y >= startPos.y-150 and y <= startPos.y+h+150 then
		if x <= startPos.x then
			return 1
		elseif x >= endPos.x + w then
			return num
		end
	end

	return 0
end

--获取手牌位置
function prototype:getDealCardPos(seatIndex, cardIndex, cardNum, size)
	local pos = cc.p(0, 0)	
	if seatIndex == 1 then
		-- local middleIndex = math.ceil(cardNum/2)
		-- local x = self.winSize.width / 2 - (middleIndex - cardIndex) * 72 - 30
		-- pos.x = x
		local space = 72
		if self.screenScale >= 2.0 then
			--宽屏手机
			space = 85
		end

		local startX = (self.winSize.width - (cardNum-1)*space - size.width) / 2
		pos.x = startX + size.width/2 + (cardIndex-1) * space
		pos.y = 115
	elseif seatIndex == 2 then
		pos.x = 1130
		pos.y = 574
	elseif seatIndex == 3 then
		pos.x = 200
		pos.y = 574
	else
		log4ui:warn("PokerCardLayer::getCardPos error ! seatIndex is not exist ! seatIndex : ".. seatIndex)
	end

	return pos
end

--回放手牌位置（其他玩家也需要明牌)
function prototype:getPlayBackDealCardPos(seatIndex, cardIndex, cardNum, size)
	local pos = cc.p(0, 0)	
	if seatIndex == 1 then
		local space = 72
		if self.screenScale >= 2.0 then
			--宽屏手机
			space = 85
		end

		local startX = (self.winSize.width - (cardNum-1)*space - size.width) / 2
		pos.x = startX + size.width/2 + (cardIndex-1) * space
		pos.y = 115
	elseif seatIndex == 2 then
		pos.x = 1250 - 30 * (cardNum - cardIndex)
		pos.y = 640
	elseif seatIndex == 3 then
		pos.x = 90 + 30 * (cardIndex - 1)
		pos.y = 640
	else
		log4ui:warn("PokerCardLayer::getCardPos error ! seatIndex is not exist ! seatIndex : ".. seatIndex)
	end

	return pos
end

--出牌位置
function prototype:getDiscardPos(seatIndex, cardIndex, cardNum, size)
	local pos = cc.p(0, 0)
	size = size or cc.size(102, 138)
	if seatIndex == 1 then
		-- local middleIndex = math.ceil(cardNum/2)
		local space = 50
		local startX = (self.winSize.width - (cardNum-1)*space - size.width) / 2
		-- local x = self.winSize.width / 2 - (middleIndex - cardIndex) * space + 30
		pos.x = startX + size.width/2 + (cardIndex-1) * space
		pos.y = 320
	elseif seatIndex == 2 then
		pos.x = 1040 - 40 * (cardNum - cardIndex)
		pos.y = 524
	elseif seatIndex == 3 then
		pos.x = 290 + 40 * (cardIndex - 1)
		pos.y = 524
	else
		log4ui:warn("PokerCardLayer::getCardPos error ! seatIndex is not exist ! seatIndex : ".. seatIndex)
	end

	return pos
end

function prototype:getResultPos(seatIndex, cardIndex, cardNum, size)
	local pos = cc.p(0, 0)
	if seatIndex == 1 then
		local space = 45
		local startX = (self.winSize.width - (cardNum-1)*space - size.width) / 2
		pos.x = startX + size.width/2 + (cardIndex-1) * space
		pos.y = 320
	elseif seatIndex == 2 then
		if cardNum <= 8 then
			pos.x = 1040 - 40 * (cardNum - cardIndex)
		else
			if cardIndex <= 8 then
				pos.x = 1040 - 40 * (8 - cardIndex)
			else
				pos.x = 1040 - 40 * (8 - (cardIndex - 8))
			end
		end
		if cardIndex <= 8 then
			pos.y = 535
		else
			pos.y = 460
		end
	elseif seatIndex == 3 then
		pos.x = 290 + 40 * ((cardIndex-1) % 8)
		if cardIndex <= 8 then
			pos.y = 535
		else
			pos.y = 460
		end
	else
		log4ui:warn("PokerCardLayer::getCardPos error ! seatIndex is not exist ! seatIndex : ".. seatIndex)
	end

	return pos
end

--音效
function prototype:playEffectSound(handsDesc, sex, value, number)
	sex = sex or 1
	local sexStr = (sex == 1) and "man" or "woman"
	if handsDesc == PaoDeKuai_pb.SINGLE then
		sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/%s/single%d.mp3", sexStr, value))
	elseif handsDesc == PaoDeKuai_pb.ONEPAIR then
		sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/%s/pair%d.mp3", sexStr, value))
	elseif handsDesc == PaoDeKuai_pb.FLUSH then
		sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/%s/straight.mp3", sexStr))
	elseif handsDesc == PaoDeKuai_pb.CONTINUOUSPAIR then
		sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/%s/doubelstraight.mp3", sexStr))
	elseif handsDesc == PaoDeKuai_pb.FULLHOUSE then
		sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/%s/3and2.mp3", sexStr))
	elseif handsDesc == PaoDeKuai_pb.PLANE then
		sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/%s/plane.mp3", sexStr))
	elseif handsDesc == PaoDeKuai_pb.BOOM then
		sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/%s/bomb.mp3", sexStr))
	elseif handsDesc == PaoDeKuai_pb.ONEHOUSE then
		sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/%s/3and1.mp3", sexStr))
	elseif handsDesc == PaoDeKuai_pb.HOUSE then
		sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/%s/triple.mp3", sexStr))
	elseif handsDesc == PaoDeKuai_pb.FOURWITHTHREE then
		if number == 6 then
			sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/%s/4and2.mp3", sexStr))
		else
			sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/%s/4and3.mp3", sexStr))
		end
	end
end

--动画
function prototype:playEffectAction(handsDesc, seatIndex, number)
	if handsDesc == PaoDeKuai_pb.FLUSH then
		local sprite = cc.Sprite:create("resource/csbimages/Effect/Flush/1.png")
		local animation = cc.Animation:create()
	    for i = 1, 8 do				
	        animation:addSpriteFrameWithFile(string.format("resource/csbimages/Effect/Flush/%d.png", i))
	    end
	    animation:setDelayPerUnit(0.7 / 8)

	    local showAction = cc.Animate:create(animation)
	    sprite:runAction(cc.Sequence:create(showAction, cc.CallFunc:create(function()
	    	sprite:removeFromParent(true)
	    	end)))

	    local pos = self:getDiscardPos(seatIndex, math.ceil(number/2), number)
	    sprite:setPosition(pos)
	    -- sprite:setPosition(cc.p(self.winSize.width/2, self.winSize.height/2))
	    self.rootNode:addChild(sprite, 1000)

	elseif handsDesc == PaoDeKuai_pb.CONTINUOUSPAIR then
		local sprite = cc.Sprite:create("resource/csbimages/Effect/PairLine/1.png")
		local animation = cc.Animation:create()
	    for i = 1, 8 do				
	        animation:addSpriteFrameWithFile(string.format("resource/csbimages/Effect/PairLine/%d.png", i))
	    end
	    animation:setDelayPerUnit(0.7 / 8)

	    local showAction = cc.Animate:create(animation)
	    sprite:runAction(cc.Sequence:create(showAction, cc.CallFunc:create(function()
	    	sprite:removeFromParent(true)
	    	end)))

	    local pos = self:getDiscardPos(seatIndex, math.ceil(number/2), number)
	    sprite:setPosition(pos)
	    -- sprite:setPosition(cc.p(self.winSize.width/2, self.winSize.height/2))
	    self.rootNode:addChild(sprite, 1000)

	elseif handsDesc == PaoDeKuai_pb.PLANE then
		local sprite = cc.Sprite:create("resource/csbimages/Effect/Plane/imgPlane.png")
		local move = cc.EaseIn:create(cc.MoveBy:create(1.0, cc.p(self.winSize.width - 150, 0)), 2.5)
		sprite:runAction(cc.Sequence:create(move, cc.CallFunc:create(function()
	    	sprite:removeFromParent(true)
	    	end)))

		sprite:setPosition(100, self.winSize.height/2 + 100)
		self.rootNode:addChild(sprite, 1000)

		local sprite2 = cc.Sprite:create("resource/csbimages/Effect/Plane/txtPlane.png")
		sprite2:setOpacity(0)
		sprite2:setScale(0.1)
		-- local move = cc.EaseIn:create(cc.MoveBy:create(1.0, cc.p(self.winSize.width - 100, 0)), 2.5)
		-- sprite2:runAction(cc.Sequence:create(move, cc.CallFunc:create(function()
	 --    	sprite2:removeFromParent(true)
	 --    	end)))
	 	local action = cc.Spawn:create(
			cc.FadeIn:create(0.4),
			cc.EaseIn:create(cc.ScaleTo:create(0.4, 1.3), 2.5)
			)
	 	sprite2:runAction(cc.Sequence:create(action, cc.ScaleTo:create(0.1, 1.0), cc.FadeOut:create(0.5), cc.CallFunc:create(function()
	    	sprite2:removeFromParent(true)
	    	end)))

		sprite2:setPosition(self.winSize.width/2, self.winSize.height/2)
		self.rootNode:addChild(sprite2, 1000)

		sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/special_plane.mp3"))

	elseif handsDesc == PaoDeKuai_pb.BOOM then
		local sprite = cc.Sprite:create("resource/csbimages/Effect/Bomb/imgBomb.png")
		local parentLayer = self.rootNode:getParent()
		--适配坐标，控件包含了一个界面的子控件（需要查找父控件的父控件，即界面UI）
		local parentProxy = tolua.getpeer(parentLayer:getParent())
		local fromPos = parentProxy["nodeRole_"..seatIndex]:getHeadPos()
		local toPos = cc.p(self.winSize.width/2, self.winSize.height/2)
		local bezier ={
	        fromPos,
	        cc.p(toPos.x - (toPos.x-fromPos.x)/2, MAX(fromPos.y, toPos.y) + 100),
	        -- cc.p(toPos.x - (toPos.x-fromPos.x)/2, toPos.y - (toPos.y-fromPos.y)/2),
	        toPos
	    }

		local moveAction = cc.Spawn:create(
			-- cc.MoveTo:create(0.4, toPos),
			cc.BezierTo:create(0.5, bezier),
			cc.RotateBy:create(0.5, 360))

		local animation = cc.Animation:create()
	    for i = 1, 7 do
	        animation:addSpriteFrameWithFile(string.format("resource/csbimages/Effect/Bomb/%d.png", i))
	    end
	    animation:setDelayPerUnit(0.7 / 7)

	    local showAction = cc.Animate:create(animation)

	    sprite:runAction(cc.Sequence:create(moveAction, showAction, cc.CallFunc:create(function()
	    	sprite:removeFromParent(true)
	    	end)))

	    sprite:setPosition(fromPos)
	    self.rootNode:addChild(sprite, 1000)

	    sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/special_bomb.mp3"))
	elseif handsDesc == 100 then
	   	--春天
	   	local sprite = cc.Sprite:create("resource/csbimages/Effect/Spring/1.png")
		local animation = cc.Animation:create()
	    for i = 1, 6 do				
	        animation:addSpriteFrameWithFile(string.format("resource/csbimages/Effect/Spring/%d.png", i))
	    end
	    animation:setDelayPerUnit(0.8 / 6)

	    local showAction = cc.Animate:create(animation)
	    sprite:runAction(cc.Sequence:create(showAction, cc.CallFunc:create(function()
	    	sprite:removeFromParent(true)
	    	end)))

	    sprite:setPosition(cc.p(self.winSize.width/2, self.winSize.height/2))
	    self.rootNode:addChild(sprite, 1000)

	   	sys.sound:playEffectByFile(string.format("resource/audio/Paodekuai/special_chuntian.mp3"))
	end
end


