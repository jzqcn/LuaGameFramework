module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.size = self.rootNode:getContentSize()
end

function prototype:refresh(data)
	self.gameList = {}
	local size 
	for i, v in ipairs(data) do
		local itemName = v.itemName .. "Item"
		local itemNode = self:getLoader():loadAsLayer("Hall/GoldItem/" .. itemName)
		if itemNode then
			itemNode:setItemInfo(v)
			self.rootNode:addChild(itemNode)

			itemNode:setAnchorPoint(cc.p(0.5, 0.5))

			size = itemNode:getContentSize()
			itemNode:setPosition(size.width/2, self.size.height - size.height/2 - (i-1)*size.height)
			itemNode:setName(itemName)

			self.gameList[i] = itemNode
		else
			log4ui:warn("load hall game gold item failed ! item name : " .. itemName)
		end
	end
end

function prototype:playAction(delayTime)
	for i, node in ipairs(self.gameList) do
		delayTime = delayTime + (i-1) * 0.1

		local size = node:getContentSize()
		local pos = cc.p(size.width/2, self.size.height - size.height/2 - (i-1)*size.height)
		local action = cc.MoveTo:create(0.45, pos)
		node:setPosition(pos.x + 1000, pos.y)
		node:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.EaseSineIn:create(action)))
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

function prototype:getGameNodeByType(typename)
	local items = {}
	if self.gameList then
		for i, v in ipairs(self.gameList) do
			if string.find(v:getName(), typename) then
				table.insert(items, v)
			end
		end
	end

	return items
end
