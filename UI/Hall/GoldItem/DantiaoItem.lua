local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

function prototype:enter()
	Model:load({"Games/DantiaoGoldConfig", "Games/Dantiao"})

	self.gameName = "Dantiao"

	self:bindModelEvent("Games/DantiaoGoldConfig.EVT.PUSH_LEVEL_CONFIG_DATA", "onPushLevelConfigData")

	-- util.timer:after(300, self:createEvent("playAction"))
	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/GoldItem/dantiao_ske.dbbin", "dantiao")
    factory:loadTextureAtlasData("resource/csbimages/Hall/GoldItem/dantiao_tex.json", "dantiao")
    local itemAnimation = factory:buildArmatureDisplay("Armature", "dantiao")
    if itemAnimation then
	    itemAnimation:getAnimation():play("animation", 0)
	    itemAnimation:setPosition(size.width/2, size.height/2)
	    self.panelBg:addChild(itemAnimation, 1, 100)

	    self.itemAnimation = itemAnimation
	end

	--明牌标记
	factory:loadDragonBonesData("resource/csbimages/Hall/SignAnim/mingpai_ske.dbbin", "mingpai")
    factory:loadTextureAtlasData("resource/csbimages/Hall/SignAnim/mingpai_tex.json", "mingpai")
    local signAnimation = factory:buildArmatureDisplay("armatureName", "mingpai")
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
	if self.itemAnimation then
		self.itemAnimation:removeFromParent()
		self.itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("dantiao")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("dantiao")
	end

	if self.signAnimation then
		self.signAnimation:removeFromParent()
		self.signAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("mingpai")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("mingpai")
	end
end

function prototype:versionPass()
	Model:get("Games/DantiaoGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
end

function prototype:onBtnItemTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
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

--龙虎斗没有房间等级，直接进入
function prototype:onPushLevelConfigData(goldData)
	if not goldData or #goldData == 0 then
		log4ui:warn("[DantiaoItem::onPushLevelConfigData] get level data failed !")
		return
	end

	local levelInfo = goldData[1]
	-- log(levelInfo)

	local modelName = "Games/"..self.gameName
	--Model:get(modelName):requestEnterRoom(levelInfo.playId, levelInfo.typeId)
	Model:get(modelName):requestEnterRoom(113001, 113)
end
