module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local SHOW_TYPE = Enum
{
	"MAIL",
	"VIP_RECHARGE"
}

function prototype:enter()
	self:showTabType(SHOW_TYPE.VIP_RECHARGE)

	-- ui.mgr:setSceneImageBg(self.imgBg, true)

	--[[local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)]]
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))

	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.rootNode, actionOver)
	sys.sound:playEffectByFile("resource/audio/Hall/kefu_enter.mp3")
end

function prototype:showTabType(_type)
	if self.showType == _type then
		return
	end

	if _type == SHOW_TYPE.MAIL then
		self.nodeCustomer:setVisible(true)
		self.nodeVip:setVisible(false)
		self.imgMailSel:setVisible(true)
		self.imgVipSel:setVisible(false)
	elseif _type == SHOW_TYPE.VIP_RECHARGE then
		self.nodeCustomer:setVisible(false)
		self.nodeVip:setVisible(true)
		self.imgMailSel:setVisible(false)
		self.imgVipSel:setVisible(true)
	end

	self.showType = _type
end

function prototype:onBtnMailClick()
	self:showTabType(SHOW_TYPE.MAIL)
end

function prototype:onBtnVipRechargeClick()
	self:showTabType(SHOW_TYPE.VIP_RECHARGE)
end

function prototype:onBtnCloseClick()
	self:close()
end

