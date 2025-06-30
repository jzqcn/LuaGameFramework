module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	local accountInfo = Model:get("Account"):getUserInfo()
	self.txtGoldNum:setString(Assist.NumberFormat:amount2Hundred(accountInfo.gold))

	self.bankSaveNum = 0
	self.txtDepositNum:setString("0")
end

function prototype:setBankSaveNum(num)
	self.bankSaveNum = num
	self.txtDepositNum:setString(Assist.NumberFormat:amount2Hundred(num))

	local accountInfo = Model:get("Account"):getUserInfo()
	self.txtGoldNum:setString(Assist.NumberFormat:amount2Hundred(accountInfo.gold))

	self.tfGoldNum:setString("")
	self.tfGoldNum:setInputMode(ccui.EditBox.InputMode.phonenumber)
end

function prototype:onTFGoldClick(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfGoldNum:getPlaceHolder() == "请输入金额" then
			self.tfGoldNum:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onBtnDrawTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		-- Assist.TextField:onEvent(self.tfContent, ccui.TextFiledEventType.detach_with_ime)
		
		local content = self.tfGoldNum:getString()
		if content == "" then
			local data = {
				content = "请输入取款金额！",
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		-- log(content)

		local num = tonumber(content)
		if num == nil then
			local data = {
				content = "输入金额必须为数字！",
			}
			ui.mgr:open("Dialog/DialogView", data)

			self.tfGoldNum:setPlaceHolder("")
			return
		end

		num = num * 100

		if self.bankSaveNum <= 0 or self.bankSaveNum < num  then
			local data = {
				content = "没有足够金币！",
			}
			ui.mgr:open("Dialog/DialogView", data)

			self.tfGoldNum:setPlaceHolder("")
			return
		end

		if num < 100 or (num % 100) ~= 0 then
			local data = {
				content = "输入金额必须为正整数！",
			}
			ui.mgr:open("Dialog/DialogView", data)

			self.tfGoldNum:setPlaceHolder("")
			return
		end

		Model:get("User"):requestBankDraw(num)
	end
end

function prototype:onBtnAddClick(sender)
	local num = self.tfGoldNum:getString()
	num = tonumber(num) or 0

	local name = sender:getName()
	local index = tonumber(string.sub(name, -1))
	if index == 1 then
		-- +10
		num = self.bankSaveNum
	elseif index == 2 then
		-- +50
		num = num + 50
	elseif index == 3 then
		-- +100
		num = num + 100
	elseif index == 4 then
		-- +1000
		num = num + 1000
	end

	num = num * 100
	if self.bankSaveNum < num  then
		num = self.bankSaveNum
	end

	self.tfGoldNum:setString(Assist.NumberFormat:amount2Hundred(num))
end

--[[function prototype:onBtnDrawOne(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:requestDrawGold(1000)
	end
end

function prototype:onBtnDrawTwo(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:requestDrawGold(10000)
	end
end

function prototype:onBtnDrawThree(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:requestDrawGold(50000)
	end
end
--]]
function prototype:onBtnDrawAll(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.bankSaveNum < 100 then
			local data = {
				content = "存款不足，无法取出",
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		else
			self:requestDrawGold(self.bankSaveNum)
		end
	end
end

function prototype:requestDrawGold(num)
	if self.bankSaveNum < num then
		local data = {
			content = "存款不足，无法取出",
		}
		ui.mgr:open("Dialog/DialogView", data)
		return
	end
	Model:get("User"):requestBankDraw(num)
end
