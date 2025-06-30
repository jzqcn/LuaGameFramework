
module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:dispose()
    self.rootNode:unscheduleUpdate()
    super.dispose(self)
end

function prototype:enter()
	self.btnReadyPos = cc.p(self.btnReady:getPosition())
	self.btnRefreshPos = cc.p(self.btnRefreshLeft:getPosition())
end

--房卡场不能换桌
function prototype:show(isReady, isRefresh, delay)
	if isReady == false then
		self.btnReady:setVisible(true)

		if isRefresh then
			self.btnRefreshLeft:setVisible(true)
			if self.isStartSchedule then
				self.txtTimeLeft:setVisible(true)
			else
				self.txtTimeLeft:setVisible(false)
			end

			self.btnReady:setPosition(self.btnReadyPos)
			-- self.btnRefreshLeft:setPosition(self.btnRefreshPos)
		else
			self.btnReady:setPosition(self.btnReadyPos.x - 180, self.btnReadyPos.y)
			self.btnRefreshLeft:setVisible(false)
		end
	else
		self.btnReady:setVisible(false)
		
		if isRefresh then
			self.btnRefreshLeft:setVisible(true)

			if self.isStartSchedule then
				self.txtTimeLeft:setVisible(true)
			else
				self.txtTimeLeft:setVisible(false)
			end
			-- self.btnRefreshLeft:setPosition(self.btnRefreshPos.x + 180, self.btnRefreshPos.y)
		else
			return
		end
	end

	delay = delay or -1
	if delay > 0 then
		self.rootNode:setVisible(false)
		self:cancelEvent("DELAY_SHOW_READY")
		util.timer:after(delay * 1000, self:createEvent("DELAY_SHOW_READY", function()
			self.rootNode:setVisible(true)
		end))
	else
		self.rootNode:setVisible(true)
	end
end

--倒计时结束
function prototype:uiEvtClockFinish()
	self.rootNode:setVisible(false)
end

function prototype:hide()
	self.rootNode:setVisible(false)
	self:cancelEvent("DELAY_SHOW_READY")
end

function prototype:hideBtnRefreshLeft(isRefresh)
	if isRefresh then
        self.btnRefreshLeft:setVisible(false)
        else
        self.btnRefreshLeft:setVisible(true)
    end
end


function prototype:startSchedule()
	self.time = 0
	self.countdown = 5
    self.isStartSchedule = true
	self.rootNode:scheduleUpdateWithPriorityLua(bind(self.scheduleFunction, self), 0)

	self.btnRefreshLeft:setEnabled(false)
	Assist:setNodeGray(self.btnRefreshLeft)

    self.txtTimeLeft:setString(self.countdown)
    self.txtTimeLeft:setVisible(true)
end

function prototype:scheduleFunction(delta)
    self.time = self.time + delta
    if self.time >= 1 then
    	self.time = 0
    	self.countdown = self.countdown - 1
    	self.txtTimeLeft:setString(self.countdown)

    	if self.countdown <= 0 then			
			self:stop()
		end
    end
end

function prototype:stop()
	self.isStartSchedule = false
	self.rootNode:unscheduleUpdate()

	self.btnRefreshLeft:setEnabled(true)
	Assist:setNodeColorful(self.btnRefreshLeft)

    self.txtTimeLeft:setVisible(false)
end

function prototype:onBtnRefreshTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.ChangeRoom")
		self:startSchedule()
	end
end

function prototype:onBtnReadyTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		-- self.nodeClock:stop()
		self:fireUIEvent("Game.Ready")
	end
end