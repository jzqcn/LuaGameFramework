local Actions = require "UI.Mgr.Actions"
local Define = require "UI.Mgr.Define"

module(..., package.seeall)

class = Actions.class:subclass()

function class:exec()
	self.owner:setSkewX(0)
	self.owner:setSkewY(2)
	self.owner:setRotation(61.0)
	self.owner:setScaleX(-0.44)
	self.owner:setScaleY(0.47)
	self.owner:setOpacity(120)
    local actionScaleToBack = CCScaleTo:create(0.3, 1.0, 1.0)
    local rotateToBack = CCRotateTo:create(0.3, 0)
    local actionToBack = CCSkewTo:create(0.3, 0, 0)
	local fadeToBack = CCFadeTo:create(0.3, 255)

	local arrAction = {}
	table.insert(arrAction, actionToBack)
	table.insert(arrAction, CCCallFunc:create(function ()
		self:callback()
	end))
	
	local arrRotate = {}
	table.insert(arrRotate, rotateToBack)

	local arrActionScale = {}
	table.insert(arrActionScale, actionScaleToBack)

	local arrActionFade = {}
	table.insert(arrActionFade, fadeToBack)

	self.owner:runAction(CCSequence:create(arrAction))
	self.owner:runAction(CCSequence:create(arrRotate))
	self.owner:runAction(CCSequence:create(arrActionScale))
	self.owner:runAction(CCSequence:create(arrActionFade))
end
