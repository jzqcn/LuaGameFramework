module(..., package.seeall)

prototype = Controller.prototype:subclass()

local POKER_COLOR = 
{
	Block = 1,
	Plum = 2,
	Red = 3,
	Spade = 4,
	Evil = 5,
}

local POKER_SIZE = 
{
	C0 = 0,
	CA = 1,
	C2 = 2,
	C3 = 3,
	C4 = 4,
	C5 = 5,
	C6 = 6,
	C7 = 7,
	C8 = 8,
	C9 = 9,
	C10 = 10,
	CJ = 11,
	CQ = 12,
	CK = 13,
	C14 = 14,
}

function prototype:enter()
end

function prototype:refresh(info, index)
	-- log(info)
    local resultCoin = tonumber(info.bp) or 0

    local memStateInfo = json.decode(info.result)

    local resultBet= memStateInfo.betCoin or 0

    self.txtName:setString(Assist.String:getLimitStrByLen(info.nickName))
    
    -- sdk.account:getHeadImage(info.playerId, info.nickName, self.headIcon, info.headImage)
    -- if self:existEvent('LOAD_HEAD_IMG') then
    --     self:cancelEvent('LOAD_HEAD_IMG')
    -- end
    sdk.account:loadHeadImage(info.playerId, info.nickName, info.headImage, 
        self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.headIcon)

    self.txtId:setString(info.playerId)

    self.txtResultValue:setString(Assist.NumberFormat:amount2Hundred(resultCoin))

    if memStateInfo.isDealer==false then
        self.txtResultBet:setString(Assist.NumberFormat:amount2Hundred(resultBet))
    else
        self.txtResultBet:setString("")
    end

    -- if v.NoSeeTxtResultBet ~=nil then
    --     self.txtResultBet:setString("")
    -- end

    if memStateInfo.isDealer then
        self.imgDealer:setVisible(true)
    else
        self.imgDealer:setVisible(false)
    end

    -- if memStateInfo.isStarter then
    --     self.imgOwner:setVisible(true)
    -- else
        self.imgOwner:setVisible(false)
    -- end

    if resultCoin >= 0 then
        self.txtName:setTextColor(cc.c3b(255, 226, 129))
        self.txtId:setTextColor(cc.c3b(255, 226, 129))
        self.txtResultValue:setTextColor(cc.c3b(255, 226, 129))
        self.txtResultBet:setTextColor(cc.c3b(255, 226, 129))
    else
        self.txtName:setTextColor(cc.c3b(124, 247, 255))
        self.txtId:setTextColor(cc.c3b(124, 247, 255))
        self.txtResultValue:setTextColor(cc.c3b(124, 247, 255))
        self.txtResultBet:setTextColor(cc.c3b(124, 247, 255))
    end

    local initCards = json.decode(info.initCards)

    local cards = initCards
    local cardNums=#cards
    if cardNums > 0 then
        local name = ''
        local x, y = self.nodeCard_1:getPosition()
        for i, v1 in ipairs(cards) do
            name = string.format("nodeCard_%d", i)
            if self[name] == nil then
                self[name] = self:getLoader():loadAsLayer('Games/Common/GamePokerCard')
                -- self[name]:setAnchorPoint(cc.p(0.5, 0.5))
                self.rootNode:addChild(self[name])
            end

            local node = {}
			node.color = POKER_COLOR[v1.color]
			node.size = POKER_SIZE[v1.size]
			node.id = v1.id

            self[name]:setCardInfo(info.playerId, node)
            self[name]:showCardValue()
            self[name]:setScale(0.4)
            self[name]:setPosition(x + (i - 1) * 30, y)

            local resultDesc = memStateInfo.resultDesc
            if i == 1 and resultDesc ~= nil then
                local strPokerCard=string.format('resource/Mushiwang/csbimages/pokeType_%d.png', resultDesc)
                local sprSpecialCard = cc.Sprite:create(strPokerCard)
                sprSpecialCard:setAnchorPoint(0,0.5):setScale(0.8):setLocalZOrder(10)

                local x,y = self[name]:getPosition()
                sprSpecialCard:setPosition(cc.p(x, y+20))
                self.rootNode:addChild(sprSpecialCard)
                local mutiple = memStateInfo.mutiple
                local resMutipleName=nil
                if  mutiple ~=nil then
                    if resultDesc >= 10 then
                        resMutipleName=string.format( "resource/Mushiwang/csbimages/mumType_%d.png",mutiple)
                    else
                        resMutipleName=string.format( "resource/Mushiwang/csbimages/mum2Type_%d.png",mutiple)
                    end

                    local smp=cc.Sprite:create(resMutipleName)
                    smp:setAnchorPoint(0,0.5):setScale(0.8):setLocalZOrder(10)
                    if resultDesc < 12 then
                        smp:setPosition(cc.p(x+60, y+20))
                    else
                        smp:setPosition(cc.p(x+90, y+20))
                    end
                    self.rootNode:addChild(smp)
                    if   resultDesc==0 then
                        smp:setVisible(false)
                    end
                end
            end
           
        end
    end
end

function prototype:onLoadHeadImage(filename)
    self.headIcon:loadTexture(filename)
end

function prototype:playAction(index)
    local function actionOver()
        self.action:dispose()
        self.action = nil
    end
    local action = self:createListItemBezierConfig(self.rootNode, actionOver, 0.5, 0.15 + 0.1 * index)
    self.action = action
end
