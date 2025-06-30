module (..., package.seeall)

prototype = Controller.prototype:subclass()

local Show_Num = 3
local SIDE_TYPE = Enum
{
	"LEFT",
	"RIGHT",
}

function prototype:enter()
	
end

--设置神算子、富豪排行图标
function prototype:setGroupType(sideType)
	local name = ""
	for i = 1, Show_Num do
		name = "nodePlayer_"..i
		self[name]:setPlayerInfo()
		-- self[name]:setSideType(sideType)

		if sideType == SIDE_TYPE.LEFT then
			self[name]:setPlayerType(false, i)
		else
			if i == 1 then
				self[name]:setPlayerType(true)
			else
				self[name]:setPlayerType(false, Show_Num + i - 1)
			end
		end
	end
end

function prototype:getGroupItems()
	return {self.nodePlayer_1, self.nodePlayer_2, self.nodePlayer_3}
end

--设置玩家头像、ID等信息
-- function prototype:setGroupData(playerList)
-- 	if not playerList then
-- 		return
-- 	end

-- 	for i, v in ipairs(playerList) do
-- 		self["nodePlayer_"..i]:setPlayerInfo(v)
-- 	end
-- end

-- function prototype:doSettlement(info, index, currentSidesDesc)
-- 	log("doSettlement:: index == " .. index)
-- 	self["nodePlayer_"..index]:doSettlement(info, currentSidesDesc)
-- end

function prototype:getBetCoinStartPos(index)
	-- local pos = self["nodePlayer_" .. index]:getWorldPosition()
	
	-- local pos = self.rootNode:getWorldPosition()
	local pos = cc.p(self.rootNode:getPosition())
	local headPos = self["nodePlayer_" .. index]:getHeadPos()
	return cc.pAdd(pos, headPos)
end
