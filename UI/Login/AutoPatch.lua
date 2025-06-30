module (..., package.seeall)


prototype = Controller.prototype:subclass()

local EVT = AutoPatch.Mgr.EVT

function prototype:isFullWinodwMode()
	return true
end

function prototype:enter()
	patch.mgr:bindEvent(EVT.PATCH_START, self:createEvent("onPatchStart"))
	patch.mgr:bindEvent(EVT.PATCH_SUC, self:createEvent("onPatchSuc"))
	patch.mgr:bindEvent(EVT.DOWNLOAD_ASSET, self:createEvent("onDownloadAsset"))

	self.panelPercent:setVisible(false)
	self.txtLoading:setString("")
	self.loadingBar:setPercent(0)

	local version = sdk.platform:getUIShowVersion()
	self.textVersion:setString(version)
end

function prototype:onDownloadAsset(recv, total)
	local str = string.format("%d%%，总大小%.02fM", math.floor(recv/total*100), total/1024/1024)
	self.txtLoading:setString(str)
	self.loadingBar:setPercent(recv/total*100, 0.1)

	local x, y = self.loadingBar:getPosition()
	local size = self.loadingBar:getContentSize()
	self.imgSlid:setPosition(x - size.width/2 + recv/total * size.width, y)
end

function prototype:onPatchStart()
	self.txtLoading:setString("开始更新")
	self.panelPercent:setVisible(true)

	local particle = cc.ParticleSystemQuad:create("resource/particle/lightP.plist")
    self.imgSlid:addChild(particle)

    local size = self.imgSlid:getContentSize()
    particle:setPosition(cc.p(size.width/2 + 20, size.height/2))
    particle:setScale(0.5)
end

function prototype:onPatchSuc()
	self.loadingBar:setPercent(100, 0.1)
	self.txtLoading:setString("应用更新完成，重新加载中...")
end


