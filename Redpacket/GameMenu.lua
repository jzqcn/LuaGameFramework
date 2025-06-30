module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:hideMenu()
end

function prototype:onBtnMenuClick()
	if self.isShow then
		self:hideMenu()
	else
		self:showMenu()
	end
end

function prototype:showMenu()
	self.panelBg:setVisible(true)
	self.imgBg:setVisible(true)
	self.btnMenu:setScaleY(1)
	self.isShow = true
end

function prototype:hideMenu()
	self.panelBg:setVisible(false)
	self.imgBg:setVisible(false)
	self.btnMenu:setScaleY(-1)
	self.isShow = false
end

function prototype:onPanelCloseClick()
	self:hideMenu()
end

--玩法
function prototype:onBtnHelpClick()
	ui.mgr:open("Redpacket/PlayDescView")
	self:hideMenu()
end

--设置
function prototype:onBtnSettingClick()
	ui.mgr:open("User/SettingView")
	self:hideMenu()
end

