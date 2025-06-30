module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	
end

function prototype:refresh(data)
	if #data >= 2 then
		self.txtID_1:setString(data[1])
		self.txtID_2:setString(data[2])
	elseif #data == 1 then
		self.txtID_1:setString(data[1])
		self.panelRight:setVisible(false)
	end
end



function prototype:onBtnLeftCopyIdClick()
	util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtID_1:getString())
end

function prototype:onBtnRightCopyIdClick()
	util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtID_2:getString())
end
