module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	
end

function prototype:refresh(data, index)
	self.itemInfo = data
	self.fntGoldNum:setString(Assist.NumberFormat:amount2Hundred(data.num))

	local imgIconId = index--data.id % 10
	if imgIconId > 5 then
		imgIconId = 5
	elseif imgIconId <= 0 then
		imgIconId = 1
	end

	if data.itemType == Common_pb.Gold then
		--rmb购买金币
		self.fntRmbNum:setString("￥" .. data.money)
		self.imgGold:setVisible(false)

		local x, y = self.btnItem:getPosition()
		self.fntRmbNum:setPosition(cc.p(x, y))

		self.imgIcon:loadTexture(string.format("resource/csbimages/Shop/gold_%d.png", imgIconId))
	elseif data.itemType == Common_pb.Sliver then
		--金币购买银币
		-- local x, y = self.btnItem:getPosition()		
		-- self.fntRmbNum:setString(Assist.NumberFormat:amount2TrillionText(data.gold))
		
		-- local size = self.fntRmbNum:getContentSize()
		-- local iconSize = self.imgGold:getContentSize()
		-- self.fntRmbNum:setPosition(cc.p(x + iconSize.width/2, y))

		-- self.imgGold:setPosition(cc.p(x - size.width/2, y))
		-- self.imgGold:setVisible(true)

		-- self.imgIcon:loadTexture(string.format("resource/csbimages/Shop/money_%d.png", imgIconId))
	end
end

function prototype:onBtnItemTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		-- log(self.itemInfo)
		if not self.itemInfo or self.itemInfo.id <= 0 then
			log4ui:warn("shop item data error!")
			return
		end

		if self.itemInfo.itemType == Common_pb.Gold then
			if util:getPlatform() == "win32" then
				local data = {
					content = "Windows平台不支持充值！"
				}
				ui.mgr:open("Dialog/ConfirmView", data)
			else
				-- local data = {
				-- 	content = "在线充值暂未开放！敬请期待！"
				-- }
				-- ui.mgr:open("Dialog/ConfirmView", data)

				--请求充值
				Model:get("Item"):requestCharge(self.itemInfo.id, self.itemInfo.chargeChannel)	
			end
		elseif self.itemInfo.itemType == Common_pb.Sliver then
			local function buySliver()
				Model:get("Item"):requestGoldToSliver(self.itemInfo.id, self.itemInfo.itemType)
			end

			local data = {
				content = string.format("是否确认支付%d金币，购买%d银币？", tonumber(self.itemInfo.gold), tonumber(self.itemInfo.num)),
				okFunc = buySliver
			}
			ui.mgr:open("Dialog/ConfirmDlg", data)
		end
	end
end
