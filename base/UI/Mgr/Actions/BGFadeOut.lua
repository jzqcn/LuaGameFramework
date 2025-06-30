local Actions = require "UI.Mgr.Actions"
local Define = require "UI.Mgr.Define"

module(..., package.seeall)

class = Actions.class:subclass()

function class:exec()
	local eglView = cc.Director:getInstance():getOpenGLView()
	local size = eglView:getFrameSize()
	local mask = CCLayerColor:create(cc.c4b(0, 0, 0, 190), size.width, size.height)
	self.owner:addChild(mask, -1000, Define.BG_FADEIN_TAG)

	local arrAction = {}
	table.insert(arrAction, CCFadeTo:create(0.1, 0))
	table.insert(arrAction, CCCallFunc:create(function ()
											self:callback()
										end))
	table.insert(arrAction, CCCallFunc:create(function()
		mask:removeFromParent(true)
	end))
	mask:runAction(CCSequence:create(arrAction))
end