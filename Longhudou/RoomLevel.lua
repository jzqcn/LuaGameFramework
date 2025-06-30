
module (..., package.seeall)

prototype = Dialog.prototype:subclass()


function prototype:enter()
	self.nodeLevel_1:initData(115001)
	self.nodeLevel_2:initData(115002)
	sys.sound:playEffectByFile("resource/audio/Hall/qi_kai_de_sheng.mp3")
end

function prototype:onBtnCloseClick(sender, eventType)
	self:close()
end