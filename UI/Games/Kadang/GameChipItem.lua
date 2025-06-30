module(..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	
end

function prototype:setChipValue(value)
	self.chipValue = value
	self.txtChipNum:setString(value)

	--self.imgChipBg
end