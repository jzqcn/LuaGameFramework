local WindowBase = require "UI.Mgr.Window.WindowBase"
local Define = require "UI.Mgr.Define"

module(..., package.seeall)


prototype = WindowBase.prototype:subclass()

function prototype:initialize(...)
	super.initialize(self, ...)

	self.windowType = Define.WINDOW_TYPE.WINDOW
end

function prototype:getOpenAction()
	return nil
end

function prototype:getCloseAction()
	return nil
end

function prototype:getReOpenType()
	return Define.RE_OPEN_TYPE.ONLY
end

