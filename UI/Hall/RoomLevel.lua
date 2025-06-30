local Define = require "UI.Mgr.Define"

module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:getReOpenType()
	return Define.RE_OPEN_TYPE.ONLY
end

--金币场不同等级房间：初级、中级、高级、至尊场等。。。
function prototype:enter(data)
	-- self:bindUIEvent("Hall.SwitchRoomLevelTab", "uiEvtSwitchRoomTabItem")

	-- ui.mgr:setSceneImageBg(self.imgBg, true)

	self.configData = data[1]
	self.gameName = data[2]
	self.currencyType = data[3]

	self:initPlayTypeTab()

	-- cc.UserDefault:getInstance():setStringForKey("string", "value1")
	-- cc.UserDefault:getInstance():getStringForKey("string")

	local itemName = self.gameName
	local typeId = self.configData[1].typeId
	local configData = Model:get("Hall"):getGoldItem(typeId)
	if configData then
		itemName = configData.itemName
	end
	self.imgGameName:loadTexture(string.format("resource/csbimages/Hall/RoomLevel/name_%s.png", string.lower(itemName)))
	sys.sound:playEffectByFile("resource/audio/Hall/qi_kai_de_sheng.mp3")
end

function prototype:initPlayTypeTab()
	self:setSelectPlayType()
end

function prototype:setSelectPlayType(playTypeId)
	local typeData = self.configData	--self.configData[playTypeId]
	if typeData then
		for i = 1, 4 do
			self["nodeLevel_"..i]:setVisible(false)
		end

		table.sort(typeData,  function (a, b)
 	        return a.roomLevel < b.roomLevel
 	    end)

		for i, levelInfo in ipairs(typeData) do
			--房间等级分类
			self["nodeLevel_"..i]:setVisible(true)
			self["nodeLevel_"..i]:setItemInfo(self.currencyType, levelInfo, self.gameName)
		end
	else
		assert(false)
	end
end

--切换玩法类型
-- function prototype:uiEvtSwitchRoomTabItem(playTypeId)
-- 	if self.playTypeId == playTypeId then
-- 		return
-- 	end

-- 	self:setSelectPlayType(playTypeId)
-- end

function prototype:onBtnCloseClick(sender, eventType)
	self:close()
end