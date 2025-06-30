module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	local accountInfo = Model:get("Account"):getUserInfo()
	local sex = accountInfo.sex or 1 --性别,1-男、2-女
	
	self:setSex(sex)
	
	util.timer:after(200, self:createEvent("playAction"))
end

function prototype:setSex(sex)
	if sex == 1 then
		self.panelBoy:setVisible(true)
		self.panelGirl:setVisible(false)
		-- self.imgRole:loadTexture("resource/csbimages/Hall/Component/boy.png")
	else
		self.panelBoy:setVisible(false)
		self.panelGirl:setVisible(true)
		-- self.imgRole:loadTexture("resource/csbimages/Hall/Component/girl.png")
	end
end

function prototype:playAction()
	self:playActionTime(0, true)
end

function prototype:hideShadow()
	self.imgBoyShadow:setVisible(false)
	self.imgGirlShadow:setVisible(false)
end

