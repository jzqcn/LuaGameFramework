module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:refresh(data, index)
	self.data = data
	self.txtChat:setString(data.word)
end

--发送简短语言文字聊天
function prototype:onPanelSelectClick()
	self:fireUIEvent("GameChat.Text", self.data)
end