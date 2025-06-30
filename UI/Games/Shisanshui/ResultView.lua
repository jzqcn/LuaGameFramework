local Define = require "UI.Mgr.Define"

module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter(data)
	local userid = Model:get("Account"):getUserId()
	local currencyType = Model:get("Games/Shisanshui"):getCurrencyType()
	local dataItems = {}
   -- dump(data,"ResultView")
	for id, v in pairs(data) do
		if v.playerId == userid then
			--local cardNum = #(v.memStateInfo.cards)
			 local resultCoin = tonumber(v.memStateInfo.betResultCoin) or 0
			if resultCoin >= 0 then
				--胜利
				local eff = CEffectManager:GetSingleton():getEffect("a1sl2")
				local size = self.panelEff:getContentSize()
				eff:setPosition(cc.p(size.width/2, size.height/2))
				self.panelEff:addChild(eff)
				-- self.imgTitleBg:loadTexture("resource/csbimages/GameResult/imgWin.png")
				-- self.imgTitle:loadTexture("resource/csbimages/GameResult/txtWin.png")

				self.imgNickname:loadTexture("resource/csbimages/GameResult/winNickname.png")
				--self.imgLeft:loadTexture("resource/csbimages/GameResult/winLeft.png")
				-- self.imgBaseCoin:loadTexture("resource/csbimages/GameResult/winBaseScore.png")
				--self.imgBomb:loadTexture("resource/csbimages/GameResult/winBomb.png")

				self.imgResultValue:loadTexture(string.format("resource/csbimages/GameResult/winType_%d.png", currencyType))

				sys.sound:playEffectByFile("resource/audio/Paodekuai/eff_win.mp3")
			else
				--失败
				local eff = CEffectManager:GetSingleton():getEffect("a1sb2")
				local size = self.panelEff:getContentSize()
				eff:setPosition(cc.p(size.width/2, size.height/2))
				self.panelEff:addChild(eff)
				-- self.imgTitleBg:loadTexture("resource/csbimages/GameResult/imgLose.png")
				-- self.imgTitle:loadTexture("resource/csbimages/GameResult/txtLose.png")

				self.imgNickname:loadTexture("resource/csbimages/GameResult/loseNickname.png")
				--self.imgLeft:loadTexture("resource/csbimages/GameResult/loseLeft.png")
				-- self.imgBaseCoin:loadTexture("resource/csbimages/GameResult/loseBaseScore.png")
				--self.imgBomb:loadTexture("resource/csbimages/GameResult/loseBomb.png")
				
				self.imgResultValue:loadTexture(string.format("resource/csbimages/GameResult/loseType_%d.png", currencyType))

				sys.sound:playEffectByFile("resource/audio/Paodekuai/eff_lose.mp3")
			end
		end
		if table.nums(v.memStateInfo.cards)~=0 then--旁观者,结算页面不算进去
		    dataItems[#dataItems + 1] = v	
        end	
	end

	--[[if Model:get("Games/Paodekuai"):getIsPlayBack() then
		self.imgBomb:setVisible(false)
	end]]

	local param = 
	{
		data = dataItems,
		ccsNameOrFunc = "Games/Shisanshui/ResultViewItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}

    self.listview:createItems(param)

    -- self:playAction(0.4)
end

function prototype:playAction(delay)
	-- local callFunc2 = cc.CallFunc:create(function ()
	-- 	self.imgTitle:runAction(cc.RepeatForever:create(cc.Sequence:create()))
	-- end)

	-- self.imgTitle:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(delay), cc.ScaleTo:create(0.4, 1.15), 
	-- 	cc.ScaleTo:create(0.4, 1.0), cc.DelayTime:create(delay), cc.RotateBy:create(0.4, 360))))
end

function prototype:onBtnShareTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local accountLogin=Model:get("Account"):isAccountLogin()
		if accountLogin then
			util:captureScreenToCamera()
		else
			util:captureScreen()
		end
	end
end

function prototype:onBtnReturnTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		--[[if not Model:get("Games/Paodekuai"):getIsPlayBack() then
			if StageMgr:isStage("Game") then
	    		local gameView = ui.mgr:getDialogRootNode()
	    		if gameView then
	    			gameView:showGroupResultView()
	    		else
	    			log4ui:warn("get game view failed !")
	    		end
	    	end
			]]
			if StageMgr:isStage("Game") then
	    		local gameView = ui.mgr:getDialogRootNode()
	    		if gameView then
	    			gameView:showGroupResultView()
	    		else
	    			log4ui:warn("get game view failed !")
	    		end
	    	end
			self:close()
		--else
			--[[回放直接退出，返回回放列表界面
			StageMgr:chgStage("Hall")

			ui.mgr:open("GameRecord/GamePlaybackView", Model:get("PlayBack"):getPlaybackInfo())]]
		--end
	end
end

