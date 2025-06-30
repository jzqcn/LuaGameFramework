

module("Assist", package.seeall)


local GRAY_TYPE = 
{
  NONE = 0,
  GRAY = 1,
}

local function _setSingleNodeState(node, state)
  local imgRender = node:getVirtualRenderer()
  if imgRender and imgRender.setState then
    imgRender:setState(state)
  end

  local nodeChilren = node:getChildren() or {}
  for _, child in ipairs(nodeChilren) do
    _setSingleNodeState(child, state)
  end
end

function setNodeGray(_, node)
  _setSingleNodeState(node, GRAY_TYPE.GRAY)
end

function setNodeColorful(_, node)
  _setSingleNodeState(node, GRAY_TYPE.NONE)
end