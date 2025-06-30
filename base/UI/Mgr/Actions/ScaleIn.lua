local Actions = require "UI.Mgr.Actions"
local Define = require "UI.Mgr.Define"

module(..., package.seeall)

class = Actions.class:subclass()


function class:exec()
	self.owner:setScale(0.4)
	self.owner:setOpacity(5)
	
	local arrAction = {}
	table.insert(arrAction, CCSpawn:create(CCEaseSineOut:create(CCScaleTo:create(0.2, 1)), 
										   CCFadeTo:create(0.21, 255)))
	table.insert(arrAction, CCCallFunc:create(function ()
											self:callback()										
										end))

	self.owner:runAction(CCSequence:create(arrAction))
end
