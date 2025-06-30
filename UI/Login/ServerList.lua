module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter(data)
	self:bindUIEvent("ServerList.SelectItem", "uiEvtSelectItem")
	self:bindModelEvent("Account.EVT.SETSECRET", "onEvtSetSecret")  --应该用MsgGameLogin中的协议  而非账服一样的协议

	self.nodeLastSelect:setOnlyShowUI(true)
	local infoLast = Model:get("Account"):getLoginServer()
	self.nodeLastSelect:refresh(infoLast)

	local info = {}
	info.ccsNameOrFunc = "Login/ServerListItem"
	info.dataCheckFunc = bind(self.checkListView, self)
	info.data = data
	self.listServer:createItems(info)
end

function prototype:checkListView(l, r)
	return l.serverID == r.serverID
end

function prototype:uiEvtSelectItem(sender, data)
	if self.lastItem then
		self.lastItem:setCheck(false)
	end

	sender:setCheck(true)
	self.lastItem = sender

	self.nodeLastSelect:refresh(data)
	Model:get("Account"):selectServer(data)
end

function prototype:onBtnLogin()
	if nil == self.nodeLastSelect then
		ui.confirm:popup("请先选择服务器")
		return
	end

	local data = self.nodeLastSelect:getData()
	Model:get("GameServer"):connect(data.ip, data.port)
end

function prototype:onEvtSetSecret()
	Model:get("GameServer"):getPlayerList()
end
