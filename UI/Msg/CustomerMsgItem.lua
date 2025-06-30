module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:refresh(data)
	if data.side == "left" then
		self.nodeLeft:setContent(data.content)
		self.nodeLeft:setVisible(true)
		self.nodeLeft.txtTime:setString(data.time)
		self.nodeRight:setVisible(false)
	elseif data.side == "right" then
		self.nodeRight:setContent(data.content)
		self.nodeRight:setVisible(true)
		self.nodeRight.txtTime:setString(data.time)
		self.nodeLeft:setVisible(false)
	end
end



