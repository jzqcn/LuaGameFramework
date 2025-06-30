local Actions = require "UI.Mgr.Actions"

module(..., package.seeall)

class = Actions.class:subclass()


function class:exec()
	local eglView = cc.Director:getInstance():getOpenGLView()
	local size = eglView:getFrameSize()

	local arrAction = {}
	self.owner:setPosition(size.width, 0)
	table.insert(arrAction, CCMoveTo:create(0.3, cc.p(0, 0)))
	table.insert(arrAction, CCCallFunc:create(function()
		self:callback()
	end))

	self.owner:runAction(CCSequence:create(arrAction))
end
