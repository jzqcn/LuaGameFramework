module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:clear()
end

function prototype:show()
	self:clear()
	self.rootNode:setVisible(true)
end

function prototype:clear()
	for i = 1, 4 do
		self["fontNum_"..i]:setVisible(false)
		self["fontNum_"..i]:setString("")
	end

	self.showIndex = {}
	self.add = 0
end

function prototype:setValue(id, value)
	log("[CalcView::setValue] id = "..id..", value = "..value)
	if value >= 0 then
		if #self.showIndex >= 3 then
			return
		end
		
		if value > 10 then
			value = 10
		end

		local item = {id = id, value = value}
		table.insert(self.showIndex, item)		
	else
		for i, v in ipairs(self.showIndex) do
			if id == v.id then
				table.remove(self.showIndex, i)
				break
			end
		end
	end

	for i = 1, 4 do
		self["fontNum_"..i]:setVisible(false)
		self["fontNum_"..i]:setString("")
	end

	if #self.showIndex > 0 then
		table.sort(self.showIndex, function (a, b)
		    return a.id < b.id
		end)

		self.add = 0
		for i, v in ipairs(self.showIndex) do
			self.add = self.add + tonumber(v.value)
			self["fontNum_"..i]:setString(v.value)
			self["fontNum_"..i]:setVisible(true)
		end

		self.fontNum_4:setString(self.add)
		self.fontNum_4:setVisible(true)
	end
end

function prototype:showNum()
	return #self.showIndex
end

function prototype:getAddValue()
	return self.add
end

function prototype:onBtnYouniuTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Calc", true)
	end
end

function prototype:onBtnWuniuTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Calc", false)
	end
end
