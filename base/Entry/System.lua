


function registerKeyCodeBack()
    local function onKeyReleased(keyCode, event)
    	local stage = StageMgr:getStage()
    	if not stage or not stage:onKeyReleased(keyCode, event) then
	        if keyCode == cc.KeyCode.KEY_BACK then
				-- Singleton(EnvLogic):OnKeyCodeBack()
	        elseif keyCode == cc.KeyCode.KEY_MENU then
	        end
	    end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
end


function OnSysStartup()
	WriteLog("### Startup ###")
	math.randomseed(TimeGetTime())
	
	require('GameRoot'):CreateGameRootMgr()
	GameRootMgr:onSysStartup()

	registerKeyCodeBack()
end

function OnSysShutdown()
	GameRootMgr:onSysShutdown()
	GameRootMgr:dispose()
	require('GameRoot'):DestroyGameRootMgr()
end

function OnProcess()
	GameRootMgr:onTick()
end

function OnMemoryLow()
	GameRootMgr:onMemoryLow()
end

function OnEnterBackground()
	StageMgr:getStage():onEnterBackground()
end

function OnEnterForeground()
	StageMgr:getStage():onEnterForeground()
end

function OnAvaliableStorageSize(avaliableSize)
	util:setAvaliableStorageSize(avaliableSize)
end

function OnKeyboardInput(show, height)
	ui.editMgr:onKeyboardInput(show, height)
end


