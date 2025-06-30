module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()
	
end

function prototype:onBtnSnatchClick()
    --log("onBtnSnatchClick/SnatchListView")
    --[[local imgBtn="resource/Dantiao/csbimages/cancleDealer.png"
	self.btnSnatch:loadTextureNormal(imgBtn)
	self.btnSnatch:loadTexturePressed(imgBtn)]]
	if self.gamePlayId==nil then
		self.gamePlayId=113001
	end
	ui.mgr:open("Dantiao/SnatchListView",self.gamePlayId)
end
function prototype:setPlayId(playId)
	self.gamePlayId=playId
end