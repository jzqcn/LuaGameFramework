
module (..., package.seeall)


function load(_, effectId, node, lastFrameCb, key)
	local effNode = EffectNode:create(effectId)
	if not effNode then 
		return nil
	end

	if node then
		node:addChild(effNode)
		effNode:setNormalizedPosition(cc.p(0.5, 0.5))
	end

	effNode:setLastFrameCallFunc(function(id)
			if lastFrameCb then
					lastFrameCb(id, key)
			end
			effNode:removeFromParent(true)
		end)

	return effNode
end

function loadAndRun(_, effectId, node, lastFrameCb, loop, key)
	local effNode = load(_, effectId, node, lastFrameCb, key)
	if not effNode then 
		return nil
	end
	
	effNode:setLastFrameCallFunc(function(id)
			if lastFrameCb then
				lastFrameCb(id, key)
			end
			if not loop then
				effNode:removeFromParent(true)
			else
				effNode:play(0, false)
			end
		end)

	effNode:play(0, false)
	return effNode
end



