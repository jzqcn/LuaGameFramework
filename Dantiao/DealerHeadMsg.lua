module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()
	self.txtCoin:setString(0)
end

function prototype:doSettlement(winCoin)
    if winCoin==nil then return end
    local strCoin = Assist.NumberFormat:amount2TrillionText(winCoin)
    self.txtCoin:setString(strCoin)
	--[[if winCoin > 0 then
		--赢	
		local strCoin = Assist.NumberFormat:amount2TrillionText(winCoin)
		strCoin = "+"..strCoin
		self:runNumAction(self.fntWin, strCoin, 1.5)

		local size = self.imgFrame:getContentSize()
		-- local eff = CEffectManager:GetSingleton():getEffect("a1longtx")
		-- eff:setPosition(cc.p(size.width/2, size.height/2))
		-- self.imgFrame:addChild(eff)

		local skeletonNode = self.rootNode:getChildByTag(98)
		if skeletonNode == nil then
			skeletonNode = sp.SkeletonAnimation:create("resource/Dantiao/csbimages/anim/Txguangquan/Txguangquan.json", "resource/Dantiao/csbimages/anim/Txguangquan/Txguangquan.atlas")
			skeletonNode:setPosition(cc.p(size.width/2, size.height/2))
			self.imgFrame:addChild(skeletonNode, 1, 98)
		else
			skeletonNode:setVisible(true)
		end

		skeletonNode:setAnimation(0, "animation", false)

		local eff = cc.ParticleSystemQuad:create("resource/Dantiao/csbimages/Particle/guang/guang.plist")
		eff:setPosition(cc.p(size.width/2, size.height/2))
		self.imgFrame:addChild(eff, 2, 99)

		--动作播放完成监听
		skeletonNode:registerSpineEventHandler(function (event)
		  -- print(string.format("[spine] %d complete: %d", event.trackIndex, event.loopCount))
		  	skeletonNode:setVisible(false)
		  	--删除开始效果粒子
			eff:removeFromParent()

		end, sp.EventType.ANIMATION_COMPLETE)

		
	elseif winCoin == 0 then
		--开和的时候，输赢为0也显示动画
		-- if currentSidesDesc == Dantiao_pb.HE then
			local strCoin = Assist.NumberFormat:amount2TrillionText(winCoin)
			strCoin = "+"..strCoin
			self:runNumAction(self.fntWin, strCoin, 1.5)
		-- end
	else
		--输
		local strCoin = Assist.NumberFormat:amount2TrillionText(winCoin)
		self:runNumAction(self.fntLose, strCoin, 1.5)
	end]]
end

function prototype:runNumAction(fntNode, str, delayTime)
	--[[delayTime = delayTime or 1.0
	fntNode:setOpacity(255)
	fntNode:setString(str)
	fntNode:setVisible(true)
	fntNode:runAction(cc.Sequence:create(
		cc.MoveBy:create(0.5, cc.p(0, 50)), 
		cc.DelayTime:create(delayTime),
		cc.FadeOut:create(0.5), 
		cc.CallFunc:create(function()
			fntNode:setVisible(false)
			local x, y = fntNode:getPosition()
            fntNode:setPosition(cc.p(x, y - 50))
            self.txtCoin:setString(str)
		end)))]]
end