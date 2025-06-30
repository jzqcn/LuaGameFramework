--贝塞尔曲线 动作
module(..., package.seeall)

class = objectlua.Object:subclass()

local FLT_EPSILON = 0.000000119

local function bezierat(a, b, c, d, t)
	return (math.pow(1 - t, 3) * a + 3 * t*(math.pow(1 - t, 2))*b + 3 * math.pow(t, 2)*(1 - t)*c + math.pow(t, 3)*d)
end

function class:initialize(owner, bezierConfig, duration, delay, cbFunc)
	super.initialize(self)

	if not owner or not bezierConfig then
		assert(false)
	end

	self.owner = owner
	self.cbFunc = cbFunc

	self.bc = bezierConfig

	self.delayTime = delay
	self.totalTime = duration
	self.timeHasRun = 0
	self.timeHasDelay = 0
end

function class:dispose()
	super.dispose(self)
	-- log(string.format("bezier scale dispose %p", self))
end

function class:restart()
	self.endScale = self.bc.endPoint

	self.bc.ctrlPoint_1 = self.bc.ctrlPoint_1 - self.bc.startPoint
	self.bc.ctrlPoint_2 = self.bc.ctrlPoint_2 - self.bc.startPoint
	self.bc.endPoint = self.bc.endPoint - self.bc.startPoint

	self.owner:setScale(self.bc.startPoint)
	self.previousPosition = self.owner:getScale()
	self.startPosition = self.owner:getScale()
end

function class:update(delta)
	self.timeHasDelay = self.timeHasDelay + delta
	if self.delayTime > 0 and self.timeHasDelay < self.delayTime then
		return
	end

	self.timeHasRun = self.timeHasRun + delta
	if self.timeHasRun > self.totalTime then
		self.owner:setScale(self.endScale)
		self.owner:unscheduleUpdate()

		if self.cbFunc then
			self.cbFunc(self)
		end
		return
	end

	local timeTmp = (math.max(0, math.min(1, self.timeHasRun / math.max(self.totalTime, FLT_EPSILON))))
	local xa = 0;
	local xb = self.bc.ctrlPoint_1
	local xc = self.bc.ctrlPoint_2
	local xd = self.bc.endPoint

	local x = bezierat(xa, xb, xc, xd, timeTmp)

	local currentPos = self.owner:getScale()
	local diff = currentPos - self.previousPosition
	self.startPosition = self.startPosition + diff

	local newPos = self.startPosition + x
	self.owner:setScale(newPos)
	self.owner:setVisible(true)

	self.previousPosition = newPos
end
