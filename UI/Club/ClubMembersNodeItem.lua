module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	-- self:bindUIEvent("OpenOrClosePopupItem", "uiEvtHandlePopupItem")
end

function prototype:refresh(data)
	self.listview:createItems(data)
end



