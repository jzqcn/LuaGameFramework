module (..., package.seeall)

class = objectlua.Object:subclass()


function class:load(ccsname, node)
	local ani = ui.loader:loadAsNode(ccsname)

	if node then
		node:addChild(ani)
		Assist:centerNode(ani, node)
	end

	return ani
end

function class:loadAndRun(ccsname, node, loop)
	local ani = self:load(ccsname, node)
	if not loop then
		ani:setLastFrameCallFunc(function()
				ani:removeFromParent(true)
			end)
	end

	ani:playActionTime(0, loop or false)
	return ani
end



