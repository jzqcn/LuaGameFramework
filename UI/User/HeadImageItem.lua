module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:setItemInfo(info)
	self.imgHead:loadTexture(string.format("resource/csbimages/User/headImages/touxiang_%d.png", info.index))
	self.imgSelected:setVisible(info.sign)
	self.info = info
end

function prototype:getImageIndex()
	return self.info.index
end

function prototype:setSelected(var)
	self.imgSelected:setVisible(var)
end

function prototype:onBtnSelectClick()
	self:fireUIEvent("ChangeHeadImgView.Selected", self.info)
end

