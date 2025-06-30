module (..., package.seeall)

local SCENE_TYPE = Enum
{
	"ROOM_SCORE",	--房卡计分
	"ROOM_GOLD",	--房卡金币
	"GOLD",			--金币
}

SCENE_TYPE_ENABLED = {true, true, true,}

prototype = Dialog.prototype:subclass()

function prototype:enter()
	-- util.timer:after(200, self:createEvent("checkNextStage"))
	util.timer:after(300, self:createEvent("checkClipboardString"))
	if util:getPlatform() ~= "win32" then
		if Model:get("Account"):getIsShowBindAccount() then
			util.timer:after(500, self:createEvent("showAccountRegisterView"))
		end

		if Model:get("Account"):getIsShowBindDialog() and Model:get("Account"):isEnabledPromotion() then	
			util.timer:after(400, self:createEvent("showActivityBindView"))				
		end		
	end

	local index = tonumber(db.var:getUsrVar("SCENE_SHOW_TYPE_INDEX")) or SCENE_TYPE.GOLD
	if index<SCENE_TYPE.ROOM_SCORE or index>SCENE_TYPE.GOLD or SCENE_TYPE_ENABLED[index]==false then
		for i, v in ipairs(SCENE_TYPE_ENABLED) do
			if v then
				index = i
				break
			end
		end
	end

	local enabledNum = 0
	for i = 1, #SCENE_TYPE_ENABLED do
		if index == i then
			self["nodeScene_" .. i]:setVisible(true)
		else
			self["nodeScene_" .. i]:setVisible(false)
		end

		if SCENE_TYPE_ENABLED[i] then
			enabledNum = enabledNum + 1
		end
	end

	--[[if index == SCENE_TYPE.GOLD then
		self.nodeRole:setVisible(false)
	else
		self.nodeRole:setVisible(true)
	end
]]
	self.showSceneIndex = index
	self.btnSwitchScene:loadTexture(string.format("resource/csbimages/Hall/roomStyle_%d.png", index))

	if enabledNum <= 1 then
		self.btnSwitchScene:setVisible(false)
	end

	--更改背景图片
	-- ui.mgr:setSceneImageBg(self.imgBg)
	util.timer:after(200, self:createEvent("playAction"))
	
end

function prototype:getNextSceneIndex(selIndex)
	local nextIndex = selIndex + 1
	while true do
		if nextIndex > #SCENE_TYPE_ENABLED then
			nextIndex = 1
		end

		if SCENE_TYPE_ENABLED[nextIndex] then
			break
		end

		nextIndex = nextIndex + 1
	end

	return nextIndex
end

--切换场景：金币、房卡金币、房卡计分
function prototype:onBtnSwitchSceneTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local nextIndex = self:getNextSceneIndex(self.showSceneIndex)
		if nextIndex ~= self.showSceneIndex then
			self["nodeScene_" .. self.showSceneIndex]:hide()
			self["nodeScene_" .. nextIndex]:show()

			--[[f nextIndex == SCENE_TYPE.GOLD then
				self.nodeRole:setVisible(false)
			else
				self.nodeRole:setVisible(true)
			end]]

			self.showSceneIndex = nextIndex

			db.var:setUsrVar("SCENE_SHOW_TYPE_INDEX", nextIndex)

			self.btnSwitchScene:loadTexture(string.format("resource/csbimages/Hall/roomStyle_%d.png", nextIndex))

			self.btnSwitchScene:setEnabled(false)
			self.btnSwitchScene:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
				self.btnSwitchScene:setEnabled(true)
			end)))
		end
	end
end

--检查粘贴板上是否有数据（微信分享文字，复制后直接进入房间）
function prototype:checkClipboardString()
	util:checkClipboardString()
end

function prototype:showActivityBindView()
	ui.mgr:open("Promotion/ActivityBindView")
	Model:get("Account"):setIsShowBindDialog(false)
end

--账号绑定
function prototype:showAccountRegisterView()
	ui.mgr:open("Hall/RegisterAccount")
	Model:get("Account"):setIsShowBindAccount(false)
end

function prototype:sceneChangeBg(index)
	self.imgBg:loadTexture(string.format("resource/csbimages/Hall/Bg/bg_%d.png", index))
end

function prototype:onEnterBackground()
	-- self.nodeComponent:onEnterBackground()
	
	self:removeParticle()
end

function prototype:onEnterForeground()
	-- self.nodeComponent:onEnterForeground()

	util.timer:after(200, self:createEvent("playAction"))
end

function prototype:playAction()
	-- self:playActionTime(0, true)
	local visibleFun1=function()
		self.imgSwitchArrow1:setVisible(true)
		self.imgSwitchArrow2:setVisible(false)
	end
	local visibleFun2=function()
		self.imgSwitchArrow1:setVisible(false)
		self.imgSwitchArrow2:setVisible(true)
	end
	self.imgSwitchSceneBg:runAction(cc.RepeatForever:create(
		cc.Sequence:create(
			cc.CallFunc:create(visibleFun1),
			cc.DelayTime:create(1),
			cc.CallFunc:create(visibleFun2),
			cc.DelayTime:create(1)
		)))
	self:loadParticle()

	Model:get("Announce"):playChargeMsgView()
end

--粒子特效
function prototype:loadParticle()
	local particle = cc.ParticleSystemQuad:create("resource/particle/star.plist")
	-- local particle = CEffectManager:GetSingleton():getEffect("x_1",true)
    self.imgBg:addChild(particle, 0, 1000)
    local size = self.imgBg:getContentSize()
    particle:setPosition(size.width/2, size.height/2-100)
end

--移除特效
function prototype:removeParticle()
	local particle = self.imgBg:getChildByTag(1000)
	if particle then
		particle:removeFromParent(true)
	end
end