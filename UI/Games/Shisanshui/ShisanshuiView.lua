module(..., package.seeall)

prototype = Dialog.prototype:subclass()

local MAXPLAYER = 5

local Common_pb = Common_pb

function prototype:enter()
    self.winSize = cc.Director:getInstance():getWinSize()

    --UI事件
    self:bindUIEvent('Game.ChangeRoom', 'uiEvtChangeRoom')
    self:bindUIEvent('Game.Ready', 'uiEvtReady')
    self:bindUIEvent('Game.Start', 'uiEvtStart')
    self:bindUIEvent('Game.CalcResult', 'uiEvtCalcResult')
    self:bindUIEvent('Game.Clock', 'uiEvtClockFinish')
    self:bindUIEvent('Game.PlayerInfo', 'uiEvtPlayerInfo')
    self:bindUIEvent('Game.CopyRoomId', 'uiEvtCopyRoomId')
    self:bindUIEvent('Game.InviteFriend', 'uiEvtInviteFriend')
    self:bindUIEvent('Game.Distance', 'uiEvtShowDistance')
    self:bindUIEvent("Game.ReturnHall", "uiEvtReturnHall")
    --Model消息事件
    self:bindModelEvent('Games/Shisanshui.EVT.PUSH_ENTER_ROOM', 'onPushRoomEnter')
    self:bindModelEvent('Games/Shisanshui.EVT.PUSH_USER_READY', 'onPushUserReady')
    self:bindModelEvent('Games/Shisanshui.EVT.PUSH_MEMBER_STATUS', 'onPushMemberStatus')
    self:bindModelEvent('Games/Shisanshui.EVT.PUSH_ROOM_STATE', 'onPushRoomState')
    self:bindModelEvent('Games/Shisanshui.EVT.PUSH_ROOM_DRAW', 'onPushRoomDraw')
    self:bindModelEvent('Games/Shisanshui.EVT.PUSH_ROOM_DEAL', 'onPushRoomDeal')
    self:bindModelEvent('Games/Shisanshui.EVT.PUSH_OPEN_DEAL', 'onPushOpenDeal')
    self:bindModelEvent('Games/Shisanshui.EVT.PUSH_OPEN_DEAL_RESULT', 'onPushOpenDealResult')
    self:bindModelEvent('Games/Shisanshui.EVT.PUSH_SETTLEMENT', 'onPushSettlement')
    self:bindModelEvent("GamePerformance.EVT.PUSH_GAME_PERFORMANCE", "onPushGamePerformance")

    self.nodeBroadcast:setVisible(false)
    self.nodeRoomInfo:setVisible(false)
    self.nodeStart:setVisible(false)
    self.nodeInvite:setVisible(false)

    self.nodeMenu:setModelName('Games/Shisanshui')

    self.modelData = Model:get('Games/Shisanshui')
    self.nodeChat:setModelData(self.modelData)

    self.userId = Model:get('Account'):getUserId()
    self.gameStarthh = true
    self.gameOverhh = true
    self:onPushRoomEnter()
    self.compareCard = {}
    self.bSpecialType = {}
    self.scoreAll = {}
    self.specialAction = {'a1ssz', 'a1sth', 'a1ldb', 'a1ldb', 'a1siftx', 'a1sanftx', 'a1sths', 'yitiaolong', 'qinglong'}
    --1;//三顺子2;//三同花 3;//六对半4;//五对冲三5;//四套三条6;//三套炸弹-三分天下 7;//三同花顺8;//十三水 9;//同花十三水
    --{a1ldb,六对半 a1qld,全雷达 a1sb2 失败,a1sl2,胜利 a1ssz,三顺子 a1sth. 三同花 a1sths. 三同顺子}
    sys.sound:playMusicByFile('resource/audio/ShiSanShui/bg_music.mp3')
end

function prototype:gameClear()
    -- log('SV: gameClear')
    for i = 1, MAXPLAYER do
        local name1 = 'nodeRole_' .. tostring(i)
        -- local name2 = "imgReady_"..tostring(i)
        self[name1]:setVisible(false)
        -- self[name2]:setVisible(false)

        -- self["fontBet_"..i]:setVisible(false)
    end

    -- self:clearPokerCards()

    --self.nodeClock:setVisible(false)
    --self.nodeClock:stop()
    self.nodeStart:setVisible(false)
    self.nodeReady:hide()
    -- log("self.nodeReady====================")
    -- log("self.nodeStart====================")
end

function prototype:clearPlayerData(seatIndex, id)
    -- log('SV: clearPlayerData')
    self['nodeRole_' .. seatIndex]:setVisible(false)
    -- self["imgReady_"..seatIndex]:setVisible(false)
    -- log('clearPlayerData ' .. id)
    self.modelData:removeMemberById(id)
end

function prototype:clearPokerCards(id)
    -- log('SV: nodeDealResult')
    --self.nodePokerView:clearCards(id)
    for i = 1, MAXPLAYER do
        local name = 'nodeDealResult_' .. tostring(i)
        if self[name] then
            self[name]:setVisible(false)
        end
    end
end

function prototype:onPushRoomEnter()
    -- log('SV: onPushRoomEnter')
    self.gameState = ShiSanShui_pb.State_Begin
    
    self:gameClear()
    self:onPushRoomInfo()
    self:onPushRoomState()
    self:onPushMemberStatus()
    --qqqqqqqqqqqqqq
    --到这里self.roomStyle才生效
    local RoomState = self.modelData:getRoomState()
    local RoomMember = self.modelData:getRoomMember()
    local playerInfo = RoomMember[self.userId]

    --玩家处于围观，没有占座时，提示
    if playerInfo == nil then
        self.txtViewerTip:setVisible(true)
        self.txtViewerTip:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.8), cc.FadeIn:create(0.8))))
    else
        self.txtViewerTip:setVisible(false)
    end

    if RoomState == ShiSanShui_pb.State_Begin then
        -- log('Begin=========== restart')
        if self.modelData:isViewer() == false and self.roomStyle == Common_pb.RsCard then
            self:checkGameStart()
        end
    elseif RoomState == ShiSanShui_pb.State_OpenDeal or RoomState == ShiSanShui_pb.State_Deal then
        -- log('OpenDeal======== restart fa pai')
        if self.modelData:isViewer() == true then
            self.nodePokerView:seePokerCardView(false)
        end
        for id, v in pairs(RoomMember) do
            self:dealPokerCards(id, false)
        end

        if playerInfo and playerInfo.memStateInfo.isOpenDeal == true then
            self.nodePokerView:seeSelfPokerCards(false)
            self.nodePokerView:seePokerCardView(false)
        end
    elseif RoomState == ShiSanShui_pb.State_Settlement then
        -- log('Settlement========= restart ')
        if self.modelData:isViewer() == true then
            return
        end
        self:RestartsaveMemberInfo()
        self:settlementResult()
    end
end

function prototype:onPushRoomInfo()
    -- log('SV: onPushRoomInfo')
    local roomInfo = self.modelData:getRoomInfo()
    if roomInfo.roomStyle == Common_pb.RsGold then
		self.nodeChatToolbar:setVoiceVisible(false)
		self.nodeRoomInfo:setVisible(false)
		self.nodeInvite:setVisible(false)
	elseif roomInfo.roomStyle == Common_pb.RsCard then
        self.nodeChatToolbar:setVoiceVisible(true)
		self:updateRoomInfo()
	end
    
    self.roomStyle = roomInfo.roomStyle
end

--（房卡场）更新房间信息 :房间ID、底分、玩法等
function prototype:updateRoomInfo()
    --log('SV: updateRoomInfo')
    local roomInfo = self.modelData:getRoomInfo()
    local roomStateInfo=self.modelData:getRoomStateInfo()
    --dump(roomInfo,"roomInfo",5)
    --dump(roomStateInfo,"roomStateInfo",5)
    self.roomStyle = roomInfo.roomStyle
    if self.roomStyle == Common_pb.RsCard then--房卡场
        local info = {}
        --房间号默认4位，位数不够前面补充0
        table.insert(info, string.format('房间:%04d', roomInfo.roomId))
        table.insert(info, string.format('局数:%d/%d', roomInfo.currentGroup, roomInfo.groupNum))

        if self.chipRangeMsg == nil then
            local data = db.mgr:getDB("ShisanshuiCardConfig", {playId = roomInfo.playId, currencyType = roomInfo.currencyType})
            --dump(data,"data",5)
            if #data > 0 then
                local msg = data[1]["baseChipRange"]
                if msg then
                    local showStrTable = string.split(msg, ";")
                    if roomInfo.currencyType == Common_pb.Gold then
                        self.chipRangeMsg = string.format("底分:%s", Assist.NumberFormat:amount2Hundred(showStrTable[roomInfo.baseChipRange+1]))
                    else
                        self.chipRangeMsg = string.format("底分:%s", showStrTable[roomInfo.baseChipRange+1])
                    end
                    table.insert(info, self.chipRangeMsg)
                end
            end
        else
            table.insert(info, self.chipRangeMsg)
        end
        if  roomStateInfo.bonusCard and roomInfo.bonusCardSize~=-1  then 
            local strBonusCardSize=string.format("马牌:黑桃%s", roomInfo.bonusCardSize)
            table.insert(info, strBonusCardSize)
        end
        self.nodeRoomInfo:setRoomInfo(info)
        self.nodeRoomInfo:setVisible(true)
    end
end

function prototype:onPushRoomState()
   -- log('SV: onPushRoomState')
    local roomStateInfo = self.modelData:getRoomStateInfo()
    if roomStateInfo then
        local roomState = roomStateInfo.roomState
        local userInfo = self.modelData:getUserInfo()
        -- local StateStr = {
        --     'State_Begin no start game',
        --     'State_Ready',
        --     'State_Deal',
        --     'State_OpenDeal',
        --     'State_Settlement'
        -- }
        -- log('----onPushRoomState ' .. StateStr[roomState] .. ', countDown = ' .. roomStateInfo.countDown)

        if roomState == ShiSanShui_pb.State_Begin then
            -- self:visibleInviteNode(true)
            local menuLayer = ui.mgr:getLayer('Games/Common/MenuToolBarView')
            if menuLayer then
                menuLayer:refresh()
            end
            if roomStateInfo.countDown < 0 then
                self.nodeClock:setVisible(false)
                self.nodeClock:stop()
            end
        elseif roomState == ShiSanShui_pb.State_Ready then
            local RoomMember = self.modelData:getRoomMember()
            if table.nums(RoomMember)>2 then
                if roomStateInfo.countDown > 0 then
                    self.nodeClock:start(roomStateInfo.countDown, 0)
                else
                    self.nodeClock:setVisible(false)
                    self.nodeClock:stop()
                end
            end
            -- self:visibleInviteNode(true)
        elseif roomState == ShiSanShui_pb.State_Deal then
            self.nodeClock:setVisible(false)
            self.nodeClock:stop()
            self.nodeReady:hide()
            for i = 1, MAXPLAYER do
                self['nodeRole_' .. i]:setReadyVisible(false)
            end
            -- self:visibleInviteNode(false)

        elseif roomState == ShiSanShui_pb.State_OpenDeal then
            -- self.nodePokerView:hideBackNode(false)
            self.nodePokerView.nodeClockDeal:start(roomStateInfo.countDown, 0)
            self.nodePokerView.nodeClockDeal:setPosition(844.8, 566.75)

        elseif roomState == ShiSanShui_pb.State_Settlement then 
            
        else

        end

        if userInfo ~= nil and self.modelData.roomInfo.roomStyle == Common_pb.RsCard and userInfo.playerId ==self.userId then
			self:updateRoomInfo()
		end

        --记录下roomState
        self.roomState = roomState
        if userInfo ~= nil and self.modelData.roomInfo.roomStyle == Common_pb.RsCard then
			if roomState > ShiSanShui_pb.State_Begin then
				self.nodeInvite:setVisible(false)
			else
				local maxNum = self.modelData:getMaxPlayerNum()
				local playerNum = table.nums(self.modelData:getRoomMember())
				if playerNum < maxNum then
					self.nodeInvite:setVisible(true)
				else
					self.nodeInvite:setVisible(false)
				end
			end
		end
    else
        assert(false)
    end
end

--游戏开始，扣除台费
function prototype:onPushRoomDraw()
    -- log('SV: onPushRoomDraw kou fei')
    --local roomInfo = self.modelData:getRoomInfo()
    --if roomInfo.dealerType ~= ShiSanShui_pb.TBNN then
    --开始动画
    --ui.mgr:open("Games/Shisanshui/StartView")

    --通比牛牛不需要抢庄
    --local delay = 1.0
    --[[local userInfo = self.modelData:getUserInfo()
		if userInfo.memStateInfo.isRequestSnatch == false then
			self.nodeSnatch:show(delay)
		else
			self.nodeSnatch:hide()
		end
        ]]
    --local roomStateInfo = self.modelData:getRoomStateInfo()
    --self.nodeReady:hide()
    -- self.nodeReady:show(true)
    --self.nodeReady:hideBtnRefreshLeft(true)
    --self.nodeClock:start(roomStateInfo.countDown,delay)
    --end

    self:onPushMemberStatus()
end

function prototype:onPushMemberStatus(data)
    -- log('SV: onPushMemberStatus')
    local roomMember = self.modelData:getRoomMember()
    local memsId = data or table.keys(roomMember)
    if memsId then
        local roomStateInfo = self.modelData:getRoomStateInfo()
        local roomState = roomStateInfo.roomState
        for i, id in ipairs(memsId) do
            local seatIndex = self.modelData:getPlayerSeatIndex(id)
            local playerInfo = roomMember[id]
            if playerInfo then
                if playerInfo.memberType ~= Common_pb.Leave then
                    local memStateInfo = playerInfo.memStateInfo
                    local headItemName = 'nodeRole_' .. seatIndex
                    --加入房间或者更新玩家数据
                    self[headItemName]:setVisible(true)
                    self[headItemName]:setHeadInfo(playerInfo, self.modelData:getCurrencyType())
                    self:updatePlayerState(playerInfo)

                    if playerInfo.memberType == Common_pb.Add then
                        sys.sound:playEffect('ENTER')
                    end
                else
                    --离开房间
                    if self.userId == id then
                        StageMgr:chgStage('Hall')
                    else
                        self:clearPlayerData(seatIndex, id)
                        sys.sound:playEffect('LEAVE')
                    end
                end
            end
        end
    end
end

function prototype:updatePlayerState(playerInfo)
    --log('SV: updatePlayerState')
    local id = playerInfo.playerId
    local seatIndex = self.modelData:getPlayerSeatIndex(id)
    local roomStateInfo = self.modelData:getRoomStateInfo()
    local roomState = roomStateInfo.roomState
    local memStateInfo = playerInfo.memStateInfo
    local RoomStates = {}
    RoomStates[1] = 'State_Begin'
    RoomStates[2] = 'State_Ready'
    RoomStates[3] = 'State_FaPai'
    RoomStates[4] = 'State_OpenDeal'
    RoomStates[5] = 'State_Settlement'
  --  log('------updatePlayerState : ' .. RoomStates[roomState] .. '  playerId == ' .. id)
    if roomState == ShiSanShui_pb.State_Begin or roomState == ShiSanShui_pb.State_Ready then--99999999999
        --self['nodeRole_' .. seatIndex]:setBetVisible(false)
        -- 
        --self:clearPokerCards()
        self.gameStarthh = true
        if id == self.userId and self.gameOverhh == true then
            if  self.roomStyle == Common_pb.RsGold then
                self.nodeReady:show(memStateInfo.isReady,true)
               -- log("self.nodeReady============")
            else
                self.nodeReady:show(memStateInfo.isReady)
                self.nodeReady:hideBtnRefreshLeft(true)
              --  log("self.nodeReady============")
            end
        end
        self['nodeRole_' .. seatIndex]:setReadyVisible(memStateInfo.isReady)
        self:checkGameStart()
    elseif roomState == ShiSanShui_pb.State_OpenDeal then
        if playerInfo['memStateInfo']['isViewer'] == false then
            if playerInfo['memStateInfo']['isOpenDeal'] == true then
                self:seeQiPao(true, seatIndex)
                local imgP = string.format('imgP_%d', seatIndex)
                local imgW = string.format('imgW_%d', seatIndex)
                self[imgP]:setVisible(false)
                self[imgW]:setVisible(true)
            else
                self:seeQiPao(true, seatIndex)
                local imgP = string.format('imgP_%d', seatIndex)
                local imgW = string.format('imgW_%d', seatIndex)
                self[imgP]:setVisible(true)
                self[imgW]:setVisible(false)
            end
            if playerInfo.memStateInfo.isBonus == true then
                local strBonus = string.format('imgHorseCard_%d', seatIndex) -- 马牌
                self[strBonus]:setVisible(true)
            end
        end
    elseif roomState == ShiSanShui_pb.State_Deal then
        self.nodeReady:hide()

       -- log("self.nodeReady====================")
        --[[if self.nodePokerView.pokerCards[self.userId] == nil  and memStateInfo.isViewer==false then
            self['nodeRole_' .. seatIndex]:setReadyVisible(false)
            self:dealPokerCards(id, false)
            self.nodeStart:setVisible(false)
        end]]
    elseif roomState == ShiSanShui_pb.State_Settlement then

    --log('State_Settlement                ')
    --self.nodePokerView.nodeClockDeal:stop()
    end
end

--UI事件：准备按钮点击
function prototype:uiEvtReady(data)
    --log('SV: uiEvtReady')
    local roomInfo = self.modelData:getRoomInfo()
    local currencyType = roomInfo.currencyType
    local userInfo = Model:get('Account'):getUserInfo()
    self.modelData:requestReady()
    self.modelData:setMemberReadyState(true, userInfo.userId)
    if self.roomStyle == Common_pb.RsGold then
        self.nodeReady:show(true, true)
       -- log("self.nodeReady============")
    else
        --self.nodeReady:show(true,true)
        self:checkGameStart()
     --   log("self.nodeReady============")
    end
end

--用户是否 ready
function prototype:onPushUserReady(isSuccess)
    --log('SV: onPushUserReady')
    local userInfo = self.modelData:getUserInfo()
    local roomStateInfo = self.modelData:getRoomStateInfo()
    if isSuccess then
        sys.sound:playEffect('READY')
        self.modelData:setMemberReadyState(true, userInfo.playerId)
        if roomStateInfo.roomState < ShiSanShui_pb.State_Deal then
            --无法保证消息顺序，可能发牌消息先发。
            local seatIndex = self.modelData:getPlayerSeatIndex(userInfo.playerId)
            self['nodeRole_' .. seatIndex]:setReadyVisible(true)
        --[[if self.roomStyle == Common_pb.RsGold then
             --self.nodeReady:show(true, true, 1)
             -- self.nodeReady:show(true)
            end]]

        self:checkGameStart()
        end
    else
        --if roomStateInfo.roomState < ShiSanShui_pb.State_Snatch then
        --self.nodeReady:show(false, self.roomStyle == Common_pb.RsGold)
        -- self.nodeReady:show(true)
        --self.nodeClock:start(roomStateInfo.countDown)
        --end
        self.modelData:setMemberReadyState(false, userInfo.playerId)
    end
end

--检查房卡场（计分场）是否可以开始游戏 房主提前开始
function prototype:checkGameStart()
    -- log('SV: =====================checkGameStart============================')
    --and self.modelData:getCurrencyType() == Common_pb.Score then
    if self.roomStyle == Common_pb.RsCard  and self.modelData:isStarter() then
        local roomInfo = self.modelData:getRoomInfo()
        if roomInfo.currentGroup == 1 then
            --第一局需要点击开始，后续按正常流程自动开始
            local canStart = true
            local roomMember = self.modelData:getRoomMember()
            local maxNum = self.modelData:getMaxPlayerNum()
            local minNum = self.modelData:getMinPlayerNum()
            local memNum = table.nums(roomMember)
            if memNum >= minNum and memNum < maxNum then
                for _, v in pairs(roomMember) do
                    if v.memStateInfo.isReady == false then
                        canStart = false
                        break
                    end
                end
            else
                canStart = false
            end

            if canStart then
                self.nodeStart:setVisible(true)
                -- log("self.nodeStart====================")
            end
        else
            --self.modelData:requestCommonMsg(ShiSanShui_pb.Request_Start)
        end
    end
end
--返回大厅
function prototype:uiEvtReturnHall()
	StageMgr:chgStage("Hall", "Shisanshui")
end

--是否显示邀请好友
function prototype:visibleInviteNode(visible)
    -- log('SV: visibleInviteNode')
    if self.modelData:getRoomStyle() == Common_pb.RsCard and visible then
        local roomMember = self.modelData:getRoomMember()
        local maxNum = self.modelData:getMaxPlayerNum()
        local memNum = table.nums(roomMember)
        if memNum < maxNum then
            self.nodeInvite:setVisible(true)
        else
            self.nodeInvite:setVisible(false)
        end
    else
        self.nodeInvite:setVisible(false)
    end
end

--房卡场人未满时，玩家都准备，房主可以提前开始游戏
function prototype:uiEvtStart()
    -- log('SV: uiEvtStart roomcard gameStart')
    self.modelData:requestCommonMsg(ShiSanShui_pb.Request_Start)
    self.nodeStart:setVisible(false)
    -- log("self.nodeStart====================")
end

--倒计时结束
function prototype:uiEvtClockFinish()
    -- log('SV: uiEvtClockFinish clock time')
    --self.nodeBetLayer:setVisible(false)
end

function prototype:uiEvtChangeRoom()
    -- log('SV: uiEvtChangeRoom')
    Model:get('Games/Shisanshui'):requestChangeRoom()
end

--发牌
function prototype:onPushRoomDeal(data)
    -- log('SV: onPushRoomDeal')
    self:onPushRoomState()
    if self.nodePokerView.pokerCards[self.userId] == nil then
        local roomMember = self.modelData:getRoomMember()
        -- log(roomMember)
        if roomMember[self.userId] then
            for i, id in ipairs(data) do --发牌动画
                self:dealPokerCards(id, true)
            end
        else
            --不占座围观状态，发牌的时候都是背面的
            for id, v in pairs(roomMember) do
                v.memStateInfo.cards = {false, false, false, false, false, false, false, false, false, false, false, false, false}
                self:dealPokerCards(id, true)
            end
        end
    end
end

--发牌 fa pai
function prototype:dealPokerCards(playerId, isAnimation)
    -- log('SV: dealPokerCards')
    self.nodePokerView:setVisible(true)
    local roomMember = self.modelData:getRoomMember()
    local playerInfo = roomMember[playerId]
    if playerInfo == nil then
        log4ui:warn('[SV::dealPokerCards] error : get player info failed ! playerId : ' .. playerId)
        return
    end
    local seatIndex = self.modelData:getPlayerSeatIndex(playerId)
    local centerPos = cc.p(self.winSize.width / 2, self.winSize.height / 2)
    local memStateInfo = playerInfo.memStateInfo
    local bonusCard = self.modelData:getRoomStateInfo().bonusCard --马牌
    local cards = memStateInfo.cards
    for i, v in ipairs(cards) do
        local cardNode = self.nodePokerView:createPokerCard(playerId, i)
        if cardNode then
            local scale = 0.8
            -- if playerId ~= self.userId then
            if seatIndex ~= 1 then --不占座围观的时候，坐前面位置的不是自己
                scale = 0.4
            end
            local size = cc.size(cardNode:getContentSize().width * scale, cardNode:getContentSize().height * scale)
            local to = self:getCardDealPos(seatIndex, i, size)
            cardNode:setCardInfo(playerId, v)
            if memStateInfo.isBonus then
                if playerId == self.userId and bonusCard.color == cardNode:getCardColor() and bonusCard.size == cardNode:getCardValue() then -- 底部牌添加马牌hhhh
                    local sprBonusCard = cc.Sprite:create('resource/csbimages/Games/Shisanshui/horseCard.png')
                    sprBonusCard:setAnchorPoint(cc.p(0, 0)):setScale(1.5)
                    cardNode:addChild(sprBonusCard)
                end
            end
            cardNode:runDealAction(centerPos, to, scale, (i - 1) * 0.05, isAnimation)
            if playerId~=self.userId then
                cardNode:hideCardValue()
            end
        else
            log4ui:warn('[SV::dealPokerCards] error : playerId:' .. playerId .. ', card index:' .. i)
        end
    end

    if isAnimation then
        sys.sound:playEffect('DEAL_LONG')
        self['nodeRole_' .. seatIndex]:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(1.3),
                cc.CallFunc:create(
                    function()
                        self:dealActionOver(playerId)
                    end
                )
            )
        )
    elseif memStateInfo.cardCount > 0 then
        self:dealActionOver(playerId)
    end
end

--发牌的位置
function prototype:getCardDealPos(seatIndex, index, size)
    local pos = cc.p(0, 0)
    if seatIndex == 1 then --牌排序时,重置了坐标
        pos = self.nodePokerView:getDealCardPos(index, size)
    elseif seatIndex == 2 then
        --[[pos.x = 1100+ size.width/2 
		pos.y = 290 + size.height/2]]
        local p = self.nodeRole_2:getHeadPos()
        pos.x = p.x - 80
        pos.y = p.y + 10
    elseif seatIndex == 3 then
        local p = self.nodeRole_3:getHeadPos()
        pos.x = p.x - 80
        pos.y = p.y + 10
    elseif seatIndex == 4 then
        local p = self.nodeRole_4:getHeadPos()
        pos.x = p.x + 78
        pos.y = p.y + 10
    end
    return pos
end

function prototype:seeQiPao(visibale, index) --气泡显示其他人是否已摆好牌
    local imgQiPao = string.format('imgQiPao_%d', index)
    if self[imgQiPao] ~= nil then
        self[imgQiPao]:setVisible(visibale)
    end
end

--发牌动画结束
function prototype:dealActionOver(playerId)
    -- log('SV: dealActionOver fa pai over')
    local playerInfo = self.modelData:getMemberInfoById(playerId)
    if playerInfo then
        local seatIndex = self.modelData:getPlayerSeatIndex(playerId)
        if playerInfo.memStateInfo.isViewer == false then --不是旁观者时
            self:seeQiPao(true, seatIndex)
        end
        if playerInfo.memStateInfo.isBonus == true then
            local strBonus = string.format('imgHorseCard_%d', seatIndex) -- 马牌
            self[strBonus]:setVisible(true)
        end
    end
    if playerId ~= self.userId then --发别人的牌也会调用这里
        return
    end
    self.nodePokerView:seePokerCardView(true)
    self.nodePokerView:initSpecialBtn()
    self.nodePokerView:initAllBtn()
end

--摆牌结束
function prototype:uiEvtCalcResult(data)
    -- log('SV: uiEvtCalcResult bai pai over')
    self.modelData:requestOpenDeal(data)
    self.resultCards={}
    self.resultCards={data.frontCardInfo,data.midCardInfo,data.tailCardInfo}
    --自己的牌可见
end

function prototype:onPushOpenDeal(isSuccess)
    -- log('SV: onPushOpenDeal')
    -- if isSuccess then
    --     log('ming pai yes')
    -- else
    --     log('ming pai no')
    -- end
end

--摆牌结果
function prototype:onPushOpenDealResult(data)
    -- log('SV: onPushOpenDealResult')
    --[[for i, id in ipairs(data) do
		self:dealOpenDealCards(id, false)
	end]]
    -- log('ming ping Result playID' .. data.playerId)
end

--faaaaaaaaaaaa
function prototype:settlementDealPokerCards(m_playerId, m_seatIndex, m_CardInfo)
    -- log('SV: settlementDealPokerCards')
    local cards = m_CardInfo
    local cardsCount = 1
    local cardInfo = {{}, {}, {}}
    for i, v in ipairs(cards) do
        for k1, v1 in ipairs(cards[i]) do
            local cardNode = self.nodePokerView:createPokerCard(m_playerId, cardsCount)
            cardsCount = cardsCount + 1
            if cardNode then
                local scale = 0.5
                local size = cc.size(cardNode:getContentSize().width * scale, cardNode:getContentSize().height * scale)
                local to = self:getCardResultPos(m_seatIndex, k1, size)
                if i == 1 then
                    to.x = to.x + 50
                elseif i == 2 then
                    to.y = to.y - 56
                elseif i == 3 then
                    to.y = to.y - 112
                end
                cardNode:setCardInfo(m_playerId, v1)
                cardNode:runDealAction(cc.p(0, 0), to, scale, 0, false)
                cardNode:hideCardValue()
                cardNode:setEnabled(false)
                cardInfo[i][k1] = cardNode
            else
                log4ui:warn('[SV::dealPokerCards] error : playerId:' .. playerId .. ', card index:' .. i)
            end
        end
    end
    self.compareCard[m_playerId] = cardInfo
end

function prototype:getCardResultPos(seatIndex, index, size)
    local pos = cc.p(0, 0)
    if seatIndex == 1 then
        pos.x = 187 + size.width / 2 + (index - 1) * 43
        pos.y = 280 + size.height / 2
    elseif seatIndex == 2 then
        local p = self.nodeRole_2:getHeadPos()
        pos.x = p.x - 530 + size.width / 2 + (index - 1) * 43
        pos.y = p.y
    elseif seatIndex == 3 then
        local p = self.nodeRole_3:getHeadPos()
        pos.x = p.x - 530 + size.width / 2 + (index - 1) * 43
        pos.y = p.y + 57
    elseif seatIndex == 4 then
        local p = self.nodeRole_4:getHeadPos()
        pos.x = p.x + 112 + size.width / 2 + (index - 1) * 43
        pos.y = p.y + 57
    end

    return pos
end

--比牌 bi pai
function prototype:compareCardFun(data)
    -- log('SV: compareCardFun kai shi bi pai')
    sys.sound:playEffectByFile('resource/audio/ShiSanShui/start_compare.mp3')
    self.gameStarthh = false
    self.gameOverhh = false
    -- log('kai shi bi pai')
    --dump(data,"data",5)
    self:saveMemberInfo(data)
    --dump(self.compareCard)
    local delayTimeShoot = 1
    local memberInfo = nil
    local cards = nil
    -- 特殊牌型标识显示
    local function seeImgTeShuPai(visible)
        for k, v in pairs(self.bSpecialType) do
            if v ~= ShiSanShui_pb.NOT_SPECIALTYPE then
                local index = self.modelData:getPlayerSeatIndex(k)
                local tips = string.format('imgTeShuPai_%d', index)
                if nil ~= self[tips] then
                    self[tips]:setVisible(visible)
                else
                   -- log('imgSpecialIcon kong')
                end
            end
        end
    end
    seeImgTeShuPai(true)

    local function seeFntPanel(visible)
        self.fntPanel:setVisible(visible)
        if visible == false then
            return
        end
        local strFontWin, strFontLose, strFontWinAll, strFontLoseAll, strnodeDealResult
        for i = 1, 4 do
            for j = 1, 3 do
                strFontWin = string.format('fontWin_%d_%d', i, j)
                strFontLose = string.format('fontLose_%d_%d', i, j)
                strnodeDealResult = string.format('nodeDealResult_%d_%d', i, j)
                self[strFontWin]:setVisible(false)
                self[strFontLose]:setVisible(false)
                self[strnodeDealResult]:setVisible(false)
            end
            strFontWinAll = string.format('fontWinAll_%d_%d', i, 4)
            strFontLoseAll = string.format('fontLoseAll_%d_%d', i, 4)
            self[strFontWinAll]:setVisible(false)
            self[strFontLoseAll]:setVisible(false)
        end
    end
    seeFntPanel(true)
    local showCardType = function(id, index) -- 显示牌型和加水的图片数据
        local CardTypeInfo = {}
        local cardType, cardResult
        local cardAllType = {}
        if index == 1 then
            cardType = data[id]['headNormalDesc']
            cardResult = data[id]['headResult']
        elseif index == 2 then
            cardType = data[id]['bodyNormalDesc']
            cardResult = data[id]['bodyResult']
        elseif index == 3 then
            cardType = data[id]['tailNormalDesc']
            cardResult = data[id]['tailResult']
        end
        if cardType == 2 then
            cardType = 1
        elseif cardType == 7 or cardType == 8 then
            cardType = 6
        elseif cardType == 10 or cardType == 11 then
            cardType = 9
        elseif cardType == 15 or cardType == 16 then
            cardType = 14
        end
        CardTypeInfo.cardResult = cardResult
        CardTypeInfo.cardType = cardType
        CardTypeInfo.id = id
        return CardTypeInfo
    end

    local showCardTypeAction = function(node, info) --显示牌型和加水的UI
        if self.scoreAll[info.CTAR.id] == nil then
            self.scoreAll[info.CTAR.id] = info.CTAR.cardResult
            --log(info.CTAR.id .. ' ' .. self.scoreAll[info.CTAR.id])
        else
            self.scoreAll[info.CTAR.id] = self.scoreAll[info.CTAR.id] + info.CTAR.cardResult
            --log(info.CTAR.id .. ' ' .. self.scoreAll[info.CTAR.id])
        end
        if info.isGun == false then
            -- end
            -- 不是打枪
            local musicIndex = 0
            if info.CTAR.cardType == 1 then --乌龙
                musicIndex = 1
            elseif info.CTAR.cardType == 3 then --对子
                musicIndex = 2
            elseif info.CTAR.cardType == 4 then --两对
                musicIndex = 3
            elseif info.CTAR.cardType == 5 then --三条
                musicIndex = 4
            elseif info.CTAR.cardType == 6 then --顺子
                musicIndex = 5
            elseif info.CTAR.cardType == 9 then --同花
                musicIndex = 6
            elseif info.CTAR.cardType == 12 then --葫芦
                musicIndex = 7
            elseif info.CTAR.cardType == 13 then --铁支
                musicIndex = 8
            elseif info.CTAR.cardType == 14 then --同花顺
                musicIndex = 9
            end
            if musicIndex ~= 0 then --and info.CTAR.id == self.userId
                sys.sound:playEffectByFile('resource/audio/ShiSanShui/common' .. musicIndex .. '.mp3')
            end
            local nodeDealResult = string.format('nodeDealResult_%d_%d', info.seat, info.index) --牌型
            self[nodeDealResult]:loadTexture(string.format('resource/csbimages/Games/Shisanshui/specialType/cardType_%d.png', info.CTAR.cardType))
            self[nodeDealResult]:ignoreContentAdaptWithSize(true)
            self[nodeDealResult]:setVisible(true)
            self[nodeDealResult]:runAction(
                cc.Sequence:create(
                    cc.ScaleTo:create(0.3, 1.5),
                    cc.ScaleTo:create(0.2, 1),
                    cc.DelayTime:create(0.2),
                    cc.CallFunc:create(
                        function(sender)
                            sender:setVisible(false)
                        end
                    )
                )
            )
            local fontAction = nil
            if info.CTAR.cardResult >= 0 then
                fontAction = string.format('fontWin_%d_%d', info.seat, info.index)
                self[fontAction]:setString('+' .. info.CTAR.cardResult)
            else
                fontAction = string.format('fontLose_%d_%d', info.seat, info.index)
                self[fontAction]:setString(info.CTAR.cardResult)
            end
            self[fontAction]:setVisible(true)
            local allFontAction = nil --总分
            if self.scoreAll[info.CTAR.id] >= 0 then --赢者的分数显示
                allFontAction = string.format('fontWinAll_%d_%d', info.seat, 4)
                self[allFontAction]:setString('+' .. self.scoreAll[info.CTAR.id])
                local fontOld = string.format('fontLoseAll_%d_%d', info.seat, 4)
                self[fontOld]:setVisible(false)
            else
                allFontAction = string.format('fontLoseAll_%d_%d', info.seat, 4)
                self[allFontAction]:setString(self.scoreAll[info.CTAR.id])
                local fontOld = string.format('fontWinAll_%d_%d', info.seat, 4)
                self[fontOld]:setVisible(false)
            end
            self[allFontAction]:setVisible(true)
            -- if  info.CTAR.id==self.userId then
            self[allFontAction]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.2), cc.ScaleTo:create(0.1, 1)))
        elseif info.isGun == true then --hhhh
            local fontAction = nil
            if self.scoreAll[info.CTAR.id] >= 0 then --赢者的分数显示
                fontAction = string.format('fontWinAll_%d_%d', info.seat, info.index)
                self[fontAction]:setString('+' .. self.scoreAll[info.CTAR.id])
                local fontOld = string.format('fontLoseAll_%d_%d', info.seat, info.index)
                self[fontOld]:setVisible(false)
            else
                fontAction = string.format('fontLoseAll_%d_%d', info.seat, info.index)
                self[fontAction]:setString(self.scoreAll[info.CTAR.id])
                local fontOld = string.format('fontWinAll_%d_%d', info.seat, info.index)
                self[fontOld]:setVisible(false)
            end
            self[fontAction]:setVisible(true)
            self[fontAction]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.2), cc.ScaleTo:create(0.1, 1)))
        end
    end

    -- 牌打开动画
    local cardsAction = function(node, info)
        local cards = nil
        if info.index == 0 then -- 特殊牌打开全部牌
            cards = {}
            local cards2 = self.compareCard[info.id]
            for k, v in ipairs(cards2) do
                for k1, v1 in ipairs(v) do
                    table.insert(cards, v1)
                end
            end
        else
            cards = self.compareCard[info.id][info.index]
        end
        local ScaleNum = 0.5
        for k, v in ipairs(cards) do
            v:showCardValue()
        end
        --[[ for k, v in ipairs(cards) do  -- 牌的真实节点在 self.compareCard
            v:setVisible(true)
            v:runAction(
               --  cc.Spawn:create(
                     --cc.DelayTime:create(k * 0.03),
                     --cc.ScaleTo:create(0.1, -ScaleNum, ScaleNum),
                     -- cc.ScaleTo:create(0, ScaleNum, ScaleNum),
                    cc.CallFunc:create(
                        function()
                            log("size3: "..v.size)                       
                            
                        end
                    )
               --  )
            )
        end]]
    end
    -- 正式执行 hhhh
    local function openCard()
        local openList = {}
        for i = 1, 3 do
            for k, v in pairs(data) do
                if i == 1 then
                    local info = {id = k, Result = v['headResult'], index = i, seat = self.modelData:getPlayerSeatIndex(k)}
                    table.insert(openList, info)
                end
                if i == 2 then
                    local info = {id = k, Result = v['bodyResult'], index = i, seat = self.modelData:getPlayerSeatIndex(k)}
                    table.insert(openList, info)
                end
                if i == 3 then
                    local info = {id = k, Result = v['tailResult'], index = i, seat = self.modelData:getPlayerSeatIndex(k)}
                    table.insert(openList, info)
                end
            end
            table.sort(
                openList,
                function(a, b)
                    return a.Result < b.Result
                end
            )
            --dump(openList,"openList")
            for k, v in ipairs(openList) do
                while true do
                    local id = v.id
                    if data[id]['specialType'] ~= ShiSanShui_pb.NOT_SPECIALTYPE then
                        break
                    end
                    local CardTypeAndResult = showCardType(id, v.index)
                    local action = {
                        cc.DelayTime:create(delayTimeShoot),
                        cc.CallFunc:create(cardsAction, {id = id, index = v.index, seatIndex = v.seat}),
                        cc.CallFunc:create(showCardTypeAction, {CTAR = CardTypeAndResult, index = v.index, seat = v.seat, isGun = false})
                    }
                    delayTimeShoot = delayTimeShoot + 0.85
                    self:runAction(cc.Sequence:create(action))
                    openList = {}
                    break
                end
            end
        end
    end
    
    local HorseCardCallback = function(node, info) -- 马牌
        --log('HorseCardCallback ========= seat '..info.seat)
        local HorseCard = string.format('imgHorseCard_%d', info.seat)
        if self[HorseCard]:isVisible() == true then -- 放大 缩小
            sys.sound:playEffect('COINS_FLY_IN')
            self[HorseCard]:runAction(
                cc.Sequence:create(
                    cc.RotateBy:create(0.3, 360),
                    cc.ScaleTo:create(0.4, 2.5),
                    cc.ScaleTo:create(0.3, 1.5),
                    cc.CallFunc:create(
                        function()
                            self[HorseCard]:setVisible(false)
                        end
                    )
                )
            )
        end
    end
    local imgHoleAll = {}
    local shootCallback = function(node, info) -- 打枪aaaaaaaaaaaaaa
       -- log('shootCallback===========================')
        local function gungun(node, param)
            local info = param[1]
            local gun = node
            local gun2 = gun:getChildByName('imgGunFire')
            local bullet1 = gun:getChildByName('imgBullet_1')
            local bullet2 = gun:getChildByName('imgBullet_2')
            local bullet3 = gun:getChildByName('imgBullet_3')
            local imgHole1 = gun:getChildByName('imgHole_1')
            local imgHole2 = gun:getChildByName('imgHole_2')
            local imgHole3 = gun:getChildByName('imgHole_3')
            local bullet = {bullet1, bullet2, bullet3}
            imgHole1:setPosition(info.Holep_1)
            imgHole2:setPosition(info.Holep_2)
            imgHole3:setPosition(info.Holep_3)
            gun:setPosition(info.gunPosition)
            gun:setScaleY(info.ScaleY)
            gun:setRotation(info.Rotation)
            local function actionBullet(node, node2)
                node2.imgHole:setVisible(true)
                node:setVisible(false)
            end
            local function actionFun(node)
                gun:setVisible(true)
                sys.sound:playEffectByFile('resource/audio/ShiSanShui/daqiang3.mp3')
                bullet[1]:setVisible(true)
                bullet[1]:runAction(cc.Sequence:create(cc.MoveTo:create(info.time, info.Holep_1), cc.CallFunc:create(actionBullet, {imgHole = imgHole1})))
            end
            local function actionFun2(node)
                --sys.sound:playEffectByFile("resource/audio/Shisanshui/daqiang2.mp3")
                gun2:setVisible(true)
            end
            local function actionFun4(node)
                gun2:setVisible(false)
                sys.sound:playEffectByFile('resource/audio/ShiSanShui/daqiang3.mp3')
                bullet[2]:setVisible(true)
                bullet[2]:runAction(cc.Sequence:create(cc.MoveTo:create(info.time, info.Holep_2), cc.CallFunc:create(actionBullet, {imgHole = imgHole2})))
            end
            local function actionFun4_1(node)
                gun2:setVisible(false)
                sys.sound:playEffectByFile('resource/audio/ShiSanShui/daqiang3.mp3')
                bullet[3]:setVisible(true)
                bullet[3]:runAction(cc.Sequence:create(cc.MoveTo:create(info.time, info.Holep_3), cc.CallFunc:create(actionBullet, {imgHole = imgHole3})))
            end

            local function soundFun()
                sys.sound:playEffectByFile('resource/audio/ShiSanShui/daqiang3.mp3')
            end
            local gunAction = {
                cc.CallFunc:create(actionFun),
                cc.DelayTime:create(0.01),
                cc.CallFunc:create(actionFun2),
                cc.DelayTime:create(0.2),
                cc.CallFunc:create(actionFun4),
                cc.DelayTime:create(0.01),
                cc.CallFunc:create(actionFun2),
                cc.DelayTime:create(0.2),
                cc.CallFunc:create(actionFun4_1)
                --cc.CallFunc:create(soundFun),cc.DelayTime:create(0.2),cc.CallFunc:create(soundFun),
                --cc.DelayTime:create(0.2),cc.CallFunc:create(soundFun),
            }

            sys.sound:playEffectByFile('resource/audio/ShiSanShui/daqiang1.mp3')
            node:runAction(cc.Sequence:create(gunAction))
        end
        local function getInfo(seat1, seat2)
            local msg = {}
            for i = 1, 4 do
                msg[i] = {}
                for j = 1, 3 do
                    msg[i][j] = {}
                end
            end
            msg[1][2] = {-1, 180, -453, 89, 322, 221} -- 缩放,旋转,弹孔坐标,枪坐标
            msg[1][3] = {-1, 150, -513, 50, 339, 249}
            msg[1][4] = {1, 90, -191, 84, 315, 260}

            msg[2][1] = {1, 0, -453, 89, 860, 221}
            msg[2][3] = {1, 90, -190, 93, 851, 261}
            msg[2][4] = {1, 30, -520, 39, 874, 261}

            msg[3][1] = {1, -30, -517, 100, 860, 520}
            msg[3][2] = {1, 270, -224, 95, 876, 555}
            msg[3][4] = {1, 0, -456, 84, 860, 520}

            msg[4][1] = {1, -90, -244, 83, 335, 560}
            msg[4][2] = {1, -150, -516, 51, 322, 535}
            msg[4][3] = {-1, 180, -456, 84, 322, 520}
            local gunData = {}
            gunData.ScaleY = msg[seat1][seat2][1]
            gunData.Rotation = msg[seat1][seat2][2]
            gunData.Holep_1 = cc.p(msg[seat1][seat2][3], msg[seat1][seat2][4])
            gunData.Holep_2 = cc.p(gunData.Holep_1.x - 10, gunData.Holep_1.y - 40)
            gunData.Holep_3 = cc.p(gunData.Holep_1.x + 30, gunData.Holep_1.y - 30)
           -- gunData.Holep_1 =cc.p(self.panelPop:convertToNodeSpace(gunData.Holep_1))
           -- gunData.Holep_2 =cc.p(self.panelPop:convertToNodeSpace(gunData.Holep_2))
            --gunData.Holep_3 =cc.p(self.panelPop:convertToNodeSpace(gunData.Holep_3))
            gunData.gunPosition = cc.p(msg[seat1][seat2][5], msg[seat1][seat2][6])
            gunData.time = 0.3
            return gunData
        end
        local function clean(node)
            node:removeFromParent(true)
        end

        local gunData = getInfo(info[1].seat1, info[1].seat2)
        node:runAction(cc.Sequence:create(cc.CallFunc:create(gungun, {gunData}), cc.DelayTime:create(1.3), cc.CallFunc:create(clean)))
    end
    local specialTypePos = {{342, 292}, {887, 292}, {887, 567}, {342, 567},{self.winSize.width / 2, self.winSize.height / 2}}
    local specialTypeCallback = function(node, strEffect)
        local musicIndex = 1
        if strEffect[1] == 'a1qld' then --全垒打
            musicIndex = 1
        elseif strEffect[1] == 'a1sth' then --三同花
            musicIndex = 2
        elseif strEffect[1] == 'a1ssz' then --三顺子
            musicIndex = 3
        elseif strEffect[1] == 'a1ldb' then --六对半
            musicIndex = 4
        elseif strEffect[1] == 'a1siftx' then --四套三条
            musicIndex = 5
        elseif strEffect[1] == 'a1sanftx' then --三分天下
            musicIndex = 6
        elseif strEffect[1] == 'a1sths' then --三同花顺
            musicIndex = 7
        elseif strEffect[1] == 'yitiaolong' then --一条龙
            musicIndex = 8
        elseif strEffect[1] == 'qinglong' then --青龙
            musicIndex = 9
        end
        if musicIndex ~= 0 then
            sys.sound:playEffectByFile('resource/audio/Shisanshui/special' .. musicIndex .. '.mp3')
        end
        -- 特殊牌动画
        if strEffect[1] == 'yitiaolong' or strEffect[1] == 'qinglong' then
            local animationLong = cc.Animation:create()
            for i = 1, 9 do
                animationLong:addSpriteFrameWithFile('resource/csbimages/Games/Shisanshui/specialType/long/' .. i .. '.png')
            end
            animationLong:setDelayPerUnit(1 / 9)
            -- animationLong:setRestoreOriginalFrame(true)
            local showAction = cc.Animate:create(animationLong)
            local funAction =
                cc.CallFunc:create(
                function(sender)
                    sender:removeFromParent()
                end
            )
            local action = cc.Sequence:create(showAction, funAction)
            local LongFirstSprite = cc.Sprite:create('resource/csbimages/Games/Shisanshui/specialType/long/1.png'):setPosition(self.winSize.width / 2, self.winSize.height / 2)
            self.panelPop:addChild(LongFirstSprite)
            LongFirstSprite:runAction(action)
            return
        end

        local eff = CEffectManager:GetSingleton():getEffect(strEffect[1], true)
        local pos = specialTypePos[strEffect[2]]
        self.panelEff:setPosition(pos[1], pos[2])
        self.panelEff:addChild(eff)
    end
    --马牌
    local function openHorseCard()
        for k, v in pairs(data) do -- 马牌数据
            if data[k]['bonusResult'] ~= 0 then
                local cardWin = {}
                local bonusScore = data[k]['bonusResult']
                cardWin.cardResult = bonusScore
                cardWin.id = k
                local mySeat = self.modelData:getPlayerSeatIndex(k)
                self:runAction(
                    cc.Sequence:create(
                        cc.DelayTime:create(delayTimeShoot),
                        cc.CallFunc:create(showCardTypeAction, {CTAR = cardWin, index = 4, seat = mySeat, isGun = true}),
                        cc.CallFunc:create(HorseCardCallback, {seat = mySeat})
                    )
                )
            else --有马牌但没有水数时
                local mySeat = self.modelData:getPlayerSeatIndex(k)
                local strBonus = string.format('imgHorseCard_%d', mySeat) -- 马牌
                if self[strBonus]:isVisible() == true then
                    local cardWin = {}
                    cardWin.cardResult = 0
                    cardWin.id = k
                    self:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(delayTimeShoot),
                            cc.CallFunc:create(showCardTypeAction, {CTAR = cardWin, index = 4, seat = mySeat, isGun = true}),
                            cc.CallFunc:create(HorseCardCallback, {seat = mySeat})
                        )
                    )
                end
            end
        end
        delayTimeShoot= delayTimeShoot+1
    end
    --全垒打
    local function GunShootAll()
        for k, v in pairs(data) do ----全垒打,数据
            local gunScore = data[k]['fourbaggerResult']
            if gunScore ~= 0 then
                local cardWin = {}
                cardWin.cardResult = gunScore
                cardWin.id = k
               -- log('fourbaggerResult ' .. gunScore)
                self:runAction(
                    cc.Sequence:create(
                        cc.DelayTime:create(delayTimeShoot),
                        cc.CallFunc:create(showCardTypeAction, {CTAR = cardWin, index = 4, seat = self.modelData:getPlayerSeatIndex(k), isGun = true})
                    )
                )
            end
            if table.nums(data) == 4 and table.nums(data[k]['shootPlayerId']) == 3 then
                self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTimeShoot), cc.CallFunc:create(specialTypeCallback, {'a1qld',5})))
                delayTimeShoot = delayTimeShoot + 1.5
            end
        end
    end
    --打枪
    local function GunShoot()
        local gunlist = {}
        for k, v in pairs(data) do
            local shootNum = table.nums(data[k]['shootPlayerId'])
            if shootNum ~= 0 then
                local info = {id = k, allShootNum = shootNum, seat = self.modelData:getPlayerSeatIndex(k)}
                table.insert(gunlist, info)
            end
        end
        if table.nums(gunlist) == 0 then
            return
        end
        table.sort(
            gunlist,
            function(a, b)
                return a.allShootNum < b.allShootNum
            end
        )
        for k, v in ipairs(gunlist) do
            local ids = v.id
            local gunScore = data[ids]['shootResult'] -- 打枪水数只发来一个总值
            local cardWin = {}
            cardWin.cardResult = gunScore
            cardWin.id = ids
            for k1, v1 in ipairs(data[ids]['shootPlayerId']) do -- 被打枪玩家
                local info = {}
                info.seat1 = v.seat
                local S2 = self.modelData:getPlayerSeatIndex(v1)
                info.seat2 = S2
                local cardLose = {}
                cardLose.cardResult = -gunScore
                cardLose.id = v1
                local Tempgun = self['imgGun']:clone()
                self.panelPop:addChild(Tempgun)
                Tempgun:runAction(cc.Sequence:create(cc.DelayTime:create(delayTimeShoot), cc.CallFunc:create(shootCallback, {info})))
                self:runAction(
                    cc.Sequence:create(cc.DelayTime:create(delayTimeShoot), cc.CallFunc:create(showCardTypeAction, {CTAR = cardLose, index = 4, seat = S2, isGun = true}))
                )
            end
            self:runAction(
                cc.Sequence:create(cc.DelayTime:create(delayTimeShoot), cc.CallFunc:create(showCardTypeAction, {CTAR = cardWin, index = 4, seat = v.seat, isGun = true}))
            )
            delayTimeShoot = delayTimeShoot + 1.5
            if table.nums(data) == 4 and table.nums(data[ids]['shootPlayerId']) == 3 then
                GunShootAll()
            end
        end
    end

    
    --特殊牌
    local function openspecialCard()
        local Freezetime = delayTimeShoot
        for k, v in pairs(data) do
            if data[k]['specialTypeResult'] ~= 0 then -- 特殊牌
                local cardWin = {}
                cardWin.cardResult = data[k]['specialTypeResult']
                cardWin.id = k
                --log(' specialTypeResult2 ' .. data[k]['specialTypeResult'])
               -- log(' specialType ' .. data[k]['specialType'])
                if data[k]['specialType'] ~= ShiSanShui_pb.NOT_SPECIALTYPE then
                    local mySeat = self.modelData:getPlayerSeatIndex(k)
                    local action =
                        cc.Sequence:create(
                        cc.CallFunc:create(cardsAction, {id = k, index = 0}),
                        cc.CallFunc:create(specialTypeCallback, {self.specialAction[data[k]['specialType']], mySeat}),
                        cc.CallFunc:create(showCardTypeAction, {CTAR = cardWin, index = 4, seat = mySeat, isGun = true})
                    )
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTimeShoot), action))
                    delayTimeShoot = delayTimeShoot + 1.5
                else --普通牌只显示扣分动画
                    local action = cc.Sequence:create(cc.CallFunc:create(showCardTypeAction, {CTAR = cardWin, index = 4, seat = self.modelData:getPlayerSeatIndex(k), isGun = true}))
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(Freezetime), action))
                end
            end
            if data[k]['specialType'] ~= ShiSanShui_pb.NOT_SPECIALTYPE and data[k]['specialTypeResult'] == 0 then --有特殊牌但水数是0时
                local cardWin = {}
                cardWin.cardResult = 0
                cardWin.id = k
                --  log("================ specialTypeResult2 " .. data[k]["specialTypeResult"])
                -- log("================ specialType " .. data[k]["specialType"])
                local mySeat = self.modelData:getPlayerSeatIndex(k)
                local action =
                    cc.Sequence:create(
                    cc.CallFunc:create(cardsAction, {id = k, index = 0}),
                    cc.CallFunc:create(specialTypeCallback, {self.specialAction[data[k]['specialType']], mySeat}),
                    cc.CallFunc:create(showCardTypeAction, {CTAR = cardWin, index = 4, seat = mySeat, isGun = true})
                )
                self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTimeShoot), action))
                delayTimeShoot = delayTimeShoot + 1.5
            end
        end
    end
    
    local function hideFontAll()
        seeFntPanel(false)
        self.scoreAll = {}
        self['imgGun']:setVisible(false)
        seeImgTeShuPai(false)
        for k, v in pairs(self.compareCard) do
            for k1, v1 in ipairs(v) do
                for k2, v2 in ipairs(v1) do
                    v2:removeFromParent(true)
                end
            end
            self.compareCard[k] = nil
        end
        self.compareCard = {}
        self.nodePokerView:setEmptyPokerCards()
    end

    local dealFlyCoin = function()
        --处理金币动画ddddddddddddd
        util.timer:after(
            1,
            self:createEvent(
                'SHOW_SETTLEMENT_VIEW',
                function()
                    for k, v in pairs(data) do
                        local seat = self.modelData:getPlayerSeatIndex(k)
                        local coin = self.TempMemberInfo[k]['memStateInfo']['betResultCoin']
                        if coin ~= nil and seat ~=nil then
                           -- log('AllCoin2 ' .. k .. ', ' .. coin)
                            self['nodeRole_' .. seat]:runSettlementNumAction(coin)
                        end
                    end
                end
            )
        )
    end
    local exitsSpecialCard=false
    for k, v in pairs(data) do
        if data[k]['specialTypeResult'] ~= 0 then -- 特殊牌
            exitsSpecialCard=true
        end
    end
    if exitsSpecialCard==false then
        openCard()--普通开牌
        openHorseCard()--马牌
        GunShoot() --打枪
        openspecialCard()--特殊牌
    else
        openCard()--普通开牌
        openspecialCard()--特殊牌
        openHorseCard()--马牌
        GunShoot() --打枪
    end
    --结算页面
    self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTimeShoot), cc.CallFunc:create(dealFlyCoin), cc.CallFunc:create(hideFontAll)))
   -- log('=======ALLTime===========' .. delayTimeShoot)
    util.timer:after(
        (delayTimeShoot + 1) * 1000,
        self:createEvent(
            'DELAY_SHOW_RESULT',
            function()
                self.gameOverhh = true
                if self.gameStarthh == true then
                    if self.roomStyle == Common_pb.RsGold then
                        self.nodeReady:show(false, true, 1)
                       -- log("self.nodeReady============")
                    else
                        self.nodeReady:show(false)
                        self.nodeReady:hideBtnRefreshLeft(true)
                        --log("self.nodeReady============")
                    end
                    
                end
                self:settlementResult()
            end
        )
    )
    delayTimeShoot = 0
end

function prototype:saveMemberInfo(data)
    self.TempMemberInfo = {}
    local settlementCoin = {}
    local members = self.modelData:getRoomMember() -- 比牌时间太慢,导致第二局开始,传来空值
    --dump(members,"members",5)
    for id, v in pairs(data) do
        local playerInfo = self.modelData:getMemberInfoById(id)
        if playerInfo then
            settlementCoin[id] = playerInfo.memStateInfo.betResultCoin
        end
    end
    for id, v in pairs(data) do
        for id2, v2 in pairs(settlementCoin) do
            if id == id2 then
                members[id]['memStateInfo']['betResultCoin'] = clone(settlementCoin[id2])
            end
        end
    end
    local bonusCard = self.modelData:getRoomStateInfo().bonusCard -- 马牌    hhhh
    if bonusCard ~= nil then
        for id, v in pairs(members) do
            if v.memStateInfo.isBonus then
                local virtualBonusCard = {}
                virtualBonusCard.value = bonusCard.size
                virtualBonusCard.color = bonusCard.color
                members[id]['memStateInfo']['virtualBonusCard'] = virtualBonusCard
            end
        end
    end

    for id, v in pairs(members) do -- 摆的牌
        for id2, v2 in pairs(data) do
            if id == id2 then
                members[id]['memStateInfo']['cards'] =
                    clone(
                    {
                        v2['headCardInfo'][1],
                        v2['headCardInfo'][2],
                        v2['headCardInfo'][3],
                        v2['bodyCardInfo'][1],
                        v2['bodyCardInfo'][2],
                        v2['bodyCardInfo'][3],
                        v2['bodyCardInfo'][4],
                        v2['bodyCardInfo'][5],
                        v2['tailCardInfo'][1],
                        v2['tailCardInfo'][2],
                        v2['tailCardInfo'][3],
                        v2['tailCardInfo'][4],
                        v2['tailCardInfo'][5]
                    }
                )
            end
        end
    end
    for id, v in pairs(data) do --specialType 特殊牌型
        for id2, v2 in pairs(self.bSpecialType) do
            if id == id2 then
                members[id]['memStateInfo']['specialType'] = clone(self.bSpecialType[id2])
            end
        end
    end
    -- dump(members,"hh1",5)
    --log(members)
    self.TempMemberInfo = table.clone(members)
end

function prototype:RestartsaveMemberInfo() --结算时,掉线重连
    self.TempMemberInfo = {}
    local settlementCoin = {}
    local members = self.modelData:getRoomMember() -- 比牌时间太慢,导致第二局开始,传来空值
    for id, v in pairs(members) do
        local playerInfo = self.modelData:getMemberInfoById(id)
        if playerInfo then
            settlementCoin[id] = playerInfo.memStateInfo.betResultCoin
        end
    end
    for id, v in pairs(members) do
        for id2, v2 in pairs(settlementCoin) do
            if id == id2 then
                members[id]['memStateInfo']['betResultCoin'] = clone(settlementCoin[id2])
            end
        end
    end
    local bonusCard = self.modelData:getRoomStateInfo().bonusCard -- 马牌    hhhh
    if bonusCard ~= nil then
        for id, v in pairs(members) do
            if v.memStateInfo.isBonus then
                local virtualBonusCard = {}
                virtualBonusCard.value = bonusCard.size
                virtualBonusCard.color = bonusCard.color
                members[id]['memStateInfo']['virtualBonusCard'] = virtualBonusCard
            end
        end
    end
    local OpenDealData = self.modelData.OpenDealData
    if OpenDealData then
        for id, v in pairs(members) do -- 摆的牌
            for id2, v2 in pairs(OpenDealData) do
                if id == id2 then
                    members[id]['memStateInfo']['cards'] =
                        clone(
                        {
                            v2['headCardInfo'][1],
                            v2['headCardInfo'][2],
                            v2['headCardInfo'][3],
                            v2['bodyCardInfo'][1],
                            v2['bodyCardInfo'][2],
                            v2['bodyCardInfo'][3],
                            v2['bodyCardInfo'][4],
                            v2['bodyCardInfo'][5],
                            v2['tailCardInfo'][1],
                            v2['tailCardInfo'][2],
                            v2['tailCardInfo'][3],
                            v2['tailCardInfo'][4],
                            v2['tailCardInfo'][5]
                        }
                    )
                end
            end
        end
        --dump(OpenDealData,"OpenDealData", 5)
        for id, v in pairs(OpenDealData) do --specialType 特殊牌型
            members[id]['memStateInfo']['specialType'] = clone(v.specialType)
        end
    end
    --dump(members,"members",5)
    self.TempMemberInfo = table.clone(members)
    self.modelData.OpenDealData = nil
end

function prototype:settlementResult()
    ui.mgr:open('Games/Shisanshui/ResultView', self.TempMemberInfo)
end
function prototype:clearOldCards()
   -- log('SV: clearOldCards clearn id old cards')
    self.nodePokerView:clearSanDunCards()
    self.nodePokerView:clearAllCards()
end
-- 结算,在结算处  开始比牌
function prototype:onPushSettlement(data)
   -- log('SV: onPushSettlement bi pai zhun bei')
    self.nodePokerView.nodeClockDeal:stop()
   -- log("nodePokerView.nodeClockDeal====================")
    self.nodePokerView:seePokerCardView(false)
    self:clearOldCards()
    self.bSpecialType = {}
    for k, v in pairs(data.OpenDealData) do
        local m_playerId = k
        local seatIndex = self.modelData:getPlayerSeatIndex(m_playerId)
        local imgP = string.format('imgP_%d', seatIndex) -- 重置气泡状态
        local imgW = string.format('imgW_%d', seatIndex)
        self[imgP]:setVisible(true)
        self[imgW]:setVisible(false)
        self:seeQiPao(false, seatIndex)
        local headCardInfo = self:sortSanDunPai(v.headCardInfo)
        local bodyCardInfo = self:sortSanDunPai(v.bodyCardInfo)
        local tailCardInfo = self:sortSanDunPai(v.tailCardInfo)
       -- log('id ' .. k .. ' v.specialType ' .. v.specialType)
        self.bSpecialType[k] = v.specialType
        local m_CardInfo = {headCardInfo, bodyCardInfo, tailCardInfo}
        self:settlementDealPokerCards(m_playerId, seatIndex, m_CardInfo)
    end
    self:compareCardFun(data.OpenDealData)
end

function prototype:sortSanDunPai(temp)
    --log('SV: sortSanDunPai')
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

--房卡场总结算
function prototype:onPushGamePerformance(info)
    -- log("SV:onPushGamePerformance")
    --dump(info,"info",5)
	local roomInfo = self.modelData:getRoomInfo()
	if roomInfo.roomStyle == Common_pb.RsCard then
		local roomState = self.modelData:getRoomState()
        info.currencyType = roomInfo.currencyType
		info.strCurrencyType = roomInfo.currencyType==Common_pb.Score and "计分" or "金币"
        info.strCurrencyType = string.format("%s(%s)", info.strCurrencyType, self.chipRangeMsg)
        if roomInfo.currencyType==Common_pb.Score then
            info.strPayType = "房主付费"
        else
            info.strPayType = "大赢家付费"
        end
		if roomState == ShiSanShui_pb.State_Settlement then
			if roomInfo.groupNum == roomInfo.currentGroup then
				--最后一局（总结算延迟，关闭了单局结算后，直接弹出总结算）
				--if ui.mgr:isOpen("Games/Shisanshui/ResultView") then
                    self.groupPerformance = info
                    -- log("do0")
				--else
                  --  ui.mgr:open("GameResult/GroupResultView", info)	
                   -- log("do1")
				--end
			else
				--中间
                ui.mgr:open("GameResult/GroupResultView", info)
                -- log("do2")
			end
		else
            ui.mgr:open("GameResult/GroupResultView", info)
            -- log("do3")
		end

		self.nodeRoomInfo:setVisible(false)
	end
end


--显示总结算（单局结算关闭之后显示）
function prototype:showGroupResultView()
	if self.groupPerformance then
		ui.mgr:open("GameResult/GroupResultView", self.groupPerformance)
	end
end

function prototype:uiEvtPlayerInfo(playerId)
    -- log('SV: uiEvtPlayerInfo')
    local fromIndex = self.modelData:getPlayerSeatIndex(self.userId)
    local fromPos = self['nodeRole_' .. fromIndex]:getHeadPos()
    local toIndex = self.modelData:getPlayerSeatIndex(playerId)
    local toPos = self['nodeRole_' .. toIndex]:getHeadPos()
    local playerInfo = self.modelData:getMemberInfoById(playerId)
    ui.mgr:open('Games/Common/PlayerInfoView', {node = self.rootNode, info = playerInfo, from = fromPos, to = toPos})
end

function prototype:uiEvtCopyRoomId()
    -- log('SV: uiEvtCopyRoomId')
    local roomInfo = self.modelData:getRoomInfo()
    util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, tostring(roomInfo.roomId))
end

--邀请好友
function prototype:uiEvtInviteFriend()
    -- log('SV: uiEvtInviteFriend')
    local shareTable = {}
    shareTable.ShareType = 'Text' --内容（文本：Text， 链接：Link, 图片：Image）
    shareTable.Scene = 'SceneSession' --分享类型（朋友圈：SceneTimeline， 好友：SceneSession）

    --字符串
    local roomInfo = self.modelData:getRoomInfo()
	local roomId = roomInfo.roomId
	local groupNum = string.format("局数%d",roomInfo.groupNum)
	local strCurrencyType = roomInfo.currencyType==Common_pb.Score and "计分" or "金币"
	local strPayType = "房主付费"
    if roomInfo.clubId and roomInfo.clubId > 0 and roomInfo.currencyType==Common_pb.Gold then
        strPayType = "大赢家付费"
    end
    --log(roomInfo)
    local strBonusCardSize="马牌无"
    if roomInfo.bonusCardSize~=-1 then
        strBonusCardSize=string.format("马牌黑桃%s", roomInfo.bonusCardSize)
    end
	shareTable.Text = string.format("【十三水-%s-%04d-%s-%s(%s)-%s】(长按复制此消息后打开游戏)", 
                                    strBonusCardSize, roomId, groupNum, strCurrencyType, self.chipRangeMsg, strPayType)
    --local dataTable={content=shareTable.Text,okFunc=nil}
    --ui.mgr:open("Dialog/ConfirmView",dataTable)
    local str = json.encode(shareTable)
    local isAccountLogin = Model:get("Account"):isAccountLogin()
	if isAccountLogin == true then
		util:setClipboardString(shareTable.Text)
	else
		util:fireCoreEvent(REFLECT_EVENT_WEIXIN_SHARE, 0, 0, str)	
	end
end

function prototype:uiEvtShowDistance()
    -- log('SV: uiEvtShowDistance')
    self.nodeDistance:showDistance('Games/Shisanshui')
end

--菜单
function prototype:onBtnMenuClick(sender)
    -- log('SV: onBtnMenuClick')
    ui.mgr:open('Games/Common/MenuToolBarView', 'Games/Shisanshui')
end
