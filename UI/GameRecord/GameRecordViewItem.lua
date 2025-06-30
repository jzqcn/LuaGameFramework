module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()
	
end

function prototype:refresh(info, index)
	-- for i = 1, 4 do
	-- 	self["panelRole_"..i]:setVisible(false)
	-- end

	-- log(info)

	local gameInfo = Model:get("Hall"):getCardItem(info.typeId)
	if gameInfo then
		local itemName = string.lower(gameInfo.itemName)
		self.imgIcon:ignoreContentAdaptWithSize(true)
		self.imgIcon:loadTexture(string.format("resource/csbimages/GameRecord/icon_%s.png", itemName))
	end

	--玩家累计分数
	local playerScore = {}
	local data = info.groupData
	-- for i, v in ipairs(data) do
	for i, v in pairs(data) do
		for _, m in ipairs(v.playerGroup) do
			if playerScore[m.playerId] == nil then
				playerScore[m.playerId] = 0
			end
			playerScore[m.playerId] = playerScore[m.playerId] + m.bp
		end
	end

	local playerData = {}
	for k, v in pairs(info.playerData) do
		local item = {}
		item.nickName = v.nickName
		item.playerId = v.playerId
		item.score = playerScore[v.playerId]

		playerData[#playerData + 1] = item
		-- self["txtName_"..v.seatIndex]:setString(Assist.String:getLimitStrByLen(v.nickName, 8))
		-- self["txtResult_"..v.seatIndex]:setString(Assist.NumberFormat:amount2TrillionText(playerScore[v.playerId]))
		-- self["panelRole_"..v.seatIndex]:setVisible(true)
	end

	


	local param = 
	{
		data = playerData,
		ccsNameOrFunc = "GameRecord/RecordPlayerItem",
		dataCheckFunc = function (info1, elem) return info1 == elem end
	}
    self.listview:createItems(param)
    self.listview:setScrollBarEnabled(false)

	local roomId = string.format("%04d", info.roomId)
	self.txtRoomId:setString("房间:"..roomId)

	local time = math.floor(info.time / 1000)
	local time_t = util.time:getTimeDate(time)
	local timeStr = string.format("%d-%02d-%02d", time_t.year, time_t.month, time_t.day)
	self.txtTime:setString(timeStr)

	timeStr = string.format("%02d:%02d", time_t.hour, time_t.min)
	self.txtTime2:setString(timeStr)

	self.info = info

	self:playAction(index)
end

function prototype:onBtnDetailsClick()
	ui.mgr:open("GameRecord/GamePlaybackView", self.info)
end

function prototype:playAction(index)
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.rootNode:setVisible(false)

	local action = self:createListItemBezierConfig(self.rootNode, actionOver, 0.5, 0.15+0.1*index)
	self.action = action
end

