module (..., package.seeall)

local ItemText = require "Hall/CreateRoom/ItemText"

module(..., package.seeall)

prototype = ItemText.prototype:subclass()

function prototype:enter()

end

function prototype:getOptionNum()
	return 8
end

function prototype:setConfigParam(name, config, showStrTable, valueStrTable)
	super.setConfigParam(self, name, config, showStrTable, valueStrTable)
end

