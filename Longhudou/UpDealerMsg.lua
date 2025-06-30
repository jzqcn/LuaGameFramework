module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()
	
end

function prototype:onBtnSnatchClick()
    --log("onBtnSnatchClick/SnatchListView")
	if self.gamePlayId==nil then
		self.gamePlayId=115001
	end
	ui.mgr:open("Longhudou/SnatchListView",self.gamePlayId)
end
function prototype:setPlayId(playId)
	self.gamePlayId=playId
end