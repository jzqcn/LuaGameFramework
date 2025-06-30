local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

function prototype:enter()
	Model:load({"Games/NiuniuGoldConfig", "Games/Niuniu"})

	self.gameName = "Niuniu"

	self:bindModelEvent("Games/NiuniuGoldConfig.EVT.PUSH_LEVEL_CONFIG_DATA", "onPushLevelConfigData")

	-- util.timer:after(300, self:createEvent("playAction"))
	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/GoldItem/niuniu_ske.dbbin", "niuniu")
    factory:loadTextureAtlasData("resource/csbimages/Hall/GoldItem/niuniu_tex.json", "niuniu")
    local itemAnimation = factory:buildArmatureDisplay("armatureName", "niuniu")
    if itemAnimation then
	    itemAnimation:getAnimation():play("Animation1", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2)
	    -- itemAnimation:setScale(0.5)
	    -- itemAnimation:setTag(100)
	    self.panelBg:addChild(itemAnimation)

	    self.itemAnimation = itemAnimation
	end

	local skeletonNode = sp.SkeletonAnimation:create("resource/csbimages/Hall/SignAnim/rem.json", "resource/csbimages/Hall/SignAnim/rem.atlas")
	if skeletonNode then
		skeletonNode:setAnimation(0, "animation", true)
		skeletonNode:setTag(101)
		skeletonNode:setPosition(25, size.height-20)
		self.panelBg:addChild(skeletonNode)
	end
end

function prototype:exit()
	--DragonBones骨骼动画资源释放
	-- local armatureDisplay = self.panelBg:getChildByTag(100)
	if self.itemAnimation then
		self.itemAnimation:removeFromParent()
		self.itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("niuniu")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("niuniu")
	end	
end

function prototype:playAction()
	self:playActionTime(0, true)
end

function prototype:versionPass()
	Model:get("Games/NiuniuGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
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
				-- self:checkVersion()
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


--[[function prototype:onCheckVersion(name, data)
	local resVer = db.var:getSysVar("GV_NIUNIU_VER")
	resVer = resVer and tonumber(resVer) or 0
	log(data)
	if data == nil then		
		if resVer > 0 then
			Model:get("Games/NiuniuGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
		else
			local data = {
				content = "获取游戏包版本失败，请稍后重试",
			}
			ui.mgr:open("Dialog/DialogView", data)
		end
	else
		local verinfo = json.decode(data)
		if resVer >= verinfo.version then
			Model:get("Games/NiuniuGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
		else
			local dir = db.var:getDocDir('zip_tmp')
			verinfo.filepath = dir .. '/' .. verinfo.flag ..".zip"

			verinfo.onError = function(errorCode)
				if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
			       	local err = "资源版本文件内容错误，是否重试？"
					-- local retry = bind(self.start, self)
					-- self.mgr:promptExit(err, retry)
					log(err)
			    elseif errorCode == cc.ASSETSMANAGER_NETWORK then
			        log4patch:warn("network error")
			        local tip = "亲，网络不给力哦\n请检查一下网络吧"
			        log(tip)
			        -- self.mgr:promptExit(tip, bind(self.start, self))
			    end
			end

			verinfo.onProgress = function(percent)
				log("niuniu download package percent :: "..percent)
			end

			verinfo.onSuccess = function()
				if not self:checkFile(verinfo.filepath, verinfo.md5) then
					util:deleteFile(verinfo.filepath)

					local tip = "下载更新包失败，是否重试？"
					log(tip)
					-- patch.mgr:promptExit(tip, function() self:downloadByInfo(verinfo) end)
					return
				else
					local unzipPath = db.var:getDocDir('unzip_tmp')
					util:clearFolder(unzipPath)

					local ret = util:unzip(self.versionInfo.filepath, unzipPath)
					if ret ~= 0 then
						local tip = "文件解压失败，是否重试？"
						log(tip)
						return
					end

					local tmpFileDir = db.var:getDocDir('unzip_tmp')
					local patchFileDir = db.var:getSysVar(GV_PATCHPATH)
					local ret = util:renameFolder(tmpFileDir, patchFileDir)

					local zipFileDir = db.var:getDocDir('zip_tmp')
					util:clearFolder(zipFileDir)
					util:clearFolder(tmpFileDir)

					if not ret then
						db.var:setSysVar("GV_NIUNIU_VER", 0)
						-- util:clearFolder(patchFileDir)
					
						local tip = "更新文件失败，是否重新下载？"
						log(tip)
					end

					db.var:setSysVar("GV_NIUNIU_VER", verinfo.version)

					Model:get("Games/NiuniuGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
				end
			end

			patch.mgr:gameDownloadStart(verinfo)
		end

		self.versionInfo = verinfo
	end
end--]]

