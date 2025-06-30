module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()

end

function prototype:setRoleInfo(info)
	sdk.account:loadHeadImage(info.playerId, info.playerName, info.headimage, 
		self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.imgHeadIcon)

	self.txtName:setString(Assist.String:getLimitStrByLen(info.playerName))
	self.txtGold:setString(Assist.NumberFormat:amount2TrillionText(info.coin))
end

function prototype:onLoadHeadImage(filename)
	self.imgHeadIcon:loadTexture(filename)
end

