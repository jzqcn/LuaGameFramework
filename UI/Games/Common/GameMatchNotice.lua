module (..., package.seeall)

prototype = Controller.prototype:subclass()

local SHOW_TIPS = {
	["准备"] = "等待玩家准备",
	["抢庄"] = "等待玩家抢庄",
	["下注"] = "等待玩家下注",
	["摆牌"] = "等待玩家摆牌",
	["没有牌大过上家"] = "没有牌大过上家",
}

function prototype:enter()

end

--消息提示(内容、延迟时间、持续时间)
function prototype:start(msg, delay, duration)
	msg = tostring(msg)
	self.msg = msg
	self.delay = tonumber(delay) or 0
	self.duration = tonumber(duration) or 0

	local tipContent = SHOW_TIPS[msg]
	if tipContent then
		self.txtTip:setString(tipContent)
		-- self.imgTip:loadTexture(imgRes)
		-- self.imgTip:ignoreContentAdaptWithSize(true)
		self:updateDotPosition()
	end

	--持续时间小于等于0，由外部控制结束
	if self.duration > 0 then
		util.timer:after(self.duration*1000, self:createEvent('SHOW_TIMEOUT_TIMER', 'finish'))
	end
	
	if self.delay > 0 then
		self.rootNode:setVisible(false)
		util.timer:after(self.delay*1000, self:createEvent('SHOW_DELAY_TIMER', 'show'))
	else
		self.rootNode:setVisible(true)
	end

	self.rootNode:stopAllActions()

	self.showDotNum = 0
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

	self.rootNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(updateDot))))

	updateDot()
end

function prototype:updateDotPosition()
	-- local size = self.imgTip:getContentSize()
	-- local x, y = self.imgTip:getPosition()
	-- for i = 1, 3 do
	-- 	self["imgDot_"..i]:setPosition(cc.p(x + size.width/2 + 15*i, y - size.height/2 + 15))
	-- end
	local size = self.txtTip:getContentSize()
	local x, y = self.txtTip:getPosition()
	self.txtTipDot:setPosition(x + size.width/2 + 3, y)
end

function prototype:show()
	self.rootNode:setVisible(true)
end

function prototype:finish()
	self.rootNode:setVisible(false)
	self.rootNode:stopAllActions()

	self:cancelEvent('SHOW_TIMEOUT_TIMER')
	self:cancelEvent('SHOW_DELAY_TIMER')
end


