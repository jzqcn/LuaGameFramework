module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.isSelected = false
end

function prototype:refresh(data)
	self.imgSelected:setVisible(false)
	-- log("data.typeKey")
	-- log(string.format("resource/csbimages/Hall/CreateRoom/tabName/%s_1.png", data.typeKey))
	self.imgNormalName:loadTexture(string.format("resource/csbimages/Hall/CreateRoom/tabName/%s_1.png", data.typeKey))
	self.imgSelName:loadTexture(string.format("resource/csbimages/Hall/CreateRoom/tabName/%s_2.png", data.typeKey))

	self.imgNormalName:ignoreContentAdaptWithSize(true)
	self.imgSelName:ignoreContentAdaptWithSize(true)
	self.data = data
end

function prototype:setSelected(var)
	self.isSelected = var
	if self.isSelected then
		self.imgSelected:setVisible(true)
		self.btnNormal:setVisible(false)
	else
		self.imgSelected:setVisible(false)
		self.btnNormal:setVisible(true)
	end
end

function prototype:onBtnSelectedClick()
	if self.isSelected == true then
		return 
	end

	self:fireUIEvent("SelectCardTabItem", self.data)
end

