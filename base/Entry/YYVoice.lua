--YY语音事件响应
function OnLoginListern(result, userId)
	log("OnLoginListern:: result == "..result..", userId == "..userId)
end

function OnReConnectListern(userId)
	log("OnReConnectListern:: userId == "..userId)
end

--停止录音 time:毫秒
function OnStopRecordListern(strfilepath, time)
	log("OnStopRecordListern:: file path == "..strfilepath..", time == "..time)
	if time < 1000 then
		local data = {
			content = "录音时间太短！不能低于1秒！"
		}
		ui.mgr:open("Dialog/DialogView", data)
	else
		sdk.yvVoice:upLoadFile(strfilepath)
	end

	Model:get("Chat"):onRecordFinish()
	--AudioEngine.resumeMusic()
end

function OnFinishSpeechListern(msg, result)
	log("OnFinishSpeechListern:: msg == "..msg..", result == "..result)
end

--语音播放完成
function OnFinishPlayListern(result)
	log("OnFinishPlayListern:: result == "..result)

	sdk.yvVoice:setIsPlaying(false)

	Model:get("Chat"):onVoiceFinish()
	--AudioEngine.resumeMusic()
end

--语音文件上传
function OnUpLoadFileListern(fileUrl, result, percent)
	log("OnUpLoadFileListern:: fileUrl == "..fileUrl..", result == "..result..", percent == "..percent)
	if result == 0 then
		Model:get("Chat"):requestVoiceMsg(fileUrl)
	else
		log("OnUpLoadFileListern:: upload voice file failed ! error code : "..result..", error msg : "..fileUrl)
	end
end

function OnDownLoadFileListern(fileName, result)
	log("OnDownloadVoiceListern:: fileName == "..fileName..", result == "..result)
end

--录音音量变化 0-100
function OnRecordVoiceListern(volume)
	log("OnRecordVoiceListern:: volume == "..volume)

	local layer = ui.mgr:getLayer("Chat/ChatRecordView")
	if layer then
		layer:updateVolume(volume)
	end
end

function OnDownloadVoiceListern(percent)

end

function OnFlowListern(upflow, downflow, allflow)

end

