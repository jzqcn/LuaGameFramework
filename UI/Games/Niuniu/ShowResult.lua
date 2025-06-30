module (..., package.seeall)

prototype = Controller.prototype:subclass()



function prototype:enter()
	-- util.timer:after(100, self:createEvent("playCardAction"))
end

function prototype:show(value)
	if self.rootNode:isVisible() then
		return
	end

	self:setValue(value)

	-- util.timer:after(100, self:createEvent("playCardAction"))
	self:playCardAction()
	self.rootNode:setVisible(true)
end

function prototype:setValue(value)
	self.value = tonumber(value)
	self.imgValue:loadTexture(string.format("resource/csbimages/Games/Niuniu/niu_%d.png", value))
end

function prototype:playAudioEffect(sex)
	if self.value == nil then
		return
	end
	
	sex = sex or 1
	if sex == 1 then
		sys.sound:playEffectByFile(string.format("resource/audio/Niuniu/man/niu_%d.mp3", self.value))
	else
		sys.sound:playEffectByFile(string.format("resource/audio/Niuniu/lady/niu_%d.mp3", self.value))
	end
end

function prototype:playCardAction()
	-- self:playActionTime(0, false)
	local anchor = self.rootNode:getAnchorPoint()
	if anchor.x == 0 and anchor.y == 0 then
		local x, y = self.rootNode:getPosition()
		local size = self.rootNode:getContentSize()
		self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
		self.rootNode:setPosition(x+size.width/2, y+size.height/2)
	end
	
	local seq = cc.Sequence:create(cc.EaseIn:create(cc.ScaleTo:create(0.15, 2.5), 2.5), cc.EaseOut:create(cc.ScaleTo:create(0.2, 1), 2.5))
	self.rootNode:runAction(seq)

	self:playAudioEffect()
end