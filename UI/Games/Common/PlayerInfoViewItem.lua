module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	
end

function prototype:refresh(data)
	self.data = data
	local iconRes = string.format("resource/csbimages/Games/Actions/%s.png", data.name)
	self.imgIcon:loadTexture(iconRes)
end

function prototype:onActionClick()
	self:fireUIEvent("Game.SelectActionId", self.data)
end
