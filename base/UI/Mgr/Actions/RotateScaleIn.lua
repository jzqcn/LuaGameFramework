local Actions = require "UI.Mgr.Actions"
local Define = require "UI.Mgr.Define"

module(..., package.seeall)

class = Actions.class:subclass()

function class:exec()
	self.owner:setRotation(900)
	self.owner:setScale(0.1)
    local scaleTo = CCScaleTo:create(.5, 1, 1)
    local rotateTo = CCRotateTo:create(.5, 0)

	local arrScale = {}
	table.insert(arrScale, scaleTo)
	table.insert(arrScale, CCCallFunc:create(function ()
		self:callback()
	end))
	
	local arrRotate = {}
	table.insert(arrRotate, rotateTo)

	self.owner:runAction(CCSequence:create(arrScale))
	self.owner:runAction(CCSequence:create(arrRotate))
end
