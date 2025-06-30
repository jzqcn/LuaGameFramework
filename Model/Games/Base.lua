module(..., package.seeall)

class = Model.class:subclass()

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

function class:initialize()
	super.initialize(self)

	self.responseMsg = {}
	self.passMsg = {}

	self:clear()
end

function class:clear()
	self.roomInfo = {}
	self.roomStateInfo = {}
	self.memberMap = {}
	self.seatIndexMap = {}
	self.cardConfigInfo = {}

	self.frontSeatId = nil
	self.frontId = nil
end

function class:bindResponse(type, callback, isPass)
	self.responseMsg[type] = callback
	if isPass then
		self.passMsg[type] = true
	end
end

function class:onResponse(type, data)
	local callback = self.responseMsg[type]
	if callback then
		if data.isSuccess == false then
			if not self.passMsg[type] then
				local data = {
					content = data.tips
				}
				ui.mgr:open("Dialog/ConfirmView", data)
				
				return
			end
		end

		callback(data)
	else
		log("****************** game msg missing response type ! type == "..type)
	end
end

function class:isEnabledDiatance()
	return false
end

function class:getGameId()
	return self.roomInfo.gameId
end

function class:getGameType()
	return self.roomInfo.gameType
end

function class:getMaxPlayerNum()
	return self.roomInfo.maxPlayerNum
end

function class:getMinPlayerNum()
	return self.roomInfo.minPlayerNum
end

--玩家自己座位下标从1开始，自己如果围观，则选择房主
function class:initUserSeatIndex(userId)
	local userInfo = self.memberMap[userId]
	if userInfo and userInfo.seatId ~= -1 then
		self.seatIndexMap = {}
		self.seatIndexMap[userId] = 1
		self.frontSeatId = userInfo.seatId
		self.frontId = userId
	else
		local isInit = false
		for id, v in pairs(self.memberMap) do
			if v.memStateInfo.isStarter then
				self.seatIndexMap = {}
				self.seatIndexMap[id] = 1
				self.frontSeatId = v.seatId
				self.frontId = id
				isInit = true
				break
			end
		end

		if not isInit then
			for id, v in pairs(self.memberMap) do
				self.seatIndexMap = {}
				self.seatIndexMap[id] = 1
				self.frontSeatId = v.seatId
				self.frontId = id
				isInit = true
				break
			end
		end
	end
end

function class:initOtherSeatIndex()
	local userId = Model:get("Account"):getUserId()
	-- local userIndex = self.seatIndexMap[userId]
	-- if userIndex == nil then
	-- 	return
	-- end

	local frontSeatId = self.frontSeatId
	if not frontSeatId then
		self:initUserSeatIndex(userId)

		frontSeatId = self.frontSeatId
	end

	local frontIndex = self.seatIndexMap[self.frontId]

	for id, v in pairs(self.memberMap) do
		if userId ~= id then
			local otherIndex = v.seatId - frontSeatId + frontIndex
			if otherIndex <= 0 then
				otherIndex = otherIndex + self.roomInfo.maxPlayerNum
			end

			-- log("Base::initOtherSeatIndex:: id:"..id..", seatId:"..v.seatId..", seatIndex:"..otherIndex)
			self.seatIndexMap[id] = otherIndex
		end
	end

	-- log(self.seatIndexMap)
end

function class:getPlayerSeatIndex(playerId)
	--[[if self.seatIndexMap[playerId] == nil then
		--assert(false, "player is not exist ! id : "..playerId)
	end]]

	return self.seatIndexMap[playerId]
end

--玩家座位号（自己正面）
function class:getSeatIndexMap()
	return self.seatIndexMap
end

--获取房间信息
function class:getRoomInfo()
	return self.roomInfo
end

--获取俱乐部ID
function class:getClubId()
	return self.roomInfo.clubId
end

--获取货币类型
function class:getCurrencyType()
	return self.roomInfo.currencyType 
end

--房间类型 金币场、房卡场、活动场
function class:getRoomStyle()
	return self.roomInfo.roomStyle
end

--获取成员信息
function class:getRoomMember()
	return self.memberMap
end

function class:getUserInfo()
	local userId = Model:get("Account"):getUserId()
	return self:getMemberInfoById(userId)
end

function class:removeMemberById(playerId)
	self.memberMap[playerId] = nil
	self.seatIndexMap[playerId] = nil
end

function class:getMemberInfoById(playerId)
	if self.memberMap[playerId] == nil then
		-- assert(false)
		return nil
	end

	return self.memberMap[playerId]
end

function class:getMemberInfoByIndex(seatIndex)
	for k, v in pairs(self.seatIndexMap) do
		if seatIndex == v then
			return self:getMemberInfoById(k)
		end
	end

	log4model:warn("get member info by seat index error ! seat index : "..seatIndex)
	return nil 
end

function class:setMemberReadyState(var, id)
	if not id then
		for k, v in pairs(self.memberMap) do
			if v.memStateInfo.isViewer == false then
				v.memStateInfo.isReady = var
			end
		end
	else
		local info = self.memberMap[id]
		if info then
			info.memStateInfo.isReady = var
		end
	end
end

function class:isViewer()
	local userId = Model:get("Account"):getUserId()
	local userInfo = self:getMemberInfoById(userId)
	if userInfo then
		return userInfo.memStateInfo.isViewer
	end

	return true
end

function class:isDealer()
	local userId = Model:get("Account"):getUserId()
	local userInfo = self:getMemberInfoById(userId)
	if userInfo then
		return userInfo.memStateInfo.isDealer
	else
		return false
	end
end

function class:isStarter()
	local userId = Model:get("Account"):getUserId()
	local userInfo = self:getMemberInfoById(userId)
	if userInfo then
		return userInfo.memStateInfo.isStarter
	end
	return false
end

--房间状态信息
function class:getRoomStateInfo()
	return self.roomStateInfo
end

function class:getRoomState()
	return self.roomStateInfo.roomState
end

--庄家ID
function class:getDealerId()
	for k, v in pairs(self.memberMap) do
		if v.memStateInfo.isDealer then
			return k
		end
	end

	return nil
end

--------------------版本检测（玩家已在游戏中，进入后直接被拉入游戏，检测是否下载版本）began -------------------------
function class:enterGameStage(gameName)
	StageMgr:chgStage("Game", gameName)
end

function class:checkGameVersion(gameName)
	local gameVer = "GV_" .. string.upper(gameName) .. "_VER"
	local resVer = db.var:getSysVar(gameVer)
	resVer = resVer and tonumber(resVer) or 0
	-- log("game item res ver:" .. resVer)
	if resVer > 0 then
		self:enterGameStage(gameName)
	else
		--版本检测
		local event = self:createEvent('CHECK_VERSION', 'onCheckVersion')
		patch.mgr:gameVertionStart(gameName, event)
	end
end

function class:onCheckVersion(gameName, data)
	local gameVer = "GV_" .. string.upper(gameName) .. "_VER"
	local resVer = db.var:getSysVar(gameVer)
	resVer = resVer and tonumber(resVer) or 0
	-- log(data)
	if data == nil then		
		if resVer > 0 then
			self:enterGameStage(gameName)
		else
			local data = {
				content = "获取游戏包版本失败，请稍后重试",
			}
			ui.mgr:open("Dialog/DialogView", data)
		end
	else
		local verinfo = json.decode(data)
		if verinfo.ack_code and string.lower(verinfo.ack_code) == "fail" then
			local errorModel = verinfo.errorModel
			local err
			if errorModel and errorModel.error_msg then
				err = errorModel.error_msg
			else
				err = "获取游戏包版本失败，请稍后重试"
			end

			local data = {
				content = err,
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		if resVer >= verinfo.version then
			self:enterGameStage(gameName)
		else
			verinfo.gameName = gameName

			ui.mgr:open("Hall/AutoPatchUpdate", verinfo)
		end
	end
end

--------------------版本检测（玩家已在游戏中，进入后直接被拉入游戏，检测是否下载版本） end -------------------------


----------------------------回放相关------------------------------
function class:getPokerCardColor(strColor)
	return POKER_COLOR[strColor]
end

function class:getPokerCardSize(strSize)
	return POKER_SIZE[strSize]
end

function class:setPlayBackInfo(info, details, selIndex)
	if not info or not details then
		log4model:warn("[Paodekuai::setPlayBackInfo] error :: info is nil or details is nil !")		
		return
	end

	-- log(info)
	-- log("selIndex:"..selIndex)

	local dbName = info.gameName.."CardConfig"
	local data = db.mgr:getDBById(dbName, info.playId)
	-- log(data)

	self:clear()

	self.roomInfo.currencyType = data.currencyType

	self.roomInfo.playId = info.playId
	self.roomInfo.typeId = info.typeId
	self.roomInfo.roomId = info.roomId	
	self.roomInfo.maxPlayerNum = table.nums(info.playerData)
	self.roomInfo.minPlayerNum = self.roomInfo.maxPlayerNum
	self.roomInfo.roomStyle = Common_pb.RsCard
	self.roomInfo.viewCount = 0
	self.roomInfo.isPlayBack = true

	local userId = Model:get("Account"):getUserId()
	local playerInfo = info.playerData[userId]

	self:initUserSeatIndex(userId, playerInfo.seatIndex)

	local groupInfo = info.groupData[selIndex]
	self.roomInfo.currentGroup = selIndex
	self.roomInfo.groupNum = table.nums(info.groupData) --#(info.groupData)

	-- log(groupInfo)	
	for i, v in ipairs(groupInfo.playerGroup) do
		playerInfo = {}
		playerInfo.playerId = v.playerId

		local data = info.playerData[v.playerId]		
		playerInfo.playerName = data.nickName
		playerInfo.headimage = data.headImage
		playerInfo.seatId = data.seatIndex
		playerInfo.sex = tonumber(data.sex) or 1 --性别,1-男、2-女

		playerInfo.memStateInfo = {}
		playerInfo.memStateInfo.isSettlement = false 	--是否结算
		if v.cardKind == 1 then
			--扑克
			local initCards = json.decode(v.initCards)
			playerInfo.memStateInfo.cardCount = #initCards			--手牌数量
			-- log(initCards)
			
			self.roomInfo.handCardCount = #initCards

			local cards = {}
			for _, card in ipairs(initCards) do
				local node = {}
				node.id = card.id
				node.color = self:getPokerCardColor(card.color)
				node.size = self:getPokerCardSize(card.size)
				node.value = node.size

				-- log(node)
				
				--A变成14，2变成15
				if node.value == 1 then
					node.value = 14
				elseif node.value == 2 then
					node.value = 15
				end

				cards[#cards + 1] = node
			end

			playerInfo.memStateInfo.cards = cards
		end

		playerInfo.memStateInfo.isOffLine = false		--是否离线
		playerInfo.memStateInfo.isReady = false			--是否准备
		playerInfo.memStateInfo.isViewer = false		--是否旁观

		playerInfo.memStateInfo.resultCoin = v.bp
		playerInfo.coin = v.totalPb

		self.memberMap[playerInfo.playerId] = playerInfo
	end

	self:initOtherSeatIndex()

	self.singleState = {}

	for i = 1, self.roomInfo.maxPlayerNum do
		self.singleState[i] = false
	end

	self.playBackDetail = details
	self.playBackStep = 0

	--进入游戏
	StageMgr:chgStage("Game", info.gameName)
end

--获取下一步回放数据
function class:getNextPlayBackStep()
	if not self.playBackDetail then
		log4model:warn("get next play back step data error ! details is nil !")
		return nil
	end

	self.playBackStep = self.playBackStep + 1
	log("step index : "..self.playBackStep)

	local stepsData = self.playBackDetail.steps
	if self.playBackStep > #stepsData then
		--牌局结束
		return nil
	else
		return stepsData[self.playBackStep]
	end
end

--是否回放
function class:getIsPlayBack()
	return self.roomInfo.isPlayBack
end


