module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
end

function prototype:refresh(data, index)
	self.nodeItem_1:setVisible(false)
	self.nodeItem_2:setVisible(false)
	self.nodeItem_3:setVisible(false)

	local function actionOver(action)
		action:dispose()
		action = nil
	end

	for i, v in ipairs(data) do
		local name = "nodeItem_"..i
		local node = self[name]
		-- local anchor = node:getAnchorPoint()
		-- if anchor.x ~= 0.5 and anchor.y ~= 0.5 then
		-- 	local x, y = node:getPosition()
		-- 	local size = node:getContentSize()
		-- 	node:setAnchorPoint(cc.p(0.5, 0.5))
		-- 	node:setPosition(x + size.width/2, y + size.height/2)
		-- end
		node:setVisible(true)		
		node:refresh(v, i + (index-1)*3)
	end
end
