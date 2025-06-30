module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter()
	self:setFrameEventCallFunc(bind(self.frameEventCallback, self))
	-- self:setLastFrameCallFunc(function ()
	-- 	-- log("NiuniuStart lastFrameCallback")
	-- 	self:close()
	--  end)

	util.timer:after(1.5*1000, self:createEvent("close"))

	-- self:playAction()
	util.timer:after(100, self:createEvent("playAction"))

	sys.sound:playEffectByFile("resource/audio/Niuniu/start.mp3")
end

function prototype:playAction()
	self:playActionTime(0, false)

	
end

function prototype:frameEventCallback(frame)
	local name = frame:getEvent()
	log("NiuniuStart framecallback:" .. name)
	
	local size = self.imgBg:getContentSize()
	local aniNode = ui.aniMgr:load("Effect/Light01", self.imgBg)
	aniNode:playActionTime(0, false)
	aniNode:setPosition(size.width/2, size.height/2+50)
end
