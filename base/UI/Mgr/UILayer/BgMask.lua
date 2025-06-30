module(..., package.seeall)


class = objectlua.Object:subclass()

function class:initialize(layerMgr)
	super.initialize(self)
	self.layerMgr = layerMgr
end

-- 为了让弹出窗口的半透区域颜色不重叠
-- 每次只显示最上层背景
function class:addWindow(layer)
	local curTopLayer = self.layerMgr:getTopLayer()
	if curTopLayer then
		curTopLayer:removeBgMask()
	end
	layer:addBgMask()
end

function class:delWindow(layer)
	local curTopLayer = self.layerMgr:getTopLayer()
	if curTopLayer then
		curTopLayer:addBgMask()
	end
end

