module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local ROOM_NUM_LENGTH = 6

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	--Model消息事件
	self:bindModelEvent("Club.EVT.PUSH_JOIN_CLUB_RESULT", "onPushJoinResult")

	self:clear()

	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
end

function prototype:clear()
	for i = 1, ROOM_NUM_LENGTH do
		self["imgInput_"..i]:setVisible(false)
	end

	self.inputNumTab = {}
end

function prototype:onPushJoinResult(isSuccess)
	if isSuccess then
		local data = {
			content = "申请消息已发送，请等待管理员审核！"
		}
		ui.mgr:open("Dialog/DialogView", data)
		self:close()
	else
		self:clear()
	end
end

function prototype:onBtnNumTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local length = #self.inputNumTab
		if length >= ROOM_NUM_LENGTH then
			return
		end

		local name = sender:getName()
		local num = tonumber(string.sub(name, -1))
		local inputName = "imgInput_"..(length+1)
		self[inputName]:setString(string.format("%d", num))
		self[inputName]:setVisible(true)

		table.insert(self.inputNumTab, num)

		if #self.inputNumTab == ROOM_NUM_LENGTH then
			local numStr = table.concat( self.inputNumTab)
			local clubId = tonumber(numStr)
			Model:get("Club"):requestJoinClub(clubId)
		end
	end
end

function prototype:onBtnDelTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local length = #self.inputNumTab
		if length > 0 then
			table.remove(self.inputNumTab, length)
			self["imgInput_"..length]:setVisible(false)
		end
	end
end

function prototype:onBtnResetTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:clear()
	end
end

function prototype:onPanelCloseClick()
	self:close()
end

