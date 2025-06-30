require "Protol.Currency_pb"

module(..., package.seeall)

class = Model.class:subclass()

local Common_pb = Common_pb

function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_CURRENCY, self:createEvent("onCurrencyResponse"))
end

function class:onCurrencyResponse(data)
	local response = Currency_pb.SynCurrencyResponse()
	response:ParseFromString(data)

	local lackCoinStatus = response.lackCoinStatus
	local currencyType = lackCoinStatus.currencyType
	local userId = lackCoinStatus.userId
	local coin = lackCoinStatus.coin

	log("[Currency::onCurrencyResponse] coin:"..coin..", requestType:"..response.requestType)

	if response.requestType == Currency_pb.Push_LackCoin then
		--缺少货币
		-- log(currencyType)
		if currencyType == Common_pb.Sliver then
			-- util.timer:after(1000, self:createEvent("SHOW_SHOP_VIEW", function()
			-- 	ui.mgr:open("Shop/ShopView", 3)
			-- end))
		elseif currencyType == Common_pb.Gold then
			util.timer:after(1000, self:createEvent("SHOW_SHOP_VIEW", function()
				ui.mgr:open("Shop/ShopView", 1)
			end))
		elseif currencyType == Common_pb.Card then
			util.timer:after(1000, self:createEvent("SHOW_SHOP_VIEW", function()
				ui.mgr:open("Shop/ShopView", 1)
			end))
		end
	elseif response.requestType == Currency_pb.Request_Charge then
		--充值
	else
		log4model:warn("[Currency::onCurrencyResponse] currencyType error !!!")
	end
end
