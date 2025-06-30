local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

function prototype:enter()
	-- ui.aniMgr:load("Effect/Star/Star01", self.rootNode)
	Model:load({"Games/PaodekuaiGoldConfig", "Games/Paodekuai"})

	self.gameName = "Paodekuai"
	
	self:bindModelEvent("Games/PaodekuaiGoldConfig.EVT.PUSH_LEVEL_CONFIG_DATA", "onPushLevelConfigData")
	-- util.timer:after(300, self:createEvent("playAction"))

	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/GoldItem/paodekuai_ske.dbbin", "paodekuai")
    factory:loadTextureAtlasData("resource/csbimages/Hall/GoldItem/paodekuai_tex.json", "paodekuai")
    local itemAnimation = factory:buildArmatureDisplay("Armature", "paodekuai")
    if itemAnimation then
	    itemAnimation:getAnimation():play("newAnimation", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2 - 15)
	    -- itemAnimation:setScale(0.5)
	    -- itemAnimation:setTag(100)
	    self.panelBg:addChild(itemAnimation)

	    self.itemAnimation = itemAnimation
	end

	local skeletonNode = sp.SkeletonAnimation:create("resource/csbimages/Hall/SignAnim/Tuij.json", "resource/csbimages/Hall/SignAnim/Tuij.atlas")
	if skeletonNode then
		skeletonNode:setAnimation(0, "animation", true)
		skeletonNode:setTag(101)
		skeletonNode:setPosition(25, size.height-20)
		self.panelBg:addChild(skeletonNode)
	end

    --[[local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()        
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        print("sprite onTouchesBegan..")
        return true
    end

    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
        local posX,posY = target:getPosition()
        local delta = touch:getDelta()
        -- target:setPosition(cc.p(posX + delta.x, posY + delta.y))
        print("sprite onTouchesMoved..")
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        print("sprite onTouchesEnded..")
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    -- listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )

    local eventDispatcher = self.rootNode:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, armatureDisplay)
    --]]

    -- log(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

function prototype:exit()
	--DragonBones骨骼动画资源释放
	local itemAnimation = self.itemAnimation --self.panelBg:getChildByTag(100)
	if itemAnimation then
		itemAnimation:removeFromParent()
		itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("paodekuai")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("paodekuai")
	end
end

function prototype:versionPass()
	Model:get("Games/PaodekuaiGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
end

function prototype:onBtnItemTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self:checkIsPlayingGame() then
			return
		end
		
		if self.itemInfo then
			-- log("game typeId : "..self.itemInfo.typeId)
			if self.itemInfo.isOpen == true then
				self:versionPass()
			else
				local data = {
					content = "暂未开放，敬请期待！"
				}
				ui.mgr:open("Dialog/ConfirmView", data)
			end
		else
			assert(false)
		end
	end
end


