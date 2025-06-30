module(..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
end

function prototype:refresh(info, index)
    --log(info)
    if info.isPlayBack then
        self:showPlaybackResult(info, index)
        return
    end

    for k,v in ipairs(info)do
        local itemNode=string.format("itemNode_%d",k)
        self[itemNode]:setVisible(true)
        local resultCoin = v.memStateInfo.betResultCoin or 0
        local resultBet= v.memStateInfo.betCoin or 0
        self[itemNode].txtName:setString(Assist.String:getLimitStrByLen(v.playerName))
        sdk.account:getHeadImage(v.playerId, v.playerName, self[itemNode].headIcon, v.headimage)
        self[itemNode].txtId:setString(v.playerId)
        self[itemNode].txtResultValue:setString(Assist.NumberFormat:amount2Hundred(resultCoin))
        if v.memStateInfo.isDealer==false then
            self[itemNode].txtResultBet:setString(Assist.NumberFormat:amount2Hundred(resultBet))
        else
            self[itemNode].txtResultBet:setString("")
        end
        if v.NoSeeTxtResultBet ~=nil then
            self[itemNode].txtResultBet:setString("")
        end
        if v.memStateInfo.isDealer then
            self[itemNode].imgDealer:setVisible(true)
        else
            self[itemNode].imgDealer:setVisible(false)
        end
        if v.memStateInfo.isStarter then
            self[itemNode].imgOwner:setVisible(true)
        else
            self[itemNode].imgOwner:setVisible(false)
        end
        if resultCoin >= 0 then
            self[itemNode].txtName:setTextColor(cc.c3b(255, 226, 129))
            self[itemNode].txtId:setTextColor(cc.c3b(255, 226, 129))
            self[itemNode].txtResultValue:setTextColor(cc.c3b(255, 226, 129))
            self[itemNode].txtResultBet:setTextColor(cc.c3b(255, 226, 129))
        else
            self[itemNode].txtName:setTextColor(cc.c3b(124, 247, 255))
            self[itemNode].txtId:setTextColor(cc.c3b(124, 247, 255))
            self[itemNode].txtResultValue:setTextColor(cc.c3b(124, 247, 255))
            self[itemNode].txtResultBet:setTextColor(cc.c3b(124, 247, 255))
        end
        local cards = v.memStateInfo.cards
        local cardNums=#cards
        if cardNums > 0 then
            local name = ''
            local x, y = self[itemNode].nodeCard_1:getPosition()
            for i, v1 in ipairs(cards) do
                name =string.format("nodeCard_%d_%d",k,i)
                if self[name] == nil then
                    self[name] = self:getLoader():loadAsLayer('Games/Common/GamePokerCard')
                    -- self[name]:setAnchorPoint(cc.p(0.5, 0.5))
                    self[itemNode].rootNode:addChild(self[name])
                end
                self[name]:setCardInfo(v.playerId, v1)
                self[name]:showCardValue()
                self[name]:setScale(0.4)
                self[name]:setPosition(x + (i - 1) * 30, y)
                local resultDesc=v.memStateInfo.resultDesc
                if i == 1 and resultDesc ~= nil then
                    local strPokerCard=string.format('resource/Mushiwang/csbimages/pokeType_%d.png',resultDesc)
                    local sprSpecialCard = cc.Sprite:create(strPokerCard)
                    sprSpecialCard:setAnchorPoint(0,0.5):setScale(0.8):setLocalZOrder(10)
                    local x,y=self[name]:getPosition()
                    sprSpecialCard:setPosition(cc.p(x, y+20))
                    self[itemNode].rootNode:addChild(sprSpecialCard)
                    local mutiple=v.memStateInfo.mutiple
                    local resMutipleName=nil
                    if  mutiple ~=nil then
                        if resultDesc>=10 then
                            resMutipleName=string.format( "resource/Mushiwang/csbimages/mumType_%d.png",mutiple)
                        else
                            resMutipleName=string.format( "resource/Mushiwang/csbimages/mum2Type_%d.png",mutiple)
                        end
                        local smp=cc.Sprite:create(resMutipleName)
                        smp:setAnchorPoint(0,0.5):setScale(0.8):setLocalZOrder(10)
                        if resultDesc<12 then
                            smp:setPosition(cc.p(x+60, y+20))
                        else
                            smp:setPosition(cc.p(x+90, y+20))
                        end
                        self[itemNode].rootNode:addChild(smp)
                        if   resultDesc==0 then
                            smp:setVisible(false)
                        end
                    end
                end
               
            end
        end
    end
    self:playAction(index)
end

function prototype:showPlaybackResult(info, index)
    if not info or #info == 0 then
        return
    end

    for i = 1, 2 do
        if i > #info then
            self["itemNode_" .. i]:setVisible(false)
        else
            self["itemNode_" .. i]:setVisible(true)
        end

        self["itemNode_" .. i]:refresh(info[i])
    end

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
