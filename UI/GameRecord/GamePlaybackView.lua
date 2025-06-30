module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter(info)
	self:bindUIEvent("PlayBack.RequestDetail", "uiEvtRequestDetail")

	self:bindModelEvent("PlayBack.EVT.PUSH_PLAYBACK_DETAIL_DATA", "onPushDetailData")

	--玩家累计分数
	local playerScore = {}
	local data = info.groupData
	-- for i, v in ipairs(data) do
	for index, v in pairs(data) do
		for _, m in ipairs(v.playerGroup) do
			if playerScore[m.playerId] == nil then
				playerScore[m.playerId] = 0
			end
			playerScore[m.playerId] = playerScore[m.playerId] + m.bp
		end
	end

	local playerNum = 0
	local roleData = {}
	for k, v in pairs(info.playerData) do
		local seatIndex = v.seatIndex
		local item = {}
		item.nickName = v.nickName
		item.playerId = v.playerId
		item.score = playerScore[v.playerId]
		item.seatIndex = v.seatIndex
		
		roleData[seatIndex] = item
		
		-- self["txtName_"..seatIndex]:setString(Assist.String:getLimitStrByLen(v.nickName, 8))
		-- self["txtID_"..seatIndex]:setString("ID:"..v.playerId)

		-- local score = playerScore[v.playerId]
		-- if score > 0 then
		-- 	self["fntWin_"..seatIndex]:setString(Assist.NumberFormat:amount2TrillionText(score))
		-- 	self["fntLose_"..seatIndex]:setVisible(false)
		-- else
		-- 	self["fntLose_"..seatIndex]:setString(Assist.NumberFormat:amount2TrillionText(score))
		-- 	self["fntWin_"..seatIndex]:setVisible(false)
		-- end

		-- playerNum = playerNum + 1
	end

	-- for i = playerNum + 1, 4 do
	-- 	self["txtName_"..i]:setVisible(false)
	-- 	self["txtID_"..i]:setVisible(false)
	-- 	self["fntWin_"..i]:setVisible(false)
	-- 	self["fntLose_"..i]:setVisible(false)
	-- end

	local listData = table.values(data)
	local function sortFunc(a, b)
		return a.index < b.index
	end

	table.sort(listData, sortFunc)

	local param = 
	{
		data = listData,
		ccsNameOrFunc = "GameRecord/GamePlaybackViewItem",
		dataCheckFunc = function (info, elem) return info == elem end,
		autoContentSize = true
	}
    self.listview:createItems(param)


    param = 
	{
		data = roleData,
		ccsNameOrFunc = "GameRecord/GamePlayBackRoleItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.listRole:createItems(param)
    self.listRole:setScrollBarEnabled(false)

  --   if #roleData > 5 then
  --   	self.imgArrow:setVisible(true)
		-- self.imgArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.8), cc.FadeIn:create(0.8))))
  --   else
  --   	self.imgArrow:setVisible(false)
  --   end

    self.info = info

    Model:get("PlayBack"):setPlaybackInfo(info)

	--[[local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)]]
end

-- function prototype:onBtnArrowClick()
-- 	self.listRole:jumpToRight()
-- end

--请求详情
function prototype:uiEvtRequestDetail(index)
	-- log("request playback detail id == "..self.info.id..", index == "..index)
	Model:get("PlayBack"):requestRecordDetail(self.info.id, index)
	self.selIndex = index
end

--返回详情数据。进入回放
function prototype:onPushDetailData(detailData)
	local gameName = string.lower(self.info.gameName)
	if string.find(gameName, "paodekuai") then
		self.info.gameName = "Paodekuai"
		Model:get("Games/Paodekuai"):setPlayBackInfo(self.info, detailData, self.selIndex)

	elseif string.find(gameName, "mushiwang") then
		
	else
		log4ui:warn("[GamePlaybackView::onPushDetailData] error :: get play back game name error ! game name == "..gameName)
	end 
end

function prototype:onBtnCloseClick()
	self:close()

	ui.mgr:open("GameRecord/GameRecordView", Model:get("PlayBack"):getPlaybackList())
end



