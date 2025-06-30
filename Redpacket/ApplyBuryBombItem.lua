module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:refresh(data, index)
	self.txtName:setString(data.playerName)
	self.txtValue:setString(Assist.NumberFormat:amount2TrillionText(data.redpacketInfo.redpacketCoin))
end
