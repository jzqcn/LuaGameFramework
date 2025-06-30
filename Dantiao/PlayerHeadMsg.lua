module (..., package.seeall)

prototype = Controller.prototype:subclass()

local NUMBER_MOVE_OFF = 60

function prototype:enter()
	self.imgSign:ignoreContentAdaptWithSize(true)
end

function prototype:setPlayerInfo(info)
	if not info then
		self.txtID:setVisible(false)
		self.txtCoin:setVisible(false)
		self.imgIcon:loadTexture("resource/Dantiao/csbimages/none.png")
		return
	end

	self.txtID:setString("ID:" .. info.playerId)
	self.txtCoin:setString(Assist.NumberFormat:amount2Hundred(info.coin))
	self.txtID:setVisible(true)
	self.txtCoin:setVisible(true)

	--设置头像
	-- sdk.account:getHeadImage(info.playerId, info.playerName, self.imgIcon, info.headimage)
	if self:existEvent('LOAD_HEAD_IMG') then
		self:cancelEvent('LOAD_HEAD_IMG')
	end
	sdk.account:loadHeadImage(info.playerId, info.playerName, info.headimage, 
		self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.imgIcon)
end

function prototype:onLoadHeadImage(filename)
	self.imgIcon:loadTexture(filename)
end

function prototype:doPlayerBet(info, betValue, isUser)
	-- if not isUser then
		info.coin = info.coin - betValue
		if info.coin < 0 then
			info.coin = 0
		end
	-- end
	self.txtCoin:setString(Assist.NumberFormat:amount2Hundred(info.coin))
end

--结算
function prototype:doSettlement(info, currentSidesDesc)
	self.txtCoin:setString(Assist.NumberFormat:amount2Hundred(info.coin))

	if info.winCoin > 0 then
		local size = self.rootNode:getContentSize()

		local skeletonNode = self.rootNode:getChildByTag(100)
		if skeletonNode == nil then
			skeletonNode = sp.SkeletonAnimation:create("resource/Dantiao/csbimages/anim/Txguangquan/Txguangquan.json", "resource/Dantiao/csbimages/anim/Txguangquan/Txguangquan.atlas")
			skeletonNode:setPosition(cc.p(size.width/2, size.height/2))
			self.rootNode:addChild(skeletonNode, 1, 100)
		else
			skeletonNode:setVisible(true)
		end

		skeletonNode:setAnimation(0, "animation", false)

		local eff = cc.ParticleSystemQuad:create("resource/Dantiao/csbimages/Particle/guang/guang.plist")
		eff:setPosition(cc.p(size.width/2, size.height/2))
		self.rootNode:addChild(eff, 2, 101)

		--动作播放完成监听
		skeletonNode:registerSpineEventHandler(function (event)
		  -- print(string.format("[spine] %d complete: %d", event.trackIndex, event.loopCount))
		  	skeletonNode:setVisible(false)
		  	--删除开始效果粒子
			eff:removeFromParent()

		end, sp.EventType.ANIMATION_COMPLETE)
		
		-- local size = self.rootNode:getContentSize()
		-- local eff = CEffectManager:GetSingleton():getEffect("a1longtx")
		-- eff:setPosition(cc.p(size.width/2, size.height/2))
		-- self.rootNode:addChild(eff)
	end
end

--神算子图标或富豪排行图标
function prototype:setPlayerType(isDiviner, ranking)
	if isDiviner then
		self.imgSign:loadTexture("resource/Dantiao/csbimages/HeadFrame/diviner.png")
	else
		ranking = ranking or 1		
		self.imgSign:loadTexture(string.format("resource/Dantiao/csbimages/HeadFrame/rich_No_%d.png", ranking))
	end
end

function prototype:getHeadPos()
	local x1, y1 = self.rootNode:getPosition()
	local x2, y2 = self.imgFrame:getPosition()
	return cc.p(x1+x2, y1+y2)	
end
