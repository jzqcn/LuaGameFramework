local GameBase = require 'Games.Base'
require 'Protol.ShiSanShui_pb'

module(..., package.seeall)

EVT =
    Enum {
    'PUSH_ENTER_ROOM',
    'PUSH_USER_READY',
    'PUSH_ROOM_DRAW',
    'PUSH_MEMBER_STATUS',
    'PUSH_ROOM_STATE',
    'PUSH_USER_SNATCH',
    'PUSH_SNATCH_RESULT',
    'PUSH_ROOM_DEAL',
    'PUSH_OPEN_DEAL',
    'PUSH_OPEN_DEAL_RESULT',
    'PUSH_SETTLEMENT',
    "PUSH_CLUB_CREATE_ROOM",
}

class = GameBase.class:subclass()

local ShiSanShui_pb = ShiSanShui_pb
local Common_pb = Common_pb

local bCheckClubManager = false

function class:initialize()
    --log("SM: initialize")
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_SHISANSHUI, self:createEvent('onShiSanShuiResponse'))

    --消息协议解析
    self:bindResponse(ShiSanShui_pb.Request_Enter, bind(self.responseEnterRoom, self))
    self:bindResponse(ShiSanShui_pb.Request_Ready, bind(self.responseReady, self), true)
    self:bindResponse(ShiSanShui_pb.Push_Draw, bind(self.responseDraw, self))
    self:bindResponse(ShiSanShui_pb.Request_Deal, bind(self.responseDeal, self))
    self:bindResponse(ShiSanShui_pb.Push_State, bind(self.responseRoomState, self))
    self:bindResponse(ShiSanShui_pb.Push_Member, bind(self.responseMember, self))
    self:bindResponse(ShiSanShui_pb.Request_OpenDeal, bind(self.responseOpenDeal, self), true)
    self:bindResponse(ShiSanShui_pb.Push_OpenDeal, bind(self.responseOpenDealResult, self))
    self:bindResponse(ShiSanShui_pb.Push_Settlement, bind(self.responseSettlement, self))
    self:bindResponse(ShiSanShui_pb.Request_Leave, bind(self.responseLeaveRoom, self))
    self:bindResponse(ShiSanShui_pb.Request_Destroy, bind(self.responseDissolveRoom, self))
    self:bindResponse(ShiSanShui_pb.Push_Destory, bind(self.responseRoomDestory, self))
    self:bindResponse(ShiSanShui_pb.Push_To_Destory, bind(self.responseApplyRoomDestory, self))
    self:bindResponse(ShiSanShui_pb.Push_Agree_Destroy, bind(self.responseAgreeRoomDestory, self))
    self:bindResponse(ShiSanShui_pb.Request_Start, bind(self.responseStartGame, self))
end

function class:onShiSanShuiResponse(data)
    -- log("SM: onShiSanShuiResponse")
    local response = ShiSanShui_pb.ShiSanShuiResponse()
    response:ParseFromString(data)
    if response.requestType == nil then
        log4model:error('[SM:::onShisanshuiResponse] requestType is nil !!!!')
        return
    end
    -- local requestTypeStr = {
    --     'into room',
    --     'ready',
    --     'fa pai',
    --     'bai pai result',
    --     'push bai pai result',
    --     'push room state',
    --     'push player state',
    --     'request leave room',
    --     'push kuo chu gold',
    --     'leave room into room',
    --     'Request Destroy room',
    --     'push Argee Destroy',
    --     'push room has Destroy',
    --     'push To Destory',
    --     'Push_Agree_Destroy room',
    --     'Push OpenDeal info',
    --     'Request Start game'
    -- }
    -- log('SM: Response : ' .. response.requestType .. ' ' .. requestTypeStr[response.requestType])
    
    --log("[Shisanshui::onShiSanShuiResponse] response type == "..response.requestType)
    self:onResponse(response.requestType, response)
end

--通用请求，不需要附带其他数据(准备、请求开始游戏等)
function class:requestCommonMsg(msgType)
    -- log("SM :requestCommonMsg")
    local gameRequest = ShiSanShui_pb.ShiSanShuiRequest()
    gameRequest.requestType = msgType
    gameRequest.room.playId = self.roomInfo.playId
    gameRequest.room.roomId = self.roomInfo.roomId
    gameRequest.room.roomStyle = self.roomInfo.roomStyle
    net.msg:send(MsgDef_pb.MSG_SHISANSHUI, gameRequest:SerializeToString())
end

--请求开始游戏返回
function class:responseStartGame(data)
    -- log("SM: responseStartGame")
    -- self:fireEvent(EVT.PUSH_START_GAME, data.isSuccess)
end

--请求加入游戏
function class:requestEnterRoom(playId, typeId, roomStyle, roomId)
    --log('SM: requestEnterRoom '..playId)
    local gameRequest = ShiSanShui_pb.ShiSanShuiRequest()
    gameRequest.requestType = ShiSanShui_pb.Request_Enter
    gameRequest.room.playId = playId
    gameRequest.room.typeId = typeId
    gameRequest.room.roomStyle = roomStyle

    --房卡场请求加入房间需要添加roomID
    if roomId then
        gameRequest.room.roomId = roomId
    end

    bCheckClubManager = false

    net.msg:send(MsgDef_pb.MSG_SHISANSHUI, gameRequest:SerializeToString())
end

--房卡场创建房间
function class:requestCreateCardRoom(configInfo,clubId)
   -- log('SM: requestCreateCardRoom')
    local gameRequest = ShiSanShui_pb.ShiSanShuiRequest()
    gameRequest.requestType = ShiSanShui_pb.Request_Enter
    gameRequest.room.playId = configInfo.playId
    gameRequest.room.typeId = configInfo.typeId
    gameRequest.room.currencyType = tonumber(configInfo.currencyType)

    gameRequest.room.roomStyle = Common_pb.RsCard
    --客户端选择相关配置
    for k, v in pairs(configInfo.config) do
		if string.find(k, "C_groupConfig") then
			--局数
			gameRequest.cardConfigRequest.groupConfig = tonumber(v[1])
		-- elseif string.find(k, "C_scorePayType") then
		-- 	--支付类型
		-- 	gameRequest.cardConfigRequest.scorePayType = tonumber(v[1])
		elseif string.find(k, "C_bonusCardSize") then
			--马牌
			gameRequest.cardConfigRequest.bonusCardSize = tonumber(v[1])
		elseif string.find(k, "C_baseChipRange") then
			--底注范围
			gameRequest.cardConfigRequest.baseChipRange = tonumber(v[1])
		end
	end

    gameRequest.cardConfigRequest.scorePayType = Common_pb.RoomOwnner
    
    gameRequest.cardConfigRequest.maxPlayerNums = 4
	--俱乐部ID
	if clubId then
		gameRequest.room.clubId = clubId
		-- log("create shisanshui room :: clubId == "..clubId)
        bCheckClubManager = true
	end
    -- dump(configInfo,"configInfo")
    net.msg:send(MsgDef_pb.MSG_SHISANSHUI, gameRequest:SerializeToString())
end

function class:responseEnterRoom(data)
    -- log('SM: responseEnterRoom')
    self:clear()
    local initInfo = data.initInfo
    self:parseRoomInfo(initInfo.info)

    if bCheckClubManager and self.roomInfo.roomStyle == Common_pb.RsCard then
        --用来判断是否是在创建的时候，否则后面点加入也会被处理掉
        bCheckClubManager = false
        --俱乐部主、管理员创建房间不进入游戏
        if self.roomInfo.clubId then
            local clubData = Model:get("Club"):getClubData(self.roomInfo.clubId)
            if clubData ~= nil then
                if clubData.isOwner == true or clubData.isManager == true then              
                    self:clear()
                    self:fireEvent(EVT.PUSH_CLUB_CREATE_ROOM)
                    return
                end
            end
        end
    end


    self:parseRoomMember(initInfo.rmem)
    self:parseRoomStateInfo(initInfo.state)
    self:parseCardConfigInfo(initInfo.cardConfigInfo)
    local OpenDealData =nil
    if data.pushBatchOpenDeal then
        OpenDealData =self:parseBatchOpenDeal(data.pushBatchOpenDeal.pOpenDeal)
        self.OpenDealData=OpenDealData
    end
    --dump(OpenDealData,"OpenDealData11111111",5)
    local userId = Model:get('Account'):getUserId()
    --先初始化自己的座位下标（自己坐正面）
    self:initUserSeatIndex(userId)
    --初始化其他玩家座位下标
    self:initOtherSeatIndex()

    if not StageMgr:isStage('Game') then
        StageMgr:chgStage('Game', 'Shisanshui')
    else
        self:fireEvent(EVT.PUSH_ENTER_ROOM)
    end

    --有人申请解散房间
    if data.pushToDestory then
        self:responseApplyRoomDestory(data)
    end
end

--准备
function class:requestReady()
    -- log('SM: requestReady')
    local gameRequest = ShiSanShui_pb.ShiSanShuiRequest()
    gameRequest.requestType = ShiSanShui_pb.Request_Ready
    gameRequest.room.playId = self.roomInfo.playId
    gameRequest.room.roomId = self.roomInfo.roomId
    gameRequest.room.roomStyle = self.roomInfo.roomStyle

    net.msg:send(MsgDef_pb.MSG_SHISANSHUI, gameRequest:SerializeToString())
end

--玩家准备操作返回
function class:responseReady(data)
    -- log('SM: responseReady')
    self:fireEvent(EVT.PUSH_USER_READY, data.isSuccess)
end

--推送扣除台费、进入抢庄阶段
function class:responseDraw(data)
    -- log('SM: responseDraw')
    self:parseRoomStateInfo(data.roomState.state)
    self:parseRoomMember(data.batchMemeberStatus.rmem)
    self:fireEvent(EVT.PUSH_ROOM_DRAW)
end

--请求明牌
function class:requestOpenDeal(data)
    -- log('SM: requestOpenDeal')
    local gameRequest = ShiSanShui_pb.ShiSanShuiRequest()
    gameRequest.requestType = ShiSanShui_pb.Request_OpenDeal
    gameRequest.room.playId = self.roomInfo.playId
    gameRequest.room.roomId = self.roomInfo.roomId
    gameRequest.room.roomStyle = self.roomInfo.roomStyle
    --log(self.roomInfo.roomStyle)
    local cardInfo
    for i, v in ipairs(data.frontCardInfo) do
        cardInfo = CardKind_pb.CardInfo()
        cardInfo.id = v.id
        cardInfo.size = v.size
        cardInfo.color = v.color
        table.insert(gameRequest.openDealRequest.headCardInfo, cardInfo)
    end

    for i, v in ipairs(data.midCardInfo) do
        cardInfo = CardKind_pb.CardInfo()
        cardInfo.id = v.id
        cardInfo.size = v.size
        cardInfo.color = v.color
        table.insert(gameRequest.openDealRequest.bodyCardInfo, cardInfo)
    end

    for i, v in ipairs(data.tailCardInfo) do
        cardInfo = CardKind_pb.CardInfo()
        cardInfo.id = v.id
        cardInfo.size = v.size
        cardInfo.color = v.color
        table.insert(gameRequest.openDealRequest.tailCardInfo, cardInfo)
    end
    gameRequest.openDealRequest.specialType = data.specialCardInfo
    net.msg:send(MsgDef_pb.MSG_SHISANSHUI, gameRequest:SerializeToString())
end

function class:responseOpenDeal(data)
    -- log('SM: responseOpenDeal' .. tostring(data.isSuccess))
    self:fireEvent(EVT.PUSH_OPEN_DEAL, data.isSuccess)
end

--明牌结果
function class:responseOpenDealResult(data)
    -- log('SM: responseOpenDealResult')
    -- self:parseRoomMember(data.batchMemeberStatus.rmem)
    -- local memData = self:parseOpenDeal(data.pushOpenDeal)
    -- local memData=self:parseRoomStateInfo(data.roomState.state)

    self:fireEvent(EVT.PUSH_OPEN_DEAL_RESULT, data.pushOpenDeal)
end

--请求离开房间
function class:requestLeaveGame()
    -- log('SM: requestLeaveGame')
    local gameRequest = ShiSanShui_pb.ShiSanShuiRequest()
    gameRequest.requestType = ShiSanShui_pb.Request_Leave
    gameRequest.room.playId = self.roomInfo.playId
    gameRequest.room.roomId = self.roomInfo.roomId
    gameRequest.room.roomStyle = self.roomInfo.roomStyle
    net.msg:send(MsgDef_pb.MSG_SHISANSHUI, gameRequest:SerializeToString())
end

--离开房间
function class:responseLeaveRoom(data)
    -- log('SM: responseLeaveRoom')
    self:clear()
    StageMgr:chgStage('Hall')
end

--请求换桌
function class:requestChangeRoom()
    -- log('SM: requestChangeRoom')
    local gameRequest = ShiSanShui_pb.ShiSanShuiRequest()
    gameRequest.requestType = ShiSanShui_pb.Request_Change
    gameRequest.room.playId = self.roomInfo.playId
    gameRequest.room.roomId = self.roomInfo.roomId
    gameRequest.room.roomStyle = self.roomInfo.roomStyle

    net.msg:send(MsgDef_pb.MSG_SHISANSHUI, gameRequest:SerializeToString())
end

--请求解散房间
function class:requestDissolveRoom()
    -- log('SM: requestDissolveRoom')
    local gameRequest = ShiSanShui_pb.ShiSanShuiRequest()
    gameRequest.requestType = ShiSanShui_pb.Request_Destroy
    gameRequest.room.playId = self.roomInfo.playId
    gameRequest.room.roomId = self.roomInfo.roomId
    gameRequest.room.roomStyle = self.roomInfo.roomStyle
   -- dump(self.roomInfo,"self.roomInfo")
    net.msg:send(MsgDef_pb.MSG_SHISANSHUI, gameRequest:SerializeToString())
end

--申请解散房间返回
function class:responseDissolveRoom(data)
   -- log('SM: responseDissolveRoom')
end

--服务器推送解散房间
function class:responseRoomDestory(data)
    -- log('SM: responseRoomDestory')
    ui.mgr:close('Games/Common/DissolveRoomView')
    --房卡场通过结算界面返回大厅
    --self:clear()
    --StageMgr:chgStage("Hall")

    local userInfo = self:getUserInfo()
    if userInfo == nil then
        --围观解散
        StageMgr:chgStage("Hall")       
    end
end

--服务器推送 有人申请解散房间
function class:responseApplyRoomDestory(data)
    -- log('SM: responseApplyRoomDestory')
    local agreeInfo = data.pushToDestory
    if not agreeInfo.requestPlayerId or agreeInfo.requestPlayerId == '' then
        return
    end

    local userInfo = self:getUserInfo()
    if userInfo == nil then
        --围观玩家忽略
        return
    end

    local info = {}
    info.modelName = 'Games/Shisanshui'
    info.countDown = agreeInfo.countDown
    info.requestPlayerId = agreeInfo.requestPlayerId

    local playerInfo = self:getMemberInfoById(info.requestPlayerId)
    if playerInfo then
        info.requestPlayerName = playerInfo.playerName

        local agreeTab = {}
        local agreePlayerIdTab = agreeInfo.agreePlayerId
        for _, v in ipairs(agreePlayerIdTab) do
            local playerInfo = self:getMemberInfoById(v)
            agreeTab[v] = {id = v, name = playerInfo.playerName, headImage = playerInfo.headimage, isAgree = 1}
        end

        for k, v in pairs(self.memberMap) do
            if agreeTab[k] == nil then
                agreeTab[k] = {id = k, name = v.playerName, headImage = playerInfo.headimage, isAgree = 0}
            end
        end

        info.agreeTab = agreeTab

        ui.mgr:open('Games/Common/DissolveRoomView', info)
    end
end

--是否同意解散房间
function class:requestAgreeDissolve(isAgree)
    -- log('SM: requestAgreeDissolve')
    local gameRequest = ShiSanShui_pb.ShiSanShuiRequest()
    gameRequest.requestType = ShiSanShui_pb.Request_Agree_Destroy
    gameRequest.room.playId = self.roomInfo.playId
    gameRequest.room.roomId = self.roomInfo.roomId
    gameRequest.room.roomStyle = self.roomInfo.roomStyle

    gameRequest.agreeDestoryRequest.isAgree = isAgree

    net.msg:send(MsgDef_pb.MSG_SHISANSHUI, gameRequest:SerializeToString())
end

--推送用户是否同意解散房间请求
function class:responseAgreeRoomDestory(data)
    -- log('SM: responseAgreeRoomDestory')
    local agreeInfo = data.pushArgeeDestroy
    local isAgree = agreeInfo.isAgree
    local playerId = agreeInfo.playerId
    local countDown = agreeInfo.countDown

    if isAgree == false then
        ui.mgr:close('Games/Common/DissolveRoomView')

        local playerInfo = self:getMemberInfoById(playerId)
        --dump(playerInfo,"playerInfo")
        if playerInfo then
            local data = {
                content = '玩家【' .. playerInfo.playerName .. '】 拒绝解散组局！'
            }
            ui.mgr:open('Dialog/ConfirmView', data)
        end
    else
        local layer = ui.mgr:getLayer('Games/Common/DissolveRoomView')
        if layer then
            layer:refreshAgreeState(playerId, countDown)
        end
    end
end

--发牌
function class:responseDeal(data)
    -- log('SM: responseDeal')
    self:parseRoomStateInfo(data.roomState.state)
    local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)
    self:fireEvent(EVT.PUSH_ROOM_DEAL, memData)
end

--结算
function class:responseSettlement(data)
    -- log('SM: responseSettlement')
    self:parseRoomStateInfo(data.roomState.state)
    local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)
    local OpenDealData=nil
    if data.pushBatchOpenDeal then
        OpenDealData=self:parseBatchOpenDeal(data.pushBatchOpenDeal.pOpenDeal)
    end
    memData.OpenDealData=OpenDealData
    self:fireEvent(EVT.PUSH_SETTLEMENT, memData)
end
--解析比牌玩家的三墩牌
function class:parseBatchOpenDeal(data)
    -- log('SM: parseBatchOpenDeal')
    if data == nil then
        log4model:warn('SM: :: parse parseBatchOpenDeal ! data is nil !')
        return nil
    end
    local parseCardData = {}
    for k, v in ipairs(data) do
        local info = {}
        if v.playerId == nil or v.playerId == '' then
            log4model:warn('[SM:::parseRoomMember] parse room member error ! playerId == ' .. v.playerId)
        end
        info.specialType = v.specialType
        info.headNormalDesc = v.headNormalDesc --牌型
        info.bodyNormalDesc = v.bodyNormalDesc
        info.tailNormalDesc = v.tailNormalDesc
        info.headResult = v.headResult --每墩加水数
        info.bodyResult = v.bodyResult
        info.tailResult = v.tailResult
        info.specialTypeResult = v.specialTypeResult
        info.bonusResult = v.bonusResult
        info.fourbaggerResult=v.fourbaggerResult
        info.shootPlayerId = {} --被打枪玩家id
        for k1, v1 in ipairs(v.shootPlayerId) do
            table.insert(info.shootPlayerId, v1)
        end
        info.shootResult = v.shootResult ----被打枪玩家水数

        -- 手牌信息
        local cards = {}
        for __, card in ipairs(v.headCardInfo) do
            local node = {}
            node.color = tonumber(card.color)
            node.size = tonumber(card.size)
           --log("1 size "..node.size)
            cards[#cards + 1] = node
        end
        info.headCardInfo = cards
        cards = {}
        for __, card in ipairs(v.bodyCardInfo) do
            local node = {}
            node.color = tonumber(card.color)
            node.size = tonumber(card.size)
           -- log("2 size "..node.size)
            cards[#cards + 1] = node
        end
        info.bodyCardInfo = cards
        cards = {}
        for __, card in ipairs(v.tailCardInfo) do
            local node = {}
            node.color = tonumber(card.color)
            node.size = tonumber(card.size)
            --log("3 size "..node.size)
            cards[#cards + 1] = node
        end
        info.tailCardInfo = cards
        parseCardData[v.playerId] = info
    end

    return parseCardData
end

--更新房间状态
function class:responseRoomState(data)
    -- log('SM: responseRoomState')
    local roomStateInfo = data.roomState
    self:parseRoomStateInfo(roomStateInfo.state)
    self:fireEvent(EVT.PUSH_ROOM_STATE)
end

--更新成员状态
function class:responseMember(data)
    -- log('SM: responseMember')
    local memData = self:parseRoomMember(data.batchMemeberStatus.rmem)
    --初始化其他玩家座位下标(新加入玩家)
    self:initOtherSeatIndex()
    self:fireEvent(EVT.PUSH_MEMBER_STATUS, memData)
end

function class:parseRoomInfo(data)
    -- log('SM: parseRoomInfo')
    if data == nil then
        log4model:warn('SM: :: parse room info error ! data is nil !')
        return
    end

    if data.playId ~= nil then
        self.roomInfo.playId = data.playId
    end
    if data.typeId ~= nil then
        self.roomInfo.typeId = data.typeId
    end
    --if data.dealerType ~= nil then self.roomInfo.dealerType = data.dealerType end				  --抢庄类型
    --if data.dealerDesc ~= nil then self.roomInfo.dealerDesc = data.dealerDesc end
    --if data.maxLimit ~= nil then self.roomInfo.maxLimit = tonumber(data.maxLimit) end			  --下注上限
    if data.roomId ~= nil then
        self.roomInfo.roomId = data.roomId
    end
    if data.currencyType ~= nil then
        self.roomInfo.currencyType = data.currencyType
    end
    if data.maxPlayerNum ~= nil then
        self.roomInfo.maxPlayerNum = data.maxPlayerNum
    end
    if data.minPlayerNum ~= nil then
        self.roomInfo.minPlayerNum = data.minPlayerNum
    end
    if data.roomStyle ~= nil then
        self.roomInfo.roomStyle = data.roomStyle
    end --房卡、竞技、活动
    if data.clubId ~= nil then
        self.roomInfo.clubId = data.clubId
    end
    -- log('[SM:::parseRoomInfo] room indo playerId:' .. data.playId .. ', roomId:' .. data.roomId .. ', currencyType:' .. data.currencyType)
end

function class:parseRoomMember(data)
    -- log('SM: parseRoomMember')
    if data == nil then
        log4model:warn('SM: :: parse room member error ! data is nil !')
        return nil
    end

    local parseMemData = {}
    for k, v in ipairs(data) do
        if v.memberType ~= Common_pb.Leave then
            if v.playerId == nil or v.playerId == '' then
                log4model:warn('[SM:::parseRoomMember] parse room member error ! playerId == ' .. v.playerId)
            end
            local info = {}
            info.playerId = v.playerId
            if v.memberType ~= nil then
                info.memberType = v.memberType
            end
            if v.playerName ~= nil then
                info.playerName = v.playerName
                --dump(info.playerName,"info.playerName=======================")
            end
            
            if v.headimage ~= nil then
                info.headimage = v.headimage
            end
            if v.coin ~= nil then
                info.coin = tonumber(v.coin)
            end --货币数
            if v.index ~= nil then
                info.seatId = tonumber(v.index)
            end --座位号 1开始
            if v.sex ~= nil then
                info.sex = v.sex
            end
            info.memStateInfo = {}
            local memStateInfo = v.state
            if memStateInfo then
                -- log(info)
                if memStateInfo.isSettlement ~= nil then
                    info.memStateInfo.isSettlement = memStateInfo.isSettlement
                end --是否结算
                if memStateInfo.cardCount ~= nil then
                    info.memStateInfo.cardCount = memStateInfo.cardCount
                end --手牌数量
                if memStateInfo.result ~= nil then
                    info.memStateInfo.result = memStateInfo.result
                end --true 赢  false 输
                if memStateInfo.mutiple ~= nil then
                    info.memStateInfo.mutiple = memStateInfo.mutiple
                end --倍数
                --[[if memStateInfo.resultDesc ~= nil then
                    info.memStateInfo.resultDesc = memStateInfo.resultDesc
                end --描述]]
                if memStateInfo.isOffLine ~= nil then
                    info.memStateInfo.isOffLine = memStateInfo.isOffLine
                end --是否离线
                if memStateInfo.isReady ~= nil then
                    info.memStateInfo.isReady = memStateInfo.isReady
                end --是否准备
                --if memStateInfo.isDealer ~= nil then info.memStateInfo.isDealer = memStateInfo.isDealer end
                --if memStateInfo.betCoin ~= nil then info.memStateInfo.betCoin = tonumber(memStateInfo.betCoin) end			  --下注金额
                if memStateInfo.isViewer ~= nil then
                    info.memStateInfo.isViewer = memStateInfo.isViewer
                end --是否旁观
                --if memStateInfo.isSnatch ~= nil then info.memStateInfo.isSnatch = memStateInfo.isSnatch end
                --if memStateInfo.isBet ~= nil then info.memStateInfo.isBet = memStateInfo.isBet end
                if memStateInfo.betResultCoin ~= nil then
                    info.memStateInfo.betResultCoin = tonumber(memStateInfo.betResultCoin)
                end --输赢金币数
                --if memStateInfo.isRequestSnatch ~= nil then info.memStateInfo.isRequestSnatch = memStateInfo.isRequestSnatch end
                if memStateInfo.isOpenDeal ~= nil then
                    info.memStateInfo.isOpenDeal = memStateInfo.isOpenDeal
                end --是否已明牌
                if memStateInfo.isStarter ~= nil then
                    info.memStateInfo.isStarter = memStateInfo.isStarter
                end --是否可选择开始游戏 （房卡场人未满开始）
                if memStateInfo.isBonus ~= nil then
                    info.memStateInfo.isBonus = memStateInfo.isBonus
                end --是否有马牌

                if memStateInfo.specialTypeDesc ~= nil then
                    info.memStateInfo.specialTypeDesc = memStateInfo.specialTypeDesc
                end --特殊牌型
                --手牌信息
                local cards = {}
                for __, card in ipairs(memStateInfo.cards) do
                    local node = {}
                    node.color = tonumber(card.color)
                    node.size = tonumber(card.size)
                    node.id = card.id
                    cards[#cards + 1] = node
                end

                --非玩家自己，未结算时，其他人牌不发送结果
                if memStateInfo.cardCount > 0 and #cards == 0 then
                    for index = 1, memStateInfo.cardCount do
                        cards[#cards + 1] = false
                    end
                end

                info.memStateInfo.cards = cards
            else
                log4model:warn('[SM:::parseRoomMember] parse room member state info error !')
            end

            local positionInfo = {}
            local position = v.position
            if position then
                positionInfo.ip = position.ip or ''
                positionInfo.longitude = position.longitude or ''
                positionInfo.latitude = position.latitude or ''
            end

            info.positionInfo = positionInfo
            -- Model:get("Position"):setPlayerPosInfo(info.playerId, positionInfo)

            self:checkPlayerStateChange(self.memberMap[info.playerId], info)

            self.memberMap[info.playerId] = info
            -- dump(info,"info",5)
            parseMemData[#parseMemData + 1] = info.playerId
        else
            --离开房间不用更新数据
            local info = self.memberMap[v.playerId]
            if info ~= nil then
                info.memberType = v.memberType
                parseMemData[#parseMemData + 1] = info.playerId
            else
                log4model:warn('[SM:::parseRoomMember] parse room member info error ! memberType==' .. v.memberType .. ', playerId==' .. v.playerId)
            end
        end
       
    end
   
    return parseMemData
end

function class:parseRoomStateInfo(data)
    -- log('SM: parseRoomStateInfo')
    if data == nil then
        log4model:warn('SM: :: parse room state info error ! data is nil !')
        return
    end

    self.roomStateInfo = {}
    self.roomStateInfo.roomState = data.state
    if data.state then
        self.roomStateInfo.roomState = data.state
    end
    self.roomStateInfo.countDown = data.countDown
    if data.countDown then
        self.roomStateInfo.countDown = data.countDown
    end
    if data.bonusCard ~= nil then
        self.roomStateInfo.bonusCard = data.bonusCard
    end
    --房卡场 总局数、当前局数
    if data.groupConfig then
        self.roomInfo.groupNum = data.groupConfig
    end
    if data.currentGroup then
        self.roomInfo.currentGroup = data.currentGroup
    end

    --log("[SM:::parseRoomStateInfo] roomState == "..data.state..", countDown == "..data.countDown)
end

function class:parseCardConfigInfo(data)
    -- log('SM: parseCardConfigInfo')
    if data == nil then
         log4model:warn("SM: :: parse room card config info error ! data is nil !")
        return
    end

    if data.groupConfig then self.roomInfo.groupNum = data.groupConfig end   --局数
    if data.scorePayType then self.roomInfo.scorePayType = data.scorePayType end --支付类型
    if data.limit then self.roomInfo.limit = tonumber(data.limit) end --入场限制
    if data.baseChipRange then self.roomInfo.baseChipRange = data.baseChipRange end --底注范围
    if data.bonusCardSize then self.roomInfo.bonusCardSize = data.bonusCardSize end --马牌
    --[[log("==================================================")
    dump(data.baseChipRange,"data.baseChipRange")
    dump(data.groupConfig,"data.groupConfig")
    dump(data.bonusCardSize,"data.bonusCardSize")]]
    -- log(self.roomInfo)
end

function class:checkPlayerStateChange(preInfo, curInfo)
    -- log('SM: checkPlayerStateChange')
    if preInfo == nil then
        return
    end

    if preInfo.memStateInfo.isReady == false and curInfo.memStateInfo.isReady == true then
        sys.sound:playEffect('READY')
    end

    --[[if preInfo.memStateInfo.isRequestSnatch==false and curInfo.memStateInfo.isRequestSnatch==true then
		sys.sound:playEffect("SNATCH")
	end]]

    -- if preInfo.memStateInfo.isBet==false and curInfo.memStateInfo.isBet==true then
    -- 	sys.sound:playEffect("BET_COIN")
    -- end
end
