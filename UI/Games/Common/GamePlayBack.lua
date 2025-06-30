module(..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.btnPlay:setVisible(false)
	self.btnPause:setVisible(true)
	self.btnNextStep:setVisible(false)
	self.btnPreStep:setVisible(false)
end

--上一步
-- function prototype:onBtnPreStepTouch(sender, eventType)
-- 	if eventType == ccui.TouchEventType.ended then
-- 		self:fireUIEvent("Game.PlayBackPreStep")
-- 	end
-- end

-- --下一步
-- function prototype:onBtnNextStepTouch(sender, eventType)
-- 	if eventType == ccui.TouchEventType.ended then
-- 		self:fireUIEvent("Game.PlayBackNextStep")
-- 	end
-- end

--播放
function prototype:onBtnPlayTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.PlayBackPlay")
		self.btnPlay:setVisible(false)
		self.btnPause:setVisible(true)
	end
end

--暂停
function prototype:onBtnPauseTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.PlayBackPause")
		self.btnPlay:setVisible(true)
		self.btnPause:setVisible(false)
	end
end

