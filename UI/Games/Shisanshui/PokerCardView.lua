module(..., package.seeall)

prototype = Controller.prototype:subclass()
local MAX = math.max
local MIN = math.min
local ABS = math.abs
local COLOR_WHITE = cc.c3b(0xff, 0xff, 0xff)
local COLOR_GRAY = cc.c3b(0x99, 0x8e, 0x8e)

function prototype:enter()
   -- log('PCV: enter')
    self.nodeClockDeal:stop()
    self:bindUIEvent('Game.Clock', 'uiEvtClockFinish')
    self.pokerCards = {}
    self.selectedCards = {}
    self.frontCards = {}
    self.midCards = {}
    self.tailCards = {}
    self.ShisanshuiLogic = Logic:get('ShisanshuiLogic')
    self.userId = Model:get('Account'):getUserId()
    self.cardType = 0
    self.touchEnabled = true
    self:seePokerCardView(false)
    self.allBtnNum = {0, 0, 0, 0, 0, 0, 0, 0}
    self.allBtn = {}
    self.allBtnImg={}
    self.btnTeShuPai:setColor(COLOR_GRAY)
    self.allBtn[1] = self.btnDuiZi
    self.allBtn[2] = self.btnLiangDui
    self.allBtn[3] = self.btnSanTiao
    self.allBtn[4] = self.btnShunZi
    self.allBtn[5] = self.btnTongHua
    self.allBtn[6] = self.btnHuLu
    self.allBtn[7] = self.btnTieZhi
    self.allBtn[8] = self.btnTongHuaShun
    self.allBtn[11] = self.btnTeShuPai
    self.allBtnImg[1] = self.img99_1
    self.allBtnImg[2] = self.img99_2
    self.allBtnImg[3] = self.img99_3
    self.allBtnImg[4] = self.img99_4
    self.allBtnImg[5] = self.img99_5
    self.allBtnImg[6] = self.img99_6
    self.allBtnImg[7] = self.img99_7
    self.allBtnImg[8] = self.img99_8
    self.allBtnImg[11] = self.img99_11
    
    self.SortRecord = {}
    self.allBtnFlush = false
    self.SpecialCardType = ShiSanShui_pb.NOT_SPECIALTYPE
    self.sendSpecialCardType = ShiSanShui_pb.NOT_SPECIALTYPE
    self.SpecialCard = {}
    self.onBtnSortDaXiao = true
    self.imgDaXiao:setVisible(false)
    self.btnCancel:setVisible(false)
    self.btnConfirm:setVisible(false)
    self.noNeedAutoSelect=false
end
--时钟倒计时结束
function prototype:uiEvtClockFinish()
   -- log('bai pai clock down')
    --self.nodeNotice:finish()
    --[[if self.discardPlayerId == self.userId then
		 -- self.nodePokerLayer:hideDiscardOption()
	end]]
end

function prototype:seePokerCardView(visible)
    --log('PCV: seePokerCardView')
    if visible == false then
        self.nodeClockDeal:setPosition(616, 303)
       -- log("nodePokerView.nodeClockDeal====================")    
        self:seeSpecialAction(false, false)
        self.noNeedAutoSelect=false
    end
    
    self.panelCenter:setVisible(visible)
    self.panelBtn:setVisible(visible)
    self.btnSort:setVisible(visible)
    self.onPanelPai_1:setVisible(visible)
    self.onPanelPai_2:setVisible(visible)
    self.onPanelPai_3:setVisible(visible)
    if self.frontCards ~= nil then
        for k, v in ipairs(self.frontCards) do
            v:setVisible(visible)
        end
    end
    if self.midCards ~= nil then
        for k, v in ipairs(self.midCards) do
            v:setVisible(visible)
        end
    end
    if self.tailCards ~= nil then
        for k, v in ipairs(self.tailCards) do
            v:setVisible(visible)
        end
    end
end

function prototype:clearCards(id)
    if id ~= nil then
        local cards = self.pokerCards[id]
        if cards then
            for i, card in ipairs(cards) do
                if card ~= nil then
                    card:removeFromParent(true)
                end
            end
        end

        self.pokerCards[id] = nil
    end

    --self.touchEnabled = false
    --self.cardType = 0
end

function prototype:setEmptyPokerCards()
    --log('PCV: setEmptyPokerCards')
    self.pokerCards = {}
end
function prototype:seeSelfPokerCards(visible)
   -- log('PCV: seeSelfPokerCards')
    for k, v in pairs(self.pokerCards[self.userId]) do
        v:setVisible(visible)
    end
end
function prototype:clearAllCards()
   -- log('PCV: clearAllCards')
    for k, v in pairs(self.pokerCards) do -- 其他人的牌也清空
        self:clearCards(k)
    end
    self.pokerCards = {}
end
function prototype:clearSanDunCards()
   -- log('PCV: clearSanDunCards')
    local tableTemp = {self.frontCards, self.midCards, self.tailCards}
    for k, v in ipairs(tableTemp) do
        for k1, v1 in pairs(tableTemp[k]) do
            v1:removeFromParent(true)
        end
    end
    self.selectedCards = {}
    --self.cardType = 0
    self.frontCards = {}
    self.midCards = {}
    self.tailCards = {}
    self.SpecialCardType = ShiSanShui_pb.NOT_SPECIALTYPE
    self.sendSpecialCardType = ShiSanShui_pb.NOT_SPECIALTYPE
    self.btnCancel:setVisible(false)
    self.btnConfirm:setVisible(false)
end


--移除手牌 ,移到牌墩上,
function prototype:removeHandCard(removeList, cardData)
   -- log('PCV: removeHandCard')
    if removeList == nil or table.nums(removeList) == 0 or cardData == nil then
        return 
    end
    local iCardCount = #cardData
    for i = 1, table.nums(removeList) do
        for j = 1, table.nums(cardData) do
            if removeList[i] == cardData[j] then
                table.remove(cardData, j)
                break
            end
        end
    end
end
--添加手牌,从牌墩移回手牌,
function prototype:addHandCard(addList, cardData)
   -- log('PCV: addHandCard')
    if addList == nil or cardData == nil then
        return
    end
    for i = 1, table.nums(addList) do
        table.insert(cardData, addList[i])
    end
end

function prototype:createPokerCard(id, index)
    --log('PCV: createPokerCard')
    if self.pokerCards[id] == nil then
        self.pokerCards[id] = {}
    end
    local cardNode = nil
    if cardNode == nil then
        cardNode = self:getLoader():loadAsLayer('Games/Common/GamePokerCard')
        self.rootNode:addChild(cardNode, index)
        table.insert(self.pokerCards[id], cardNode)
        cardNode:setCardIndex(index)
        if id == self.userId then
            cardNode:addCardTouchEvent(bind(self.onTouch, self))
        end
    end
    return cardNode
end
--重新排列,排列牌
function prototype:sortDealCards(cbCardData, cbCardCount, enAscend)
   -- log('PCV: sortDealCards')
    if cbCardData == nil or #cbCardData == 0 then
        return
    end
    local cardTemp

    if enAscend == true then
        self.ShisanshuiLogic:SortCardList2(cbCardData, cbCardCount, self.ShisanshuiLogic.enAscend) --升序123
    else
        self.ShisanshuiLogic:SortCardList2(cbCardData, cbCardCount, self.ShisanshuiLogic.enDescend) --降序
    end
    if self.onBtnSortDaXiao == false then
        cardTemp = self.ShisanshuiLogic:SortCardListColor(cbCardData, cbCardCount)
    end
    if cardTemp == nil then
        cardTemp = cbCardData
    end
    self.pokerCards[self.userId] = self:findRealCard(cardTemp, self.pokerCards[self.userId])
    local size = cc.size(self.pokerCards[self.userId][1]:getContentSize().width, self.pokerCards[self.userId][1]:getContentSize().height)
    for i, v in ipairs(self.pokerCards[self.userId]) do
        v:setCardIndex(i)
        v:setLocalZOrder(i)
        local pos = self:getDealCardPos(i, size)
        v:setPosition(pos)
    end
end

function prototype:getDealCardPos(index, size)
    local pos = cc.p(0, 0)
    pos.x = 110 + (index - 1) * 85
    pos.y = 32 + size.height / 2
    return pos
end

--扑克牌点击事件
function prototype:onTouch(cardNode, sender, event)
    if self.touchEnabled == false then
        return
    end

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
    -- log("[PokerCardView:onTouch began] sender : value = "..sender:getCardSize()..", color = "..sender:getCardColor())
    -- log("[PokerCardView:onTouch began] pos : x == "..pos.x..", y == "..pos.y)
    sender:setCardColor(COLOR_GRAY)
    local cardIndex = sender:getCardIndex()
    -- log("onTouchBegan cardIndex:"..cardIndex..", touchX:"..touchX..", touchY:"..touchY)
    if sender.up == nil or sender.up == 0 then
        self.moveData = {}
        self.moveData.startIndex = 0
        self.moveData.moveIndex = 0
        if cardIndex > 0 then
            self.moveData.startIndex = cardIndex
            self.moveData.startPos = {x = touchX, y = touchY}
            self.moveData.contentSize = sender:getContentSize()
            self.moveData.movePos = {x = 0, y = 0}
        -- self.moveData.lastMoveIndex = cardIndex
        end
    end
    sys.sound:playEffect('CLICK_CARD')
    -- log("TouchBegan 1")
end

function prototype:onTouchMove(sender, touchX, touchY)
    if sender.up == nil or sender.up == 0 then
        local cardIndex = sender:getCardIndex()
        -- log("onTouchMove cardIndex:"..cardIndex..", touchX:"..touchX..", touchY:"..touchY)
        if self.moveData and self.moveData.startIndex > 0 then
            self.moveData.moveIndex = 0

            local offsetX = touchX - self.moveData.startPos.x --计算拖动偏移
            local offsetY = touchY - self.moveData.startPos.y --计算拖动偏移
            if ABS(offsetX) >= 5 or ABS(offsetY) >= 5 then
                local userCardData = self.pokerCards[self.userId]
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
    --log("TouchMove 2")
end

function prototype:onTouchEnd(sender, touchX, touchY)
    if sender.up == nil or sender.up == 0 then
        local cardIndex = sender:getCardIndex()
        -- log("[PokerCardView:onTouch end] sender : value = "..sender:getCardSize()..", color = "..sender:getCardColor())
        -- log("[PokerCardView:onTouch end] pos : x == "..pos.x..", y == "..pos.y)
        if self.moveData and self.moveData.startIndex > 0 then
            local userCardData = self.pokerCards[self.userId]
            if cardIndex > 0 then
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
        end
        self.moveData = nil
    else
        if sender:getIsSelected() == true then
            --[[if table.nums(self.selectedCards) < 5 then
                            sender:setIsSelected(true, cc.p(0, 25))
                            table.insert(self.selectedCards, sender)
                        end]]
            sender:setCardColor(COLOR_WHITE)
            self:CardDown(sender)
        -- 点击牌墩上的牌,下来
        --[[ else
                            sender:setIsSelected(false)
                            for i = #self.selectedCards, 1, -1 do
                                if self.selectedCards[i].index == sender.index then
                                    table.remove(self.selectedCards, i)
                                end
                            end]]
        end
    end
    -- log("TouchEnd 3")
end

function prototype:onTouchCancel(sender)
    if sender.up == nil or sender.up == 0 then
        if self.moveData and self.moveData.startIndex > 0 and self.moveData.moveIndex > 0 then
            local startIndex = MIN(self.moveData.startIndex, self.moveData.moveIndex)
            local endIndex = MAX(self.moveData.startIndex, self.moveData.moveIndex)
            local userCardData = self.pokerCards[self.userId]
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
            else
                if userCardData then
                    for i, v in ipairs(userCardData) do
                        v:setCardColor(COLOR_WHITE)
                    end
                end
            end
            self.moveData = nil
        end
    else
        sender:setCardColor(COLOR_WHITE)
    end
    --log("TouchCance 4")
end
function prototype:CardDown(sender)
  --  log('PCV: CardDown')
    -- log("CardDown================== "..sender.up)
    local TempCards = {}
    if sender.up == 1 then
        TempCards = self.frontCards
    elseif sender.up == 2 then
        TempCards = self.midCards
    elseif sender.up == 3 then
        TempCards = self.tailCards
    end
    sender.up = 0
    sender:setScale(0.8)
    -- v:setEnabled(true)
    sender:setIsSelected(false)
    self:removeHandCard({sender}, TempCards)
    self:addHandCard({sender}, self.pokerCards[self.userId])
    --self:sortSanDunPai(TempCards)
    self:initAllBtn()
    self:typeSelectCheck()
    self:seeSpecialAction(false,true)
    --标志消失,跑马灯动画取消
end
--判断是否点击在卡牌上
function prototype:isCardContainsPoint(x, y)
    local item = nil
    local userCardData = self.pokerCards[self.userId]
    local w = self.moveData.contentSize.width
    local h = self.moveData.contentSize.height
    local num = #userCardData
    local startPos = cc.p(0, 0)
    local endPos = cc.p(0, 0)
    for index = num, 1, -1 do
        item = userCardData[index]
        if item then
            local pos = item:getWorldPosition()
            local rect = cc.rect(pos.x - w / 2, pos.y - h / 2, w, h)
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

    if y >= startPos.y - 150 and y <= startPos.y + h + 150 then
        if x <= startPos.x then
            return 1
        elseif x >= endPos.x + w then
            return num
        end
    end

    return 0
end

function prototype:initSpecialBtn() --只判断自己的特殊牌 --hhhh
   -- log("PCV: initSpecialBtn")
    if self.pokerCards[self.userId] == nil or table.nums(self.pokerCards[self.userId]) == 0 then
        return
    end
    local function creatVirtualCard(value, color)
        if value == nil or color == nil then
            return
        end
        local mCard = {}
        mCard.value = value
        mCard.color = color
        return mCard
    end
    local virtualCards = {}
    for k, v in ipairs(self.pokerCards[self.userId]) do -- 虚拟牌
        virtualCards[k] = creatVirtualCard(self.pokerCards[self.userId][k].size, self.pokerCards[self.userId][k].color)
    end
    self:sortDealCards(virtualCards, table.nums(virtualCards), false) -- 牌排序
    local SpecialcardType, cbLineCardData = self.ShisanshuiLogic:GetSpecialType(virtualCards, table.nums(virtualCards))
    if SpecialcardType ~= nil and SpecialcardType ~= ShiSanShui_pb.NOT_SPECIALTYPE  then
      --  log('Te shu pai=========>>>>' .. SpecialcardType)
        self.SpecialCardType = SpecialcardType
        self.SpecialCard = cbLineCardData
        self.allBtn[11]:setColor(COLOR_WHITE)
        self.allBtn[11]:setEnabled(true)
        self.allBtnImg[11]:loadTexture("resource/csbimages/Games/Shisanshui/specialType/img100_11.png")
        if self['sprPMD'] == nil then
            local animationPMD = cc.Animation:create()
            for i = 1, 5 do
                animationPMD:addSpriteFrameWithFile('resource/csbimages/Games/Shisanshui/specialType/specialPaomaDeng/' .. i .. '.png')
            end
            animationPMD:setDelayPerUnit(0.1)
            -- animationLong:setRestoreOriginalFrame(true)
            --animationPMD:setLoops(-1)
            local action = cc.Animate:create(animationPMD)
            local x,y=self.allBtn[11]:getPosition()
            self['sprPMD'] = cc.Sprite:create('resource/csbimages/Games/Shisanshui/specialType/specialPaomaDeng/1.png')
            self['sprPMD']:setPosition(cc.p(x+10,y))
            self.rootNode:addChild(self['sprPMD'])
            self['sprPMD']:setVisible(true)
            self['sprPMD']:runAction(cc.RepeatForever:create(action))
            local eff = CEffectManager:GetSingleton():getEffect('a1texp', true)
            self.panelEff1:addChild(eff)
            self.panelEff1:setVisible(false)
        else
            self:seeSpecialAction(false,true)
        end
    else
        self.allBtn[11]:setColor(COLOR_GRAY)
        self.allBtn[11]:setEnabled(false)
        self.allBtnImg[11]:loadTexture("resource/csbimages/Games/Shisanshui/specialType/img101_11.png")
    end
end
function prototype:initAllBtn()
   -- log("PCV: initAllBtn")
    if self.pokerCards[self.userId] == nil or table.nums(self.pokerCards[self.userId]) == 0 then
        if self.allBtn == nil then --经常出bug显示self.allBtn为空
            self.allBtn = {}
            self.allBtn[1] = self.btnDuiZi
            self.allBtn[2] = self.btnLiangDui
            self.allBtn[3] = self.btnSanTiao
            self.allBtn[4] = self.btnShunZi
            self.allBtn[5] = self.btnTongHua
            self.allBtn[6] = self.btnHuLu
            self.allBtn[7] = self.btnTieZhi
            self.allBtn[8] = self.btnTongHuaShun
            self.allBtnImg={}
            self.allBtnImg[1] = self.img99_1
            self.allBtnImg[2] = self.img99_2
            self.allBtnImg[3] = self.img99_3
            self.allBtnImg[4] = self.img99_4
            self.allBtnImg[5] = self.img99_5
            self.allBtnImg[6] = self.img99_6
            self.allBtnImg[7] = self.img99_7
            self.allBtnImg[8] = self.img99_8
            self.allBtnImg[11] = self.img99_11
        end
        for k, v in ipairs(self.allBtn) do
            v:setColor(COLOR_GRAY)
            v:setEnabled(false)
        end
        for k, v in ipairs(self.allBtnImg) do
            v:loadTexture(string.format("resource/csbimages/Games/Shisanshui/specialType/img101_%d.png",k ) )
        end
        return
    end
    local function creatVirtualCard(value, color)
        if value == nil or color == nil then
            return
        end
        local mCard = {}
        mCard.value = value
        mCard.color = color
        return mCard
    end
    if table.nums(self.selectedCards) ~= 0 then
        self:clearSelectedCards()
    end
    self.allBtnFlush = true
    for k, v in ipairs(self.allBtn) do
        v:setColor(COLOR_GRAY)
        v:setEnabled(false)
    end
    for k, v in ipairs(self.allBtnImg) do
        v:loadTexture(string.format("resource/csbimages/Games/Shisanshui/specialType/img101_%d.png",k ) )
    end
    local virtualCards = {}
    for k, v in ipairs(self.pokerCards[self.userId]) do --虚拟牌
        virtualCards[k] = creatVirtualCard(self.pokerCards[self.userId][k].size, self.pokerCards[self.userId][k].color)
    end
    self:sortDealCards(virtualCards, table.nums(virtualCards), false) --牌排序
    local SortResult, SortRecord = self.ShisanshuiLogic:sortAllCarsType(virtualCards, table.nums(virtualCards))
    self.SortRecord = SortRecord
    --dump(self.SortRecord)
    local noBtnSelect = true
    for k, v in ipairs(SortRecord) do
        if v.bTag == true then
            self.allBtn[k]:setColor(COLOR_WHITE)
            self.allBtnImg[k]:loadTexture(string.format("resource/csbimages/Games/Shisanshui/specialType/img101_%d.png",k))
            self.allBtn[k]:setEnabled(true)
            noBtnSelect = false
        end
    end
    if noBtnSelect == true and self.noNeedAutoSelect==false then
        if table.nums(self.pokerCards[self.userId]) == 8 then
            self:clearSelectedCards()
            for i = 2, 4 do
                local v = self.pokerCards[self.userId][i]
                if v:getIsSelected() == false then
                    v:setIsSelected(true, cc.p(0, 25))
                    table.insert(self.selectedCards, v)
                end
            end
            self.noNeedBtnSelect=true
            self:onPanelPai_1Click()
        end
    end
end
function prototype:clearSelectedCards()
   -- log('PCV: clearSelectedCards')
    for k, v in ipairs(self.pokerCards[self.userId]) do
        v:setIsSelected(false)
    end
    self.selectedCards = {}
end
function prototype:getOnPlaneCardPos(args1, args2)
    local pos = {}
    local pos2 = {}
    pos2[1] = {530, 654, 778, 0, 0, 610} --最后一个是Y值
    pos2[2] = {407, 531, 656, 780, 904, 471}
    pos2[3] = {407, 532, 656, 780, 904, 332}
    pos.x = pos2[args1][args2]
    pos.y = pos2[args1][6]
    return pos
end

function prototype:sortSanDunPai(temp)
    --log('PCV: sortSanDunPai')
    if table.nums(temp) == 0 then
        return
    end
    if table.nums(temp) == 1 then
        return temp
    end
    local tempdou = {}
    local tempsin = {}
    local active = false

    local cbSortValue = {}
    for i = 1, table.nums(temp) do
        table.insert(cbSortValue, i, temp[i].value)
    end
    local tempT2 = {} --把A当16
    for k, v in ipairs(cbSortValue) do
        if v == 1 then
            table.insert(tempT2, k)
        end
    end
    for k, v in ipairs(tempT2) do
        cbSortValue[v] = 16
    end

    local bSorted = true
    local cbLast = table.nums(cbSortValue) - 1
    repeat
        bSorted = true
        for i = 1, cbLast do
            if (cbSortValue[i] < cbSortValue[i + 1]) then
                --设置标志
                bSorted = false

                --扑克数据
                temp[i], temp[i + 1] = temp[i + 1], temp[i]

                --排序权位
                cbSortValue[i], cbSortValue[i + 1] = cbSortValue[i + 1], cbSortValue[i]
            end
        end
        cbLast = cbLast - 1
    until bSorted ~= false

    local i = 1
    while i < #temp do
        if temp[i].value == temp[i + 1].value then
            active = true
            table.insert(tempdou, temp[i])
        else
            if active == false then
                table.insert(tempsin, temp[i])
            else
                table.insert(tempdou, temp[i])
            end
            active = false
        end
        i = i + 1
    end
    if temp[#temp - 1].value ~= temp[#temp].value then
        -- 最后一个数没有比较
        table.insert(tempsin, temp[#temp])
    else
        table.insert(tempdou, temp[#temp])
    end
    if table.nums(tempdou) == 5 and tempdou[2].value ~= tempdou[3].value then
        tempdou[1], tempdou[4] = tempdou[4], tempdou[1]
        tempdou[2], tempdou[5] = tempdou[5], tempdou[2]
        return tempdou
    end
    if table.nums(tempdou) == 0 then
        return tempsin
    end
    temp = {}
    for k, v in ipairs(tempdou) do
        table.insert(temp, v)
    end
    for k, v in ipairs(tempsin) do
        table.insert(temp, v)
    end
    return temp
end
--三牌墩点击事件
--第一墩 --hhhh
function prototype:onPanelPai_1Click()
   -- log('111111111111111111111111')
    if table.nums(self.selectedCards) == 0 then
   --     log('hh 0')
        return
    end
    if table.nums(self.frontCards) == 3 then
     --   log('hh self.frontCards full')
        return
    end
    local TempCards = {}

    for k, v in ipairs(self.selectedCards) do
        if table.nums(self.frontCards) < 3 then
            table.insert(self.frontCards, v)
            TempCards[#TempCards + 1] = v
        end
    end
    sys.sound:playEffect('OUT_CARD')
    self.frontCards = self:sortSanDunPai(self.frontCards) --整理摆好的牌
    local code = self:ComparePokerCard(1) --后墩必须大于前墩
  --  log('code 1 :' .. code)
    if code == 1 or code == 4 then
        for k, v in ipairs(self.frontCards) do
            -- v.oldPosition=cc.p(v:getPosition())
            local pos = self:getOnPlaneCardPos(1, k)
            --[[ local action = cc.Spawn:create(
		           cc.MoveTo:create(0.4,pos),
		            cc.ScaleTo:create(0.4,0.64,0.6)
		            ) 
                    v:runAction(action)    ]]
            v:setPosition(pos)
            v:setScale(0.64, 0.6)
            -- v:setEnabled(false)
            v.up = 1 --让牌墩的牌可以点下来
        end
    elseif code == 3 then
        self:removeHandCard(TempCards, self.pokerCards[self.userId])
        self:clearSelectedCards()
        self:btnCancelPai_1Click()
        return
    end
    self:removeHandCard(TempCards, self.pokerCards[self.userId])
    self:clearSelectedCards()
    self:initAllBtn()
    if table.nums(self.frontCards) == 3 then
        self:typeSelectCheck()
        local resiCount = table.nums(self.pokerCards[self.userId]) --最后一墩自动摆上去
        if #self.tailCards == 5 and #self.midCards ~= 5 then
            for i = 1, resiCount do
                self.selectedCards[i] = self.pokerCards[self.userId][i]
                self.selectedCards[i].isSelected = true
            end
            self:onPanelPai_2Click()
        elseif #self.midCards == 5 and #self.tailCards ~= 5 then
            for i = 1, resiCount do
                self.selectedCards[i] = self.pokerCards[self.userId][i]
                self.selectedCards[i].isSelected = true
            end
            self:onPanelPai_3Click()
        end
    end
end
--第二墩
function prototype:onPanelPai_2Click()
  --  log('222222222222222222222222222')
    if table.nums(self.selectedCards) == 0 then
     --   log('hh 0')
        return
    end
    if table.nums(self.midCards) == 5 then
       -- log('hh tip self.midCards full')
        return
    end

    local TempCards = {}
    for k, v in ipairs(self.selectedCards) do
        if table.nums(self.midCards) < 5 then
            table.insert(self.midCards, v)
            TempCards[#TempCards + 1] = v
        end
    end
    sys.sound:playEffect('OUT_CARD')
    self.midCards = self:sortSanDunPai(self.midCards) --整理摆好的牌
    local code = self:ComparePokerCard(2) --后墩必须大于前墩
   -- log('code 2 :' .. code)
    if code == 1 or code == 4 then
        for k, v in ipairs(self.midCards) do
            local pos = self:getOnPlaneCardPos(2, k)
            v:setPosition(pos)
            v:setScale(0.64, 0.6)
            v.up = 2
        end
    elseif code == 2 then --调整前墩大于后墩的牌型
        self.midCards, self.tailCards = self.tailCards, self.midCards
        for k, v in ipairs(self.midCards) do
            local pos = self:getOnPlaneCardPos(2, k)
            v:setPosition(pos)
            v:setScale(0.64, 0.6)
            v.up = 3
        end
        for k, v in ipairs(self.tailCards) do
            local pos = self:getOnPlaneCardPos(3, k)
            v:setPosition(pos)
            v:setScale(0.64, 0.6)
            v.up = 2
        end
    elseif code == 3 then
        self:removeHandCard(TempCards, self.pokerCards[self.userId])
        self:clearSelectedCards()
        self:btnCancelPai_2Click()
        return
    end
    self:removeHandCard(TempCards, self.pokerCards[self.userId])
    self:clearSelectedCards()
    self:initAllBtn()
    if table.nums(self.midCards) == 5 then
        self:typeSelectCheck()
        local resiCount = table.nums(self.pokerCards[self.userId])
        if #self.tailCards == 5 and #self.frontCards ~= 3 then
            for i = 1, resiCount do
                self.selectedCards[i] = self.pokerCards[self.userId][i]
                self.selectedCards[i].isSelected = true
            end
            self:onPanelPai_1Click()
        elseif #self.frontCards == 3 and #self.tailCards ~= 5 then
            for i = 1, resiCount do
                self.selectedCards[i] = self.pokerCards[self.userId][i]
                self.selectedCards[i].isSelected = true
            end
            self:onPanelPai_3Click()
        end
    end
end
--第三墩
function prototype:onPanelPai_3Click()
   -- log('333333333333333333333')
    if table.nums(self.selectedCards) == 0 then
    --    log('hh 0')
        return
    end

    if table.nums(self.tailCards) == 5 then
    --    log('hh tip tialCards full')
        return
    end

    local TempCards = {}
    for k, v in ipairs(self.selectedCards) do
        if table.nums(self.tailCards) < 5 then
            table.insert(self.tailCards, v)
            TempCards[#TempCards + 1] = v
        end
    end

    sys.sound:playEffect('OUT_CARD')
    self.tailCards = self:sortSanDunPai(self.tailCards) --整理摆好的牌
    local code = self:ComparePokerCard(3) --后墩必须大于前墩
  --  log('code 3 :' .. code)
    if code == 1 or code == 4 then
        for k, v in ipairs(self.tailCards) do
            local pos = self:getOnPlaneCardPos(3, k)
            v:setPosition(pos)
            v:setScale(0.64, 0.6)
            v.up = 3
        end
    elseif code == 3 then
        self:removeHandCard(TempCards, self.pokerCards[self.userId])
        self:clearSelectedCards()
        self:btnCancelPai_3Click()
        return
    elseif code == 2 then --调整前墩大于后墩的牌型
        self.midCards, self.tailCards = self.tailCards, self.midCards
        for k, v in ipairs(self.midCards) do
            local pos = self:getOnPlaneCardPos(2, k)
            v:setPosition(pos)
            v:setScale(0.64, 0.6)
            v.up = 2
        end
        for k, v in ipairs(self.tailCards) do
            local pos = self:getOnPlaneCardPos(3, k)
            v:setPosition(pos)
            v:setScale(0.64, 0.6)
            v.up = 3
        end
    --return
    end
    self:removeHandCard(TempCards, self.pokerCards[self.userId])
    self:clearSelectedCards()
    self:initAllBtn()
    if table.nums(self.tailCards) == 5 then
        self:typeSelectCheck()
        local resiCount = table.nums(self.pokerCards[self.userId])
        if #self.midCards == 5 and #self.frontCards ~= 3 then
            for i = 1, resiCount do
                self.selectedCards[i] = self.pokerCards[self.userId][i]
                self.selectedCards[i].isSelected = true
            end
            self:onPanelPai_1Click()
        elseif #self.frontCards == 3 and #self.midCards ~= 5 then
            for i = 1, resiCount do
                self.selectedCards[i] = self.pokerCards[self.userId][i]
                self.selectedCards[i].isSelected = true
            end
            self:onPanelPai_2Click()
        end
    end
end
--,后墩大于前墩 true
function prototype:ComparePokerCard(index)
  --  log('PCV: ComparePokerCard')
    --1.符合2.不符合,已经自动调整 3.不符合,无法调整 4.其他墩没有牌不用比较
    local virtualCards = {}
    local needCompare = false
    local content = ''
    local function creatVirtualCard(value, color)
        if value == nil or color == nil then
            return
        end
        local mCard = {}
        mCard.value = value
        mCard.color = color
        return mCard
    end
    if index == 3 then
        if table.nums(self.midCards) == 5 or table.nums(self.frontCards) == 3 then
            needCompare = true
        end
        if needCompare and table.nums(self.tailCards) == 5 then
            if table.nums(self.midCards) == 5 then
                local virtualCards1 = {}
                local virtualCards2 = {}
                for k, v in ipairs(self.midCards) do
                    virtualCards1[k] = creatVirtualCard(self.midCards[k].value, self.midCards[k].color)
                end
                for k, v in ipairs(self.tailCards) do
                    virtualCards2[k] = creatVirtualCard(self.tailCards[k].value, self.tailCards[k].color)
                end
                local code = self.ShisanshuiLogic:compareCard(virtualCards1, virtualCards2, 5, 5)
                if code == false then
                    ui.mgr:open('Dialog/DialogView', {content = '第二墩 大于 第三墩 已经自动调整'})
                    return 2
                end
            end
            if table.nums(self.frontCards) == 3 then
                local virtualCards1 = {}
                local virtualCards2 = {}
                for k, v in ipairs(self.frontCards) do
                    virtualCards1[k] = creatVirtualCard(self.frontCards[k].value, self.frontCards[k].color)
                end
                for k, v in ipairs(self.tailCards) do
                    virtualCards2[k] = creatVirtualCard(self.tailCards[k].value, self.tailCards[k].color)
                end
                local code = self.ShisanshuiLogic:compareCard(virtualCards1, virtualCards2, 3, 5)
                if code == false then
                    ui.mgr:open('Dialog/DialogView', {content = '第一墩 大于 第三墩 '})
                    return 3
                end
            end
            return 1
        end
    end

    if index == 2 then
        if table.nums(self.tailCards) == 5 or table.nums(self.frontCards) == 3 then
            needCompare = true
        end
        if needCompare and table.nums(self.midCards) == 5 then
            if table.nums(self.tailCards) == 5 then
                local virtualCards1 = {}
                local virtualCards2 = {}
                for k, v in ipairs(self.midCards) do
                    virtualCards1[k] = creatVirtualCard(self.midCards[k].value, self.midCards[k].color)
                end
                for k, v in ipairs(self.tailCards) do
                    virtualCards2[k] = creatVirtualCard(self.tailCards[k].value, self.tailCards[k].color)
                end
                local code = self.ShisanshuiLogic:compareCard(virtualCards1, virtualCards2, 5, 5)
                if code == false then
                    ui.mgr:open('Dialog/DialogView', {content = '第二墩 大于 第三墩 已经自动调整'})
                    return 2
                end
            end
            if table.nums(self.frontCards) == 3 then
                local virtualCards1 = {}
                local virtualCards2 = {}
                for k, v in ipairs(self.frontCards) do
                    virtualCards1[k] = creatVirtualCard(self.frontCards[k].value, self.frontCards[k].color)
                end
                for k, v in ipairs(self.midCards) do
                    virtualCards2[k] = creatVirtualCard(self.midCards[k].value, self.midCards[k].color)
                end
                local code = self.ShisanshuiLogic:compareCard(virtualCards1, virtualCards2, 3, 5)
                if code == false then
                    ui.mgr:open('Dialog/DialogView', {content = '第一墩 大于 第二墩 '})
                    return 3
                end
            end
            return 1
        end
    end

    if index == 1 then
        if table.nums(self.midCards) == 5 or table.nums(self.tailCards) == 5 then
            needCompare = true
        end
        if needCompare and table.nums(self.frontCards) == 3 then
            if table.nums(self.midCards) == 5 then
                local virtualCards1 = {}
                local virtualCards2 = {}
                for k, v in ipairs(self.frontCards) do
                    virtualCards1[k] = creatVirtualCard(self.frontCards[k].value, self.frontCards[k].color)
                end
                for k, v in ipairs(self.midCards) do
                    virtualCards2[k] = creatVirtualCard(self.midCards[k].value, self.midCards[k].color)
                end
                local code = self.ShisanshuiLogic:compareCard(virtualCards1, virtualCards2, 3, 5)
                if code == false then
                    ui.mgr:open('Dialog/DialogView', {content = '第一墩 大于 第二墩'})
                    return 3
                end
            end
            if table.nums(self.tailCards) == 5 then
                local virtualCards1 = {}
                local virtualCards2 = {}
                for k, v in ipairs(self.frontCards) do
                    virtualCards1[k] = creatVirtualCard(self.frontCards[k].value, self.frontCards[k].color)
                end
                for k, v in ipairs(self.tailCards) do
                    virtualCards2[k] = creatVirtualCard(self.tailCards[k].value, self.tailCards[k].color)
                end
                local code = self.ShisanshuiLogic:compareCard(virtualCards1, virtualCards2, 3, 5)
                if code == false then
                    ui.mgr:open('Dialog/DialogView', {content = '第一墩 大于 第三墩 '})
                    return 3
                end
            end
            return 1
        end
    end
    return 4
end
--是否开牌检查检查
function prototype:typeSelectCheck()
   -- log('PCV: typeSelectCheck')
    if table.nums(self.frontCards) == 3 and table.nums(self.midCards) == 5 and table.nums(self.tailCards) == 5 then
        self.btnCancel:setVisible(true)
        self.btnConfirm:setVisible(true)
    else
        self.btnCancel:setVisible(false)
        self.btnConfirm:setVisible(false)
    end
end
--牌墩清空第一墩取消
function prototype:btnCancelPai_1Click()
   -- log('PCV: 444444444444')
    if #self.frontCards == 0 then
        return
    end

    local callback = function()
        self:addHandCard(self.frontCards, self.pokerCards[self.userId])
        self.noNeedAutoSelect=true
        self.frontCards = {}
        self:initAllBtn()
        self:typeSelectCheck()
    end

    self:seeSpecialAction(false, true)--标志消失,跑马灯动画取消
    sys.sound:playEffect('OUT_CARD')
    for k, v in ipairs(self.frontCards) do
        v:setScale(0.8)
        v.up = 0
        v:setIsSelected(false)
        callback()
    end
end
function prototype:btnCancelPai_2Click()
   -- log('PCV: 55555555555')
    if #self.midCards == 0 then
        return
    end
    local callback = function()
        self:addHandCard(self.midCards, self.pokerCards[self.userId])
        self.noNeedAutoSelect=true
        self.midCards = {}
        self:initAllBtn()
        self:typeSelectCheck()
    end
    self:seeSpecialAction(false, true)
    --标志消失,跑马灯动画取消
    sys.sound:playEffect('OUT_CARD')
    for k, v in ipairs(self.midCards) do
        v:setScale(0.8)
        v.up = 0
        v:setIsSelected(false)
        callback()
    end
end
function prototype:btnCancelPai_3Click()
 --   log('PCV: 666666666666')
    if #self.tailCards == 0 then
        return
    end
    local callback = function()
        self:addHandCard(self.tailCards, self.pokerCards[self.userId])
        self.noNeedAutoSelect=true
        self.tailCards = {}
        self:initAllBtn()
        self:typeSelectCheck()
    end
    self:seeSpecialAction(false, true)
    sys.sound:playEffect('OUT_CARD')
    for k, v in ipairs(self.tailCards) do
        --[[ local action = cc.Sequence:create(
            cc.ScaleTo:create(0,0.8),
			cc.MoveTo:create(0.4,cc.p(v.oldPosition)),
             cc.CallFunc:create(callback)
			) 
        v:runAction(action)]]
        v:setScale(0.8)
        --  v:setPosition(cc.p(v.oldPosition))
        --v:setEnabled(true)
        v.up = 0
        v:setIsSelected(false)
        callback()
    end
end


function prototype:findRealCard(VirtualCard, RealCard)
   -- log('PCV: findRealCard')
    local RealCards = {}
    for i = 1, table.nums(VirtualCard) do
        for j = 1, table.nums(RealCard) do
            if VirtualCard[i].value == RealCard[j].value and VirtualCard[i].color == RealCard[j].color then
                RealCards[i] = RealCard[j]
            end
        end
    end
    return RealCards
end

function prototype:onBtnHelp(helpID)
   -- log('PCV: onBtnHelp')
    self:clearSelectedCards()
    local CardResult = self.SortRecord[helpID]
    if CardResult.bTag == false then
        return
    end
    local cardList = CardResult.list
    --dump(cardList,"cardList")
    local cardCount = table.nums(cardList)
    --log('hava ' .. cardCount .. ' ge')
    if cardCount == 0 then
        return
    end
    if self.allBtnFlush == true then-- 牌刷新后,重新调整
        self.allBtnFlush = false
        self.allBtnNum[helpID] = 1
    else
        self.allBtnNum[helpID] = self.allBtnNum[helpID] + 1
    end

    local count = self.allBtnNum[helpID]
    if self.allBtnNum[helpID] > cardCount then
        self.allBtnNum[helpID] = 0 --没有触发刷新设置为0,上面加了一
        local tempTableJ = self:findRealCard(cardList[count - 1], self.pokerCards[self.userId]) --最后一次全部落下
        for k, v in ipairs(tempTableJ) do
            if v:getIsSelected() == true then
                v:setIsSelected(false)
            end
        end
        return
    end
    count = self.allBtnNum[helpID]
    local tempTableJ = self:findRealCard(cardList[count], self.pokerCards[self.userId])
    for k, v in ipairs(tempTableJ) do
        if v:getIsSelected() == false then
            v:setIsSelected(true, cc.p(0, 25))
            table.insert(self.selectedCards, v)
        end
    end
    tempTableJ = {}
end
--对子
function prototype:onBtnDuiZiClick()
   -- log('PCV: dui zi')
    self:onBtnHelp(1)
end
--两对
function prototype:onBtnLiangDuiClick()
   -- log('PCV: Liang dui ')
    self:onBtnHelp(2)
end
-- 三条
function prototype:onBtnSanTiaoClick()
   -- log('PCV: San tiao ')
    self:onBtnHelp(3)
end
-- 顺子
function prototype:onBtnShunZiClick()
  --  log('PCV: Shun zi ')
    self:onBtnHelp(4)
end
-- 同花
function prototype:onBtnTongHuaClick()
   -- log('PCV: Tong hua ')
    self:onBtnHelp(5)
end
-- 葫芦
function prototype:onBtnHuLuClick()
   -- log('PCV: hu lu')
    self:onBtnHelp(6)
end
-- 铁支
function prototype:onBtnTieZhiClick()
  --  log('PCV: Tie zhi')
    self:onBtnHelp(7)
end
-- 同花顺
function prototype:onBtnTongHuaShunClick()
   -- log('PCV: Tong hua ')
    self:onBtnHelp(8)
end
-- 五同
function prototype:onBtnWuTongClick()
   -- log('PCV: no implements')
end
-- 特殊牌
function prototype:onBtnTeShuPaiClick() --teshupai
   -- log("PCV: onBtnTeShuPaiClick")
    if self.SpecialCardType == ShiSanShui_pb.NOT_SPECIALTYPE then
        return
    end
    
    self:btnCancelPai_3Click() -- 牌归位
    self:btnCancelPai_1Click()
    self:btnCancelPai_2Click()
    --[[for k,v in ipairs(self.SpecialCard)do
        for k2,v2 in ipairs(v)do
            log("k "..k.."v "..v2.value)
        end
    end]]
    self.selectedCards = self:findRealCard(self.SpecialCard[2], self.pokerCards[self.userId])
    for k, v in ipairs(self.selectedCards) do
        v.isSelected = true
    end
    self:onPanelPai_2Click()
    self.selectedCards = self:findRealCard(self.SpecialCard[3], self.pokerCards[self.userId])
    --[[for k,v in ipairs(self.SpecialCard[3])do
            log(v.value)
        end]]
    for k, v in ipairs(self.selectedCards) do
        v.isSelected = true
    end
    self:onPanelPai_3Click()
    self:seeSpecialAction(true, true)
    self.sendSpecialCardType = self.SpecialCardType
    self:initAllBtn()
end
function prototype:seeSpecialAction(seeEff, seePMD)
   -- log('PCV: seeSpecialAction')
    if self.SpecialCardType == ShiSanShui_pb.NOT_SPECIALTYPE then
        return
    end
    if self['sprPMD'] == nil then
        return
    end
    if seePMD == true then
        self['sprPMD']:setVisible(true)
        self['sprPMD']:resume()
    else
        self['sprPMD']:setVisible(false)
        self['sprPMD']:pause()
    end
    if seeEff == true then
        self.panelEff1:setVisible(true)
    else
        self.panelEff1:setVisible(false)
    end
    if seeEff==false or  seePMD==false then
        self.sendSpecialCardType = ShiSanShui_pb.NOT_SPECIALTYPE
    end
end
--大小和花色排序
function prototype:onBtnSort() --反向操作,展示将要进行的状态,UI和实际操作相反
   -- log("PCV: onBtnSort")
    if self.onBtnSortDaXiao == true then
        self.imgDaXiao:setVisible(true)
        self.imgHuaSe:setVisible(false)
        self.onBtnSortDaXiao = false
    else
        self.imgHuaSe:setVisible(true)
        self.imgDaXiao:setVisible(false)
        self.onBtnSortDaXiao = true
    end
    self:initAllBtn()
end

--确定按钮
function prototype:onBtnConfirmClick()
   -- log('PCV: onBtnConfirmClick')
    --log('Game.CalcResult go')
    local data = {}
    data.frontCardInfo = self.frontCards
    data.midCardInfo = self.midCards
    data.tailCardInfo = self.tailCards
    data.specialCardInfo = self.sendSpecialCardType
   -- log('send specialCard========== ' .. self.sendSpecialCardType)
    self:fireUIEvent('Game.CalcResult', data)
    self.btnCancel:setVisible(false)
    self.btnConfirm:setVisible(false)
    self:seeSpecialAction(false, false)
    self:seePokerCardView(false)
end
--取消按钮
function prototype:onBtnCancelClick()
   -- log('PCV: onBtnCancelClick')
    --log('hello hh')
    self:btnCancelPai_3Click() -- 牌归位
    self:btnCancelPai_1Click()
    self:btnCancelPai_2Click()
    if self.btnCancel and self.btnConfirm then
        self.btnCancel:setVisible(false)
        self.btnConfirm:setVisible(false)
    end
end
