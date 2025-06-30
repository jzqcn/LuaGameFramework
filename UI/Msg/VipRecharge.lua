module (..., package.seeall)

prototype = Controller.prototype:subclass()

--客服微信号


function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_USER_CUSTOM_SERVICE_NUMBERS", "onPushCustomServiceNumbers")
	local serviceNumbers=Model:get("User"):getCustomServiceNumbers()
	if #serviceNumbers < 1 then
		Model:get("User"):requestCustomServiceNumbers()
		--[[self.fontCoin_1:setVisible(false)
		self.fontCoin_2:setVisible(false)
		self.fontCoin_3:setVisible(false)
		self.fontCoin_4:setVisible(false)]]
	else
		self:onPushCustomServiceNumbers(serviceNumbers)
	end

	

    
    local userId = Model:get("Account"):getUserId()
    self.texID:setString("ID:"..userId)
end

function prototype:onPushCustomServiceNumbers(datas)
	if datas==nil then return end
	local info={}
	if #datas==1 then
		 info = {{datas[1]}}
	elseif #datas>=2 then
		 info = {{datas[1],datas[2]}}
	end
	local param = 
	{
		data = info,
		ccsNameOrFunc = "Msg/VipRechargeItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
	self.listview:createItems(param)
end

function prototype:onBtnCopyIdClick()
	-- log(self.texID:getString())
	util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, Model:get("Account"):getUserId())
end

