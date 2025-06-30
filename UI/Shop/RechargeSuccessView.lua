module (..., package.seeall)

prototype = Dialog.prototype:subclass()

--充值成功奖励
function prototype:hasBgMask()
	return false
end

--获得奖励界面
function prototype:enter(data)	
	self.txtNum:setString(data.content)
	self.txtNum:setVisible(false)
	self.imgIcon:setVisible(false)
	self.btnConfirm:setVisible(false)

	if data.coinType == Common_pb.Gold then
		self.imgIcon:loadTexture("resource/csbimages/Common/goldIcon.png")
	elseif  data.coinType == Common_pb.Card then
		self.imgIcon:loadTexture("resource/csbimages/User/cardIcon.png")
	end

	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/animation/awardAnim_ske.dbbin", "awardAnim")
    factory:loadTextureAtlasData("resource/animation/awardAnim_tex.json", "awardAnim")

	local armatureDisplay = factory:buildArmatureDisplay("armatureName", "awardAnim")
	--龙虎事件监听
	-- const char* EventObject::START = "start";
	-- const char* EventObject::LOOP_COMPLETE = "loopComplete";
	-- const char* EventObject::COMPLETE = "complete";
	-- const char* EventObject::FADE_IN = "fadeIn";
	-- const char* EventObject::FADE_IN_COMPLETE = "fadeInComplete";
	-- const char* EventObject::FADE_OUT = "fadeOut";
	-- const char* EventObject::FADE_OUT_COMPLETE = "fadeOutComplete";
	-- const char* EventObject::FRAME_EVENT = "frameEvent";
	-- const char* EventObject::SOUND_EVENT = "soundEvent";		

	-- local function eventCustomListener(event)
 --        self.btnConfirm:setVisible(true)
 --    end

 --    local listener = cc.EventListenerCustom:create("complete", eventCustomListener)
 --    armatureDisplay:getEventDispatcher():setEnabled(true)
	-- armatureDisplay:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

	local size = self.panelBg:getContentSize()
	armatureDisplay:getAnimation():play("Animation1", 1)
	armatureDisplay:setPosition(size.width/2, size.height/2)

	self.panelBg:addChild(armatureDisplay, -1, 100)

	self.showAnimation = armatureDisplay

	util.timer:after(800, self:createEvent("playAction"))
end

function prototype:playAction()
	self.imgIcon:setVisible(true)
	
	local size = self.panelBg:getContentSize()
	self.imgIcon:setScale(1.5)
	self.imgIcon:setPosition(size.width/2, size.height/2)

	local move = cc.Spawn:create(
		cc.MoveBy:create(0.3, cc.p(0, 30)),
		cc.ScaleTo:create(0.3, 1.1)
	)

	self.imgIcon:runAction(cc.Sequence:create(move, cc.CallFunc:create(function() 
		self.txtNum:setVisible(true)
		self.btnConfirm:setVisible(true)
	end)))
end

function prototype:exit()
	local armatureDisplay = self.showAnimation
	if armatureDisplay then
		armatureDisplay:removeFromParent()
		armatureDisplay:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("awardAnim")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("awardAnim")
	end
end


function prototype:onBtnCloseTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:close()
	end
end