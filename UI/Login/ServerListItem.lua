module (..., package.seeall)


local SERVER_STATUS = MsgAccount:typeDef("SERVER_STATUS")
local SERVER_STATUS_NAME = {}
SERVER_STATUS_NAME[SERVER_STATUS.HIDE] 		= "隐藏"
SERVER_STATUS_NAME[SERVER_STATUS.MAINTAIN] 	= "维护"
SERVER_STATUS_NAME[SERVER_STATUS.GOOD] 		= "流畅"
SERVER_STATUS_NAME[SERVER_STATUS.BUSY] 		= "繁忙"
SERVER_STATUS_NAME[SERVER_STATUS.FULL] 		= "爆满"
SERVER_STATUS_NAME[SERVER_STATUS.CLOSE] 	= "未开放"


prototype = Controller.prototype:subclass()

function prototype:enter()
	self.onlyShowUI = false
end

function prototype:setOnlyShowUI(value)
	self.onlyShowUI = value
end

function prototype:refresh(data)
	self.data = data
	
	self.txtName:setString(data.serverName)
	self.txtNum:setString("数量:" .. tostring(data.roleNum))
	self.txtStatus:setString(SERVER_STATUS_NAME[data.status] or "")
	self.imgSelect:setVisible(false)

	if not self.onlyShowUI then
		local infoLast = Model:get("Account"):getLoginServer()
		if data.serverID == infoLast.serverID then
			self:onBtnBg()
		end
	end
end

function prototype:onBtnBg()
	if self.onlyShowUI then
		return
	end

	ui.confirm:popup(self.data.serverName)
	self:fireUIEvent("ServerList.SelectItem", self, self.data)
end

function prototype:setCheck(value)
	self.imgSelect:setVisible(value)
end

function prototype:getData()
	return self.data
end


