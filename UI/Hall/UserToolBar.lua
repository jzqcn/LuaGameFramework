module (..., package.seeall)

prototype = Controller.prototype:subclass()

local SHOW_POS_X = -38
local HIDE_POS_X = -750

function prototype:enter()
	-- self:showToolBar()
	self:checkRedPoint()

	if Model:get("Announce"):haveChargeMsg() then
		self.imgBankRed:setVisible(true)
	else
		self.imgBankRed:setVisible(false)
	end

	self:bindModelEvent("Announce.EVT.PUSH_MAIL_MSG", "onPushMailMsg")
	self:bindModelEvent("Announce.EVT.PUSH_CUSTOM_MSG", "onPushCustomMsg")
	self:bindModelEvent("Announce.EVT.PUSH_REQUEST_READ", "checkRedPoint")
	self:bindModelEvent("Announce.EVT.PUSH_RECHARGE_MSG", "onPushRechargeMsg")

	util.timer:after(100, self:createEvent("playAction"))

	--self.btnPromotion:setVisible(false)
	--充值图标动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/Chongzhi/chongzhi_ske.dbbin", "chongzhi")
    factory:loadTextureAtlasData("resource/csbimages/Hall/Chongzhi/chongzhi_tex.json", "chongzhi")
    local signAnimation = factory:buildArmatureDisplay("armatureName", "chongzhi")
    if signAnimation then
	    signAnimation:getAnimation():play("animation", 0)
		--local x,y=self.imgShop:getPosition()
		signAnimation:setPosition(1180,50)
		self.rootNode:addChild(signAnimation, 1, 101)
	    self.signAnimation = signAnimation
	end
end


function prototype:exit()
	--DragonBones骨骼动画资源释放
	if self.signAnimation then
		self.signAnimation:removeFromParent()
		self.signAnimation:dispose()
		dragonBones.CCFactory:getFactory():removeDragonBonesData("chongzhi")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("chongzhi")
	end
end

function prototype:playAction()
	--self:playActionTime(0, true)

	--商城图标流光效果
	--local vsh = "resource/shaders/simple.vsh"
    --local fsh = "resource/shaders/stream3.fsh"
	--Assist.Shader:create(vsh, fsh, self.imgShop)
	
	
end

function prototype:onPushMailMsg()
	self.imgMsgRed:setVisible(true)
end

function prototype:onPushCustomMsg()
	self.imgServiceRed:setVisible(true)
end

--是否需要显示消息红点
function prototype:checkRedPoint()
	if Model:get("Announce"):haveUnreadMailMsg() then
		self.imgMsgRed:setVisible(true)
	else
		self.imgMsgRed:setVisible(false)
	end

	if Model:get("Announce"):haveUnreadCustomMsg() then
		self.imgServiceRed:setVisible(true)
	else
		self.imgServiceRed:setVisible(false)
	end

	if Model:get("User"):checkPromotionRedPoint() then
		self.imgPromotionRed:setVisible(false)
	else
		self.imgPromotionRed:setVisible(true)
	end
end

--保险箱
function prototype:onBtnBankTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Shop/BankView")
		self.imgBankRed:setVisible(false)
	end
end

--保险柜红点提醒
function prototype:onPushRechargeMsg()
	self.imgBankRed:setVisible(true)
end

--客服
function prototype:onBtnServiceTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Msg/CustomerView", 1)
	end
end

--消息
function prototype:onBtnMsgTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Msg/MsgView")
	end
end

--设置
function prototype:onBtnSettingTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("User/SettingView", 2)
	end
end

--分享（图片二维码，扫码下载）
function prototype:onBtnShareTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if Model:get("Account"):isAccountLogin() then
			ui.mgr:open("System/AccountShareView")
		else
			local shareTable = {}
			shareTable.ShareType = "Image" --内容（文本：Text， 链接：Link, 图片：Image）
			-- shareTable.Scene = "SceneSession"  --分享类型（朋友圈：SceneTimeline， 好友：SceneSession）

			shareTable.Title = "威尼斯娱乐"
			shareTable.Desc = "激情玩牌，斗智斗勇乐不停！"
			shareTable.IsAward = true

			local file = util:getFullPath("resource/share/downloadShare.jpg")
			shareTable.ImagePath = file
			-- shareTable.PageUrl = "http://www.yfgame777.com/download/download.html" 
			
			ui.mgr:open("System/WeixinShareView", shareTable)
		end
	end
end

--战绩
function prototype:onBtnRecordTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		--游戏中返回大厅，不允许查看战绩
		local gameName = StageMgr:getStage():getPlayingGameName()
		if gameName then
			local data = {
				content = "您正处于游戏中，无法查看战绩！"
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		--请求战绩数据
		Model:get("PlayBack"):requestRecordList()
		-- ui.mgr:open("GameRecord/GameRecordView")
	end
end

--商店
function prototype:onBtnShopTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		-- if Model:get("Account"):getIsTest() then
		-- 	ui.mgr:open("GmView")
		-- else
			ui.mgr:open("Shop/ShopView")
		-- end
	end
end

--绑定推广码
function prototype:onBtnBindCodeTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Promotion/PromotionBindCodeView")
	end
end

--推广
function prototype:onBtnPromotionTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Promotion/PromotionView")
		self.imgPromotionRed:setVisible(false)
	end
end

--[[function prototype:showToolBar()
	self.imgBg:setPosition(SHOW_POS_X, 0)
	self.btnHide:setVisible(true)
	self.isShow = true
	self.btnShow:setVisible(false)
end

function prototype:hideToolBar()
	self.imgBg:setPosition(HIDE_POS_X, 0)
	self.btnShow:setVisible(true)
	self.isShow = false
	self.btnHide:setVisible(false)
end--]]

--[[function prototype:onBtnShowClick(sender)
	if self.isShow == true then
		return
	end

	local act = cc.MoveTo:create(0.2, cc.p(SHOW_POS_X, 0))
	local callFunc = cc.CallFunc:create(function()						
						self.btnHide:setVisible(true)
						self.isShow = true
					end)
	local seq = cc.Sequence:create(act, callFunc)
	self.imgBg:runAction(seq)

	self.btnShow:setVisible(false)
end

function prototype:onBtnHideClick(sender)
	if self.isShow == false then
		return
	end

	local act = cc.MoveTo:create(0.2, cc.p(HIDE_POS_X, 0))
	local callFunc = cc.CallFunc:create(function()						
						self.btnShow:setVisible(true)
						self.isShow = false
					end)
	local seq = cc.Sequence:create(act, callFunc)
	self.imgBg:runAction(seq)

	self.btnHide:setVisible(false)
end--]]