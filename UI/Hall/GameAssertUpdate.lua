module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	
end

--下载进度
function prototype:onDownloadAsset(recv, total)
	local percent = math.floor(recv/total*100)
	if percent < 0 then
		percent = 0
	elseif percent > 100 then
		percent = 100
	end

	local str = string.format("%d%%，总大小%.02fM", percent, total/1024/1024)
	self.txtTip:setString(str)
	self.loadingbar:setPercent(recv/total*100, 0.1)
end

