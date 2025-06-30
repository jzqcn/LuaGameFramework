
module(..., package.seeall)

prototype = Controller.prototype:subclass()

-- local ChipImgType = {
-- 	"resource/csbimages/Games/Common/chip_1.png",
-- 	"resource/csbimages/Games/Common/chip_2.png",
-- 	"resource/csbimages/Games/Common/chip_3.png",
-- 	"resource/csbimages/Games/Common/chip_4.png",
-- 	"resource/csbimages/Games/Common/chip_5.png",
-- }

local CoinImageRes = {
	"resource/csbimages/Hall/moneyIcon.png",
	"resource/csbimages/Hall/moneyIcon.png",
	"resource/csbimages/Hall/goldIcon.png",
}

local ScoreCell = {
	{10, 100, 1000, 10000},
	{100, 1000, 10000, 100000},
	{10, 100, 1000, 10000}
}

local ChipLevel = {
	{10, 100, 1000, 10000, 100000},
	{100, 1000, 10000, 100000, 1000000},
	{10, 100, 1000, 10000, 100000},
}

local CoinNum = {12, 13, 15, 15, 15}

function prototype:enter()
	self.currencyType = Common_pb.Sliver
	self.chip = -1
	self.bitmapChip:setString(0)
	
	for i = 1, 5 do
		self["imgChip_"..i]:setVisible(false)
	end
	-- self.imgRed_1:setVisible(false)
	-- self.imgBlue_1:setVisible(false)
	-- self.imgGreen_1:setVisible(false)

	self.chipTable = 
	{
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
	}
	-- self.chipGreenTab = {}
	-- self.chipBlueTab = {}
	-- self.chipRedTab = {}

	self.flyCoinTab = {}
end

--飞出多少筹码
function prototype:getCoinNum(score)
	local cellvalue = 1
	local scoreCellTab = ScoreCell[self.currencyType]
	for i = 1, #scoreCellTab do
		if score > scoreCellTab[i] then
		  	cellvalue = i + 1
		else
			break
		end
	end

	return CoinNum[cellvalue]
end

function prototype:clear()
	self.chip = 0
	self.bitmapChip:setString(0)
	for _, chips in ipairs(self.chipTable) do
		for i, v in ipairs(chips) do
			v:removeFromParent(true)
		end
	end

	self.chipTable = 
	{
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
	}

	self.flyCoinTab = {}
end

function prototype:setCurrencyType(cur, baseChip)
	if cur == nil then
		return
	end

	self.currencyType = cur
	self.baseChip = baseChip or 100
end

function prototype:updateGameChip()
	-- log("[GameChip::updateGameChip] chip value == "..self.chip)
	self.bitmapChip:setString(Assist.NumberFormat:amount2Hundred(self.chip))

	local chipLevelTab = ChipLevel[self.currencyType]
	if self.baseChip >= 500 then
		chipLevelTab = ChipLevel[2]
	end

	local chipValue = self.chip
	local iNumItem = {0, 0, 0, 0, 0}

	iNumItem[5] = math.floor(chipValue / chipLevelTab[5])
	chipValue = chipValue - iNumItem[5]*chipLevelTab[5]

	iNumItem[4] = math.floor(chipValue / chipLevelTab[4])
	chipValue = chipValue - iNumItem[4]*chipLevelTab[4]

	iNumItem[3] = math.floor(chipValue / chipLevelTab[3])
	chipValue = chipValue - iNumItem[3]*chipLevelTab[3]

	iNumItem[2] = math.floor(chipValue / chipLevelTab[2])

	chipValue = chipValue - iNumItem[2]*chipLevelTab[2]
	iNumItem[1] = math.ceil(chipValue / chipLevelTab[1])

	-- log(iNumItem)

	for i, chips in ipairs(self.chipTable) do
		if #chips > iNumItem[i] then
			local index = iNumItem[i] + 1
			while index <= #chips do
				local itemChip = chips[index]
				itemChip:removeFromParent(true)
				table.remove(chips, index)
			end
		else
			for index = 1, iNumItem[i] do
				if index > #chips then
					local x, y = self["imgChip_"..i]:getPosition()
					local itemChip = self["imgChip_"..i]:clone()
					itemChip:setPosition(x, y + (index-1)*11)
					itemChip:setVisible(true)
					self.rootNode:addChild(itemChip, index)

					chips[#chips + 1] = itemChip
				end
			end
		end
	end
end

function prototype:setChipValue(value, bRefresh)
	if value == nil or value < 0 then
		return
	end

	value = tonumber(value)
	if value == self.chip then
		return
	end
	
	bRefresh = bRefresh or false

	self.chip = value
	if bRefresh then
		self:updateGameChip()
	end
end

function prototype:getMoveAction(startPos, endPos ,inOrOut)
	local pos = cc.p(startPos.x + (endPos.x-startPos.x)/2, startPos.y + (endPos.y-startPos.y)/2 + 100)

	local bezier2 = {
        startPos,
        pos,
        endPos
    }

    local action = cc.BezierTo:create(0.6, bezier2)

    if inOrOut == true then
     	return cc.EaseExponentialOut:create(action)
    else
     	return cc.EaseExponentialIn:create(action)
    end
end

function prototype:uploadChip(value, fromPos, callback)
	local toPos = cc.p(self.imgChip_2:getPosition())
	self:runChipAction(value, fromPos, toPos, true, callback)

	sys.sound:playEffect("COINS_FLY")
end

function prototype:downloadChip(value, toPos, callback)
	local fromPos = cc.p(self.imgChip_2:getPosition())
	self:runChipAction(value, fromPos, toPos, true, callback)

	sys.sound:playEffect("COINS_FLY")
end

function prototype:runChipAction(num, fromPos, toPos, inOrOut, callback)
	num = tonumber(num)
	if num < 0 then
		assert(false)
	end
	
	self.callback = callback

	local coinNum = self:getCoinNum(num)
	for i = 1, coinNum do
		local coinSprite = cc.Sprite:create(CoinImageRes[self.currencyType])
		coinSprite:setPosition(fromPos)
		coinSprite:setVisible(false)

		local delay = cc.DelayTime:create(math.random()*0.3)
		local callFunc = cc.CallFunc:create(function()
              coinSprite:setVisible(true)
              coinSprite:runAction(self:getMoveAction(fromPos, toPos, inOrOut))
            end)
		coinSprite:runAction(cc.Sequence:create(delay, callFunc))

		self.rootNode:addChild(coinSprite, 100 + i)

		self.flyCoinTab[#self.flyCoinTab + 1] = coinSprite
	end

	self.rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
		self:updateGameChip()
		self:clearFlyCoin()
		if self.callback then
			self.callback()
		end
	end)))
end

function prototype:clearFlyCoin()
	for _, v in ipairs(self.flyCoinTab) do
		v:removeFromParent(true)
	end

	self.flyCoinTab = {}
end


