module(..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:dispose()
    self.rootNode:unscheduleUpdate()
    super.dispose(self)
end

function prototype:enter()
	
end

function prototype:start(countdown, delay)
	self.countdown = tonumber(countdown)
	if self.countdown < 0 then
		self.countdown = 0
	end

	self.time = 0
	self.delay = delay or 0
	self.txtTimeNum:setString(self.countdown)

	if self.delay > 0 then
		self.rootNode:setVisible(false)
	else
		self.rootNode:setVisible(true)
	end

	if self.countdown > 0 then
		self.rootNode:unscheduleUpdate()
		self.rootNode:scheduleUpdateWithPriorityLua(bind(self.update, self), 0)
	else
		self:finish()
	end
end

function prototype:stop()
	self.rootNode:unscheduleUpdate()
	self.rootNode:setVisible(false)
end

function prototype:finish(isHide)
	isHide = isHide or false
	self.rootNode:unscheduleUpdate()
	self.rootNode:setVisible(not isHide)

	self:fireUIEvent("Game.Clock")
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
