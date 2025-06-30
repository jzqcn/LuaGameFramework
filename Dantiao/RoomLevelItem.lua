
module (..., package.seeall)
prototype = Controller.prototype:subclass()
function prototype:enter()
	-- self.panelBg:setColor(cc.c3b(127, 127, 127))
end

function prototype:initData(PlayId)
	self.playId=PlayId
	local size = self.panelBg:getContentSize()--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	local aniPathDbbin=""
	local aniPathTex=""
	local aniName=""
	if self.playId == 114001 then
		aniPathDbbin="resource/Dantiao/csbimages/GoldItem/szdantiaotwo_ske.dbbin"
		aniPathTex="resource/Dantiao/csbimages/GoldItem/szdantiaotwo_tex.json"
		aniName="szdantiaotwo"
	else
		aniPathDbbin="resource/Dantiao/csbimages/GoldItem/szdantiaofive_ske.dbbin"
		aniPathTex="resource/Dantiao/csbimages/GoldItem/szdantiaofive_tex.json"
		aniName="szdantiaofive"
	end
	factory:loadDragonBonesData(aniPathDbbin, aniName)
	factory:loadTextureAtlasData(aniPathTex, aniName)
	local itemAnimation = factory:buildArmatureDisplay("armatureName", aniName)
	if itemAnimation then
		itemAnimation:getAnimation():play("animation", 0)
		itemAnimation:setPosition(size.width/2, size.height/2)
		self.panelBg:addChild(itemAnimation, 1, 100)
		self.itemAnimation = itemAnimation
	end

	--[[上庄标记
	factory:loadDragonBonesData("resource/csbimages/Hall/SignAnim/shangZhuang_ske.dbbin", "shangzhuang1")
    factory:loadTextureAtlasData("resource/csbimages/Hall/SignAnim/shangZhuang_tex.json", "shangzhuang1")
    local signAnimation = factory:buildArmatureDisplay("armatureName", "shangzhuang1")
    if signAnimation then
	    signAnimation:getAnimation():play("animation", 0)
		if self.playId == 114001 then
			signAnimation:setPosition(-40, size.height+100)
		else
			signAnimation:setPosition(-67, size.height+100)
		end
	    self.panelBg:addChild(signAnimation, 1, 101)

	    self.signAnimation = signAnimation
	end
	]]
end

function prototype:exit()
	--DragonBones骨骼动画资源释放
	if  self.itemAnimation then
		self.itemAnimation:removeFromParent()
		self.itemAnimation:dispose()
		local aniName=""
		if self.playId == 114001 then
			aniName="szdantiaotwo"
		else
			aniName="szdantiaofive"
		end
		dragonBones.CCFactory:getFactory():removeDragonBonesData(aniName)
		dragonBones.CCFactory:getFactory():removeTextureAtlasData(aniName)
	end
	--[[if self.signAnimation then
		self.signAnimation:removeFromParent()
		self.signAnimation:dispose()
		dragonBones.CCFactory:getFactory():removeDragonBonesData("shangzhuang1")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("shangzhuang1")
	end
	]]
end

function prototype:onBtnItemClick(sender, eventType)
	if self.playId == 114001 then
		Model:get("Games/Dantiao"):requestEnterRoom(114001, 114)
	else
		Model:get("Games/Dantiao"):requestEnterRoom(114002, 114)
	end
end

