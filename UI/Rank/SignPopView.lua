module (..., package.seeall)

local TAG_BG = 100
local TAG_MASK = 101
local TOUCHES_BG = 102

local ORDER_BG = -1
local ORDER_MASK = -2

prototype = Window.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter(userInfo)
	if not userInfo then
		return
	end
	
	sdk.account:getHeadImage(userInfo.userId, userInfo.nickName, self.headIcon, userInfo.headImage)

	self.fntGold:setString(Assist.NumberFormat:amount2Hundred(userInfo.gold))
	self.fntCard:setString(tostring(userInfo.cardNum))
	self.txtName:setString(Assist.String:getLimitStrByLen(userInfo.nickName))
	self.txtId:setString("ID:" .. userInfo.userId)
	if userInfo.redeemCode and userInfo.redeemCode~="" then
		local isEnabledPromotion = Model:get("Account"):isEnabledPromotion()
		if isEnabledPromotion or userInfo.isPromote then
			--开启三级分销或者是推广员显示推广码
			self.txtCode:setString(userInfo.redeemCode)
			self.btnCopyCode:setVisible(true)
		else
			self.txtCode:setString("已绑定")
			self.btnCopyCode:setVisible(false)
		end
	else
		self.txtCode:setString("未绑定")
		self.btnCopyCode:setVisible(false)
	end

	self.nodeRole:setSex(userInfo.sex)

	self.txtPersonalSign:setString(userInfo.personalSign)
	self.btnCopySign:setVisible(userInfo.personalSign ~= "")
	if userInfo.personalSign == "" then
		self.txtPersonalSign:setString("玩家还未设置个性签名！")
	end

	self.txtPos:setString("")

	local function setAddress(addr)
		self.txtPos:setString(addr)
	end

	getPlayerAddress(userInfo.longitude, userInfo.latitude, setAddress)	
end

function prototype:onBtnIdCopyTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtId:getString())
	end
end

function prototype:onBtnCodeCopyTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtCode:getString())
	end
end

function prototype:onBtnSignCopyTouch()
	if eventType == ccui.TouchEventType.ended then
		util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtPersonalSign:getString())
	end
end

function prototype:onPanelCloseClick()
	self:close()
end

--个性签名复制
function prototype:onBtnSignCopyTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtSign:getString())
	end
end


