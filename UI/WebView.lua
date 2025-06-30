module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter(strUrl)
	if strUrl == nil or strUrl == '' then
		local data = {
			content = "url地址错误！",
		}
		ui.mgr:open("Dialog/DialogView", data)

		util.timer:after(2*1000, self:createEvent("close"))
		return
	end

	local winSize = cc.Director:getInstance():getWinSize()
	local size = self.panelNode:getContentSize()

    self.webView = ccexp.WebView:create()
    self.webView:setPosition(size.width / 2, size.height / 2)
    self.webView:setContentSize(size.width,  size.height)
    self.webView:loadURL(strUrl)
    self.webView:setScalesPageToFit(true)

    self.webView:setOnShouldStartLoading(function(sender, url)
        print("onWebViewShouldStartLoading, url is ", url)
        ui.mgr:open("Net/Connect")
        return true
    end)

    self.webView:setOnDidFinishLoading(function(sender, url)
        print("onWebViewDidFinishLoading, url is ", url)
        ui.mgr:close("Net/Connect")
    end)

    self.webView:setOnDidFailLoading(function(sender, url)
        print("onWebViewDidFinishLoading, url is ", url)

        local data = {
			content = "页面加载失败！请稍后重试！",
		}
		ui.mgr:open("Dialog/DialogView", data)

    end)

    self.panelNode:addChild(self.webView)

end

function prototype:onBtnRefreshClick()
	if self.webView then
		self.webView:reload()
	end
end

function prototype:onBtnCloseClick()
	self:close()
end
