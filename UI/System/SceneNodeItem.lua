module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:refresh(data)
	local sceneImage = string.format("resource/csbimages/System/sceneBg/bg_%d.png", data)
	self.imgBg:loadTexture(sceneImage)
end

