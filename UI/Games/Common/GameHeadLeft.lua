local Hall = require "Model.Hall"
local GameHead = require "Games/Common/GameHead"

module(..., package.seeall)

prototype = GameHead.prototype:subclass()

function prototype:getLabelAnchorPoint()
	return cc.p(0, 0.5)
end

