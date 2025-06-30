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

	-- self.initPos = cc.p(owner:getPosition())
end

function class:dispose()
	super.dispose(self)
end

function class:restart()
	self.owner:setPosition(self.bc.startPoint)
	self.bc.ctrlPoint_1 = cc.pSub(self.bc.ctrlPoint_1, self.bc.startPoint)
	self.bc.ctrlPoint_2 = cc.pSub(self.bc.ctrlPoint_2, self.bc.startPoint)
	self.bc.endPoint = cc.pSub(self.bc.endPoint, self.bc.startPoint)
	self.previousPosition = cc.p(self.owner:getPosition())
	self.startPosition = cc.p(self.owner:getPosition())
end

function class:update(delta)
	self.timeHasDelay = self.timeHasDelay + delta
	if self.delayTime > 0 and self.timeHasDelay < self.delayTime then
		return
	end

	self.timeHasRun = self.timeHasRun + delta
	if self.timeHasRun > self.totalTime then
		-- self.owner:setPosition(self.initPos)
		self.owner:unscheduleUpdate()

		if self.cbFunc then
			self.cbFunc(self)
		end
		return
	end

	local timeTmp = (math.max(0, math.min(1, self.timeHasRun / math.max(self.totalTime, FLT_EPSILON))))
	local xa = 0
	local xb = self.bc.ctrlPoint_1.x
	local xc = self.bc.ctrlPoint_2.x
	local xd = self.bc.endPoint.x

	local ya = 0
	local yb = self.bc.ctrlPoint_1.y
	local yc = self.bc.ctrlPoint_2.y
	local yd = self.bc.endPoint.y

	local x = bezierat(xa, xb, xc, xd, timeTmp)
	local y = bezierat(ya, yb, yc, yd, timeTmp)

	local currentPos = cc.p(self.owner:getPosition())
	local diff = cc.pSub(currentPos, self.previousPosition)
	self.startPosition = cc.pAdd(self.startPosition, diff)

	local newPos = cc.pAdd(self.startPosition, cc.p(x, y))
	self.owner:setPosition(newPos)

	self.previousPosition = newPos
end

