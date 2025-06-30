module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()

end

function prototype:setConfigParam(name, config, showStrTable, valueStrTable)
	self.txtName:setString(name)
	self.txtLimitNum:setString(showStrTable[config.default])

	self.showStrTable = showStrTable
end

function prototype:setShowLimit(index)
	if self.showStrTable[index] then
		self.txtLimitNum:setString(self.showStrTable[index])
	end
end

function prototype:getValueConfig()
	return nil
end

function prototype:getKeyConfig()
	return nil
end

function prototype:getShowHeight()
	return self.rootNode:getContentSize().height
end