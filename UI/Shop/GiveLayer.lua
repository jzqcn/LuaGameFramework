module (..., package.seeall)

prototype = Controller.prototype:subclass()

local GIVE_TYPE = Enum
{
	"gold",
	"card"
}

function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_USER_INFO_MSG", "onPushUserInfo")
	self:bindModelEvent("User.EVT.PUSH_USER_GIVE_COIN", "onPushUserGiveCoin")
	self:bindModelEvent("User.EVT.PUSH_GIVECOIN_CONFIG", "onPushGiveCoinConfig")
	self.panelPlayerMsg:setVisible(false)

	--只能输入数字
	self.tfGoldNum:setInputMode(ccui.EditBox.InputMode.phonenumber)
	self.tfCardNum:setInputMode(ccui.EditBox.InputMode.phonenumber)

	self.tfCode:setInputMode(ccui.EditBox.InputMode.phonenumber)

	local shareGold=Model:get("User"):getShareGold()
	if #shareGold < 1 then
		Model:get("User"):requestShare()
		self.txtLimitCoin:setVisible(false)
	else
		self:onPushGiveCoinConfig(shareGold)
	end
end

function prototype:onPushGiveCoinConfig(shareGold)
	if shareGold and #shareGold > 0 then
		self.shareGold=shareGold
		local strCoin=string.format("2.给玩家赠送金币，金币余额不低于%d。",shareGold[5]/100)
		self.txtLimitCoin:setString(strCoin)
		self.txtLimitCoin:setVisible(true)
	end
end

function prototype:show()
	self.rootNode:setVisible(true)
	self.panelPlayerMsg:setVisible(false)
	self.panelSearch:setVisible(true)
end

function prototype:onTFIDClick(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfCode:getPlaceHolder() == "请输入玩家ID" then
			self.tfCode:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then
		
	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onBtnPasteClick()
	local strClipboardString = CEnvRoot:GetSingleton():GetClipboardString()
	if strClipboardString ~= "" then
		--查找ID。部分ID复制内容为 “ID:9999998"
		local i, j = string.find(strClipboardString, "%d+")
		if i and j then
			local strId = string.sub(strClipboardString, i, j)
			self.tfCode:setString(strId)
		else
			local data = {
				content = "复制内容不符合规范！请重新复制！"
			}
			ui.mgr:open("Dialog/DialogView", data)

			self.tfCode:setString("")
		end
	else
		local data = {
			content = "剪切板上没有数据！请检查！"
		}
		ui.mgr:open("Dialog/DialogView", data)
	end
end

--查找玩家ID
function prototype:onBtnSearchClick()
	local strId = self.tfCode:getString()
	if strId ~= nil and strId ~= "" then
		if strId == Model:get("Account"):getUserId() then
			local data = {
				content = "不能给自己赠送金币或房卡！"
			}
			ui.mgr:open("Dialog/DialogView", data)
		else
			Model:get("User"):requestRoleMsg(strId)
		end
	else
		local data = {
			content = "请输入玩家ID"
		}
		ui.mgr:open("Dialog/DialogView", data)
	end
end

--玩家信息
function prototype:onPushUserInfo(userInfo)
	if not userInfo then
		return 
	end

	self.panelSearch:setVisible(false)
	self.panelPlayerMsg:setVisible(true)

	sdk.account:getHeadImage(userInfo.userId, userInfo.nickName, self.headIcon, userInfo.headImage)

	self.fntGold:setString(Assist.NumberFormat:amount2Hundred(userInfo.gold))
	self.fntCard:setString(tostring(userInfo.cardNum))
	self.txtName:setString(Assist.String:getLimitStrByLen(userInfo.nickName))
	self.txtId:setString("ID:" .. userInfo.userId)

	self.checkboxGold:setSelected(true)
	self.checkboxCard:setSelected(false)
	self.tfGoldNum:setString("")
	self.tfCardNum:setString("")

	self.giveUserId = userInfo.userId
	self:setGiveType(GIVE_TYPE.gold)	
end

function prototype:onCheckGoldClick()
	self:setGiveType(GIVE_TYPE.gold)
	self.checkboxCard:setSelected(false)
end

function prototype:onCheckCardClick()
	self:setGiveType(GIVE_TYPE.card)
	self.checkboxGold:setSelected(false)
end

function prototype:setGiveType(_type)
	if self.giveType == _type then
		return
	end

	self.checkboxGold:setEnabled(_type == GIVE_TYPE.card)
	-- self.tfGoldNum:setEnabled(_type == GIVE_TYPE.gold)

	self.checkboxCard:setEnabled(_type == GIVE_TYPE.gold)
	-- self.tfCardNum:setEnabled(_type == GIVE_TYPE.card)

	self.giveType = _type

	local accountInfo = Model:get("Account"):getUserInfo()
	if _type == GIVE_TYPE.gold then		
		local gold = accountInfo.gold / 100
		if gold < 50 then
			Assist:setNodeGray(self.btnGive)
		else
			Assist:setNodeColorful(self.btnGive)
		end
	else
		if accountInfo.cardNum > 0 then
			Assist:setNodeColorful(self.btnGive)	
		else
			Assist:setNodeGray(self.btnGive)
		end		
	end

	if _type == GIVE_TYPE.gold then
		local nums = {50, 100, 500, 1000}
		for i = 1, 4 do
			self["fontNum_" .. i]:setString("+" .. nums[i])
		end

		self.tfCardNum:setString("")
	else
		local nums = {1, 5, 10, 100}
		for i = 1, 4 do
			self["fontNum_" .. i]:setString("+" .. nums[i])
		end

		self.tfGoldNum:setString("")
	end
end

function prototype:onBtnAddClick(sender)
	local number = 0

	local name = sender:getName()
	local index = tonumber(string.sub(name, -1))

	local nums

	local accountInfo = Model:get("Account"):getUserInfo()
	if self.giveType == GIVE_TYPE.gold then
		nums = {50,100,500, 1000}
		number = tonumber(self.tfGoldNum:getString()) or 0
		number = number + nums[index]

		if number*100 > accountInfo.gold then
			number = math.floor(accountInfo.gold/100)
		end

		self.tfGoldNum:setString(tostring(number))
	else
		nums = {1, 5, 10, 100}
		number = tonumber(self.tfCardNum:getString()) or 0
		number = number + nums[index]

		if number > accountInfo.cardNum then
			number = accountInfo.cardNum
		end

		self.tfCardNum:setString(tostring(number))
	end	
end

function prototype:onTFGoldClick(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfGoldNum:getPlaceHolder() == "请输入赠送金额" then
			self.tfGoldNum:setPlaceHolder("")
		end

		self.checkboxGold:setSelected(true)
		self:onCheckGoldClick()

	elseif eventType == ccui.TextFiledEventType.detach_with_ime then
		local accountInfo = Model:get("Account"):getUserInfo()
		local number = tonumber(self.tfGoldNum:getString())
		if number then
			if number*100 > accountInfo.gold then
				number = math.floor(accountInfo.gold/100)
			end

			self.tfGoldNum:setString(tostring(number))
		end
	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onTFCardClick(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfCardNum:getPlaceHolder() == "请输入赠送房卡数" then
			self.tfCardNum:setPlaceHolder("")
		end

		self.checkboxCard:setSelected(true)
		self:onCheckCardClick()

	elseif eventType == ccui.TextFiledEventType.detach_with_ime then
		local accountInfo = Model:get("Account"):getUserInfo()
		local number = tonumber(self.tfCardNum:getString())
		if number then
			if number > accountInfo.cardNum then
				number = accountInfo.cardNum
			end

			self.tfCardNum:setString(tostring(number))
		end
	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onBtnGiveTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.giveType == GIVE_TYPE.gold then
			local accountInfo = Model:get("Account"):getUserInfo()
			local gold = tonumber(accountInfo.gold) / 100
			if self.shareGold and #self.shareGold > 0 then
				if gold < (self.shareGold[5]/100)  then
					local strCoin=string.format( "赠送金币时，金币余额不低于%d!",self.shareGold[5]/100)
					local data = {
						content = strCoin
					}
					ui.mgr:open("Dialog/DialogView", data)
					return
				end	
			else
				if gold < 50 then
					local data = {
						content = "赠送金币时，金币余额不低于50!",
					}
					ui.mgr:open("Dialog/DialogView", data)
					return
				end	
			end

			local number = tonumber(self.tfGoldNum:getString())
			if number and number > 0 then
				number = number * 100
				if number % 100 == 0 then
					local accountInfo = Model:get("Account"):getUserInfo()
					if number > accountInfo.gold then
						local data = {
							content = "金币不够，无法赠送！",
						}
						ui.mgr:open("Dialog/DialogView", data)
					else
						self:requestGiveCoin(self.giveUserId, Common_pb.Gold, number)
					end
				else
					local data = {
						content = "输入金额必须为正整数！",
					}
					ui.mgr:open("Dialog/DialogView", data)

					self.tfGoldNum:setPlaceHolder("")
				end
			else
				local data = {
					content = "请输入赠送金额",
				}
				ui.mgr:open("Dialog/DialogView", data)
			end
		else
			local number = tonumber(self.tfCardNum:getString())
			if number and number > 0 then
				local accountInfo = Model:get("Account"):getUserInfo()
				if number > accountInfo.cardNum then
					local data = {
						content = "房卡不够，无法赠送！",
					}
					ui.mgr:open("Dialog/DialogView", data)
				else
					self:requestGiveCoin(self.giveUserId, Common_pb.Card, number)
				end
			else
				local data = {
					content = "输入数量有误！",
				}
				ui.mgr:open("Dialog/DialogView", data)

				self.tfCardNum:setPlaceHolder("")
			end
		end
	end
end

function prototype:requestGiveCoin(userId, giveType, number)
	local confirmFunc = function ()
		Model:get("User"):requestGiveCoin(userId, giveType, number)
	end

	local userName = self.txtName:getString()
	local desc = giveType == Common_pb.Gold and "金币" or "房卡"
	local showNum = number
	if giveType == Common_pb.Gold then
		showNum = number / 100
	end

	local data = {
		okFunc = confirmFunc,
		content = string.format("您将向玩家【%s】赠送%d%s", userName, showNum, desc)
	}
	ui.mgr:open("Dialog/ConfirmDlg", data)
end

function prototype:onPushUserGiveCoin()
	local data = {
		content = "赠送成功！",
	}
	ui.mgr:open("Dialog/DialogView", data)

	-- self.tfGoldNum:setString("")
	-- self.tfCardNum:setString("")
	-- self.tfGoldNum:setPlaceHolder("请输入赠送金额")
	-- self.tfCardNum:setPlaceHolder("请输入赠送房卡数")
	self.panelSearch:setVisible(true)
	self.panelPlayerMsg:setVisible(false)

end

function prototype:onBtnReturnTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self.panelSearch:setVisible(true)
		self.panelPlayerMsg:setVisible(false)
	end
end
