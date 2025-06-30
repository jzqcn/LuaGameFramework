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

--路单
function prototype:onBtnWaybillTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Dantiao/BranchMapView")
		self:hideMenu()
	end
end

--玩法
function prototype:onBtnPlayTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Dantiao/PlayDescView")
		self:hideMenu()
	end
end

--设置
function prototype:onBtnSettingTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Dantiao/SettingView")
		self:hideMenu()
	end
end

