require "Protol.User_pb"

module(..., package.seeall)

class = Model.class:subclass()

EVT = Enum
{
	"PUSH_BIND_CODE",
	"PUSH_BANK_GOLD",
	"PUSH_BANK_QUERY_GOLD",
	"PUSH_PERSONAL_SIGN",
	"PUSH_PROMOTION_PICKUP_INCOME",
	"PUSH_PROMOTION_QUERY_INCOME",
	"PUSH_USER_INFO_MSG",
	"PUSH_USER_GIVE_COIN",
	"PUSH_EXCHANGE_BANK_LIST",
	"PUSH_EXCHANGE_BIND_BANK_CARD",
	"PUSH_EXCHANGE_GOLD",
	"PUSH_SET_ACCOUNT",
	"PUSH_CHANGE_HEAD_IMG",
	"PUSH_CHANGE_NICK_NAME",
	"PUSH_GIVECOIN_CONFIG",
	"PUSH_USER_CUSTOM_SERVICE_NUMBERS"
}

function class:initialize()
	super.initialize(self)
	
	net.msg:on(MsgDef_pb.MSG_USER, self:createEvent("onPushUserResponse"))

	self.promotionRequested = false
end

function class:onPushUserResponse(data)
	local response = User_pb.UserResponse()
	response:ParseFromString(data)

	local responseType = response.type
	-- log("type:"..responseType)
	-- log(response.isSuccess)
	if response.isSuccess then
		if responseType == User_pb.Request_Bind_RedeemCode then
			local redeemCode = response.bindRedeemCodeResponse.redeemCode
			self:fireEvent(EVT.PUSH_BIND_CODE, redeemCode)

		elseif responseType == User_pb.Request_Box_DrawOrSave then
			--保险箱存取
			-- log(response.boxResponse.gold..", "..response.boxResponse.gold)
			self:fireEvent(EVT.PUSH_BANK_GOLD, response.boxResponse.gold)

		elseif responseType == User_pb.Request_Box_Query then
			--保险箱金额查询
			-- log(response.boxResponse.gold..", "..response.boxResponse.gold)
			self:fireEvent(EVT.PUSH_BANK_QUERY_GOLD, response.boxResponse.gold)

		elseif responseType == User_pb.Daily_Free_PUSH then
			--每日赠送银币推送
			-- local sliver = tonumber(response.dailyFreePush.sliver)
			-- ui.mgr:open("Promotion/ShareAwardView", {value=sliver, type=Common_pb.Sliver})
			
		elseif responseType == User_pb.Request_Set_PersonalSign then
			--个性签名
			self:fireEvent(EVT.PUSH_PERSONAL_SIGN, true)
		elseif responseType == User_pb.Request_Pickup_income then
			--提现推广奖励
			self:fireEvent(EVT.PUSH_PROMOTION_PICKUP_INCOME)
		elseif responseType == User_pb.Request_Query_income then
			--查询推广奖励
			local promoteIncome = response.promoteIncomeResponse
			local incomeData = {}
			incomeData.incomea = tonumber(promoteIncome.incomea) or 0
			incomeData.incomeb = tonumber(promoteIncome.incomeb) or 0
			incomeData.incomec = tonumber(promoteIncome.incomec) or 0
			incomeData.totalIncomea = tonumber(promoteIncome.totalIncomea) or 0
			incomeData.totalIncomeb = tonumber(promoteIncome.totalIncomeb) or 0
			incomeData.totalIncomec = tonumber(promoteIncome.totalIncomec) or 0
			self:fireEvent(EVT.PUSH_PROMOTION_QUERY_INCOME, incomeData)

		elseif responseType == User_pb.Request_Share_Award then
			--分享奖励
			local shareAWardResponse = response.shareAWardResponse
			local sliverValue = shareAWardResponse.sliver
			ui.mgr:open("Promotion/ShareAwardView", {value=sliverValue, type=Common_pb.Sliver})
		
		elseif responseType == User_pb.Request_GiveCoin_Config then
			--请求分享
			local giveCoin = response.giveCoinConfigResponse
			-- if self.giveCoin == nil then
				self.giveCoin={}
			-- end
			for k,v in ipairs(giveCoin) do
				local goldValue = v.coin 
				local awardType = v.type
				if awardType ~=nil and goldValue~=nil then
					self.giveCoin[awardType]=goldValue
				end
			end

			self:fireEvent(EVT.PUSH_GIVECOIN_CONFIG, self.giveCoin)
			
		elseif responseType == User_pb.Push_Present_Gold then
			--赠送金币
			local pushPresentGold = response.pushPresentGold
			local goldValue = tonumber(pushPresentGold.gold)
			local awardType = pushPresentGold.type
			ui.mgr:open("Promotion/ShareAwardView", {value=goldValue, type=Common_pb.Gold, desc = pushPresentGold.type})
		elseif responseType == User_pb.Request_QueryUserInfo then
			local userInfoResponse = response.userInfoResponse
			local userInfo = {}
			-- userInfo.sliver = tonumber(userInfoResponse.sliver)
			userInfo.cardNum = tonumber(userInfoResponse.cardNum) or 0
			userInfo.gold = tonumber(userInfoResponse.gold)
			userInfo.vip = userInfoResponse.vip
			userInfo.nickName = userInfoResponse.nickName
			userInfo.userId = userInfoResponse.userId
			userInfo.headImage = userInfoResponse.headImage
			userInfo.redeemCode = userInfoResponse.redeemCode
			userInfo.sex = userInfoResponse.sex
			userInfo.personalSign = userInfoResponse.personalSign or ""
			userInfo.longitude = userInfoResponse.longitude or ""
			userInfo.latitude = userInfoResponse.latitude or ""
			userInfo.isPromote = userInfoResponse.isPromote

			-- log(userInfo)
			self:fireEvent(EVT.PUSH_USER_INFO_MSG, userInfo)

		elseif responseType == User_pb.Request_GiveCoin then
			self:fireEvent(EVT.PUSH_USER_GIVE_COIN)

		elseif responseType == User_pb.Request_BankList then
			--银行列表
			local item = {}
			local listData = {}
			local banklist = response.banklist
			for i, v in ipairs(banklist) do
				item = {}
				item.bankname = v.bankname
				item.bankid = v.bankid
				listData[#listData + 1] = item				
			end

			-- log(listData)			

			self.bankList = listData

			self:fireEvent(EVT.PUSH_EXCHANGE_BANK_LIST, listData)

		elseif responseType == User_pb.Request_BindBankNo then
			--绑定银行卡
			self:fireEvent(EVT.PUSH_EXCHANGE_BIND_BANK_CARD)

		elseif responseType == User_pb.Request_TurnsOut then
			--兑换
			self:fireEvent(EVT.PUSH_EXCHANGE_GOLD)

		elseif responseType == User_pb.Request_SetAccount then
			--绑定账号
			self:fireEvent(EVT.PUSH_SET_ACCOUNT)

		elseif responseType == User_pb.Request_ChangeHeadImage then
			--设置头像
			self:fireEvent(EVT.PUSH_CHANGE_HEAD_IMG)

		elseif responseType == User_pb.Request_ChangeUserName then
			--设置昵称
			self:fireEvent(EVT.PUSH_CHANGE_NICK_NAME)			
		end

		if response.customServiceNumbers ~= nil then
			local customServiceNumbers={}
			for k,v in ipairs(response.customServiceNumbers) do
				table.insert(customServiceNumbers,v)
			end
			self.customServiceNumbers=customServiceNumbers
			self:fireEvent(EVT.PUSH_USER_CUSTOM_SERVICE_NUMBERS, customServiceNumbers)
		end
	else
		local errMsg
		if response.errMsg and response.errMsg ~= "" then
			errMsg = response.errMsg
		else
			if responseType == User_pb.Request_Bind_RedeemCode then
				errMsg = "推广码绑定失败！"

			elseif responseType == User_pb.Request_Box_DrawOrSave then
				errMsg = "操作失败！"

			elseif responseType == User_pb.Request_Box_Query then
				errMsg = "无法获取保险柜信息"
			elseif responseType == User_pb.Request_Set_PersonalSign then
				errMsg = "签名设置失败"
			elseif responseType == User_pb.Request_GetCSNumber then
				errMsg = "没有设置微信客服账号"
				return
			end
		end

		log("user msg error !")
		-- log(string.format( "%s , %d",errMsg,responseType))

		local data = {
			content = errMsg,
			time = 3
		}
		ui.mgr:open("Dialog/DialogView", data)

		if responseType == User_pb.Request_Set_PersonalSign then
			self:fireEvent(EVT.PUSH_PERSONAL_SIGN, false)
		end
	end
end

function class:getBankList()
	return self.bankList
end

function class:getShareGold()
	if self.giveCoin == nil then
		self.giveCoin={}
	end
	return self.giveCoin
end

function class:getCustomServiceNumbers()
	if self.customServiceNumbers == nil then
		self.customServiceNumbers={}
	end
	return self.customServiceNumbers
end

--绑定推广码
function class:requestBindCode(code)
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_Bind_RedeemCode
	request.bindRedeemCodeRequest.redeemCode = code

	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

--保险箱存取请求,正数存，负数取
function class:requestBankDraw(goldNum)
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_Box_DrawOrSave
	request.drawOrSaveRequest.gold = tostring(-goldNum)
	-- log(tostring(-goldNum))

	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

function class:requestBankSave(goldNum)
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_Box_DrawOrSave
	request.drawOrSaveRequest.gold = tostring(goldNum)

	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

--保险箱金额查询
function class:requestBankQuery()
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_Box_Query

	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

--设置个性签名
function class:requestSetPersonalSign(personalSign)
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_Set_PersonalSign
	request.setPsRequest.personalSign = personalSign
	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

--推广奖励提现
function class:requestPickupIncome()
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_Pickup_income
	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

--推广奖励查询
function class:requestQueryIncome()
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_Query_income
	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())

	self.promotionRequested = true
end

--分享奖励
function class:requestShareAward()
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_Share_Award
	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())	
end

function class:checkPromotionRedPoint()
	return self.promotionRequested
end

--查询用户信息
function class:requestRoleMsg(userId)
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_QueryUserInfo
	request.userInfoRequest.userId = userId
	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

--赠送金币或房卡
function class:requestGiveCoin(userId, giveType, giveValue)
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_GiveCoin
	request.giveCoinRequest.userId = userId
	request.giveCoinRequest.currencyType = giveType
	request.giveCoinRequest.coin = tostring(giveValue)
	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())

	-- log("userId:" .. userId .. ", giveType : " .. giveType .. ", giveValue : " .. giveValue)
end

--请求兑换银行列表
function class:requestBankList()
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_BankList
	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

--请求绑定银行卡
function class:requestBindBankCard(cardNumber, bankId, userName, telphone)
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_BindBankNo
	request.bindBankNoRequest.name = userName
	request.bindBankNoRequest.telphone = telphone
	request.bindBankNoRequest.bankno = cardNumber
	request.bindBankNoRequest.bankid = bankId

	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

--请求兑换
function class:requestExchange(gold)
	gold = tostring(gold)

	local request = User_pb.UserRequest()
	request.type = User_pb.Request_TurnsOut
	request.turnsOutRequest.gold = gold

	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

--绑定账号
function class:requestBindAccount(accountId, password, verificationCode,nickName)
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_SetAccount
	request.setAccountRequest.account = accountId
	request.setAccountRequest.passwd = password
	request.setAccountRequest.passwd2 = password
	request.setAccountRequest.verificationCode = verificationCode

	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
	if nickName~=nil then
		self:requestModifyNickName(nickName)
	end
end

--修改头像
function class:requestChangeHeadImg(headImageId)
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_ChangeHeadImage
	request.changeHeadImageRequest.headImageId = headImageId

	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

--修改昵称
function class:requestModifyNickName(nickName)
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_ChangeUserName
	request.changeUserNameRequest.userName = nickName
	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())
end

--请求分享数据
function class:requestShare()
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_GiveCoin_Config
	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())	
end

--请求客服微信
function class:requestCustomServiceNumbers()
	local request = User_pb.UserRequest()
	request.type = User_pb.Request_GetCSNumber
	net.msg:send(MsgDef_pb.MSG_USER, request:SerializeToString())	
end