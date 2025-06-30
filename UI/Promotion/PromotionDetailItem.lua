module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	
end

function prototype:refresh(data)
	self.txtName:setString(Assist.String:getLimitStrByLen(data.userName))
	self.txtID:setString(data.userId)

	local totalLevelDraw = math.floor(data.totalLevelDraw)
	self.numReward:setString(Assist.NumberFormat:amount2Hundred(totalLevelDraw))
end
