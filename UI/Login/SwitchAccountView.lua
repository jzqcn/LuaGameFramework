module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	self:bindUIEvent("Account.Refresh", "uiEvtDelete")
	self:bindUIEvent("Account.Select", "uiEvtSelect")

	self:refresh()
end

function prototype:refresh()
	local accountList = Model:get("Account"):getAccountData()
	-- log(accountList)

	local param = 
	{
		data = accountList,
		ccsNameOrFunc = "Login/AccountListItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.listview:createItems(param)
    self.listview:setScrollBarEnabled(false)
end

function prototype:uiEvtDelete(data)
	if data.name == "" then
		return
	end

	local accountList = Model:get("Account"):getAccountData()
	local accountName = db.var:getSysVar("account_login_name")
	if data.name == accountName then
		db.var:setSysVar("account_login_name", "")
		db.var:setSysVar("account_login_password", "")

		for i, v in ipairs(accountList) do
			if not v.name or v.name == "" then
				db.var:setSysVar("account_login_id", v.id)

				local loginNode = ui.mgr:getDialogRootNode()
				if loginNode and loginNode.refreshShowAccount then
					loginNode:refreshShowAccount()
				end

				break
			end
		end
	end

	Model:get("Account"):delAccountData(data.name)

	accountList = Model:get("Account"):getAccountData()

	local param = 
	{
		data = accountList,
		ccsNameOrFunc = "Login/AccountListItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.listview:recreateListView(param)
end

function prototype:uiEvtSelect(index)
	local items = self.listview:getAllItems()
	for i, v in ipairs(items) do
		if i == index then
			v:setSelected(true)
		else
			v:setSelected(false)
		end
	end
end

--重置密码
function prototype:onBtnResetPwClick()
	ui.mgr:open("Login/FindPasswordView")
end

--切换账号
function prototype:onBtnSwitchAccountClick()
	ui.mgr:open("Login/AccountLoginView")
end

function prototype:onBtnLoginClick()
	local items = self.listview:getAllItems()
	for i, v in ipairs(items) do
		if v:isSelected() then
			local data = v:getData()
			if data.name ~= "" and data.password ~= "" then
				Model:get("Account"):accountLogin(data.name, data.password)
			else
				Model:get("Account"):visitorlogin()
			end
			break
		end
	end
end

function prototype:onBtnCloseClick()
	self:close()
end

