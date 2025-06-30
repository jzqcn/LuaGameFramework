module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:refresh(data, index)
	self.data = data

	self.txtBankName:setString(data.bankname)
end

function prototype:onBtnItemClick()
	self:fireUIEvent("Exchange.BankSelected", self.data)
end