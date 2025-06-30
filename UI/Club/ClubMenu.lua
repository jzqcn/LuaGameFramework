module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.pos = cc.p(self.imgMem:getPosition())
end

function prototype:setIsOwner(isOwner)
	isOwner = isOwner or false
	self.imgServiceCharge:setVisible(isOwner)
	self.imgDissolve:setVisible(isOwner)
	self.imgExit:setVisible(not isOwner)

	local size = self.imgPop:getContentSize()
	-- local x, y = self.imgInviteFriend:getPosition()
	
	if not isOwner then
		local widgets = {self.imgMem, self.imgInviteFriend, self.imgExit}
		self.imgPop:setContentSize(cc.size(size.width, 240))
		for i = 1, #widgets do
			widgets[i]:setPosition(self.pos.x, self.pos.y - 78 * i)
		end
	else
		local widgets = {self.imgMem, self.imgInviteFriend, self.imgServiceCharge, self.imgExit}
		self.imgPop:setContentSize(cc.size(size.width, 320))
		for i = 1, #widgets do
			widgets[i]:setPosition(self.pos.x, self.pos.y - 78 * (i-1))
		end
	end
end

--成员数据
function prototype:onBtnMemberClick()
	self:fireUIEvent("Club.ClubMembers")
	self.rootNode:setVisible(false)
end

--邀请好友
function prototype:onBtnInviteFriendClick()
	self:fireUIEvent("Club.InviteFriend")
	self.rootNode:setVisible(false)
end

--服务费调整
function prototype:onBtnServiceChargeClick()
	self:fireUIEvent("Club.ServiceCharge")
	self.rootNode:setVisible(false)
end

--解散（俱乐部主）
function prototype:onBtnDissolveClick()
	self:fireUIEvent("Club.DissolveClub")
	self.rootNode:setVisible(false)
end

--退出
function prototype:onBtnExitClick()
	self:fireUIEvent("Club.ExitClub")
	self.rootNode:setVisible(false)
end

function prototype:onPanelCanelClick()
	self.rootNode:setVisible(false)
end