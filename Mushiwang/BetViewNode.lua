module (..., package.seeall)

prototype = Controller.prototype:subclass()

local BET_NUM = 4

function prototype:enter()
	self.size = self.rootNode:getContentSize()
end

function prototype:show(betRange, currencyType)
	if betRange == nil then
		log4ui:warn("[BetViewNode::show] bet range data error !")
	end

	local btnSize = self.btnBet_1:getContentSize()
	local betNum = #betRange
	local space = (self.size.width - btnSize.width*betNum) / (betNum+1)

	for i = 1, BET_NUM do
		if i <= betNum then
			if currencyType==Common_pb.Score then
				self["fontBet_"..i]:setString(betRange[i])
			else
				self["fontBet_"..i]:setString(Assist.NumberFormat:amount2Hundred(betRange[i]))
			end

			self["btnBet_"..i]:setTag(tonumber(betRange[i]))

			self["btnBet_"..i]:setVisible(true)

			local pos = cc.p((space+btnSize.width) * i - btnSize.width/2, self.size.height/2)
			self["btnBet_"..i]:setPosition(pos)
		else
			self["btnBet_"..i]:setVisible(false)
		end
	end

	self.rootNode:setVisible(true)
end

function prototype:onBtnBetTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local value = tonumber(sender:getTag())
		self:fireUIEvent("Game.Bet", value)
	end
end