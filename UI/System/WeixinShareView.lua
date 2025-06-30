module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter(data)
	self.shareData = data

	self.touchEnable = false
	local size = self.imgBg:getContentSize()
	local x, y = self.imgBg:getPosition()
	self.imgBg:setPosition(x, y - size.height)
	self.imgBg:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, size.height)), cc.CallFunc:create(function ()
			self.touchEnable = true
		end)))
end

--分享类型（朋友圈：SceneTimeline， 好友：SceneSession）
--好友、群
function prototype:onBtnSessionClick()
	self.shareData.Scene = "SceneSession"

	local str = json.encode(self.shareData)
	util:fireCoreEvent(REFLECT_EVENT_WEIXIN_SHARE, 0, 0, str)

	-- Model:get("Account"):setShareScene(self.shareData.Scene, self.shareData.IsAward)
	self:close()
end

--朋友圈
function prototype:onBtnFriendClick()
	self.shareData.Scene = "SceneTimeline"

	local str = json.encode(self.shareData)
	util:fireCoreEvent(REFLECT_EVENT_WEIXIN_SHARE, 0, 0, str)

	-- Model:get("Account"):setShareScene(self.shareData.Scene, self.shareData.IsAward)
	self:close()
end

function prototype:onPanelCloseClick()
	if not self.touchEnable then
		return
	end

	self:close()
end

