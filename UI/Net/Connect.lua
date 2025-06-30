module(..., package.seeall)

local CONNECT_SHOW_NOTICE = 1000
local CONNECT_TIMEOUT = 15 * 1000--连接超时时间

prototype = Window.prototype:subclass()

function prototype:initialize(...)
	super.initialize(self, ...)
	log4net:info("Block begin")
end

function prototype:dispose(...)
	log4net:info("Block end")
	super.dispose(self)
end

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	self:playActionTime(0, true)

	log4net:info("Block enter")
	self.nodWait:setVisible(false)
	if not self:existEvent('onShowNotice') then
		util.timer:after(CONNECT_SHOW_NOTICE, self:createEvent('onShowNotice'))
	end

	if self:existEvent('onConnectTimeOut') then
		self:cancelEvent('onConnectTimeOut')
	end
	util.timer:after(CONNECT_TIMEOUT, self:createEvent('onConnectTimeOut'))
end

function prototype:onShowNotice()
	self:showWaiting()
end

function prototype:showWaiting()
	log4net:info("Block visible.")
	self.nodWait:setVisible(true)
end

function prototype:onConnectTimeOut()
	self:close()
end
