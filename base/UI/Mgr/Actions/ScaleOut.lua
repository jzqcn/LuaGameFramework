local Actions = require "UI.Mgr.Actions"
local Define = require "UI.Mgr.Define"

module(..., package.seeall)

class = Actions.class:subclass()

function class:exec()
	local arrAction = {}
	
	table.insert(arrAction, CCSpawn:create(CCScaleTo:create(0.1, 0.95), 
										   CCFadeTo:create(0.22, 0)))
	table.insert(arrAction, CCCallFunc:create(function ()
								self:callback()
							end))
	self.owner:runAction(CCSequence:create(arrAction))
end
