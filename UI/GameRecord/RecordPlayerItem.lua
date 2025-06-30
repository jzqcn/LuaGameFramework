module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter(data)

end

function prototype:refresh(data, index)
	self.txtName:setString(Assist.String:getLimitStrByLen(data.nickName, 8))
	self.txtResult:setString(Assist.NumberFormat:amount2Hundred(data.score))
	if data.score < 0 then
		self.txtResult:setTextColor(cc.c3b(102, 157, 147))
	else
		self.txtResult:setTextColor(cc.c3b(255,214,22))
	end
end


