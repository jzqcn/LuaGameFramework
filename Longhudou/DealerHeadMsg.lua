module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()
	self.txtCoin:setString("上局输赢:0")
end
