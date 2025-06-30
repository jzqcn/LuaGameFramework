module (..., package.seeall)

local ItemText = require "Hall/CreateRoom/ItemText"

module(..., package.seeall)

prototype = ItemText.prototype:subclass()

function prototype:enter()

end

function prototype:getOptionNum()
	return 1
end

function prototype:getShowHeight()
	return self.rootNode:getContentSize().height
end

function prototype:setConfigParam(name, config, showStrTable, valueStrTable)
	-- super.setConfigParam(self, name, config, showStrTable, valueStrTable)
end

function prototype:setPayValue(value)
	self.txtNum_1:setString("大赢家付费（" .. Assist.NumberFormat:amount2Hundred(value))

	local x, y = self.txtNum_1:getPosition()
	local size = self.txtNum_1:getContentSize()
	self.imgGold:setPosition(x+size.width+5, y+3)
	self.txtNum_2:setPosition(x+size.width+25+5, y)
end
