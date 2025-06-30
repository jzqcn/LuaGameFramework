module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_BIND_CODE", "onPushBindCode")

	--更改背景图片
	-- ui.mgr:setSceneImageBg(self.imgBg, true)

	local accountInfo = Model:get("Account"):getUserInfo()
	local redeemCode = accountInfo.redeemCode
	if redeemCode and redeemCode ~= "" then
		self.btnBind:setVisible(false)
		self.btnPaste:setVisible(false)

		self.txtBinded:setVisible(true)		
		self.btnPromotion:setVisible(true)
	else
		self.btnBind:setVisible(true)
		self.btnPaste:setVisible(true)

		self.txtBinded:setVisible(false)
		self.btnPromotion:setVisible(false)
	end

	self.exitEditing = false

	self.tfCode:setPlaceHolderColor(cc.c3b(127, 127, 127))
	self.tfCode:setTextColor(cc.c3b(42, 31, 31))
	self.tfCode:setInputMode(ccui.EditBox.InputMode.phonenumber)

	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
end

function prototype:onTFCodeEvent(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfCode:getPlaceHolder() == "请输入推广码" then
			self.tfCode:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then
		self.exitEditing = true
		util.timer:after(200, function ()
    		self.exitEditing = false
    	end)
	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onBtnBindTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		-- Assist.TextField:onEvent(self.tfContent, ccui.TextFiledEventType.detach_with_ime)
		
		local code = self.tfCode:getString()
		if code == "" then
			local data = {
					content = "请输入推广码",
				}
				ui.mgr:open("Dialog/DialogView", data)
			return
		end

		self.pRedeemCode=code --不指定三级代理，绑定成功后推送的是自己的推广码，不是上级的推广码，缓存起来，方便立即刷新
		Model:get("User"):requestBindCode(code)
	end
end

function prototype:onBtnPromotionTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Promotion/PromotionView")
		self:close()
	end
end

function prototype:onPushBindCode(redeemCode)
	-- local data = {
	-- 	content = "恭喜！推广码绑定成功！赶快完成你的推广任务吧！"
	-- }
	-- ui.mgr:open("Dialog/ConfirmView", data)

	--获得600金币
	-- ui.mgr:open("Promotion/ShareAwardView", {value=300, type=Common_pb.Gold})
	self.btnBind:setVisible(false)
	self.btnPaste:setVisible(false)

	self.txtBinded:setVisible(true)

	local accountInfo = Model:get("Account"):getUserInfo()

	local isEnabledPromotion = Model:get("Account"):isEnabledPromotion()
	if isEnabledPromotion then
		accountInfo.redeemCode = redeemCode
	else
		if self.pRedeemCode ~=nil then
			accountInfo.pRedeemCode = self.pRedeemCode
		end
	end
	self:close()
end

function prototype:onBtnPasteTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local strClipboardString = CEnvRoot:GetSingleton():GetClipboardString()
		if strClipboardString ~= "" then
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
			-- self.tfCode:setString(strClipboardString)
		else
			local data = {
				content = "剪切板上没有数据！请检查！"
			}
			ui.mgr:open("Dialog/DialogView", data)
		end
	end
end

function prototype:onImgCloseClick()
	if self.exitEditing == true then
		return
	end
	self:close()
end

