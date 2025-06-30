module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.slidMusic:setPercent(sys.sound:getMusicVolume()*100)
	self.slidEffect:setPercent(sys.sound:getEffectVolume()*100)

	if StageMgr:isStage("Game") or (StageMgr:isStage("Hall") and StageMgr:getStage():isPlayingGame()) then
		self.btnLogout:setVisible(false)
	end
end

function prototype:onBtnAbountUsClick()

end

function prototype:onBtnHelpClick()
	ui.mgr:open("GameHelp/GameHelpView")
end

--切换账号(断开连接，回到登录界面)
function prototype:onBtnLogoutTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if not StageMgr:isStage("Game") then
			net.mgr:disconnect()			
			StageMgr:chgStage("Login", false)
		end
	end
end

function prototype:onEventSliderMusic(sender, eventType)
	if eventType ~= cc.SliderEventType.ON_PERCENTAGE_CHANGED then
		return
	end
	self:setMusicVolume(self.slidMusic:getPercent())
end

function prototype:onEventSliderEffect(sender, eventType)
	if eventType ~= cc.SliderEventType.ON_PERCENTAGE_CHANGED then
		return
	end
	self:setEffectVolume(self.slidEffect:getPercent())
end

function prototype:setMusicVolume(value)
	sys.sound:setMusicVolume(value/100)
	if value > 0 then
		if not sys.sound:isMusicEnable() then
			sys.sound:setEnableMusic(true)
		end
	else
		if sys.sound:isMusicEnable() then
			sys.sound:setEnableMusic(false)
		end
	end
end

function prototype:setEffectVolume(value)
	sys.sound:setEffectVolume(value/100)
	if value > 0 then
		if not sys.sound:isEffectEnable() then
			sys.sound:setEnableEffect(true)
		end
	else
		if sys.sound:isEffectEnable() then
			sys.sound:setEnableEffect(false)
		end
	end
end
