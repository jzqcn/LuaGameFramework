module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter(data)

end

function prototype:refresh(data, index)
	self["txtName"]:setString(Assist.String:getLimitStrByLen(data.nickName, 12))
	self["txtID"]:setString("ID:"..data.playerId)

	local score = data.score
	if score > 0 then
		self["fntWin"]:setString(Assist.NumberFormat:amount2Hundred(score))
		self["fntLose"]:setVisible(false)
	else
		self["fntLose"]:setString(Assist.NumberFormat:amount2Hundred(score))
		self["fntWin"]:setVisible(false)
	end
end