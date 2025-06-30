module (..., package.seeall)

prototype = Controller.prototype:subclass()

local levelTxtImg = {
	[1] = "basicTxt",
	[2] = "middleTxt",
	[3] = "seniorTxt",
	[4] = "superTxt"
}

local levelIconImg = {
	[1] = {"silver_box_1", "silver_box_1", "silver_box_2", "silver_box_3"},
	[2] = {"silver_box_1", "silver_box_1", "silver_box_2", "silver_box_3"},
	[3] = {"gold_box_1", "gold_box_1", "gold_box_2", "gold_box_3"}
}

local showMsg = {
	"您不能加入该等级房间，请前往更高等级房间！"
}

function prototype:enter()
	self.currencyType = -1
	self.levelInfo = nil
	self.gameName = ""

	self.panelBg:addTouchEventListener(bind(self.onBtnLevelTouch, self))
end

function prototype:setItemInfo(type, data, name)
	self.currencyType = type
	self.levelInfo = data
	--self.imgLevelBg:loadTexture(string.format("resource/csbimages/Hall/RoomLevel/level_%d.png", data.roomLevel))
	self.imgrm:loadTexture(string.format("resource/csbimages/Hall/RoomLevel/rm%d.png", data.roomLevel))
	local Chip=data.baseChip/100
	if Chip < 10 then
		self.fontChip:setString(string.format("%.1f",data.baseChip/100))
	else
		self.fontChip:setString(Chip)
	end
	self.txtLimit:setString("入场限制 " .. math.ceil(data.minCoin/100))
	--self.txtPlayerNum:setString(data.onlineNum)
	local onlineNum = tonumber(data.onlineNum)
	if onlineNum < 50 then
		self.imgRoomStatus:loadTexture("resource/csbimages/Hall/room_status_lianghao.png")
	elseif onlineNum > 50 and onlineNum < 100 then
		self.imgRoomStatus:loadTexture("resource/csbimages/Hall/room_status_yongji.png")
	else
		self.imgRoomStatus:loadTexture("resource/csbimages/Hall/room_status_baoman.png")
	end

	if not name or name == "" then
		assert(false)
	end

	self.gameName = name

	local size = self.panelBg:getContentSize()--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	local aniPathDbbin=""
	local aniPathTex=""
	local aniName=""

	aniPathDbbin=string.format("resource/csbimages/Hall/RoomLevel/Level%d_ske.dbbin",self.levelInfo.roomLevel)
	aniPathTex=string.format("resource/csbimages/Hall/RoomLevel/Level%d_tex.json",self.levelInfo.roomLevel)
	aniName=string.format("Level%d",self.levelInfo.roomLevel)

		
	factory:loadDragonBonesData(aniPathDbbin, aniName)
	factory:loadTextureAtlasData(aniPathTex, aniName)
	local itemAnimation = factory:buildArmatureDisplay("armatureName", aniName)
	if itemAnimation then
		itemAnimation:getAnimation():play("newAnimation", 0)--kengdie is 1 not l
		itemAnimation:setPosition(size.width/2, size.height/2+100)
		self.panelBg:addChild(itemAnimation, 1, 100)
		--self.panelBg:setScale(0.8)
		self.itemAnimation = itemAnimation
	end
end

function prototype:exit()
	--DragonBones骨骼动画资源释放
	if  self.itemAnimation then
		self.itemAnimation:removeFromParent()
		self.itemAnimation:dispose()
		local aniName=string.format("Level%d",self.levelInfo.roomLevel)
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

function prototype:onBtnLevelTouch(sender, event)
	if event == ccui.TouchEventType.began then
		-- self.rootNode:runAction(cc.ScaleTo:create(0.2, 1.05))
		-- self.rootNode:setOpacity(220)
		self.rootNode:setColor(cc.c3b(222, 189, 189))
		sys.sound:playEffect("CLICK")

	elseif event == ccui.TouchEventType.moved then
		

	elseif event == ccui.TouchEventType.ended then
		self.rootNode:setColor(cc.c3b(255, 255, 255))
		
		local accountInfo = Model:get("Account"):getUserInfo()
		if self.currencyType == Common_pb.Sliver then
			-- if accountInfo.silver < self.levelInfo.minCoin then
			-- 	local function openShop()
			-- 		ui.mgr:open("Shop/ShopView", 3)
			-- 	end

			-- 	local data = {
			-- 		content = "您的银币不足，无法参与游戏！",
			-- 		okFunc = openShop
			-- 	}
			-- 	ui.mgr:open("Dialog/ConfirmDlg", data)
			-- 	return
				
			-- elseif accountInfo.silver>self.levelInfo.maxCoin and self.levelInfo.maxCoin>0 then

			-- end
		elseif self.currencyType == Common_pb.Gold then
			if accountInfo.gold < self.levelInfo.minCoin then
				local function openShop()
					ui.mgr:open("Shop/ShopView", 1)
				end

				local data = {
					content = "您的金币不足，无法参与游戏！",
					okFunc = openShop
				}
				ui.mgr:open("Dialog/ConfirmDlg", data)

				return
			end
		end

		-- log("click item info :: play id == "..self.levelInfo.playId..", type id == "..self.levelInfo.typeId..", currencyType : "..self.currencyType)
		local modelName = "Games/"..self.gameName
        -- log("request GameName:"..self.gameName)
		Model:get(modelName):requestEnterRoom(self.levelInfo.playId, self.levelInfo.typeId, Common_pb.RsGold)

		-- self.rootNode:setOpacity(255)
		-- self.rootNode:runAction(cc.ScaleTo:create(0.1, 1.0))
	elseif event == ccui.TouchEventType.canceled then
		self.rootNode:setColor(cc.c3b(255, 255, 255))
		-- self.rootNode:setOpacity(255)
		-- self.rootNode:runAction(cc.ScaleTo:create(0.1, 1.0))
	end
end
