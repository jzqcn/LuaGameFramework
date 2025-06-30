module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.enableVoice = true
	self.isRecording = false
end

function prototype:setVoiceVisible(var)
	self.btnVoiceChat:setVisible(var)
end

function prototype:onBtnTextTouch(sender, event)
	if event == ccui.TouchEventType.ended then
		ui.mgr:open("Chat/GameChatView")
	end
end

function prototype:onBtnVoiceTouch(sender, event)
	if event == ccui.TouchEventType.began then
		-- log("btn touchBeg")
		
		sdk.yvVoice:stopPlay()

		if self.enableVoice == false then
			local data = {
				content = "你说话的速度太快了！请稍等会！"
			}
			ui.mgr:open("Dialog/DialogView", data)
		else
			local time = util.time:getTime()
			-- local dateZero = util.time:getWorldDate()
			-- local date, time = util.time:timeZoneWorldToCur(dateZero)
			-- local timeStr = string.format("%d%02d%02d-%02d%02d%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
			local fileName = string.format("%d.amr", time)
			--开始录音
			self.isRecording = sdk.yvVoice:startRecord(fileName, 0)
			if self.isRecording == true then
				ui.mgr:open("Chat/ChatRecordView")
			else
				local data = {
					content = "录音出错！"
				}
				ui.mgr:open("Dialog/DialogView", data)
			end
		end

	elseif event == ccui.TouchEventType.moved then
		--log("btn touchMove")

	elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
		-- log("btn touchEnd")
		if self.isRecording == false then
			return
		end

		--停止录音
		sdk.yvVoice:stopRecord()

		self.enableVoice = false
		util.timer:after(2000, self:createEvent("setEnableVoice"))

		ui.mgr:close("Chat/ChatRecordView")
	-- elseif event == ccui.TouchEventType.canceled then
	-- 	log("btn touchCanl")
	-- 	if self.isRecording == false then
	-- 		return
	-- 	end

	-- 	--停止录音
	-- 	sdk.yvVoice:stopRecord(true)

	-- 	ui.mgr:close("Chat/ChatRecordView")
	end
end

function prototype:setEnableVoice()
	self.enableVoice = true
end
