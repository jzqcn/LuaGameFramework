local Define = require "UI.Mgr.Define"

module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter(data)
	if data.isPlayBack then
		self:showPlayBackDetails(data)
		return
	end

	local userid = Model:get("Account"):getUserId()
	local currencyType = Model:get("Games/Mushiwang"):getCurrencyType()
	local roomStyle=Model:get("Games/Mushiwang"):getRoomStyle()
	local dataItems = {}
	for id, v in pairs(data) do
		if v.playerId == userid then
			 local resultCoin = tonumber(v.memStateInfo.betResultCoin) or 0
			if resultCoin >= 0 then--胜利
				local eff = CEffectManager:GetSingleton():getEffect("a1sl2")
				local size = self.panelEff:getContentSize()
				eff:setPosition(cc.p(size.width/2, size.height/2))
				self.panelEff:addChild(eff)
				self.imgNickname:loadTexture("resource/csbimages/GameResult/winNickname.png")
				self.imgResultValue:loadTexture(string.format("resource/csbimages/GameResult/winType_%d.png", currencyType))
				self.imgResultBet:loadTexture("resource/Mushiwang/csbimages/sprBet.png")

				self.imgNickname_1:loadTexture("resource/csbimages/GameResult/winNickname.png")
				self.imgResultValue_1:loadTexture(string.format("resource/csbimages/GameResult/winType_%d.png", currencyType))
				self.imgResultBet_1:loadTexture("resource/Mushiwang/csbimages/sprBet.png")
				sys.sound:playEffect("COMMON_WIN")
			else
				--失败
				local eff = CEffectManager:GetSingleton():getEffect("a1sb2")
				local size = self.panelEff:getContentSize()
				eff:setPosition(cc.p(size.width/2, size.height/2))
				self.panelEff:addChild(eff)
				self.imgNickname:loadTexture("resource/csbimages/GameResult/loseNickname.png")
				self.imgResultValue:loadTexture(string.format("resource/csbimages/GameResult/loseType_%d.png", currencyType))
				self.imgResultBet:loadTexture("resource/Mushiwang/csbimages/sprBet2.png")
				self.imgNickname_1:loadTexture("resource/csbimages/GameResult/loseNickname.png")
				self.imgResultValue_1:loadTexture(string.format("resource/csbimages/GameResult/loseType_%d.png", currencyType))
				self.imgResultBet_1:loadTexture("resource/Mushiwang/csbimages/sprBet2.png")
				sys.sound:playEffect("COMMON_LOSE")
			end
		end
		if roomStyle == Common_pb.RsGold then
			self.imgResultBet:setVisible(false)
			self.imgResultBet_1:setVisible(false)
			v["NoSeeTxtResultBet"]=true
		end
		if v.memStateInfo.isViewer==false then--旁观者,结算页面不算进去
		    dataItems[#dataItems + 1] = v	
        end	
	end
	--把自己的id放在最前面
	for k,v in ipairs(dataItems) do
		if v.playerId == userid and v.memStateInfo.isViewer==false then
			if k ~= 1 then
				dataItems[1],dataItems[k]=dataItems[k],dataItems[1]
				break
			end
		end
	end
	local dataItems2={}
	local i=1
	local j=1
	for k,v in ipairs (dataItems) do
		if dataItems2[i] == nil then
			dataItems2[i] = {}
		end
		dataItems2[i][j]=v
		j=j+1
		if k % 2==0 then
			i=i+1
			j=1
		end
	end
	local param = 
	{
		data = dataItems2,
		ccsNameOrFunc = "Mushiwang/ResultViewItem2",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.listview:createItems(param)

    -- self:playAction(0.4)
end

--木虱王回放数据
function prototype:showPlayBackDetails(data)
	if not data then
		return
	end

	local userid = Model:get("Account"):getUserId()
	local currencyType = Common_pb.Gold
	local roomStyle = Common_pb.RsCard

	local playerGroup = data.playerGroup

	local rowItems = {}
	--每一列放2个图标
	local dataItems = {}
	for id, v in pairs(playerGroup) do
		if v.playerId == userid then
			 local resultCoin = tonumber(v.bp) or 0
			if resultCoin >= 0 then--胜利
				local eff = CEffectManager:GetSingleton():getEffect("a1sl2")
				local size = self.panelEff:getContentSize()
				eff:setPosition(cc.p(size.width/2, size.height/2))
				self.panelEff:addChild(eff)
				self.imgNickname:loadTexture("resource/csbimages/GameResult/winNickname.png")
				self.imgResultValue:loadTexture(string.format("resource/csbimages/GameResult/winType_%d.png", currencyType))
				self.imgResultBet:loadTexture("resource/Mushiwang/csbimages/sprBet.png")

				self.imgNickname_1:loadTexture("resource/csbimages/GameResult/winNickname.png")
				self.imgResultValue_1:loadTexture(string.format("resource/csbimages/GameResult/winType_%d.png", currencyType))
				self.imgResultBet_1:loadTexture("resource/Mushiwang/csbimages/sprBet.png")
				-- sys.sound:playEffect("COMMON_WIN")
			else
				--失败
				local eff = CEffectManager:GetSingleton():getEffect("a1sb2")
				local size = self.panelEff:getContentSize()
				eff:setPosition(cc.p(size.width/2, size.height/2))
				self.panelEff:addChild(eff)
				self.imgNickname:loadTexture("resource/csbimages/GameResult/loseNickname.png")
				self.imgResultValue:loadTexture(string.format("resource/csbimages/GameResult/loseType_%d.png", currencyType))
				self.imgResultBet:loadTexture("resource/Mushiwang/csbimages/sprBet2.png")
				self.imgNickname_1:loadTexture("resource/csbimages/GameResult/loseNickname.png")
				self.imgResultValue_1:loadTexture(string.format("resource/csbimages/GameResult/loseType_%d.png", currencyType))
				self.imgResultBet_1:loadTexture("resource/Mushiwang/csbimages/sprBet2.png")
				-- sys.sound:playEffect("COMMON_LOSE")
			end
		end

		table.insert(rowItems, v)
		if #rowItems == 2 then
			rowItems.isPlayBack = true
			dataItems[#dataItems + 1] = rowItems
			rowItems = {}
		end
	end

	if #rowItems > 0 then
		rowItems.isPlayBack = true
		dataItems[#dataItems + 1] = rowItems
	end
	
	local param = 
	{
		data = dataItems,
		ccsNameOrFunc = "Mushiwang/ResultViewItem2",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.listview:createItems(param)
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

