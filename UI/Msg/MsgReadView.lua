module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter(data)
	self:bindModelEvent("Announce.EVT.PUSH_REQUEST_ATTACH", "onPushAttachTake")

	-- ui.mgr:setSceneImageBg(self.imgBg, true)

	self.data =data
	self.txtTitle:setString(data.title)

	-- local tb = {}
	local color = "#E8A619"
	local fontSize = 24
	-- local style = {face = "resource/fonts/FZY4JW.TTF", size = fontSize, color = color, underLine = false}
	-- tb.style = style
	-- tb.list = {{str = data.content}}
	-- log(data.content)
	local tb, strLen = Model:get("Announce"):getRichMsgTb(data.content, fontSize, color)

	local assistNode = Assist.RichText:createRichText(tb)
	assistNode:setWrapMode(RICHTEXT_WRAP_PER_CHAR)
	assistNode:ignoreContentAdaptWithSize(false)
	assistNode:setContentSize(cc.size(700, 150))
	self.imgContent:addChild(assistNode)

	assistNode:setOpenUrlHandler(function (url)
		util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, url)
		-- log("call back url:"..url)
	end)

	local size = self.imgContent:getContentSize()
	-- log(size)
	assistNode:setAnchorPoint(cc.p(0.5, 0.5))
	assistNode:setPosition(size.width/2, size.height/2)

	local time = math.floor(data.createTime / 1000)
	-- time = util.time:getTimeStr(nil, time)
	local time_t = util.time:getTimeDate(time)
	self.txtTime:setString(string.format("%d-%02d-%02d %02d:%02d", time_t.year, time_t.month, time_t.day, time_t.hour, time_t.min))

	if data.isAttachTake == true then
		-- self.btnGetAttach:setVisible(false)
	end

	local itemAttach = data.itemAttach
	if #itemAttach > 0 then
		local param = 
		{
			data = itemAttach,
			ccsNameOrFunc = "Msg/AttachItem",
			dataCheckFunc = function (info, elem) return info == elem end
		}
	    self.listviewAttach:createItems(param)
	else
		-- self.btnGetAttach:setVisible(false)
	end
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
end

function prototype:onBtnReturnTouch()
		self:close()
end

function prototype:onBtnGetAttachClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		Model:get("Announce"):requestAttachTake(self.data.id)
	end
end

function prototype:onPushAttachTake(isSuccess)
	if isSuccess then
		-- self.btnGetAttach:setVisible(false)
	end
end

function prototype:onImageCloseClick()
	self:close()
end
