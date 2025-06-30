
module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	-- if not data or data == "" then
	-- 	assert(false)
	-- end

	-- self.modelName = data
	self.startPos = cc.p(self.imgPos:getPosition())
	self.bgSize = self.imgPop:getContentSize()
	self.btnItems = {self.imgPos, self.imgSetting, self.imgHelp, self.imgShop, self.imgBank, self.imExit}

	self:hideMenu()
	-- self:refreshState()
end

function prototype:setModelName(modelName)
	self.modelName = modelName
end

function prototype:refreshState()
	local modelData = Model:get(self.modelName)
	if modelData == nil then
		log4ui:error("MenuToolBarView::get model data error ! model name == "..self.modelName)
		return
	end

	local isEnabledDiatance = modelData:isEnabledDiatance()
	if not isEnabledDiatance then
		self.imgPos:setVisible(false)

		self.imgPop:setContentSize(cc.size(self.bgSize.width, self.bgSize.height-75))

		for i, v in ipairs(self.btnItems) do
			if i > 1 then
				v:setPosition(cc.p(self.startPos.x, self.startPos.y - 75 * (i-1)))
			end
		end
	end

	local roomState = modelData:getRoomStateInfo()
	local isViewer = modelData:isViewer()
	local roomStyle = modelData:getRoomStyle()
	-- log("roomStyle:"..roomStyle)
	-- if roomStyle == Common_pb.RsGold or (roomStyle==Common_pb.RsCard and modelData:getCurrencyType()~=Common_pb.Score) then
	if roomStyle == Common_pb.RsGold then
		--金币场
		-- log("roomState:"..roomState.roomState)
		if roomState.roomState > 2 and isViewer == false then
			self.btnExit:setEnabled(false)
			self.btnBank:setEnabled(false)
			self.btnShop:setEnabled(false)
			self.btnExit:setColor(cc.c3b(127, 127, 127))
			self.btnBank:setColor(cc.c3b(127, 127, 127))
			self.btnShop:setColor(cc.c3b(127, 127, 127))
			-- Assist:setNodeGray(self.btnExit)
			-- Assist:setNodeGray(self.btnBank)
			-- Assist:setNodeGray(self.btnShop)
		else
			self.btnExit:setEnabled(true)
			self.btnBank:setEnabled(true)
			self.btnShop:setEnabled(true)
			-- Assist:setNodeColorful(self.btnExit)
			-- Assist:setNodeColorful(self.btnBank)
			-- Assist:setNodeColorful(self.btnShop)
			self.btnExit:setColor(cc.c3b(255, 255, 255))
			self.btnBank:setColor(cc.c3b(255, 255, 255))
			self.btnShop:setColor(cc.c3b(255, 255, 255))
		end

		--隐藏解散按钮
		self.btnDissolve:setVisible(false)
	else
		--房卡 计分场
		if modelData:isStarter() then
			--房主只能解散
			self.btnDissolve:setVisible(true)
			self.btnExit:setVisible(false)
		else
			local userInfo = modelData:getUserInfo()
			if userInfo then
				--非房主，游戏开始后，不能退出，只能申请解散
				local roomInfo = modelData:getRoomInfo()
				if roomInfo.currentGroup and roomInfo.currentGroup <= 1 and roomState.roomState <= 2 then
					self.btnDissolve:setVisible(false)
					self.btnExit:setVisible(true)
				else
					self.btnDissolve:setVisible(true)
					self.btnExit:setVisible(false)
				end
			else
				self.btnDissolve:setVisible(false)
				self.btnExit:setVisible(true)
			end
		end
	end
end

function prototype:updateMenuItems(roomStyle)

end

function prototype:onBtnMenuClick()
	if self.menuVisible then
		self:hideMenu()
	else
		self:showMenu()
	end
end

function prototype:onPanelCanelClick()
	-- self:close()
	self:hideMenu()
end

function prototype:hideMenu()
	self.imgBg:setVisible(false)
	self.imgPop:setVisible(false)
	self.btnMenu:setScaleY(-1)

	self.menuVisible = false
end

function prototype:showMenu()
	self.imgBg:setVisible(true)
	self.imgPop:setVisible(true)
	self.btnMenu:setScaleY(1)

	self:refreshState()

	self.menuVisible = true
end

--定位
function prototype:onBtnPosClick()
	self:hideMenu()

	self:fireUIEvent("Game.Distance")
	-- self:close()
end

--退出
function prototype:onBtnExitClick()
	Model:get(self.modelName):requestLeaveGame()

	self:hideMenu()
	-- self:close()
end

--解散（房卡场）
function prototype:onBtnDissolveClick()
	Model:get(self.modelName):requestDissolveRoom()

	self:hideMenu()
	-- self:close()
end

--设置
function prototype:onBtnSettingClick()
	ui.mgr:open("User/SettingView", 2)
	self:hideMenu()
	-- self:close()
end

--商城
function prototype:onBtnShopClick()
	ui.mgr:open("Shop/ShopView", 1)
	self:hideMenu()
	-- self:close()
end

--保险箱
function prototype:onBtnBankClick()
	ui.mgr:open("Shop/BankView")
	self:hideMenu()
	-- self:close()
end

--帮助
function prototype:onBtnHelpClick()
	ui.mgr:open("GameHelp/GameHelpView", self.modelName)
	self:hideMenu()
	-- self:close()
end
