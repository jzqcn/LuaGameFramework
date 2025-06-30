require "Protol.Announce_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_ROLLING_MSG",
	"PUSH_MAIL_MSG",
	"PUSH_CUSTOM_MSG",
	"PUSH_COUNTDOWN_MSG",
	"PUSH_REQUEST_CUSTOM",
	"PUSH_REQUEST_READ",
	"PUSH_REQUEST_ATTACH",
	"PUSH_RECHARGE_MSG"
}

class = Model.class:subclass()

local Announce_pb = Announce_pb

--消息公告
function class:initialize()
    super.initialize(self)

    self:clear()

    net.msg:on(MsgDef_pb.MSG_ANNOUNCE, self:createEvent("onAnnounceResponse"))

    local EVT = Net.Mgr.EVT
	net.mgr:on(EVT.CLOSE, self:createEvent("clear"))
end

function class:clear()
	self.rollingMsgId = nil

	self.countDownMsgTable = {}
	self.rollingMsgTable = {}
    self.mailMsgTable = {}
    self.customMsgTable = {}
    self.tipsMsgTable = {}

    self.popChargeMsg = nil
    self.popGiveMsg = nil
end

function class:requestReadMsg(msgIds, announceType)
	local request = Announce_pb.AnnounceRequest()
	request.type = Announce_pb.Request_Read
	-- log(msgIds)
	-- for i, v in ipairs(msgIds) do
	-- 	table.insert(request.id, v)
	-- end

	local readInfo
	for i, v in ipairs(msgIds) do
		readInfo = Announce_pb.ReadRequest()
		readInfo.id = v
		readInfo.announceType = announceType
		table.insert(request.readRequest, readInfo)
	end

	net.msg:send(MsgDef_pb.MSG_ANNOUNCE, request:SerializeToString())
end

function class:requestAttachTake(msgId)
	local request = Announce_pb.AnnounceRequest()
	request.type = Announce_pb.Request_Attach_Take
	table.insert(request.id, msgId)

	net.msg:send(MsgDef_pb.MSG_ANNOUNCE, request:SerializeToString())
end

function class:requestCustomMsg(content)
	local request = Announce_pb.AnnounceRequest()
	request.type = Announce_pb.Request_Custom
	request.customMsg.content = content

	net.msg:send(MsgDef_pb.MSG_ANNOUNCE, request:SerializeToString())
end

function class:onAnnounceResponse(data)
	local msgData = Announce_pb.AnnounceResponse()
	msgData:ParseFromString(data)

	local msgType = msgData.type
	if not msgType then
		return
	end

	-- log("[Announce::onAnnounceResponse] msg type == "..msgType)

	if msgType == Announce_pb.Request_Custom then
		self:fireEvent(EVT.PUSH_REQUEST_CUSTOM, msgData.isSuccess, msgData.tips)
	elseif msgType == Announce_pb.Request_Read then
		-- log(msgData.isSuccess)
		self:fireEvent(EVT.PUSH_REQUEST_READ, msgData.isSuccess)
	elseif msgType == Announce_pb.Request_Attach_Take then
		self:fireEvent(EVT.PUSH_REQUEST_ATTACH, msgData.isSuccess)
	end

	local pushResponse = msgData.pushResponse
	if pushResponse then
		if msgType == Announce_pb.Push_RollingMsg then
			--公告
			self:parseRollingMsg(pushResponse.rollingMsg)

		elseif msgType == Announce_pb.Push_MailMsg then
			--邮件
			self:parseMailMsg(pushResponse.mailMsg)

		elseif msgType == Announce_pb.Push_Custom then
			--客服
			self:parseCustomMsg(pushResponse.customMsg)

		elseif msgType == Announce_pb.Push_Cancel then
			--取消
			self:parseRollingMsg(pushResponse.rollingMsg, true)
			self:parseMailMsg(pushResponse.mailMsg, true)
			self:parseCustomMsg(pushResponse.customMsg, true)
			self:parseTipsMsg(pushResponse.tipsMsg, true)

		elseif msgType == Announce_pb.Push_TipsMsg then
			--提示框消息
			self:parseTipsMsg(pushResponse.tipsMsg)
		
		else
			--其他
			self:parseRollingMsg(pushResponse.rollingMsg)
			self:parseMailMsg(pushResponse.mailMsg)
			self:parseCustomMsg(pushResponse.customMsg)
		end
	end
end

function class:parseRollingMsg(rollingMsg, isDel)
	--滚动公告
	if not rollingMsg then
		return
	end

	for k, v in ipairs(rollingMsg) do
		if isDel == true then
			if self:deleteMsg(self.countDownMsgTable, v.id) then
				ui.mgr:close("CountdownView")
			else
				self:deleteMsg(self.rollingMsgTable, v.id)
			end

			-- log("cancel msg id:"..v.id..", type:"..v.type)
		else
			local msgItem = {}
			msgItem.id = v.id
			msgItem.content = v.content
			msgItem.type = v.type
			msgItem.countDown = v.countDown

			if msgItem.type == Announce_pb.CountDown then
				msgItem.curTime = util.time:getTime()
				table.insert(self.countDownMsgTable, msgItem)
			else
				table.insert(self.rollingMsgTable, msgItem)
			end

			if msgItem.type==Announce_pb.CountDown then
				if msgItem.countDown>0 and not StageMgr:isStage("Login") then
					--倒计时消息
					ui.mgr:open("CountdownView", msgItem)
				end
			else
				self:fireEvent(EVT.PUSH_ROLLING_MSG)
			end

			-- log(msgItem)
		end
	end
end

function class:parseMailMsg(mailMsg, isDel)
	--邮件
	if not mailMsg then
		return
	end

	local popChargeMsg = {}
	local popGiveMsg = {}

	local haveUnreadMsg = false
	for k, v in ipairs(mailMsg) do
		if isDel == true then
			self:deleteMsg(self.mailMsgTable, v.id)
		else
			local msgItem = {}
			msgItem.id = v.id
			msgItem.title = v.title
			msgItem.content = v.content
			msgItem.isRead = v.isRead
			msgItem.isAttachTake = v.isAttachTake
			msgItem.createTime = tonumber(v.creatTime) or 0
			msgItem.mailType = v.mailType

			msgItem.itemAttach = {}

			if v.attach then
				--附件
				local sliver = tonumber(v.attach.sliver)
				if sliver and sliver > 0 then
					table.insert(msgItem.itemAttach, {type=Common_pb.Sliver, num = sliver})
				end
				
				local gold = tonumber(v.attach.gold)
				if gold and gold > 0 then 
					table.insert(msgItem.itemAttach, {type=Common_pb.Gold, num = gold})
				end

				local items = v.attach.item
				if items then
					for _, item in ipairs(items) do
						local info = {type= -1 , id = item.id, name = item.name, num = item.num}
						table.insert(msgItem.itemAttach, info)
					end
				end
			end

			table.insert(self.mailMsgTable, msgItem)

			if msgItem.isRead == false then
				if msgItem.mailType == Announce_pb.Charge then
					--充值邮件（未读时弹出窗口）
					popChargeMsg[#popChargeMsg + 1] = msgItem
				else
					--普通邮件
					haveUnreadMsg = true
				end
			end

			-- log(msgItem)
		end
	end

	local function sortFunc(a, b)
		return a.createTime > b.createTime
	end

	table.sort(self.mailMsgTable, sortFunc)

	if haveUnreadMsg then
		self:fireEvent(EVT.PUSH_MAIL_MSG)
	end

	if #popChargeMsg > 0 then
		-- log(popChargeMsg)
		
		self.popChargeMsg = popChargeMsg

		if StageMgr:isStage("Hall") or StageMgr:isStage("Game") then
			if util:getPlatform() == "android" then
				util:fireCoreEvent(REFLECT_EVENT_CLOSE_WEBPAGE, 0, 0, "")
			end

			self:playChargeMsgView()			
		end

		self:fireEvent(EVT.PUSH_RECHARGE_MSG)
	end
end

function class:playChargeMsgView()
	if not self.popChargeMsg then
		return
	end

	local readMsgs = {}
	for i, v in ipairs(self.popChargeMsg) do
		v.isRead = true
		readMsgs[#readMsgs + 1] = v.id

		local content = v.content
		local value = content
		local beignIndex, endIndex = string.find(content, "金币")
		if beignIndex then
			value = string.sub(content, beignIndex, -1)
		end
		local data = {content = value, coinType = Common_pb.Gold}
		ui.mgr:open("Shop/RechargeSuccessView", data)
	end

	self:requestReadMsg(readMsgs, Announce_pb.Mail)

	self.popChargeMsg = nil
end

function class:parseCustomMsg(customMsg, isDel)
	--客服消息
	if not customMsg then
		return
	end

	isDel = isDel or false

	local haveUnreadMsg = false	
	for k, v in ipairs(customMsg) do
		if isDel == true then
			self:deleteMsg(self.customMsgTable, v.id)
		else
			if (v.content == nil or v.content=="") and (v.reply == nil or v.reply == "") then
				log("empty msg !!!!")
			else
				local isNew = false
				local msgItem = self:getCustomItem(v.content)
				if msgItem == nil then
					msgItem = {}
					-- isNew = true
				end

				msgItem.id = v.id
				msgItem.title = v.title
				msgItem.content = v.content
				msgItem.reply = v.reply
				msgItem.isRead = v.isRead
				msgItem.createTime = tonumber(v.createTime)
				msgItem.replyTime = tonumber(v.replyTime)
				-- log(msgItem.replyTime)
				-- log(msgItem.createTime)
				if msgItem.replyTime ~= nil then
					msgItem.time = msgItem.replyTime
				else
					msgItem.time = msgItem.createTime
				end
				
				table.insert(self.customMsgTable, msgItem)

				-- log(msgItem)

				if msgItem.isRead == false and msgItem.reply ~= "" then
					haveUnreadMsg = true
				end
			end

		end
	end

	-- log(self.customMsgTable)

	local function sortFunc(a, b)
		return a.time < b.time
	end

	table.sort(self.customMsgTable, sortFunc)

	if haveUnreadMsg then
		self:fireEvent(EVT.PUSH_CUSTOM_MSG)
	end
end

--加入自己发送消息
function class:insertNativeCustomMsg(item)
	local msgItem = {}
	msgItem.content = item.content
	msgItem.createTime = item.time
	msgItem.reply = ""
	msgItem.isRead = false
	msgItem.time = msgItem.createTime
	table.insert(self.customMsgTable, msgItem)
end

function class:parseTipsMsg(tipsMsg, isDel)
	if not tipsMsg then
		return
	end

	for k, v in ipairs(tipsMsg) do
		if isDel == true then
			self:deleteMsg(self.tipsMsgTable, v.id)
		else
			local msgItem = {}
			msgItem.id = v.id
			msgItem.title = v.title
			msgItem.content = v.content

			table.insert(self.tipsMsgTable, msgItem)
		end
	end
end

function class:deleteMsg(msgTable, delId)
	for i, v in ipairs(msgTable) do
		if v.id == delId then
			table.remove(msgTable, i)
			return true
		end
	end

	return false
	
	--[[local i = 1
	while i <= #self.rollingMsgTable do
		local id = self.rollingMsgTable[i].id
		if delId == id then
			table.remove(self.rollingMsgTable, i)
		else
			i = i + 1
		end
	end--]]
end

function class:getRollingMsg()
	return self.rollingMsgTable
end

function class:getNextRollingMsg()
	local nextMsg = nil
	if #self.rollingMsgTable > 0 then
		local rollingIndex = -1
		for i, v in ipairs(self.rollingMsgTable) do
			if v.type >= Announce_pb.Prizes then
				--优先播放奖励及其他消息，该类型消息只播放一次。（系统和活动消息循环播放）
				nextMsg = v
				table.remove(self.rollingMsgTable, i)
				break
			else
				if v.id == self.rollingMsgId then
					rollingIndex = i
				end
			end
		end

		if nextMsg == nil then
			if rollingIndex > 0 and rollingIndex < #self.rollingMsgTable then
				nextMsg = self.rollingMsgTable[rollingIndex + 1]
			else
				nextMsg = self.rollingMsgTable[1]
			end
			self.rollingMsgId = nextMsg.id
		end
	end

	return nextMsg
end

function class:getMailMsg()
	return self.mailMsgTable
end

function class:getCustomMsg()
	return self.customMsgTable
end

function class:getCustomItem(content)
	if content and content ~= "" then
		for i, v in ipairs(self.customMsgTable) do
			if v.content == content then
				local item = v
				table.remove(self.customMsgTable, i)
				return item
			end
		end
	end

	return nil
end

function class:getCountDownMsg()
	if #(self.countDownMsgTable) > 0 then
		local item = self.countDownMsgTable[1]
		local curTime = util.time:getTime()
		item.countDown = item.countDown - (curTime - item.curTime)
		item.curTime = curTime
		return item
	end
	
	return nil
end

function class:haveUnreadMailMsg()
	for _, v in ipairs(self.mailMsgTable) do
		if v.isRead == false then
			return true
		end
	end

	return false
end

function class:haveUnreadCustomMsg()
	for _, v in ipairs(self.customMsgTable) do
		if v.isRead == false and v.reply ~= "" then
			return true
		end
	end

	return false
end

function class:haveChargeMsg()
	if self.popChargeMsg and #self.popChargeMsg > 0 then
		return true
	end

	return false
end

function class:getFontColor(sign)
	if not sign then
		return "#ffffff"
	end

	if sign == "red" then
		return "#FF4900"
	elseif sign == "blue" then
		return "#0084FF"
	elseif sign == "green" then
		return "#00ff00"
	else
		return "#ffffff"
	end
end

--转换富文本
function class:getRichMsgTb(content, fontSize, color)
	local tb = {}
	local initColor = color or "#ffffff"
	fontSize = fontSize or 28
	
	local style = {face = "resource/fonts/FZY4JW.TTF", size = fontSize, color = initColor}
	tb.style = style
	tb.list = {}

	content = string.gsub(content, "\\", "")
	-- log(content)

	local strLength = 0
	local beginindex, endindex = string.find(content, "%b<>", 1)
	if beginindex then
		local bFirst = true
		local color = initColor
		local bLink = false
		while beginindex do
			-- 获得当前标签
	        local label = string.sub(content, beginindex, endindex)
	        -- log(label)

	        local strContent = string.sub(content, 1, beginindex-1)
	        if bFirst then
        		table.insert(tb.list, {str = strContent})
        		bFirst = false
        	else
        		local tbSub = self:getRichTb(fontSize, color)
        		-- if string.find(strContent, "http://") or string.find(strContent, "https://") then
        		if bLink then
        			table.insert(tbSub.list, {str = strContent, link = strContent})
        		else
					table.insert(tbSub.list, {str = strContent})
				end
				table.insert(tb.list, tbSub)
        	end

        	strLength = strLength + string.len(strContent)

			-- log(strContent)
			
			color = initColor
			bLink = false

	        -- 检测字符串是否以"</"开头
	        if string.find(label, "^</") then
	            -- 标签尾	            
	        else
	        	-- 检测到标签头
	        	if string.find(label, "font") then
	        		local i, j = string.find(label, "%b\"\"", 1)
	        		if i then
	        			color = self:getFontColor(string.sub(label, i+1, j-1))
	        			-- log(color)
	        		end
	        	elseif string.find(label, "image") then

	        	elseif string.find(label, "href") then
	        		bLink = true
	        	end
	        end

			content = string.sub(content, endindex+1, -1)
			-- log(content)
	        -- 获得下一个标签的位置
	        beginindex, endindex = string.find(content, "%b<>", 1)

	        if not beginindex then
	        	table.insert(tb.list, {str = content})
	        end
		end

	else
		table.insert(tb.list, {str = content})

		strLength = string.len(content)
	end

	-- log(tb)

	return tb, strLength
end

function class:getRichTb(fontSize, color)
	local tb = {}
	color = color or "#ffffff"
	local fontSize = fontSize or 28
	local style = {size = fontSize, color = color}
	tb.style = style
	tb.list = {}

	return tb
end

