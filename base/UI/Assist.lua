
module ("Assist", package.seeall)

require "UI.Assist.GrayColorAssist"
require "UI.Assist.TouchAssist"
require "UI.Assist.TextFieldAssist"
require "UI.Assist.ShaderAssist"
require "UI.Assist.NumberFormatAssist"
require "UI.Assist.BagDragAssist"
require "UI.Assist.ItemDragAssist"
require "UI.Assist.RichTextAssist"
require "UI.Assist.FlyCoinAssist"

--@todo not use
require "UI.Assist.StringAssist"
require "UI.Assist.ColorStyleAssist"
require "UI.Assist.EditAssist"
require "UI.Assist.TTFAssist"
require "UI.Assist.RichTextAssist"
require "UI.Assist.PerformAssist"

function translatePos(_, fromNode, toNode, pos)
	local computeNode = fromNode
	if nil == pos then
		local x, y = fromNode:getPosition()
		pos = cc.p(x, y)
		computeNode = fromNode:getParent()
		assert(computeNode)
	end

    local worldPos = computeNode:convertToWorldSpace(pos)
    return toNode:convertToNodeSpace(worldPos)
end

function getWorldPos(_, node)
    local parent = node:getParent()
    assert(parent ~= nil)
    return parent:convertToWorldSpace(cc.p(node:getPosition()))
end

function getNodePosAR(_, node)
	local pos = cc.p(node:getPosition())
	local anchor = node:getAnchorPoint()
	local size = node:getContentSize()
	--获取世界坐标才准确
	local parent = node:getParent()
    assert(parent ~= nil)
    pos = parent:convertToWorldSpace(cc.p(node:getPosition()))

	local posZero = {x = pos.x - size.width * anchor.x,
					 y = pos.y - size.height * anchor.y}
	return posZero, size, anchor
end

function centerNode(_, node, parent)
	local size = parent:getContentSize()
	local sizeChild = node:getContentSize()

	local pos
	if sizeChild.width == 0 or sizeChild.height == 0 then
		pos = cc.p(size.width/2, size.height/2 )
	else
		local anchor = node:getAnchorPoint()
		if anchor.x == 0 and anchor.y == 0 then
			pos = cc.p((size.width - sizeChild.width)/2, (size.height - sizeChild.height)/2)
		else
			pos = cc.p(size.width/2, size.height/2 )
		end
	end
	node:setPosition(pos)
end
