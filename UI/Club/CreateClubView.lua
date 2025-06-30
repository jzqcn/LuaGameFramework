module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)

	self.tfClubName:setPlaceHolderColor(cc.c3b(127, 127, 127))
	self.tfClubName:setTextColor(cc.c3b(255,255,122))
end

function prototype:onTFClubNameEvent(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfClubName:getPlaceHolder() == "长度不超过5个汉字" then
			self.tfClubName:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then
		
	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onBtnOkTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local content = self.tfClubName:getString()
		if content == "" then
			local data = {
				content = "名字不能为空！",
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		elseif getStrShowWidth(content) > 10 then
			local data = {
				content = "名字长度不能超过5个汉字！",
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		Model:get("Club"):requestCreateClub(content)

		self:close()
	end
end

function prototype:onBtnCancelTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:close()
	end
end

