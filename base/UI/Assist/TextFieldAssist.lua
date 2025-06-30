module("Assist.TextField", package.seeall)


function onEvent(_, sender, evtType)
	local platform = util:getPlatform()
	if platform ~= "android" and platform ~= "ios" then
		return
	end

	if evtType == ccui.TextFiledEventType.attach_with_ime then
		ui.editMgr:onTextFiledWithIme(sender, true)
	elseif evtType == ccui.TextFiledEventType.detach_with_ime then
		ui.editMgr:onTextFiledWithIme(sender, false)
	end
end

