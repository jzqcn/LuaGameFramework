module(..., package.seeall)


class = GameStage.class:subclass()

function class:onStageActive()
	ui.mgr:replaceScene("Login/AutoPatch")

	-- sys.sound:playMusic("LOGIN")
	util.timer:after(300, self:createEvent('startAutoPatch'))
end

function class:onStageClose()
end

function class:startAutoPatch()
	local suc, err = sdk.platform:checkConfig()
	if not suc then
		local info = {}
		info.content = err
		info.okFunc = function() util:exitGame() end
		info.cancelFunc = function() util:exitGame() end
		ui.confirm:open(info)
		return
	end

	local EVT = AutoPatch.Mgr.EVT
	patch.mgr:bindEvent(EVT.CHECK_PASS, self:createEvent("onPachPass"))
	patch.mgr:start()
end

function class:onPachPass()
	StageMgr:chgStage('Loading')
end



