module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.size = self.rootNode:getContentSize()
end

function prototype:refresh(data)
	self.gameList = {}

	local index = 1
	local currencyType = data.currencyType
	for i, v in ipairs(data.items) do
		local itemName = v.itemName .. "Item"
		local itemNode = self:getLoader():loadAsLayer("Hall/GoldItem/" .. itemName)
		if itemNode then
			itemNode:setItemInfo(v, currencyType)
			self.rootNode:addChild(itemNode)

			local nodeSize = itemNode:getContentSize()
			local space = (self.size.width - nodeSize.width*4) / 5
			itemNode:setPosition((index-1)*nodeSize.width + space*index, 0)
			itemNode:setName(itemName)
			index = index + 1

			self.gameList[i] = itemNode
		else
			log4ui:warn("load hall game gold item failed ! item name : " .. itemName)
		end
	end
end

function prototype:getGameNode(gameName)
	if self.gameList then
		for i, v in ipairs(self.gameList) do
			if v:getName() == gameName then
				return v
			end
		end

		-- return self.gameList[itemName]
	end

	return nil
end

