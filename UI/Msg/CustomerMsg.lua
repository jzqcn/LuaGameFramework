module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("Announce.EVT.PUSH_REQUEST_CUSTOM", "onPushRequestCustom")
	self:bindModelEvent("Announce.EVT.PUSH_CUSTOM_MSG", "onPushCustomMsg")

	self:dealCustomerMsg()
end

function prototype:dealCustomerMsg(bRefresh)
	bRefresh = bRefresh or false

	local customMsg = Model:get("Announce"):getCustomMsg()
	local data = {}
	local unRead = {}
	for i, v in ipairs(customMsg) do
		if v.content and v.content ~= "" then
			local time = math.floor(v.createTime / 1000)
			local time_t = util.time:getTimeDate(time)
			local timeStr = string.format("%d-%02d-%02d %02d:%02d", time_t.year, time_t.month, time_t.day, time_t.hour, time_t.min)
			data[#data + 1] = {side = "right", content = v.content, time = timeStr}
		end

		if v.reply and v.reply ~= "" then
			local time = math.floor(v.replyTime / 1000)
			local time_t = util.time:getTimeDate(time)
			local timeStr = string.format("%d-%02d-%02d %02d:%02d", time_t.year, time_t.month, time_t.day, time_t.hour, time_t.min)
			data[#data + 1] = {side = "left", content = v.reply, time = timeStr} --util.time:getTimeStr(nil, time)}
		end

		if v.isRead == false and v.reply ~= "" then
			unRead[#unRead + 1] = v.id

			v.isRead = true
		end
	end
	
	local param = 
	{
		data = data,
		ccsNameOrFunc = "Msg/CustomerMsgItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}

	if bRefresh then
		self.listview:refreshListView(data)
	else
    	self.listview:createItems(param)
    end
    
    self.listview:jumpToBottom()

    self.customMsg = data

	if #unRead > 0 then    
	    Model:get("Announce"):requestReadMsg(unRead, Announce_pb.Custom)
	end
end

function prototype:onPushCustomMsg()
	self:dealCustomerMsg(true)
end

function prototype:onTFContentEvent(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfName:getPlaceHolder() == "请输入内容" then
			self.tfName:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onBtnSendMsgClick()
	-- Assist.TextField:onEvent(self.tfContent, ccui.TextFiledEventType.detach_with_ime)
	
	local content = self.tfName:getString()
	if getStrShowWidth(content) < 10 then
		local data = {
			content = "内容长度不能少于10个字符！",
		}
		ui.mgr:open("Dialog/DialogView", data)
		return
	end

	if getStrShowWidth(content) > 100 then
		local data = {
			content = "内容长度不能超过100个字符！",
		}
		ui.mgr:open("Dialog/DialogView", data)
		return
	end

	Model:get("Announce"):requestCustomMsg(content)

	self.content = content
	-- log(self.content)
	self.tfName:setString("")
end

function prototype:onPushRequestCustom(isSuccess, tips)
	if isSuccess then
		local time_t = util.time:getTimeDate()
		local timeStr = string.format("%d-%02d-%02d %02d:%02d", time_t.year, time_t.month, time_t.day, time_t.hour, time_t.min)
		self.customMsg[#self.customMsg + 1] = {side = "right", content = self.content, time = timeStr}

		Model:get("Announce"):insertNativeCustomMsg({content = self.content, time = util.time:getMilliTime()})

		self.listview:refreshListView(self.customMsg)

		self.listview:jumpToBottom()
	else
		local data = {
			content = tips,
		}
		ui.mgr:open("Dialog/DialogView", data)

		self.tfName:setString(self.content)
	end
end


