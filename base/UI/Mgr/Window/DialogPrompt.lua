local Dialog = require "UI.Mgr.Window.Dialog"
local Define = require "UI.Mgr.Define"

module(..., package.seeall)


prototype = Dialog.prototype:subclass()

function prototype:initialize(...)
	super.initialize(self, ...)

	self.windowType = Define.WINDOW_TYPE.DIALOGPROMPT
end

function prototype:getReOpenType()
	return Define.RE_OPEN_TYPE.ONLY
end

function prototype:getOpenAction()
	return nil
end

function prototype:getCloseAction()
	return nil
end
