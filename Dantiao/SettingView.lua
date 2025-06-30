module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter()
	if sys.sound:getMusicVolume() > 0 then
		self:setEnableMusic(true)
	else
		self:setEnableMusic(false)
	end

	if sys.sound:getEffectVolume() > 0 then
		self:setEnableEffect(true)
	else
		self:setEnableEffect(false)
	end
end

function prototype:setEnableMusic(var)
	sys.sound:setEnableMusic(var)

	self.imgMusicOff:setVisible(not var)
	self.imgMusicOn:setVisible(var)
end

function prototype:setEnableEffect(var)
	sys.sound:setEnableEffect(var)

	self.imgEffectOff:setVisible(not var)
	self.imgEffectOn:setVisible(var)
end

function prototype:onImageMusicOffClick()
	self:setEnableMusic(true)
	sys.sound:setMusicVolume(0.8)
end

function prototype:onImageMusicOnClick()
	self:setEnableMusic(false)
	sys.sound:setMusicVolume(0)
end

function prototype:onImageEffectOffClick()
	self:setEnableEffect(true)
	sys.sound:setEffectVolume(1.0)
end

function prototype:onImageEffectOnClick()
	self:setEnableEffect(false)
	sys.sound:setEffectVolume(0)
end

function prototype:onBtnCloseClick()
	self:close()
end
