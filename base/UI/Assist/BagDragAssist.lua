module("Assist.BagDrag", package.seeall)

local DRAG_TYPE = Enum
{
	"TO_BAG",
	"OUT_BAG",
}

local internal = {}

function registBagDrag(_, equips, gridview, callback)
	internal:init(equips, gridview, callback)
end

------------- internal ------------------
--
function internal:init(equips, gridview, callback)
	self.equips = equips
	self.gridview = gridview
	self.callback = callback

	self.rootNode = ui.mgr:getRootNode()

	self.isJudge = false
	self.isScroll = false

	local layer = cc.Layer:create()
    gridview:getParent():addChild(layer, 9999)
    Assist.Touch:registLayerTouch(layer, bind(self.onTouch, self))
end

function internal:onTouch(types, pos)
	if types == "began" then
		local hitItem, dragType, idx = self:getHitItem(pos)
		if hitItem and hitItem:getData() then
			self.beganItem = hitItem
			self.beganPos = pos
			self.dragType = dragType
			self.beganIdx = idx

			self:addDrag()
			self:setBeganImgVisible(false)

			return true
		else
			self.drag = nil
			return false
		end

	elseif types == "move" then
		self.drag:setPosition(pos)

		if not self.isJudge and self.dragType == DRAG_TYPE.OUT_BAG then
			self.isJudge = true
			self:judgeDragOrScroll(pos)
		end
	elseif types == "end" then
		self.drag:removeFromParent()
		self:setBeganImgVisible(true)

		self.gridview:setTouchEnabled(true)

		if self:judgeDragIn(pos) and not self.isScroll then
			self.callback(self.dragType, self.beganIdx, self.endIdx)
		end

		self.isJudge = false
		self.isScroll = false
	end
end

function internal:getHitItem(pos)
	for k, item in ipairs(self.equips) do

		if self:judgeHit(item, pos) then
			return item, DRAG_TYPE.TO_BAG, k
		end
	end

	for k, item in ipairs(self.gridview:getAllItems()) do
		while true do
			local itemR = self:getItemRect(item)
			local gridR = self.gridview:getBoundingBox()
			if not cc.rectIntersectsRect(itemR, gridR) then
				break
			end

			if self:judgeHit(item, pos) then
				return item, DRAG_TYPE.OUT_BAG, k
			end

			break
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

function internal:judgeDragIn(pos)
	if self.dragType == DRAG_TYPE.TO_BAG then
		local grid = self.gridview
		local itemPos = grid:getWorldPosition()
		local size = grid:getContentSize()
		local rect = cc.rect(itemPos.x, itemPos.y, size.width, size.height)

		if cc.rectContainsPoint(rect, pos) then
			return true
		end

	elseif self.dragType == DRAG_TYPE.OUT_BAG then
		for k, equip in ipairs(self.equips) do
			if self:judgeHit(equip, pos) then
				self.endIdx = k
				return true
			end
		end
	end
end

function internal:getItemRect(item)
	local pos = item:getWorldPosition()
	local size = item:getContentSize()
	local rect = cc.rect(pos.x, pos.y, size.width, size.height)
	return rect
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

function internal:setBeganImgVisible(v)
	local beganImg, notHide = self.beganItem:getImage()
	if not beganImg then
		log4misc:warn("item image is nil")
	end

	if notHide then -- getImage返回这个值, 不隐藏图片
		return
	end

	beganImg:setVisible(v)
end

function internal:judgeDragOrScroll(p)
	local dragMove, scrollMove
	local dirc = self.gridview:getDirection()

	if dirc == ccui.ListViewDirection.vertical then
		dragMove = math.abs(p.x - self.beganPos.x)
		scrollMove = math.abs(p.y - self.beganPos.y)
	elseif dirc == ccui.ListViewDirection.horizontal then
		dragMove = math.abs(p.y - self.beganPos.y)
		scrollMove = math.abs(p.x - self.beganPos.x)
	end

	if dragMove > (scrollMove / 5) then
		self.gridview:setTouchEnabled(false)
	else
		self.isScroll = true
		self:setBeganImgVisible(true)
		self.drag:setOpacity(0)
	end
end