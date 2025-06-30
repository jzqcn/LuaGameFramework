module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()
	local accountInfo = Model:get("Account"):getUserInfo()
	self.txtGoldNum:setString(Assist.NumberFormat:amount2Hundred(accountInfo.gold))

	self.bankSaveNum = 0
	self.txtDepositNum:setString("0")

	self.tfGoldNum:setInputMode(ccui.EditBox.InputMode.phonenumber)
end

function prototype:setBankSaveNum(num)
	self.bankSaveNum = num
	self.txtDepositNum:setString(Assist.NumberFormat:amount2Hundred(num))

	local accountInfo = Model:get("Account"):getUserInfo()
	self.txtGoldNum:setString(Assist.NumberFormat:amount2Hundred(accountInfo.gold))

	self.tfGoldNum:setString("")
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

function prototype:onBtnDepositTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		-- Assist.TextField:onEvent(self.tfContent, ccui.TextFiledEventType.detach_with_ime)
		
		local content = self.tfGoldNum:getString()
		if content == "" then
			local data = {
				content = "请输入存款金额",
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		-- log(content)

		local num = tonumber(content) or 0
		num = num * 100

		local accountInfo = Model:get("Account"):getUserInfo()
		if num > accountInfo.gold then
			local data = {
				content = "没有足够金币",
			}
			ui.mgr:open("Dialog/DialogView", data)

			self.tfGoldNum:setPlaceHolder("")
			return
		end

		if num < 100 or (num % 100) ~= 0 then
			local data = {
				content = "输入金额必须为正整数",
			}
			ui.mgr:open("Dialog/DialogView", data)

			self.tfGoldNum:setPlaceHolder("")
			return
		end

		Model:get("User"):requestBankSave(num)
	end
end

function prototype:onBtnAddClick(sender)
	local num = self.tfGoldNum:getString()
	num = tonumber(num) or 0
	local accountInfo = Model:get("Account"):getUserInfo()
	local name = sender:getName()
	local index = tonumber(string.sub(name, -1))
	if index == 1 then
		-- +10
		num = accountInfo.gold
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
	
	if num > accountInfo.gold then
		num = math.floor(accountInfo.gold/100) * 100
	end

	self.tfGoldNum:setString(Assist.NumberFormat:amount2Hundred(num))
end

--[[function prototype:onBtnDepositOne(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:requestSaveGold(1000)
	end
end

function prototype:onBtnDepositTwo(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:requestSaveGold(10000)
	end
end

function prototype:onBtnDepositThree(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:requestSaveGold(50000)
	end
end

function prototype:onBtnDepositAll(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local accountInfo = Model:get("Account"):getUserInfo()
		local gold = accountInfo.gold
		if gold < 100 then
			local data = {
				content = "金币不足100，无法存款",
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		else
			local num = math.floor(gold / 100)
			self:requestSaveGold(num*100)
		end
	end
end--]]

function prototype:requestSaveGold(num)
	local accountInfo = Model:get("Account"):getUserInfo()
	if accountInfo.gold < num then
		local data = {
			content = "没有足够金币",
		}
		ui.mgr:open("Dialog/DialogView", data)
		return
	end
	Model:get("User"):requestBankSave(num)
end
