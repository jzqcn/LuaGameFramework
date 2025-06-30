local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

function prototype:enter()
	Model:load({"Games/DantiaoGoldConfig", "Games/Dantiao"})

	self.gameName = "Dantiao"

	--self:bindModelEvent("Games/DantiaoGoldConfig.EVT.PUSH_LEVEL_CONFIG_DATA", "onPushLevelConfigData")

	-- util.timer:after(300, self:createEvent("playAction"))
	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/GoldItem/dantiaoSz_ske.dbbin", "dantiaoSz")
    factory:loadTextureAtlasData("resource/csbimages/Hall/GoldItem/dantiaoSz_tex.json", "dantiaoSz")
    local itemAnimation = factory:buildArmatureDisplay("Armature", "dantiaoSz")
    if itemAnimation then
	    itemAnimation:getAnimation():play("animation", 0)
	    itemAnimation:setPosition(size.width/2, size.height/2)
	    self.panelBg:addChild(itemAnimation, 1, 100)

	    self.itemAnimation = itemAnimation
	end

	--上庄标记
	factory:loadDragonBonesData("resource/csbimages/Hall/SignAnim/shangZhuang_ske.dbbin", "shangzhuang")
    factory:loadTextureAtlasData("resource/csbimages/Hall/SignAnim/shangZhuang_tex.json", "shangzhuang")
    local signAnimation = factory:buildArmatureDisplay("armatureName", "shangzhuang")
    if signAnimation then
	    signAnimation:getAnimation():play("animation", 0)

	    signAnimation:setPosition(15, size.height-30)
	    self.panelBg:addChild(signAnimation, 1, 101)

	    self.signAnimation = signAnimation
	end
	-- self.panelBg:setColor(cc.c3b(127, 127, 127))
end

function prototype:exit()
	super.exit(self)
	
	--DragonBones骨骼动画资源释放
	local armatureDisplay = self.panelBg:getChildByTag(100)
	if self.itemAnimation then
		self.itemAnimation:removeFromParent()
		self.itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("dantiaoSz")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("dantiaoSz")
	end

		 armatureDisplay = self.panelBg:getChildByTag(101)
	if self.signAnimation then
		self.signAnimation:removeFromParent()
		self.signAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("shangzhuang")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("shangzhuang")
	end
end

function prototype:onBtnItemTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self:checkIsPlayingGame() then
			return
		end

		if self.itemInfo then
			-- log("game typeId : "..self.itemInfo.typeId)
			if self.itemInfo.isOpen == true then
				--判断版本号
				self:checkVersion()
				-- self:versionPass()
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

function prototype:versionPass()
	ui.mgr:open("Dantiao/RoomLevel")
end
