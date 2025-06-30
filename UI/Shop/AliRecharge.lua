module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.txtRechargeValue:setString("")

	local goodsList = Model:get("Item"):getAliItemList()
	for i, v in ipairs(goodsList) do
		if i <= 6 then
			self["fontRecharge_" .. i]:setString(tostring(v.money))
			self["fontRecharge_" .. i]:setTag(v.id)
		end
	end
end

function prototype:onBtnRechargeClick(sender)
	local name = sender:getName()
	local index = tonumber(string.sub(name, -1))
	if index >= 1 and index <= 6 then
		local numStr = self["fontRecharge_" .. index]:getString()
		local tag = self["fontRecharge_" .. index]:getTag()
		self.txtRechargeValue:setString(numStr)
		self.txtRechargeValue:setTag(tag)
	end
end

function prototype:onBtnRechargeTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if util:getPlatform() == "win32" then
			local data = {
				content = "Windows平台不支持充值！"
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		local numStr = self.txtRechargeValue:getString()
		local value = tonumber(numStr)
		if value and value > 0 then
			--请求充值
			local id = self.txtRechargeValue:getTag()
			Model:get("Item"):requestCharge(id, item_pb.Alipay)
		end
	end	
end

