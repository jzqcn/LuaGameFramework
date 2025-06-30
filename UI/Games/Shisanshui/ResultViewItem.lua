module(..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
end

function prototype:refresh(info, index)
    --log(info)

    local resultCoin = info.memStateInfo.betResultCoin or 0

    self.txtName:setString(Assist.String:getLimitStrByLen(info.playerName))
    -- if util:getPlatform() == "win32" then
    -- 	sdk.account:getHeadImage(info.playerId, info.playerName, self.headIcon)
    -- else
    sdk.account:getHeadImage(info.playerId, info.playerName, self.headIcon, info.headimage)
    -- end

    self.txtId:setString(info.playerId)
    -- self.txtLeftNum:setString(tostring(#(info.memStateInfo.cards)))

    local currencyType = Model:get("Games/Shisanshui"):getCurrencyType()
    if currencyType == Common_pb.Score then
        self.txtResultValue:setString(tostring(resultCoin))
    else
        self.txtResultValue:setString(Assist.NumberFormat:amount2TrillionText(resultCoin))
    end
    

    -- self.txtBaseScore
    --[[if not Model:get("Games/Paodekuai"):getIsPlayBack() then
		self.txtBombNum:setString(tostring(info.memStateInfo.boomNum))
	else
		self.txtBombNum:setVisible(false)
	end]]
    if info.memStateInfo.isStarter then
        self.imgOwner:setVisible(true)
    else
        self.imgOwner:setVisible(false)
    end

    if resultCoin >= 0 then
        -- self.txtBaseScore:setTextColor(cc.c3b(255, 226, 129))
        -- self.txtLeftNum:setTextColor(cc.c3b(255, 226, 129))
        self.txtName:setTextColor(cc.c3b(255, 226, 129))
        self.txtId:setTextColor(cc.c3b(255, 226, 129))
        --self.txtBombNum:setTextColor(cc.c3b(255, 226, 129))
        self.txtResultValue:setTextColor(cc.c3b(255, 226, 129))
    else
        -- self.txtBaseScore:setTextColor(cc.c3b(124, 247, 255))
        -- self.txtLeftNum:setTextColor(cc.c3b(124, 247, 255))
        self.txtName:setTextColor(cc.c3b(217,217,217))
        self.txtId:setTextColor(cc.c3b(217,217,217))
        --self.txtBombNum:setTextColor(cc.c3b(124, 247, 255))
        self.txtResultValue:setTextColor(cc.c3b(217,217,217))
    end

    local cards = info.memStateInfo.cards
    --dump(cards,"cards")
    local card11=self:sortSanDunPai3({cards[1],cards[2],cards[3]})
    local card22=self:sortSanDunPai3({cards[4],cards[5],cards[6],cards[7],cards[8]})
    local card33=self:sortSanDunPai3({cards[9],cards[10],cards[11],cards[12],cards[13]})

    cards={card11[1],card11[2],card11[3],card22[1],card22[2],card22[3],card22[4],card22[5],card33[1],card33[2],card33[3],card33[4],card33[5]}
    if #cards > 0 then
        local name = ''
        local x, y = self.nodeCard_1:getPosition()
        for i, v in ipairs(cards) do
            name = 'nodeCard_' .. i
            if self[name] == nil then
                self[name] = self:getLoader():loadAsLayer('Games/Common/GamePokerCard')
                -- self[name]:setAnchorPoint(cc.p(0.5, 0.5))
                self.rootNode:addChild(self[name])
            end

            self[name]:setCardInfo(info.playerId, v)
            self[name]:showCardValue()
            self[name]:setScale(0.4)
            if info.memStateInfo.isBonus == true then
                local bonusCard = info.memStateInfo.virtualBonusCard
                if bonusCard.color == self[name]:getCardColor() and bonusCard.value == self[name]:getCardValue() then
                    local sprBonusCard = cc.Sprite:create('resource/csbimages/Games/Shisanshui/horseCard.png')
                    sprBonusCard:setAnchorPoint(cc.p(0, 0)):setScale(1.5):setGlobalZOrder(20)
                    self[name]:addChild(sprBonusCard)
                end
            end
			if i == 5 and info.memStateInfo.specialType ~= 0 and info.memStateInfo.specialType ~= nil then
                local sprSpecialCard = cc.Sprite:create('resource/csbimages/Games/Shisanshui/specialType/img100_11.png')
                sprSpecialCard:setAnchorPoint(cc.p(0, 0)):setScale(2):setGlobalZOrder(10)
                self[name]:addChild(sprSpecialCard)
            end
            if i == 4 then
                x = x + 60
            end
            if i == 9 then
                x = x + 60
            end
            self[name]:setPosition(x + (i - 1) * 30, y)
        end
    end
    --[[local roomInfo = Model:get("Games/Paodekuai"):getRoomInfo()
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
    ]]
    self:playAction(index)
end

function prototype:playAction(index)
    local function actionOver()
        self.action:dispose()
        self.action = nil
    end

    -- self.rootNode:setVisible(false)

    local action = self:createListItemBezierConfig(self.rootNode, actionOver, 0.5, 0.15 + 0.1 * index)
    self.action = action
end

function prototype:sortSanDunPai3(temp)
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
        table.insert(cbSortValue, i, temp[i].size)
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
        if temp[i].size == temp[i + 1].size then
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
    if temp[#temp - 1].size ~= temp[#temp].size then
        -- 最后一个数没有比较
        table.insert(tempsin, temp[#temp])
    else
        table.insert(tempdou, temp[#temp])
    end
    if table.nums(tempdou) == 5 and tempdou[2].size ~= tempdou[3].size then
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