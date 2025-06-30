module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter(clubData)
	self:bindModelEvent("Club.EVT.PUSH_CLUB_SET_DRAW", "onPushClubSetDraw")

	self.selIndex = 1

	local baseDrawList = clubData.baseDrawList
	-- log(clubData)
	for i, v in ipairs(baseDrawList) do
		if i > 6 then
			break
		end

		if v == clubData.baseDraw then
			self["checkbox_"..i]:setSelected(true)
			self["checkbox_"..i]:setEnabled(false)
			self.selIndex = i
		else
			self["checkbox_"..i]:setSelected(false)
		end

		self["fntNum_"..i]:setString(tostring(v/100))
	end

	if #baseDrawList < 6 then
		for i = #baseDrawList + 1, 6 do
			self["checkbox_"..i]:setVisible(false)
			self["fntNum_"..i]:setVisible(false)
		end
	end

	self.clubData = clubData

	--[[local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)]]
end

function prototype:onCheckNumClick(sender)
	local name = sender:getName()
	local index = tonumber(string.sub(name, -1))
	if index then
		self["checkbox_"..self.selIndex]:setEnabled(true)
		self["checkbox_"..self.selIndex]:setSelected(false)

		sender:setEnabled(false)
		self.selIndex = index
	end
end

function prototype:onBtnOkTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local value = tonumber(self["fntNum_" .. self.selIndex]:getString())
		value = value * 100
		if value ~= self.clubData.baseDraw then
			Model:get("Club"):requestSetDraw(self.clubData.id, value)
			self.baseDraw = value
		else
			self:close()
		end
	end
end

function prototype:onPushClubSetDraw()
	local data = {
		content = "服务费更改成功！"
	}
	ui.mgr:open("Dialog/DialogView", data)

	self.clubData.baseDraw = self.baseDraw

	self:close()
end

function prototype:onBtnCancelTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:close()
	end
end

-- function prototype:onImageCloseClick()
-- 	self:close()
-- end
