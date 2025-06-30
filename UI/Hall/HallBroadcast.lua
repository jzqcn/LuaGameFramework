module (..., package.seeall)


prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("Announce.EVT.PUSH_ROLLING_MSG", "onPushRollingMsg")

	self.size = self.panelFrame:getContentSize()
	self.defaultMsgNode = nil
	self.isPlayingMsg = false
	self:playRollingMsg()
end

function prototype:onPushRollingMsg()
	if not self.isPlayingMsg then
		self:playRollingMsg()
	end
end

function prototype:playRollingMsg()
	local rollingMsg = Model:get("Announce"):getNextRollingMsg()
	if rollingMsg then
		-- local str = rollingMsg.content
		-- local tb = {}
		-- tb.style = {face = "resource/fonts/FZY4JW.TTF", size = 28, color = "#ffffff", underLine = false, outLine = {size=1, color="#000000"}}
		-- tb.list = {
		-- 	{str = str}
		-- }

		local tb, strLen = Model:get("Announce"):getRichMsgTb(rollingMsg.content)
		local strWidth = strLen / 3 * tb.style.size + 50

		local assistNode = Assist.RichText:createRichText(tb)
		assistNode:setWrapMode(RICHTEXT_WRAP_PER_CHAR)
		assistNode:ignoreContentAdaptWithSize(true)
		assistNode:setContentSize(cc.size(self.size.width, self.size.height))
		assistNode:setAnchorPoint(cc.p(0, 0.5))
		assistNode:setPosition(cc.p(self.size.width+5, self.size.height/2))
		
		self.panelFrame:addChild(assistNode)

		local seq = cc.Sequence:create(cc.MoveBy:create(10, cc.p(-(self.size.width + strWidth), 0)), cc.CallFunc:create(function()
				self:runningMsgOver(assistNode, true)
			end))
		assistNode:runAction(seq)

		self.rootNode:setVisible(true)

		self.isPlayingMsg = true

		if self.defaultMsgNode then
			self.defaultMsgNode:setVisible(false)
		end
	else
		local isHallStage = StageMgr:isStage("Hall")
		if not isHallStage then
			self.rootNode:setVisible(false)
			return
		end

		if self.defaultMsgNode == nil then
			local str = "本游戏仅供休闲娱乐，严禁赌博！"
			local tb = {}
			tb.style = {face = "resource/fonts/FZY4JW.TTF", size = 28, color = "#FFFF00", underLine = false, outLine = {size=1, color="#000000"}}
			tb.list = {
				{ str = str}
			}

			-- log(string.len(tb.list[1].str))
			-- log(string.len(tb.list[1].str)/3 * tb.style.size)
			local strWidth = string.len(str) / 3 * tb.style.size + 50

			local assistNode = Assist.RichText:createRichText(tb)
			assistNode:setWrapMode(RICHTEXT_WRAP_PER_CHAR)
			assistNode:ignoreContentAdaptWithSize(true)
			assistNode:setContentSize(cc.size(strWidth, self.size.height))
			assistNode:setAnchorPoint(cc.p(0, 0.5))
			assistNode:setPosition(cc.p(self.size.width+5, self.size.height/2))
			
			self.panelFrame:addChild(assistNode)
			self.defaultMsgNode = assistNode
		else
			self.defaultMsgNode:setVisible(true)
		end

		local seq = cc.Sequence:create(cc.MoveBy:create(10, cc.p(-(self.size.width + self.defaultMsgNode:getContentSize().width), 0)), cc.CallFunc:create(function()
				self.defaultMsgNode:setPosition(cc.p(self.size.width+5, self.size.height/2))
				self:runningMsgOver(self.defaultMsgNode)
			end))
		self.defaultMsgNode:runAction(seq)

		self.isPlayingMsg = true
	end
end

function prototype:runningMsgOver(node, isRemove)
	local isRemove = isRemove or false

	if isRemove then
		node:removeFromParent(true)
	end

	self.isPlayingMsg = false

	self:playRollingMsg()
end

