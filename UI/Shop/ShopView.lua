module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local SHOP_TYPE = Enum
{
	"ALI",
	"WEIXIN",
	"VIP",
	"GIVE",
}

--是否开启对应功能
local SHOP_TYPE_ENABLE = {false, false, true, true}

function prototype:enter(selType)
	-- ui.mgr:setSceneImageBg(self.imgBg, true)

	self.nodeRight = {self.nodeAliRecharge, self.nodeWeixinRecharge, self.nodeVipRecharge, self.nodeGiveLayer}

	selType = selType or 3
	if selType > SHOP_TYPE.GIVE then
		selType = SHOP_TYPE.VIP
	end

	local x1, y1 = self.btnLeft_1:getPosition()
	local x2, y2 = self.imgLeftSel_1:getPosition()
	local index = 0
	for i = 1, #SHOP_TYPE_ENABLE do
		self["imgLeftSel_"..i]:setVisible(false)
		self.nodeRight[i]:setVisible(false)
		if SHOP_TYPE_ENABLE[i] then
			self["btnLeft_"..i]:setVisible(true)
			self["imgLeftSel_"..i]:setVisible(true)

			self["btnLeft_"..i]:setPosition(x1, y1 - index * 115)
			self["imgLeftSel_"..i]:setPosition(x2, y2 - index * 115)

			index = index + 1			
		else
			self["btnLeft_"..i]:setVisible(false)
		end

		
	end

	if not SHOP_TYPE_ENABLE[selType] then
		for i = 1, #SHOP_TYPE_ENABLE do
			if SHOP_TYPE_ENABLE[i] then
				selType = i
				break
			end
		end
	end
	
	self:shopSelectTab(selType)
	--显示金币、房卡数，不要+号
	self.nodeCoinMsg:hideCoinBtn()
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))

	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.rootNode, actionOver)
	sys.sound:playEffectByFile("resource/audio/Hall/chongzhi_enter.mp3")
end

function prototype:shopSelectTab(selType)
	if self.selectType == selType then
		return
	end

	for i = 1, #SHOP_TYPE_ENABLE do
		if SHOP_TYPE_ENABLE[i] then
			self["btnLeft_"..i]:setVisible(not (selType == i))
			self["imgLeftSel_"..i]:setVisible(selType == i)
		end
	end

	if StageMgr:isStage("Game") or (StageMgr:isStage("Hall") and StageMgr:getStage():isPlayingGame()) then
		--游戏中不能赠送（包括在房卡游戏中，返回大厅）
		self["btnLeft_"..SHOP_TYPE.GIVE]:setVisible(false)
		self["imgLeftSel_"..SHOP_TYPE.GIVE]:setVisible(false)

		if selType == SHOP_TYPE.GIVE then
			-- selType = SHOP_TYPE.ALI
			for i = 1, #SHOP_TYPE_ENABLE do
				if SHOP_TYPE_ENABLE[i] then
					selType = i
					break
				end
			end
		end
	end

	for i = 1, #SHOP_TYPE_ENABLE do
		if i == selType  then
			self.nodeRight[i]:setVisible(true)
		else
			if SHOP_TYPE_ENABLE[i] then
				self.nodeRight[i]:setVisible(false)
			end
		end
	end

	-- if selType == SHOP_TYPE.ALI then
	-- 	self.nodeVipRecharge:setVisible(false)
	-- 	self.nodeGiveLayer:setVisible(false)
	-- 	self.nodeAliRecharge:setVisible(true)
	-- 	-- goodsList = Model:get("Item"):getAliItemList()

	-- -- elseif selType == SHOP_TYPE.WEIXIN then
	-- -- 	self.nodeVipRecharge:setVisible(false)
	-- -- 	self.nodeGiveLayer:setVisible(false)
	-- -- 	goodsList = Model:get("Item"):getWeixinItemList()

	-- elseif selType == SHOP_TYPE.GIVE then		
	-- 	self.nodeVipRecharge:setVisible(false)
	-- 	self.nodeAliRecharge:setVisible(false)
	-- 	self.nodeGiveLayer:show()
	-- elseif selType == SHOP_TYPE.VIP then
	-- 	self.nodeVipRecharge:setVisible(true)
	-- 	self.nodeAliRecharge:setVisible(false)
	-- 	self.nodeGiveLayer:setVisible(false)
	-- end

	self.selectType = selType
end

--赠送
function prototype:onBtnGiveClick()
	self:shopSelectTab(SHOP_TYPE.GIVE)
end

--支付宝
function prototype:onBtnAliClick()
	self:shopSelectTab(SHOP_TYPE.ALI)
end

--微信
function prototype:onBtnWeixinClick()
	self:shopSelectTab(SHOP_TYPE.WEIXIN)
end

--VIP充值
function prototype:onBtnVipClick()
	self:shopSelectTab(SHOP_TYPE.VIP)
end

--保险柜
function prototype:onBtnBankTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Shop/BankView")
	end
end

function prototype:onBtnCloseClick()
	self:close()
end
