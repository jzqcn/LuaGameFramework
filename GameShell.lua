require 'GameRoot'


module(..., package.seeall)

class = GameRoot.class:subclass()

local DUMP_MOBILE_INFO = true 

function class:initialize(...)
	super.initialize(self, ...)

	self:initModuleDb()
	self:initModuleUI()
	self:initModuleNet()
	self:initModuleSdk()
	self:initModulePatch()
	self:initModuleSystem()

	self:setupHttpUI()
	-- C2DEffectPool:CreateSingleton()
	-- UI.Animation:preLoad()
	self:dumpMobileInfo()
end

function class:dispose()
	-- C2DEffectPool:ReleaseSingleton()
	-- NewEffectSystem:ReleaseSingleton()
	-- CSpineManager:ReleaseSingleton()

	self:disposeModuleSystem()
	self:disposeModulePatch()
	self:disposeModuleSdk()
	self:disposeModuleNet()	
	self:disposeModuleUI()	
	self:disposeModuleDb()	

	super.dispose(self)
end

function class:onStartup()
	super.onStartup(self)

	local director = cc.Director:getInstance()
    director:setDisplayStats(util:getPlatform() == "win32")
    -- director:setDisplayStats(true)
    
    self.uiLoader:setLayout("landscape")

    net.msg:importData()
    sdk.feedback:active()
	StageMgr:chgStage('AutoPatch')


	-- NewEffectSystem:CreateSingleton()
	-- NewEffectSystem:GetSingleton():Start()
	-- C2DEffectPool:GetSingleton():Start()
	-- CSpineManager:CreateSingleton()
end

function class:onTick(elapsed)
end

function class:onShutdown()
	super.onShutdown(self)
end


function class:initModuleDb()
	self.variable = DB.Variable.class:new()
	db:registModule("var", self.variable)

	self.dbMgr = DB.Mgr.class:new()
	db:registModule("mgr", self.dbMgr)
end

function class:disposeModuleDb()
	db:unregistModule("mgr")
	self.dbMgr:dispose()

	db:unregistModule("var")
	self.variable:dispose()
end

function class:initModuleUI()
	self.uiLoader = UI.Loader.class:new()
	self.uiMgr = UI.Mgr.class:new()
	self.aniMgr = UI.AniMgr.class:new()
	self.editMgr = UI.EditMgr.class:new()
	self.confirm = UI.Confirm.class:new()

	ui:registModule("loader", self.uiLoader)
	ui:registModule("mgr", self.uiMgr)
	ui:registModule("aniMgr", self.aniMgr)
	ui:registModule("editMgr", self.editMgr)
	ui:registModule("confirm", self.confirm)
end

function class:disposeModuleUI()
	ui:unregistModule("loader")
	ui:unregistModule("mgr")
	ui:unregistModule("aniMgr")
	ui:unregistModule("editMgr")
	ui:unregistModule("confirm")

	self.confirm:dispose()
	self.aniMgr:dispose()
	self.editMgr:dispose()
	self.uiMgr:dispose()
	self.uiLoader:dispose()
end

function class:initModuleNet()
	self.netMsg = Net.Msg.class:new()
	net:registModule("msg", self.netMsg)

	self.netMgr = Net.Mgr.class:new()
	net:registModule("mgr", self.netMgr)

	self.http = Net.Http.class:new()
	net:registModule("http", self.http)

	self.netMonitor = Net.Monitor.class:new()
	net:registModule("monitor", self.netMonitor)
end

function class:disposeModuleNet()
	net:unregistModule("monitor")
	self.netMonitor:dispose()

	net:unregistModule("http")
	self.http:dispose()

	net:unregistModule("mgr")
	self.netMgr:dispose()

	net:unregistModule("msg")
	self.netMsg:dispose()
end

function class:initModuleSdk()
	self.sdkConfig = Sdk.Config.class:new()
	sdk:registModule("config", self.sdkConfig)

	self.sdkPlatform = Sdk.Platform.class:new()
	sdk:registModule("platform", self.sdkPlatform)

	self.sdkFeedback = Sdk.Feedback.class:new()
	sdk:registModule("feedback", self.sdkFeedback)

	self.sdkAccount = Sdk.Account.class:new()
	sdk:registModule("account", self.sdkAccount)

	self.sdkVoice = Sdk.YvVoice.class:new()
	sdk:registModule("yvVoice", self.sdkVoice)
end

function class:disposeModuleSdk()
	sdk:unregistModule("account")
	self.sdkAccount:dispose()

	sdk:unregistModule("feedback")
	self.sdkFeedback:dispose()

	sdk:unregistModule("platform")
	self.sdkPlatform:dispose()

	sdk:unregistModule("config")
	self.sdkConfig:dispose()

	sdk:unregistModule("yvVoice")
	self.sdkVoice:dispose()
end

function class:initModulePatch()
	self.patchMgr = AutoPatch.Mgr.class:new()
	patch:registModule("mgr", self.patchMgr)
end

function class:disposeModulePatch()
	patch:unregistModule("mgr")
	self.patchMgr:dispose()
end

function class:initModuleSystem()
	self.sound = System.Sound.class:new()
	sys:registModule("sound", self.sound)
end

function class:disposeModuleSystem()
	sys:unregistModule("sound")
	self.sound:dispose()
end


function class:setupHttpUI()
	local classUIControl = Net.Http.classUIControl:subclass()
	
	function classUIControl:doBlock(block)
		if block then
			local tipDialog = ui.mgr:open("Net/Connect")
			-- tipDialog:showWaiting()
		else
			ui.mgr:close("Net/Connect")
		end
	end
	
	net.http:setUIControl(classUIControl:new())
end


function class:dumpMobileInfo( ... )
	if not DUMP_MOBILE_INFO then
		return
	end

	local root = CEnvRoot:GetSingleton() 
	local variable = CVariableSystem:GetSingleton() 

	log("-----------mobile dump info----------")
	log("deviceName:" .. variable:GetSysVariable(GV_DEVICE_NAME))
	log("deviceVersion:" .. variable:GetSysVariable(GV_DEVICE_VER))
	log("identifier:" .. variable:GetSysVariable(GV_PKG_IDENTIFIER))

	log("versionApp:" .. variable:GetSysVariable(GV_VERSION))
	log("versionname:" .. root:GetVersionName())
	log("versionExe:" .. variable:GetSysVariable(GV_EXE_VER))

	log("uniqueid:" .. root:GetUniqueId())
	log("idfa:" .. root:GetIdfa())
	log("idfv:" .. variable:GetSysVariable(GV_IDFV))
	log("macaddress:" .. root:GetMacAddr())

	log("apppath:" .. variable:GetSysVariable(GV_RESPATH))
	log("docpath:" .. variable:GetSysVariable(GV_DOCPATH))
	log("patchpath:" .. variable:GetSysVariable(GV_PATCHPATH))


	log("opratorpath:" .. variable:GetSysVariable(GV_OPERATORPATH))
	log("opratorid:" .. root:GetOperatorProxyId())
	log("-------------------------------------")
end