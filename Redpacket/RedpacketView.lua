module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local MAX_REDPACKET_NUM = 9

local Redpacket_pb = Redpacket_pb

local ModelData = nil

function prototype:enter(selType)
	--Model消息事件
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_ENTER_ROOM", "onPushRoomEnter")
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_ROOM_STATE", "onPushRoomState")
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_MEMBER_STATUS", "onPushMemberStatus")
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_SNATCH", "onPushSnatch")
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_SNATCH_RESULT", "onPushSnatchResult")
	-- self:bindModelEvent("Games/Redpacket.EVT.PUSH_LAYMINES", "onPushLaymines")
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_SETTLEMENT", "onPushSettlement")
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_FLOOR", "onPushFloor")
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_BONUS", "onPushBonus")
	-- self:bindModelEvent("Games/Redpacket.EVT.PUSH_BONUS_TAKE", "onPushBonusTake")

	--货币刷新
	self:bindModelEvent("SynData.EVT.PUSH_SYN_USER_DATA", "onPushSynUserData")

	for i = 1, MAX_REDPACKET_NUM do
		if i <= 5 then
			self["nodePlayer_"..i]:setSide(1)
		else
			self["nodePlayer_"..i]:setSide(2)
		end
	end

	self.imgWelfareRed:setVisible(false)

	--我的福利 动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/Redpacket/anim/money_ske.dbbin", "welfareAnim")
    factory:loadTextureAtlasData("resource/Redpacket/anim/money_tex.json", "welfareAnim")

    local size = self.panelWelfare:getContentSize()
    local itemAnimation = factory:buildArmatureDisplay("armatureName", "welfareAnim")
    if itemAnimation then
	    itemAnimation:getAnimation():play("newAnimation", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2)
	    self.panelWelfare:addChild(itemAnimation)

	    self.welfareAnim = itemAnimation
	end

	--爬楼
	factory:loadDragonBonesData("resource/Redpacket/anim/floor_ske.dbbin", "floorAnim")
    factory:loadTextureAtlasData("resource/Redpacket/anim/floor_tex.json", "floorAnim")

    size = self.panelFloor:getContentSize()
    itemAnimation = factory:buildArmatureDisplay("armatureName", "floorAnim")
    if itemAnimation then
	    itemAnimation:getAnimation():play("newAnimation", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2)
	    self.panelFloor:addChild(itemAnimation)

	    self.floorAnim = itemAnimation
	end

	ModelData = Model:get("Games/Redpacket")

	--播放背景音乐
	-- sys.sound:playMusicByFile("resource/Redpacket/audio/music_bg.mp3")

	--播放手指特效
	self.isPlayedFingerAnim = false
	-- util.timer:after(500, self:createEvent("playFingerAnimation"))

	self:onPushRoomEnter()
end

function prototype:exit()
	local itemAnimation = self.welfareAnim
	if itemAnimation then
		itemAnimation:removeFromParent()
		itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("welfareAnim")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("welfareAnim")
	end

	itemAnimation = self.floorAnim
	if itemAnimation then
		itemAnimation:removeFromParent()
		itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("floorAnim")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("floorAnim")
	end

	itemAnimation = self.snatchAnimation
	if itemAnimation then
		itemAnimation:removeFromParent()
		itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("snatchAnimation")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("snatchAnimation")
	end

	itemAnimation = self.bombAnimation
	if itemAnimation then
		itemAnimation:removeFromParent()
		itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("bombAnimation")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("bombAnimation")
	end

	itemAnimation = self.fingerAnimation
	if itemAnimation then
		itemAnimation:removeFromParent()
		itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("fingerAnimation")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("fingerAnimation")
	end

	self:stopPigAnimation()
end

--同步货币数据
function prototype:onPushSynUserData(data)
	--将金币这算成人民币 1:100
	self.txtUserGold:setString(Assist.NumberFormat:amount2TrillionText(data.gold))

	local userInfo = ModelData:getMemberInfoById(self.userId)
	if userInfo then
		userInfo.coin = data.gold
	end
end

function prototype:gameClear()
	for i = 1, MAX_REDPACKET_NUM do
		self["nodePlayer_" .. i]:setVisible(false)
	end

	self.fntDealerWin:setVisible(false)
	self.fntDealerLose:setVisible(false)
	self.fntUserWin:setVisible(false)
	self.fntUserLose:setVisible(false)

	self.snatchIndex = 0
	self.snatchInfoMap ={}
	self.redpacketRemainder = 0
end

function prototype:onPushRoomEnter()
	self:gameClear()

	self:onPushRoomInfo()
	self:onPushRoomState()
	self:onPushMemberStatus()

	local bonusList = ModelData:getWelfareList()
	if #bonusList > 0 then
		self.imgWelfareRed:setVisible(true)
	else
		self.imgWelfareRed:setVisible(false)
	end

	local name = ""
	local snatchResult = ModelData:getSnatchResult()
	for i, v in ipairs(snatchResult) do
		name = "nodePlayer_"..i
		self[name]:setPlayerInfo(v, self.roomState == Redpacket_pb.State_Settlement)
		self.snatchInfoMap[v.index] = self[name]
	end
	--记录已抢红包下标
	self.snatchIndex = #snatchResult
end

function prototype:onPushRoomInfo()
	--玩家信息
	local userInfo = Model:get("Account"):getUserInfo()
	self.userInfo = userInfo
	self.userId = userInfo.userId
	self.txtUserName:setString(Assist.String:getLimitStrByLen(userInfo.nickName))
	self.txtUserGold:setString(Assist.NumberFormat:amount2TrillionText(userInfo.gold))

	local roomInfo = ModelData:getRoomInfo()
	self.mutiple = roomInfo.mutiple

	sdk.account:loadHeadImage(userInfo.userId, userInfo.nickName, userInfo.headImage, 
		self:createEvent('LOAD_USER_HEAD_IMG', 'onLoadUserHeadImage'), self.imgHeadIcon)
end

function prototype:onLoadUserHeadImage(filename)
	self.imgHeadIcon:loadTexture(filename)
end

function prototype:onLoadDealerHeadImage(filename)
	self.imgDealerIcon:loadTexture(filename)
end

--庄家数据 红包信息
function prototype:setDealerInfo(redpacketInfo, isBlessing)
	isBlessing = isBlessing or false
	if isBlessing then
		self.txtDealerName:setVisible(true)
		self.imgDealerIcon:setVisible(true)
		self.txtDealerName:setString("金猪送福")
		self.imgDealerFrame:setVisible(false)
		self.imgDealerIcon:loadTexture("resource/Redpacket/csbimages/systemDealer.png")
		self.txtBombId:setVisible(false)
		self.dealerId = -1
	else
		local dealerInfo = ModelData:getMemberInfoById(redpacketInfo.playerId)
		if dealerInfo then
			self.dealerId = redpacketInfo.playerId
			self.txtDealerName:setVisible(true)
			self.imgDealerIcon:setVisible(true)
			self.txtDealerName:setString(dealerInfo.playerName)
			sdk.account:loadHeadImage(dealerInfo.playerId, dealerInfo.playerName, dealerInfo.headimage, 
				self:createEvent('LOAD_DEALER_HEAD_IMG', 'onLoadDealerHeadImage'), self.imgDealerIcon)
		else
			self.dealerId = nil
			self.txtDealerName:setVisible(false)
			self.imgDealerIcon:setVisible(false)
		end

		self.imgDealerFrame:setVisible(true)
		self.txtBombId:setString(redpacketInfo.minesNum) --雷号
		self.txtBombId:setVisible(true)
	end

	self.txtRedpacketValue:setString(Assist.NumberFormat:amount2Hundred(redpacketInfo.redpacketCoin)) --红包金额
	self.txtRedpacketNum:setString(redpacketInfo.redpacketRemainder) --剩余个数

	self.redpacketRemainder = redpacketInfo.redpacketRemainder
end

function prototype:onPushRoomState()
	local roomStateInfo = ModelData:getRoomStateInfo()
	if roomStateInfo then
		local roomState = roomStateInfo.roomState
		local countDown = roomStateInfo.countDown
		local isBlessing = roomStateInfo.isBlessing
		-- log("onPushRoomState::roomState ======= " .. roomState)

		local imgRedpacket
		if isBlessing then
			imgRedpacket = self.imgRedpacketPig
			self.imgRedpacketNor:setVisible(false)

			sys.sound:playMusicByFile("resource/Redpacket/audio/music_bg2.mp3")
		else
			imgRedpacket = self.imgRedpacketNor
			self.imgRedpacketPig:setVisible(false)

			sys.sound:playMusicByFile("resource/Redpacket/audio/music_bg.mp3")
		end
		imgRedpacket:setVisible(true)

		if roomState == Redpacket_pb.State_Ready then
			--准备红包阶段
			self:gameClear()
			self.nodeCountdown:stop()

			self.panelRedpacket:setEnabled(false)
			Assist:setNodeGray(imgRedpacket)

		elseif roomState == Redpacket_pb.State_Snatch then
			--抢红包阶段
			self.nodeCountdown:start(countDown, roomState)

			self.panelRedpacket:setEnabled(true)
			Assist:setNodeColorful(imgRedpacket)

			if not self.isPlayedFingerAnim then
				self:playFingerAnimation()
			end

			if isBlessing then
				self:playPigAnimation()
			end

		elseif roomState == Redpacket_pb.State_Settlement then
			--结算
			self.nodeCountdown:start(countDown, roomState)

			if isBlessing then
				self:stopPigAnimation()
			end

			self.panelRedpacket:setEnabled(false)
			Assist:setNodeGray(imgRedpacket)

		else

		end

		self:setDealerInfo(roomStateInfo.redpacketInfo, isBlessing)
		self.roomState = roomState
	end
end

function prototype:onPushMemberStatus(refreshList)
	local roomMember = ModelData:getRoomMember()
	local memNum=table.nums(roomMember)
	refreshList = refreshList or table.keys(roomMember)
	if refreshList and #refreshList > 0 then
		for index, id in ipairs(refreshList) do
			local playerInfo = roomMember[id]
			if playerInfo then
				if playerInfo.memberType == Common_pb.Add then
					--新加入成员

				elseif playerInfo.memberType == Common_pb.Update then
					--更新成员数据。玩家充值时，金币发生变化
					
				else
					--离开房间
					if self.userId == id then
						StageMgr:chgStage("Hall")
					else
						ModelData:removeMemberById(id)				
					end
				end
			else
				--log4ui:warn("[LonghudouView::onPushMemberStatus] get player info failed ! player id == " .. id)
			end
		end
	end

	self.txtOnlineNum:setString(memNum .. "人")
end

--申请埋雷
function prototype:onBtnRequestBombTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then 
		ui.mgr:open("Redpacket/ApplyBuryBombView")
	end
end

function prototype:onPushFloor()
	
end

function prototype:onPushBonus(bonusList)
	if #bonusList > 0 then
		self.imgWelfareRed:setVisible(true)
	else
		self.imgWelfareRed:setVisible(false)
	end
end

function prototype:playPigAnimation()
	local armatureDisplay = self.pigAnimation
	if armatureDisplay == nil then
		local factory = dragonBones.CCFactory:getFactory()
		factory:loadDragonBonesData("resource/Redpacket/anim/pig_ske.dbbin", "pigAnimation")
	    factory:loadTextureAtlasData("resource/Redpacket/anim/pig_tex.json", "pigAnimation")

	    local size = self.panelRedpacket:getContentSize()
	    local armatureDisplay = factory:buildArmatureDisplay("armatureName", "pigAnimation")
	    if armatureDisplay then
	    	--监听播放完成事件
	  --   	local function eventCustomListener(event)
		 --    	armatureDisplay:setVisible(false)
		 --    end
		 --    local listener = cc.EventListenerCustom:create("complete", eventCustomListener)
		 --    armatureDisplay:getEventDispatcher():setEnabled(true)
			-- armatureDisplay:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

		    armatureDisplay:setPosition(size.width/2, size.height/2)
		    --动画播放。只播放一次
		    armatureDisplay:getAnimation():play("newAnimation", 0)
		    self.panelRedpacket:addChild(armatureDisplay)
		    self.pigAnimation = armatureDisplay
		end

		-- local roomStateInfo = ModelData:getRoomStateInfo()
		-- local redpacketInfo = roomStateInfo.redpacketInfo
		-- local fntNum = cc.Label:createWithBMFont("resource/Redpacket/bmFonts/font_win.fnt", tostring(redpacketInfo.redpacketCoin/100))
		-- fntNum:setScale(0.7)
		-- fntNum:setPosition(size.width/2+5, size.height/2-93)
		-- self.panelRedpacket:addChild(fntNum, 0, 999)
	else
		-- armatureDisplay:setVisible(true)
		-- armatureDisplay:getAnimation():play("newAnimation", 0)
	end
end

function prototype:stopPigAnimation()
	if self.pigAnimation then
		local itemAnimation = self.pigAnimation
		if itemAnimation then
			itemAnimation:removeFromParent()
			itemAnimation:dispose()

			dragonBones.CCFactory:getFactory():removeDragonBonesData("pigAnimation")
			dragonBones.CCFactory:getFactory():removeTextureAtlasData("pigAnimation")
		end
		self.pigAnimation = nil
	end

	-- self.panelRedpacket:removeChildByTag(999)
end

function prototype:playFingerAnimation()
	local armatureDisplay = self.fingerAnimation
	if armatureDisplay == nil then
		local factory = dragonBones.CCFactory:getFactory()
		factory:loadDragonBonesData("resource/Redpacket/anim/shouzhi_ske.dbbin", "fingerAnimation")
	    factory:loadTextureAtlasData("resource/Redpacket/anim/shouzhi_tex.json", "fingerAnimation")

	    local armatureDisplay = factory:buildArmatureDisplay("armatureName", "fingerAnimation")
	    if armatureDisplay then
	    	--监听播放完成事件
	    	local function eventCustomListener(event)
		    	armatureDisplay:setVisible(false)
		    end
		    local listener = cc.EventListenerCustom:create("complete", eventCustomListener)
		    armatureDisplay:getEventDispatcher():setEnabled(true)
			armatureDisplay:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

		    local size = self.panelRedpacket:getContentSize()
		    armatureDisplay:setPosition(size.width/2+50, size.height/2-90)
		    --动画播放。只播放一次
		    armatureDisplay:getAnimation():play("shouzhi", 3)
		    self.panelRedpacket:addChild(armatureDisplay, 10)
		    self.fingerAnimation = armatureDisplay
		end
	else		
		armatureDisplay:setVisible(true)
		armatureDisplay:getAnimation():play("shouzhi", 3)
	end

	self.isPlayedFingerAnim = true
end

--播放中雷效果
function prototype:playBombAnimation()
	local armatureDisplay = self.bombAnimation
	if armatureDisplay == nil then
		local factory = dragonBones.CCFactory:getFactory()
		factory:loadDragonBonesData("resource/Redpacket/anim/zhonglei_ske.dbbin", "bombAnimation")
	    factory:loadTextureAtlasData("resource/Redpacket/anim/zhonglei_tex.json", "bombAnimation")

	    armatureDisplay = factory:buildArmatureDisplay("armatureName", "bombAnimation")
	    if armatureDisplay then
	    	--监听播放完成事件
	    	local function eventCustomListener(event)
		    	armatureDisplay:setVisible(false)
		    end
		    local listener = cc.EventListenerCustom:create("complete", eventCustomListener)
		    armatureDisplay:getEventDispatcher():setEnabled(true)
			armatureDisplay:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

		    local size = self.panelRedpacket:getContentSize()
		    armatureDisplay:setPosition(size.width/2, size.height/2)
		    --动画播放。只播放一次
		    armatureDisplay:getAnimation():play("zhonglei", 1)
		    self.panelRedpacket:addChild(armatureDisplay, self.snatchIndex)
		    self.bombAnimation = armatureDisplay
		end
	else
		armatureDisplay:setLocalZOrder(self.snatchIndex)
		armatureDisplay:setVisible(true)
		armatureDisplay:getAnimation():play("zhonglei", 1)
	end
end

--播放抢红包特效
function prototype:playSnatchAnimation()
	local armatureDisplay = self.snatchAnimation
	if armatureDisplay == nil then
		local factory = dragonBones.CCFactory:getFactory()
		factory:loadDragonBonesData("resource/Redpacket/anim/qianghongbao_ske.dbbin", "snatchAnimation")
	    factory:loadTextureAtlasData("resource/Redpacket/anim/qianghongbao_tex.json", "snatchAnimation")

	    armatureDisplay = factory:buildArmatureDisplay("armatureName", "snatchAnimation")
	    if armatureDisplay then
	    	--监听播放完成事件
	    	local function eventCustomListener(event)
		    	armatureDisplay:setVisible(false)
		    end
		    local listener = cc.EventListenerCustom:create("complete", eventCustomListener)
		    armatureDisplay:getEventDispatcher():setEnabled(true)
			armatureDisplay:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

		    local size = self.panelRedpacket:getContentSize()
		    armatureDisplay:setPosition(size.width/2, size.height/2)
		    --动画播放。只播放一次
		    armatureDisplay:getAnimation():play("qianghongbao", 1)
		    self.panelRedpacket:addChild(armatureDisplay, self.snatchIndex)
		    self.snatchAnimation = armatureDisplay
		end
	else
		armatureDisplay:setLocalZOrder(self.snatchIndex)
		armatureDisplay:setVisible(true)
		armatureDisplay:getAnimation():play("qianghongbao", 1)
	end
end

--抢红包返回
function prototype:onPushSnatch(data)
	if data.isSuccess then
		
	end
end

--推送抢红包结果
function prototype:onPushSnatchResult(resultInfo)
	self.snatchIndex = self.snatchIndex + 1

	-- log("snatchIndex ============= " .. self.snatchIndex)
	-- log(resultInfo)

	self.redpacketRemainder = self.redpacketRemainder - 1
	self.txtRedpacketNum:setString(self.redpacketRemainder)

	local widgetName = "nodePlayer_" .. self.snatchIndex
	self[widgetName]:setPlayerInfo(resultInfo, self.roomState == Redpacket_pb.State_Settlement)
	self.snatchInfoMap[resultInfo.index] = self[widgetName]

	if resultInfo.member.playerId == self.userId then
		--播放特效
		if resultInfo.isBomb then
			self:playBombAnimation()
		else
			self:playSnatchAnimation()
		end
	end
end

--抢红包
function prototype:onBtnRedpacketTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.roomState ~= Redpacket_pb.State_Snatch then
			local data = {
				content = "暂无红包可抢"
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		local roomStateInfo = ModelData:getRoomStateInfo()
		if roomStateInfo.isBlessing == false then
			local redpacketValue = tonumber(self.txtRedpacketValue:getString()) * 100
			redpacketValue = redpacketValue * self.mutiple
			if self.userInfo.gold < redpacketValue then
				local data = {
					content = "余额不足，不能抢红包"
				}
				ui.mgr:open("Dialog/DialogView", data)
				return
			end
		end

		ModelData:requestSnatch()
	end
end

--结算
function prototype:onPushSettlement(settlementData)
	self:onPushRoomState()

	-- log("###############")
	-- log(settlementData)
	-- log("###############")

	local isBomb = false
	local winCoin = 0
	local snatchIndex = self.snatchIndex
	for i, v in ipairs(settlementData) do
		if v.isFloor == false then
			if i <= snatchIndex then
				self.snatchInfoMap[v.index]:setPlayerInfo(v, true)
			else
				self["nodePlayer_" .. i]:setPlayerInfo(v, true)
			end
		end

		if v.isBomb == true then
			isBomb = true
		end

		if v.member.playerId == self.userId then
			winCoin = winCoin + v.resultCoin
		end
	end

	if winCoin ~= 0 then
		if winCoin > 0 then
			self.fntUserWin:setString("+" .. Assist.NumberFormat:amount2TrillionText(winCoin))
			self.fntUserWin:setVisible(true)
		else
			self.fntUserLose:setString(Assist.NumberFormat:amount2TrillionText(winCoin))
			self.fntUserLose:setVisible(true)
		end
	end

	local dealerInfo = ModelData:getMemberInfoById(self.dealerId)
	if dealerInfo then
		if isBomb == true then
			winCoin = dealerInfo.winCoin or 0
		else
			winCoin = 0
		end

		if winCoin >= 0 then
			self.fntDealerWin:setString("+" .. Assist.NumberFormat:amount2TrillionText(winCoin))
			self.fntDealerWin:setVisible(true)
		else
			self.fntDealerLose:setString(Assist.NumberFormat:amount2TrillionText(winCoin))
			self.fntDealerLose:setVisible(true)
		end
	else
		-- log("************* settlement error ! get dealer info error ! **************")
	end

	--没有中雷，服务器不下发更新成员输赢变量。未中雷庄家输赢为0
	ModelData:clearPlayerWincoin()
end

--在线玩家
function prototype:onBtnOnlinePlayerTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then 
		ui.mgr:open("Redpacket/PlayerListView")
	end
end

--充值
function prototype:onBtnRechargeTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then 
		ui.mgr:open("Shop/ShopView", 1)
	end
end

--爬楼
function prototype:onPanelFloorClick()
	ui.mgr:open("Redpacket/FloorListView")
end

--福利
function prototype:onPanelWelfareClick()
	ui.mgr:open("Redpacket/WelfareListView")
end

function prototype:onBtnCloseClick()
	Model:get("Games/Redpacket"):requestLeaveGame()
end


