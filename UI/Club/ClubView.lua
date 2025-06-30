module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter()
	--UI事件
	self:bindUIEvent("Club.ClubMembers", "uiEvtClubMembers")
	self:bindUIEvent("Club.HideMembers", "uiEvtHideMembers")
	self:bindUIEvent("Club.DissolveClub", "uiEvtDissolveClub")
	self:bindUIEvent("Club.ExitClub", "uiEvtExitClub")
	self:bindUIEvent("Club.InviteFriend", "uiEvtInviteFriend")
	self:bindUIEvent("Club.SelectClub", "uiEvtSelectClub")
	self:bindUIEvent("Club.ServiceCharge", "uiServiceCharge")

	--Model消息事件
	self:bindModelEvent("Club.EVT.PUSH_CLUB_LIST_MSG", "onPushClubList")
	self:bindModelEvent("Club.EVT.PUSH_CLUB_ROOM_LIST", "onPushClubRoomList")
	self:bindModelEvent("Club.EVT.PUSH_CLUB_APPLY_LIST", "onPushClubApplyList")
	self:bindModelEvent("Club.EVT.PUSH_CLUB_REQUEST_LEAVE", "onPushClubLeave")
	self:bindModelEvent("Club.EVT.PUSH_CLUB_DISSOLVE", "onPushClubDissolve")

	self.nodeMenu:setVisible(false)
	self.nodeMemsInfo:setVisible(false)
	self.imgOwnerMsg:setVisible(false)

	self.btnApplyMsg:setVisible(false)
	self.imgApplyMsgRed:setVisible(false)
	self.btnIncome:setVisible(false)
	self.btnMenu:setVisible(false)

	local param = 
	{
		data = {},
		ccsNameOrFunc = "Club/ClubViewItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}

    self.clubListview:createItems(param)

    --请求列表
    self.selClubId = nil
    self.selIndex = 0

	Model:get("Club"):requestClubList()
	
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.rootNode, actionOver)
    self:unEnabledRefresh()
end

--俱乐部列表
function prototype:onPushClubList(data)
	--刷新俱乐部列表
	self.clubListview:refreshListView(data)

	if #data > 0 then
		local selIndex
		for i, v in ipairs(data) do
			-- if v.isOwner or v.isManager then
			-- 	self.btnApplyMsg:setVisible(true)
			-- 	--自己是俱乐部主或者管理员，请求查看是否有新申请消息
			-- 	Model:get("Club"):requestClubApplyList(v.id)
			-- end
			Model:get("Club"):requestClubApplyList(v.id)

			if self.selClubId and self.selClubId == v.id then
				selIndex = i
			end

			--请求俱乐部房间数据
			Model:get("Club"):requestClubRoomList(v.id)
		end

		--俱乐部主才有收入
		-- if isOwner then
		-- 	self.btnIncome:setVisible(true)
		-- end

		if not selIndex then
			selIndex = 1
			self.selClubId = data[1].id
		end

		self.selIndex = selIndex

		local itemNode = self.clubListview:getSubItemByIdx(selIndex)
		if itemNode then
			itemNode:setIsSelected(true)
		end

		self:setSelectedClubNode(data[selIndex])

		self.btnMenu:setVisible(true)
	else
		self.nodeRoomInfo:setClubInfo(nil)
		self.nodeRoomInfo:refreshRoomData({})

		self.nodeMemsInfo:setVisible(false)

		self.btnIncome:setVisible(false)

		self.btnMenu:setVisible(false)
		self.selClubId = nil
		
		self.btnApplyMsg:setVisible(false)
		self.imgApplyMsgRed:setVisible(false)

		self.imgOwnerMsg:setVisible(false)
	end
end

--俱乐部房间列表
function prototype:onPushClubRoomList(roomList, clubId)
	-- log(roomList)
	if #roomList > 0 then
		-- log("onPushClubRoomList : "..clubId)

		if self.selClubId == clubId then
			self.nodeRoomInfo:refreshRoomData(roomList)
		end
	else
		if self.selClubId == clubId then
			self.nodeRoomInfo:refreshRoomData()
		end
	end
end

--申请信息列表
function prototype:onPushClubApplyList(applyList)
	-- log(applyList)
	applyList = applyList or {}
	if #applyList > 0 then
		--显示红点
		self.btnApplyMsg:setVisible(true)
		self.imgApplyMsgRed:setVisible(true)
	else
		-- self.imgApplyMsgRed:setVisible(false)
	end
end

--离开俱乐部
function prototype:onPushClubLeave()
	if self.selClubId then
		Model:get("Club"):removeClubData(self.selClubId)

		self:onPushClubList(Model:get("Club"):getClubList())
	end
end

--解散俱乐部
function prototype:onPushClubDissolve()
	if self.selClubId then
		local clubData = Model:get("Club"):getClubData(self.selClubId)
		if clubData and clubData.isOwner then
			Model:get("Club"):removeClubData(self.selClubId)

			self:onPushClubList(Model:get("Club"):getClubList())
		end
	end
end

--5s后才能继续刷新
function prototype:unEnabledRefresh()
	self.bEnableRefresh = false
    util.timer:after(5.0*1000, self:createEvent("ENABLE_REFRESH", function()
		self.bEnableRefresh = true
	end))
end

function prototype:refreshClubView()
	Model:get("Club"):requestClubList()

	self:unEnabledRefresh()
end

--刷新
function prototype:onBtnRefreshTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.bEnableRefresh == true then
			self:refreshClubView()
		end
	end
end

--收入
function prototype:onBtnIncomeTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local selClubData = Model:get("Club"):getClubData(self.selClubId)
		-- log(selClubData)
		if selClubData then
			ui.mgr:open("Club/ClubIncomeView", selClubData)
		else
			log4ui:error("[ClubView::onBtnMenuTouch] get select club data failed ! ")
		end
	end
end

--菜单
function prototype:onBtnMenuTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local selClubData = Model:get("Club"):getClubData(self.selClubId)
		if selClubData then
			self.nodeMenu:setIsOwner(selClubData.isOwner)
			self.nodeMenu:setVisible(true)
		else
			log4ui:error("[ClubView::onBtnMenuTouch] get select club data failed ! ")
		end
	end
end

--选中某个俱乐部
function prototype:uiEvtSelectClub(clubInfo, selIndex)
	local itemNode = self.clubListview:getSubItemByIdx(self.selIndex)
	if itemNode then
		itemNode:setIsSelected(false)
	end

	local clubData = Model:get("Club"):getClubData(clubInfo.id)
	self.selClubId = clubData.id

	local itemNode = self.clubListview:getSubItemByIdx(selIndex)
	if itemNode then
		itemNode:setIsSelected(true)

		self.selIndex = selIndex
		self:setSelectedClubNode(clubData)
		-- self.nodeRoomInfo:setClubInfo(clubData)
		-- self.nodeRoomInfo:refreshRoomData(clubData.roomList)
	end
end

function prototype:setSelectedClubNode(clubData)
	if clubData.isOwner then
		self.btnIncome:setVisible(true)
	else
		self.btnIncome:setVisible(false)
	end

	self.nodeRoomInfo:setVisible(true)
	self.nodeMemsInfo:setVisible(false)

	self.nodeRoomInfo:setClubInfo(clubData)
	self.nodeRoomInfo:refreshRoomData(clubData.roomList)

	local ownerMsg = clubData.members[1]
	if util:getPlatform() == "win32" then
		sdk.account:getHeadImage(ownerMsg.userId, ownerMsg.userName, self.imgOwner)
	else
		-- sdk.account:getHeadImage(ownerMsg.userId, ownerMsg.userName, self.imgOwner, ownerMsg.headImage)
		if self:existEvent('LOAD_HEAD_IMG') then
			self:cancelEvent('LOAD_HEAD_IMG')
		end
		sdk.account:loadHeadImage(ownerMsg.userId, ownerMsg.userName, ownerMsg.headImage, 
			self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.imgOwner)
	end
	self.txtOwner:setString(Assist.String:getLimitStrByLen(ownerMsg.userName))
	self.txtOwnerId:setString(ownerMsg.userId)

	self.txtCardNum:setString(tostring(clubData.cardNum))

	self.imgOwnerMsg:setVisible(true)

	--刷新一下成员。创建房间的时候需要判断是不是管理员
	-- if self.nodeMemsInfo:isVisible() then
		self.nodeMemsInfo:refreshMembersData(self.selClubId)
	-- end
end

function prototype:onLoadHeadImage(filename)
	self.imgOwner:loadTexture(filename)
end

--成员信息
function prototype:uiEvtClubMembers()
	self.nodeRoomInfo:setVisible(false)

	self.nodeMemsInfo:refreshMembersData(self.selClubId)
	self.nodeMemsInfo:setVisible(true)
end

--隐藏成员信息
function prototype:uiEvtHideMembers()
	self.nodeRoomInfo:setVisible(true)
	self.nodeMemsInfo:setVisible(false)
end

--解散
function prototype:uiEvtDissolveClub()
	local clubData = Model:get("Club"):getClubData(self.selClubId)

	local exitFunc = function ()
		Model:get("Club"):requestDeleteClub(self.selClubId)
	end

	local data = {
		okFunc = exitFunc,
		content = string.format("是否确认解散【%s】俱乐部？", clubData.name)
	}
	ui.mgr:open("Dialog/ConfirmDlg", data)
end

--退出
function prototype:uiEvtExitClub()
	local clubData = Model:get("Club"):getClubData(self.selClubId)

	local exitFunc = function ()
		Model:get("Club"):requestLeaveClub(self.selClubId)
	end

	local data = {
		okFunc = exitFunc,
		content = string.format("是否确认退出【%s】俱乐部？", clubData.name)
	}
	ui.mgr:open("Dialog/ConfirmDlg", data)
end

--服务费调整
function prototype:uiServiceCharge()
	local clubData = Model:get("Club"):getClubData(self.selClubId)
	ui.mgr:open("Club/ServiceChargeView", clubData)
end

--邀请好友
function prototype:uiEvtInviteFriend()
	local clubData = Model:get("Club"):getClubData(self.selClubId)

	local shareTable = {}
	shareTable.ShareType = "Text" --内容（文本：Text， 链接：Link, 图片：Image）
	shareTable.Scene = "SceneSession"  --分享类型（朋友圈：SceneTimeline， 好友：SceneSession）

	--字符串	
	shareTable.Text = string.format("快来一起加入【%s】俱乐部【%d】玩游戏吧！", clubData.name, self.selClubId)

	local str = json.encode(shareTable)
	util:fireCoreEvent(REFLECT_EVENT_WEIXIN_SHARE, 0, 0, str)
end

--创建俱乐部
function prototype:onBtnCreateClubClick()
	ui.mgr:open("Club/CreateClubView")
end

--申请加入
function prototype:onBtnJoinClubClick()
	ui.mgr:open("Club/JoinClubView")
end

--申请信息
function prototype:onBtnApplyMsgClick()
	ui.mgr:open("Club/ApplyMsgView")
end


function prototype:onBtnCloseClick()
	self:close()
end

