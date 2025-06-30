require "Protol.item_pb"

module(..., package.seeall)

class = Model.class:subclass()

EVT = Enum
{
	"PUSH_RECHARGE_MSG",
}

local item_pb =item_pb

--消息公告
function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_ITEM, self:createEvent("onItemResponse"))

    self.aliItemList = {}
    self.weixinItemList = {}
    -- self.moneyItemList = {}
end

--充值
function class:requestCharge(id, chargeChannel)
	if not chargeChannel then
		chargeChannel =  item_pb.Alipay
	end

	local request = item_pb.ItemRequest()
	request.type = item_pb.Charge_Request
	request.chargeRequest.id = id
	request.chargeRequest.chargeChannel = chargeChannel
	
	if util:getPlatform() == "ios" then
		request.chargeRequest.systemType = item_pb.IOS
	else
		request.chargeRequest.systemType = item_pb.Android
	end

	request.chargeRequest.clientip = Model:get("Position"):getUserIpAddress()
	log("ip:"..request.chargeRequest.clientip)

	net.msg:send(MsgDef_pb.MSG_ITEM, request:SerializeToString())
end

--金币转银币请求
function class:requestGoldToSliver(id, itemType)
	local request = item_pb.ItemRequest()
	request.type = item_pb.GOLD_TO_SLIVER_REQUEST
	request.goldToSliverRequest.id = id
	request.goldToSliverRequest.itemType = itemType
	net.msg:send(MsgDef_pb.MSG_ITEM, request:SerializeToString())
end

function class:onItemResponse(data)
	local response = item_pb.ItemResponse()
	response:ParseFromString(data)

	if response.isSuccess then
		local requestType = response.type
		if requestType == item_pb.Push_List then
			self.aliItemList = {}
			self.weixinItemList = {}
    		-- self.moneyItemList = {}

			local listPush = response.listPush
			for k, v in ipairs(listPush.item) do
				local item = {}
				item.id = v.id
				item.itemType = v.itemType
				item.itemName = tostring(v.itemName)
				item.num = v.num
				item.money = v.money
				item.gold = v.gold
				item.desc = tostring(v.desc)
				item.chargeChannel = v.chargeChannel

				if item.itemType == 3 then
					if item.chargeChannel == item_pb.Alipay then
						self.aliItemList[#self.aliItemList + 1] = item
					elseif item.chargeChannel == item_pb.Wx then
						self.weixinItemList[#self.weixinItemList + 1] = item
					end
				elseif item.itemType == 2 then
				-- 	self.moneyItemList[#self.moneyItemList + 1] = item
				end				
			end

			table.sort(self.aliItemList, function (a, b)
     	        return a.id < b.id
     	    end)

			table.sort(self.weixinItemList, function (a, b)
     	        return a.id < b.id
     	    end)

			-- table.sort(self.moneyItemList, function (a, b)
   --   	        return a.id < b.id
   --   	    end)

			-- log(self.aliItemList)
     	    -- log(self.weixinItemList)
     	    -- log(self.moneyItemList)  	    

		elseif requestType == item_pb.GOLD_TO_SLIVER_REQUEST then
			local data = {
				content = "购买成功！"
			}
			ui.mgr:open("Dialog/ConfirmView", data)

		elseif requestType == item_pb.Charge_Request then
			local codeUrlPush = response.codeUrlPush
			if codeUrlPush and codeUrlPush.codeUrl then
				-- log("codeUrlPush : "..codeUrlPush.codeUrl)
				-- util:openUrl(codeUrlPush.codeUrl)
				if util:getPlatform() == "android" then
					util:openUrl(codeUrlPush.codeUrl)
				else
					util:openUrl(codeUrlPush.codeUrl)
					-- ui.mgr:open("WebView", codeUrlPush.codeUrl)
				end
			else
				log("Charge_Request:: url is nil")
			end

		elseif requestType == item_pb.Push_CodeUrl then
			local codeUrlPush = response.codeUrlPush
			-- log("codeUrlPush : "..codeUrlPush.codeUrl)
			-- util:openUrl(codeUrlPush)
			if util:getPlatform() == "android" then
				util:openUrl(codeUrlPush.codeUrl)
			else
				util:openUrl(codeUrlPush)
				-- ui.mgr:open("WebView", codeUrlPush.codeUrl)
			end

		elseif requestType == item_pb.PUSH_CHARGE_SUCCESS then
			local chargeSuccessPush = response.chargeSuccessPush
			if chargeSuccessPush.isSuccess then
				local coin = Assist.NumberFormat:amount2Hundred(chargeSuccessPush.coin)
				log("recharge coin : " .. coin)

				-- local data = {
				-- 	content = "恭喜，充值成功！" .. coin .. "金币已到账！"
				-- }
				-- ui.mgr:open("Dialog/ConfirmView", data)

				-- if ui.mgr:getLayer("WebView") then
				-- 	ui.mgr:close("WebView")
				-- end

				if util:getPlatform() == "android" then
					util:fireCoreEvent(REFLECT_EVENT_CLOSE_WEBPAGE, 0, 0, "")
				end

				self:fireEvent(EVT.PUSH_RECHARGE_MSG)
			end
		end

	else
		local data = {
			content = response.tips
		}
		ui.mgr:open("Dialog/ConfirmView", data)
	end
end

function class:getAliItemList()
	return self.aliItemList
end

function class:getWeixinItemList()
	return self.weixinItemList
end

-- function class:getMoneyItemList()
-- 	return self.moneyItemList
-- end
