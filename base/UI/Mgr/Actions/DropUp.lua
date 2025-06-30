local Actions = require "UI.Mgr.Actions"
local Define = require "UI.Mgr.Define"

module(..., package.seeall)

class = Actions.class:subclass()

function class:exec()
	local arrAction = {}
	local mask = self.owner:getChildByTag(Define.MASK_BG_TAG)
	if mask then 
		mask:setScale(10)
	end
	
	table.insert(arrAction, CCSpawn:create(CCMoveBy:create(0.3, cc.p(0, 1000)),
										   CCFadeTo:create(0.4, 0)
										   ))
	table.insert(arrAction, CCCallFunc:create(function ()
								self:callback()
								if mask then
									mask:setScale(1)
								end
							end))
	self.owner:runAction(CCSequence:create(arrAction))
end
