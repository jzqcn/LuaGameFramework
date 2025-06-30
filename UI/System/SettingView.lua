module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local SettingTab = Enum
{
	"PERSONAL_MSG", --个人
	"SETTING_MSG",	--设置
	-- "SCENE_MSG",	--场景
}

local titleRes = 
{
	"resource/csbimages/System/titleMsg.png",
	"resource/csbimages/System/titleSetting.png",
	-- "resource/csbimages/System/titleScene.png",
}

-- function prototype:addBgMask()

-- end

function prototype:hasBgMask()
	return false
end

function prototype:enter(selType)
	-- self:bindUIEvent("Setting.SceneBgChange", "uiEvtSceneChangeBg")

	-- ui.mgr:setSceneImageBg(self.imgBg, true)

	selType = selType or SettingTab.PERSONAL_MSG
	self:selectTab(selType)

	--[[local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)]]
end

function prototype:selectTab(selType)
	if self.selType == selType then
		return
	end

	for i = 1, 2 do
		if i == selType then
			self["btnSel_"..i]:setVisible(false)
			self["imgSel_"..i]:setVisible(true)
			self["nodePart_"..i]:setVisible(true)
		else
			self["btnSel_"..i]:setVisible(true)
			self["imgSel_"..i]:setVisible(false)
			self["nodePart_"..i]:setVisible(false)
		end
	end
	self.imgTitle:loadTexture(titleRes[selType])

	self.selType = selType
end

function prototype:onBtnMsgTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:selectTab(SettingTab.PERSONAL_MSG)
	end
end

function prototype:onBtnSettingTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:selectTab(SettingTab.SETTING_MSG)
	end
end

function prototype:onBtnSceneTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:selectTab(SettingTab.SCENE_MSG)

		self.nodePart_3:setSelectPageIndex()
	end
end

function prototype:uiEvtSceneChangeBg(index)
	self.imgBg:loadTexture(string.format("resource/csbimages/Hall/Bg/vagueBg_%d.png", index))
end

function prototype:onBtnClose()
	if self.selType == SettingTab.PERSONAL_MSG and self.nodePart_1:isExitEditing() then
		return
	end
	self:close()
end