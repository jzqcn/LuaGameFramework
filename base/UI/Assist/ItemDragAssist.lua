module("Assist.ItemDrag", package.seeall)

local internal = {}

function registItemDrag(_, items, callback)
	if table.empty(items) then
		return
	end

	internal:init(items, callback)
end

------------- internal ------------------
--
function internal:init(items, callback)
	self.items = items
	self.callback = callback

	self.rootNode = ui.mgr:getRootNode()

	local layer = cc.Layer:create()
    self.items[1]:getParent():addChild(layer, 9999)
    Assist.Touch:registLayerTouch(layer, bind(self.onTouch, self))
end

function internal:onTouch(types, pos)
	if types == "began" then
		local item, idx = self:getHitItem(pos)
		if item and item:getData() then
			self.beganItem = item
			self.beganIdx = idx

			self:addDrag()
			self:setBeganImgVisible(false)

			return true
		else
			return false
		end

	elseif types == "move" then
		self.drag:setPosition(pos)		

	elseif types == "end" then
		self.drag:removeFromParent()
		self:setBeganImgVisible(true)

		if self:judgeDragIn(pos) then
			self.callback(self.beganIdx, self.endIdx)
		end
	end
end

function internal:getHitItem(pos)
	for k, item in ipairs(self.items) do

		if self:judgeHit(item, pos) then
			return item, k
		end
	end
end

function internal:judgeHit(item, pos)
	local rect = self:getItemRect(item)

	if cc.rectContainsPoint(rect, pos) then
		return true
	end
	return false
end

function internal:getItemRect(item)
	local pos = item:getWorldPosition()
	local size = item:getContentSize()
	local rect = cc.rect(pos.x, pos.y, size.width, size.height)
	return rect
end

function internal:setBeganImgVisible(v)
	local beganImg = self.beganItem:getImage()
	if not beganImg then
		log4misc:warn("item image is nil")
	end

	beganImg:setVisible(v)
end

function internal:getItemRect(item)
	local pos = item:getWorldPosition()
	local size = item:getContentSize()
	local rect = cc.rect(pos.x, pos.y, size.width, size.height)
	return rect
end

function internal:judgeDragIn(pos)
	for k, item in ipairs(self.items) do
		if self:judgeHit(item, pos) then
			self.endIdx = k
			return true
		end
	end
end

function internal:addDrag()
	local itemImg = self.beganItem:getImage()
	if not itemImg then
		log4misc:warn("item image is nil")
	end

	local drag = itemImg:clone()
	self.drag = drag

	drag:retain()
	drag:setPosition(itemImg:getWorldPosition())

	self.rootNode:addChild(drag)
	drag:release()
end