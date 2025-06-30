module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:refresh(data, index)
	if data.name == "" then
		self.txtAccount:setString("游客" .. (data.id or ""))
		self.btnDel:setVisible(false)
	else
		self.txtAccount:setString(data.name)
	end

	local accountName = db.var:getSysVar("account_login_name") or ""
	if accountName == data.name then
		self:setSelected(true)
	else
		self:setSelected(false)
	end

	self.data = data
	self.index = index
end

function prototype:getData()
	return self.data
end

function prototype:isSelected()
	return self.selected
end

function prototype:setSelected(var)
	if var then
		self.imgSel:setVisible(true)
		self.imgUnsel:setVisible(false)
	else
		self.imgUnsel:setVisible(true)
		self.imgSel:setVisible(false)
	end

	self.selected = var
end

function prototype:onPanelSelClick()
	if self.selected then
		return
	end

	self:fireUIEvent("Account.Select", self.index)
end

function prototype:onBtnDelAccountClick()	
	self:fireUIEvent("Account.Refresh", self.data)
end

