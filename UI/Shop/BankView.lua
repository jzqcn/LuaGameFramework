module (..., package.seeall)

prototype = Dialog.prototype:subclass()

--是否开启兑换
local isEnabledExchange = false

function prototype:enter()
	self:onBtnDrawClick()
	
	if StageMgr:isStage("Game") or (StageMgr:isStage("Hall") and StageMgr:getStage():isPlayingGame()) then
		--游戏中不能存款（包括在房卡游戏中，返回大厅）

		self.btnDeposit:setVisible(false)
	end

	self:bindModelEvent("User.EVT.PUSH_BANK_GOLD", "onPushBankOperate")
	self:bindModelEvent("User.EVT.PUSH_BANK_QUERY_GOLD", "onPushBankQuery")

	Model:get("User"):requestBankQuery()

	-- ui.mgr:setSceneImageBg(self.imgBg, true)

	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))

	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.rootNode, actionOver)

	sys.sound:playEffectByFile("resource/audio/Hall/baoxianxiang_enter.mp3")
end

function prototype:onPushBankOperate(saveGold)
	saveGold = tonumber(saveGold) or 0
	self.nodeDeposit:setBankSaveNum(saveGold)
	self.nodeDraw:setBankSaveNum(saveGold)

end

function prototype:onPushBankQuery(saveGold)
	saveGold = tonumber(saveGold) or 0
	self.nodeDeposit:setBankSaveNum(saveGold)
	self.nodeDraw:setBankSaveNum(saveGold)

end

function prototype:onBtnDepositClick()
	-- if eventType == ccui.TouchEventType.ended then
		self.nodeDeposit:setVisible(true)
		self.nodeDraw:setVisible(false)
		self.imgDrawSel:setVisible(false)
		self.imgDepositSel:setVisible(true)
	-- end
end

function prototype:onBtnDrawClick()
	-- if eventType == ccui.TouchEventType.ended then
		self.nodeDraw:setVisible(true)
		self.nodeDeposit:setVisible(false)
		self.imgDrawSel:setVisible(true)
		self.imgDepositSel:setVisible(false)
	-- end
end

function prototype:onBtnExchangeTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self.nodeDraw:setVisible(false)
		self.nodeDeposit:setVisible(false)
	end
end

function prototype:refreshBindBankCardState()
	--self.nodeExchange:updateBindBankState()
end

function prototype:onBtnCloseClick()
	self:close()

	-- local function actionOver()
	-- 	log("actionOver")
	-- 	self.action:dispose()
	-- 	self.action = nil

	-- 	util.timer:after(10, self:createEvent("close"))
	-- end

	-- self.action = self:getJumpInBezierConfig(self.imgPop, actionOver)
end
