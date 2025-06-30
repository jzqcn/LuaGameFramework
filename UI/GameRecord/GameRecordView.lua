module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter(data)
	--Model消息事件
	self:bindModelEvent("PlayBack.EVT.PUSH_PLAYBACK_LIST_DATA", "onPushListData")

	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.rootNode, actionOver)

	self:onPushListData(data)
	sys.sound:playEffectByFile("resource/audio/Hall/paihangbang_enter.mp3")
end

function prototype:onPushListData(data)
	if not data then
		return
	end

	local param = 
	{
		data = data,
		ccsNameOrFunc = "GameRecord/GameRecordViewItem",
		dataCheckFunc = function (info, elem) return info == elem end,
		autoContentSize = true,
	}
    self.listview:createItems(param)

end
function prototype:onBtnRecordClick()

end

function prototype:onBtnCloseClick()
	self:close()
end


