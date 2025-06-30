module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter()
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_LAYMINES_LIST", "onPushLayminesList")
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_LAYMINES", "onPushLaymines")

	self.panelNumBtn:setVisible(false)

	local userInfo = Model:get("Account"):getUserInfo()
	self.userId = userInfo.userId

	local roomInfo = Model:get("Games/Redpacket"):getRoomInfo()
	--倍数
	local mutiple = roomInfo.mutiple
	self.mutiple = mutiple
	-- log(roomInfo)
	--红包个数设置
	local numberRanges = roomInfo.numberRanges
	self.redpacketNum = numberRanges[#numberRanges]
	-- for i, v in ipairs(numberRanges) do
	-- 	self["fntNum_" .. i]:setString(tostring(v))
	-- end
	-- self.numberRanges = numberRanges

	--红包金额范围
	local coinRanges = roomInfo.coinRanges
	self.maxCoin = coinRanges[#coinRanges]
	self.minCoin = coinRanges[1]
	self.coinRanges = coinRanges

	local userGold = userInfo.gold / 100
	--设置默认值
	local defaultValue = db.var:getUsrVar("Redpacket_Value") or self.minCoin
	-- local defaultNum = db.var:getUsrVar("Redpacket_Number") or numberRanges[#numberRanges]
	local bombId = db.var:getUsrVar("Redpacket_BombId") or 0
	if userGold < defaultValue or defaultValue > self.maxCoin or defaultValue < self.minCoin then
		defaultValue = self.minCoin
	end

	-- if defaultNum > numberRanges[#numberRanges] or defaultNum < numberRanges[1] then
	-- 	defaultNum = numberRanges[#numberRanges]
	-- end

	self.txtRedpacketValue:setString(tostring(defaultValue))
	-- self.txtRedpacketNum:setString(tostring(defaultNum))
	self.txtBombId:setString(tostring(bombId))

	self:updateSlidPercent(defaultValue)

	
	local layminesList = Model:get("Games/Redpacket"):getLayminesList()
	local param = 
	{
		data = layminesList,
		ccsNameOrFunc = "Redpacket/ApplyBuryBombItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.listview:createItems(param)

	self:isApplyBury(layminesList)	
end

function prototype:onPushLayminesList(layminesList)
	self.listview:refreshListView(layminesList)

	self:isApplyBury(layminesList)
end

function prototype:onPushLaymines(isSuccess)
	if isSuccess then
		-- self:close()
	end
end

--是否已申请埋雷
function prototype:isApplyBury(list)
	local isApply = false
	for i, v in ipairs(list) do
		if v.playerId == self.userId then
			isApply = true
			break
		end
	end

	if isApply then
		self.panelRightPart:setVisible(false)
		self.imgApplyTip:setVisible(true)
	else
		self.panelRightPart:setVisible(true)
		self.imgApplyTip:setVisible(false)
	end

	return isApply
end

--申请埋雷
function prototype:onBtnRequestBombTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local curValue = tonumber(self.txtRedpacketValue:getString())
		local userInfo = Model:get("Account"):getUserInfo()
		local value = curValue * 100
		if value <= userInfo.gold then
			local num = self.redpacketNum --self.txtRedpacketNum:getString()
			local bombId = self.txtBombId:getString()
			Model:get("Games/Redpacket"):requestLaymines(value, tonumber(num), tonumber(bombId))

			--保存记录
			db.var:setUsrVar("Redpacket_Value", curValue)
			-- db.var:setUsrVar("Redpacket_Number", tonumber(num))
			db.var:setUsrVar("Redpacket_BombId", tonumber(bombId))
		else
			local data = {
				content = "金币余额不足，无法埋雷！"
			}
			ui.mgr:open("Dialog/DialogView", data)
		end	
	end
end

function prototype:onBtnAddClick()
	local curValue = tonumber(self.txtRedpacketValue:getString())
	local userInfo = Model:get("Account"):getUserInfo()
	if curValue >= self.maxCoin or curValue >= (userInfo.gold/100) then
		return
	end

	local slidIndex = self.slidIndex + 1
	if slidIndex > #self.coinRanges then
		slidIndex = #self.coinRanges
	end

	local value = self.coinRanges[slidIndex]
	if value > (userInfo.gold/100) then
		return
	end
	self.txtRedpacketValue:setString(value)

	self:updateSlidPercent(self.coinRanges[slidIndex])
	self.slidIndex = slidIndex
end

function prototype:onBtnSubClick()
	local curValue = tonumber(self.txtRedpacketValue:getString())
	if curValue <= self.minCoin then
		return
	end

	self.slidIndex = self.slidIndex - 1
	if self.slidIndex < 1 then
		self.slidIndex = 1
	end
	self.txtRedpacketValue:setString(self.coinRanges[self.slidIndex])
	self:updateSlidPercent(self.coinRanges[self.slidIndex])
end

function prototype:updateSlidPercent(value)
	self.slidIndex = 0
	for i, v in ipairs(self.coinRanges) do
		if value == v then
			local percent = (i-1) / (#(self.coinRanges)-1)
			self.slidValue:setPercent(percent * 100)

			self.slidIndex = i
			break
		end
	end

	if self.slidIndex <= 0 then
		self.slidIndex = 1		
	end
	self.txtRedpacketValue:setString(self.coinRanges[self.slidIndex])
end

function prototype:onEventSliderValue(sender, eventType)
	if eventType ~= cc.SliderEventType.ON_PERCENTAGE_CHANGED then
		return
	end

	local userInfo = Model:get("Account"):getUserInfo()
	local percent = self.slidValue:getPercent() / 100
	local value = percent * self.maxCoin
	for i, v in ipairs(self.coinRanges) do
		if value <= v and value <= (userInfo.gold/100) then
			self.slidIndex = i
			self.txtRedpacketValue:setString(self.coinRanges[self.slidIndex])
			break
		end
	end
end

--[[function prototype:onBtnNumClick(sender)
	local name = sender:getName()
	local index = tonumber(string.sub(name, -1))
	self.txtRedpacketNum:setString(tostring(self.numberRanges[index]))
end--]]

function prototype:onPanelSetBombIdClick()
	self.panelNumBtn:setVisible(true)
	self.btnApplyBomb:setVisible(false)
	self.btnApplyBomb:stopAllActions()
end

function prototype:onBtnBombIdClick(sender)
	self.panelNumBtn:setVisible(false)

	self.btnApplyBomb:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
		self.btnApplyBomb:setVisible(true)
	end)))
	
	local name = sender:getName()
	local index = tonumber(string.sub(name, -1))
	self.txtBombId:setString(tostring(index))
end

function prototype:onBtnCloseClick()
	self:close()
end


