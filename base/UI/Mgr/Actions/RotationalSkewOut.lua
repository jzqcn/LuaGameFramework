local Actions = require "UI.Mgr.Actions"
local Define = require "UI.Mgr.Define"

module(..., package.seeall)

class = Actions.class:subclass()

function class:exec()
    local actionScaleToBack = CCScaleTo:create(0.4, -0.44, 0.47)
    local rotateToBack = CCRotateTo:create(0.4, 61)
    local actionToBack = CCSkewTo:create(0.4, 0, 2)
	local fadeToBack = CCFadeTo:create(0.4, 120)

	local arrAction = {}
	table.insert(arrAction, actionToBack)
	
	local arrRotate = {}
	table.insert(arrRotate, rotateToBack)

	local arrActionScale = {}
	table.insert(arrActionScale, actionScaleToBack)

	local arrActionFade = {}
	table.insert(arrActionFade, fadeToBack)
	table.insert(arrActionFade, CCCallFunc:create(function ()
		self:callback()
	end))

	--self.owner:runAction(CCSequence:create(arrAction))
	self.owner:runAction(CCSequence:create(arrRotate))
	self.owner:runAction(CCSequence:create(arrActionScale))
	self.owner:runAction(CCSequence:create(arrActionFade))
end
