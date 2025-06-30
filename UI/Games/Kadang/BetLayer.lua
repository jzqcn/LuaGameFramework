module (..., package.seeall)

prototype = Controller.prototype:subclass()

local ChipLevel = {0.1, 0.3, 0.7, 1}
local OverLevel = {2.0, 3.0, 4.0, 5.0}

function prototype:enter()
	-- self:bindUIEvent("Game.Clock", "uiEvtClockFinish")
	self.size = self.rootNode:getContentSize()
end

function prototype:getOverLevelValue(minLimit, maxLimit, overIndex)
	local value = maxLimit*OverLevel[overIndex]
	value = math.ceil(value/minLimit) * minLimit
	return value
end

function prototype:showBetData(minLimit, maxLimit)
	local index = #ChipLevel - 1
	local chipTab = {maxLimit}
	local overIndex = 1
	while index > 0 do
		local value = maxLimit * ChipLevel[index]
		value = math.floor(value/minLimit) * minLimit
		if value <= 0 then
			value = maxLimit*OverLevel[overIndex]
			value = math.ceil(value/minLimit) * minLimit
			overIndex = overIndex + 1
		elseif value < minLimit then
			value = minLimit
			for i, v in ipairs(chipTab) do
				if value == v then
					value = maxLimit*OverLevel[overIndex]
					value = math.ceil(value/minLimit) * minLimit
					overIndex = overIndex + 1
					break
				end
			end
		else
			for i, v in ipairs(chipTab) do
				if value == v then
					value = maxLimit*OverLevel[overIndex]
					value = math.ceil(value/minLimit) * minLimit
					overIndex = overIndex + 1
					break
				end
			end
		end

		chipTab[#chipTab + 1] = value
		
		index = index - 1
	end

	table.sort(chipTab,  function (a, b)
     	        return a < b
     	    end)

	-- log(chipTab)

	for i, v in ipairs(chipTab) do
		self["btnBet_"..i]:setTag(v)
		if v <= maxLimit then
			self["btnBet_"..i]:setEnabled(true)
			Assist:setNodeColorful(self["btnBet_"..i])
		else			
			self["btnBet_"..i]:setEnabled(false)
			Assist:setNodeGray(self["btnBet_"..i])
		end
		self["fontBet_"..i]:setString(Assist.NumberFormat:amount2TrillionText(v))
	end
end

function prototype:showBetRange(betRange, userCoin)
	table.sort(betRange,  function (a, b)
     	        return a < b
     	    end)

	local btnSize = self.btnBet_1:getContentSize()

	local rangeNum = #betRange
	local space = 17
	local btnsW = (rangeNum+1) * btnSize.width + rangeNum * space
	local posX = (self.size.width - btnsW) / 2 + btnSize.width/2
	local index = 0
	for i = 1, 5 do
		local x = posX + index * (btnSize.width + space)
		-- log("pos x:" .. x)
		if i <= rangeNum then
			local value = betRange[i]
			self["btnBet_"..i]:setTag(value)
			if value <= userCoin then
				self["btnBet_"..i]:setEnabled(true)
				Assist:setNodeColorful(self["btnBet_"..i])
			else			
				self["btnBet_"..i]:setEnabled(false)
				Assist:setNodeGray(self["btnBet_"..i])
			end

			self["fontBet_"..i]:setString(Assist.NumberFormat:amount2TrillionText(value))

			self["btnBet_"..i]:setPositionX(x)
			self["btnBet_"..i]:setVisible(true)

			index = index + 1
		elseif i == 5 then
			self.btnCancel:setPositionX(x)
			self.btnCancel:setVisible(true)
		else
			self["btnBet_"..i]:setVisible(false)
		end
	end

	-- local maxLimit = Model:get("Account"):getUserInfo()
	-- for i, v in ipairs(betRange) do
	-- 	self["btnBet_"..i]:setTag(v)
	-- 	if v <= userCoin then
	-- 		self["btnBet_"..i]:setEnabled(true)
	-- 		Assist:setNodeColorful(self["btnBet_"..i])
	-- 	else			
	-- 		self["btnBet_"..i]:setEnabled(false)
	-- 		Assist:setNodeGray(self["btnBet_"..i])
	-- 	end
	-- 	self["fontBet_"..i]:setString(v)
	-- end
end

function prototype:onBtnBetTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Bet", sender:getTag())
	end
end

function prototype:onBtnCancelTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Bet")
	end
end