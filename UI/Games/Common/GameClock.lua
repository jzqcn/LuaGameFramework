module(..., package.seeall)

prototype = Controller.prototype:subclass()

local SHOW_TIPS = {
	["准备"] = "等待玩家准备",
	["抢庄"] = "等待玩家抢庄",
	["下注"] = "等待玩家下注",
	["摆牌"] = "等待玩家摆牌",
	["发牌"] = "发牌中",
	["补牌"] = "等待玩家补牌",
	["亮牌"] = "所有玩家亮牌",
	["结算"] = "总结算",
	["有牛"] = "再仔细想想，你的牌型有牛哦！",
	["无牛"] = "当前选择的扑克没牛哦！",

}

function prototype:dispose()
    self.rootNode:unscheduleUpdate()
    super.dispose(self)
end

function prototype:enter()
	
end

function prototype:start(countdown, content, delay)
	local content = content or ""
	self.countdown = tonumber(countdown)
	self.time = 0
	self.delay = delay or 0
	self.txtTimeNum:setString(countdown)

	self.imgTipBg:stopAllActions()

	-- self.txtTip:setVisible(false)

	if self.countdown <= 0 then
		self:finish()
		return
	end

	if string.len(content) == 0 then
		self.imgTipBg:setVisible(false)
	else
		local tipContent = SHOW_TIPS[content]
		if tipContent then
			self.txtTip:setString(tipContent)
			-- self.imgTip:loadTexture(imgRes)
			-- self.imgTip:ignoreContentAdaptWithSize(true)
			self:updateDotPosition()
			self.imgTipBg:setVisible(true)
			self:runDotAction()
		else
			self.imgTipBg:setVisible(false)
		end
	end

	self.param = ""

	if self.delay > 0 then
		self.rootNode:setVisible(false)
	else
		self.rootNode:setVisible(true)
	end

	self.rootNode:unscheduleUpdate()
	self.rootNode:scheduleUpdateWithPriorityLua(bind(self.update, self), 0)

end

function prototype:showNotice(content, delay)
	sys.sound:playEffect("NOTICE")

	local tipContent = SHOW_TIPS[content]
	if tipContent then
		self.txtTip:setString(tipContent)
		-- self.imgTip:loadTexture(imgRes)
		-- self.imgTip:ignoreContentAdaptWithSize(true)
		self:updateDotPosition()
		self.imgTipBg:setVisible(true)
		self:runDotAction()
	else
		self.imgTipBg:setVisible(false)
	end

	-- self.txtTip:setVisible(false)

	delay = delay or -1
	if delay > 0 then
		self.imgTipBg:stopAllActions()
		self.imgTipBg:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function ()
			self.imgTipBg:setVisible(false)
		end)))
	end
end

function prototype:showMsg(content, delay)
	delay = delay or 0
	local tipContent = SHOW_TIPS[content]
	if tipContent then
		self.txtTip:setString(tipContent)
		-- self.imgTip:loadTexture(imgRes)
		-- self.imgTip:ignoreContentAdaptWithSize(true)
		self:updateDotPosition()
	end

	-- self.txtTip:setVisible(false)

	self.imgTipBg:setVisible(false)
	self.imgTipBg:stopAllActions()
	self.imgTipBg:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function ()
		self.imgTipBg:setVisible(true)
		self:runDotAction()
	end)))
end

function prototype:updateDotPosition()
	-- local size = self.imgTip:getContentSize()
	-- local x, y = self.imgTip:getPosition()
	local size = self.txtTip:getContentSize()
	local x, y = self.txtTip:getPosition()
	self.txtTipDot:setPosition(x + size.width/2 + 3, y)
	-- for i = 1, 3 do
	-- 	self["imgDot_"..i]:setPosition(cc.p(x + size.width/2 + 15*i, y - size.height/2 + 15))
	-- end
end

function prototype:runDotAction()
	self.txtTip:stopAllActions()

	self.showDotNum = 0

	local strContent = self.txtTip:getString()
	local function updateDot()
		-- for i = 1, 3 do
		-- 	if self.showDotNum >= i then
		-- 		self["imgDot_"..i]:setVisible(true)
		-- 	else
		-- 		self["imgDot_"..i]:setVisible(false)
		-- 	end
		-- end
		local strDot = ""
		for i = 1, self.showDotNum do
			strDot = strDot .. "."
		end

		self.txtTipDot:setString(strDot)

		self.showDotNum = self.showDotNum + 1
		if self.showDotNum > 3 then
			self.showDotNum = 0
		end
	end

	self.txtTip:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(updateDot))))

	updateDot()
end

--玩家缺钱提示（部分房卡金币场游戏，有玩家不够钱无法继续）
function prototype:showLackCoinMsg(content, countdown, delay)
	-- for i = 1, 3 do
	-- 	self["imgDot_"..i]:setVisible(false)
	-- end
	-- self.imgTip:setVisible(false)

	local content = content or ""
	self.countdown = tonumber(countdown)
	self.time = 0
	self.delay = delay or 0
	self.txtTimeNum:setString(countdown)

	self.txtTip:setString(content)
	self.txtTip:setVisible(true)

	self:updateDotPosition()
	self.imgTipBg:setVisible(true)
	self:runDotAction()

	self.rootNode:unscheduleUpdate()
	self.rootNode:scheduleUpdateWithPriorityLua(bind(self.update, self), 0)
end

function prototype:stop()
	self.rootNode:unscheduleUpdate()
	self.rootNode:setVisible(false)
	-- self.imgTip:stopAllActions()
	self.txtTip:stopAllActions()
end

function prototype:finish()
	self.rootNode:unscheduleUpdate()
	self.rootNode:setVisible(false)
	-- self.imgTip:stopAllActions()
	self.txtTip:stopAllActions()

	self:fireUIEvent("Game.Clock", self.param)
end

function prototype:setCallbackParam(param)
	self.param = param
end

function prototype:update(delta)
	if self.delay > 0 then
		self.delay = self.delay - delta
		if self.delay <= 0 then
			self.rootNode:setVisible(true)
		end
	end

	self.time = self.time + delta
	if self.time >= 1 then
		self.time = 0
		self.countdown = self.countdown - 1
		self.txtTimeNum:setString(self.countdown)

		if self.countdown <= 5 then
			sys.sound:playEffect("CLOCK")
		end
		
		if self.countdown <= 0 then			
			self:finish()
		end
	end
end