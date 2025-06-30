module (..., package.seeall)

prototype = Controller.prototype:subclass()

-- function prototype:dispose()
    
-- end

function prototype:enter()

end

--复制房间号码
-- function prototype:onBtnCoppIdTouch(sender, eventType)
-- 	if eventType == ccui.TouchEventType.ended then
-- 		self:fireUIEvent("Game.CopyRoomId")
-- 	end
-- end

function prototype:setReturnHallVisible(visible)
	self.btnReturnHall:setVisible(visible)
end

--返回大厅
function prototype:onBtnExitTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.ReturnHall")
	end
end

--邀请好友
function prototype:onBtnInviteTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.InviteFriend")
	end
end


