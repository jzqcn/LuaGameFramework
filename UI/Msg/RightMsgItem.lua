module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	
end

function prototype:setContent(str)
	local tb = {}
	local color = "#887644"
	local fontSize = 24
	local style = {face = "resource/fonts/FZY4JW.TTF", size = fontSize, color = color, underLine = false}
	tb.style = style
	tb.list = {{str = str}}

	local assistNode = Assist.RichText:createRichText(tb)
	assistNode:setWrapMode(RICHTEXT_WRAP_PER_CHAR)
	assistNode:ignoreContentAdaptWithSize(false)
	assistNode:setContentSize(cc.size(550,50))
	self.imgBg:addChild(assistNode)

	local size = self.imgBg:getContentSize()
	assistNode:setPosition(size.width/2+20, size.height/2-15)
end
