module (..., package.seeall)

prototype = Controller.prototype:subclass()

local RESULT_ROW = 5
local RESULT_COL = 20
local DALU_ROW = 6
local DALU_COL = 32
local OTHER_ROW = 3
local OTHER_COL = 16

local MATH_CEIL = math.ceil
local MATH_FLOOR = math.floor

local SHOW_INDEX = Enum
{
	"TYPE_RESULT",
	"TYPE_DALU",
	--"TYPE_DAYANZAI",
	--"TYPE_XIAOLU",
	--"TYPE_YUEYOU"
}

local SpriteRes = {
	"resource/Dantiao/csbimages/img_Diamond.png",
	"resource/Dantiao/csbimages/img_Club.png",
	"resource/Dantiao/csbimages/img_Heart.png",
	"resource/Dantiao/csbimages/img_Spade.png",
	"resource/Dantiao/csbimages/img_Joker.png",
}

local CircleRes = {
	"resource/Dantiao/csbimages/img_DiamondOpacity.png",
	"resource/Dantiao/csbimages/img_ClubOpacity.png",
	"resource/Dantiao/csbimages/img_HeartOpacity.png",
	"resource/Dantiao/csbimages/img_SpadeOpacity.png",
	"resource/Dantiao/csbimages/img_JokerOpacity.png",
}
--[[
local SmallCircleRes = {
	"resource/Dantiao/csbimages/ResultDetails/blue_s.png",
	"resource/Dantiao/csbimages/ResultDetails/red_s.png",
}

local PointRes = {
	"resource/Dantiao/csbimages/ResultDetails/blue_point.png",
	"resource/Dantiao/csbimages/ResultDetails/red_point.png",
}

local LineRes = {
	"resource/Dantiao/csbimages/ResultDetails/blue_l.png",
	"resource/Dantiao/csbimages/ResultDetails/red_l.png",
}
]]
function prototype:enter()
	self.rootNode:setVisible(false)
	self.pos = cc.p(self.rootNode:getPosition())
	self.size = self.imgBg:getContentSize()
	self.loadingSize = self.loadingbarSpade:getContentSize()

	self.imgBg:addTouchEventListener(bind(self.onTouch, self))

	local value = tonumber(db.var:getUsrVar("Dantiao_result_details"))
	self:setAutoOpen(value)

	--龙虎结果、大路、大眼仔、小路、曱甴路
	self.resultSprites = {self.imgResult_1}
	self.daluSprites = {self.imgDalu_1}
	--[[self.dayanSprites = {self.imgDayan_1}
	self.xiaoluSprites = {self.imgXiaolu_1}
	self.yueyouSprites = {self.imgYueyou_1}]]
	self.daluText = {}

	self.startPos = {
		cc.p(self.imgResult_1:getPosition()),
		cc.p(self.imgDalu_1:getPosition()),
		--[[cc.p(self.imgDayan_1:getPosition()),
		cc.p(self.imgXiaolu_1:getPosition()),
		cc.p(self.imgYueyou_1:getPosition()),]]
	}
end

function prototype:clearStates()
	for i, v in ipairs(self.resultSprites) do
		v:setVisible(false)
	end

	for i, v in ipairs(self.daluSprites) do
		v:setVisible(false)
	end

	--[[for i, v in ipairs(self.xiaoluSprites) do
		v:setVisible(false)
	end

	for i, v in ipairs(self.yueyouSprites) do
		v:setVisible(false)
	end

	for i, v in ipairs(self.dayanSprites) do
		v:setVisible(false)
	end

	for i, v in ipairs(self.daluText) do
		v:setVisible(false)
	end]]
end

function prototype:initData(sixtySideResult)
	self:clearStates()
	if not sixtySideResult or #sixtySideResult == 0 then
		return
	end

	self:updateResultData(sixtySideResult)
	self:updateDaluData(sixtySideResult)
	--[[self:updateDayanzaiData()
	self:updateXiaoluData()
	self:updateYueyouData()]]
end

function prototype:refreshData(sixtySideResult,isMing)
	isMing =isMing or false
	if not sixtySideResult or #sixtySideResult == 0 then
		self:clearStates()
		return
	end

	self:updateResultData(sixtySideResult, true)
	self:updateDaluData(sixtySideResult, true)
	--[[self:updateDayanzaiData(true)
	self:updateXiaoluData(true)
	self:updateYueyouData(true)]]

	if isMing == false and self.isAutoOpen == 1 then
		self:show()
	end
end

--右下角结果
function prototype:updateResultData(sidesDesc, bAction)
	bAction = bAction or false
	local row = 0
	local col = 0
	local pos = self.startPos[SHOW_INDEX.TYPE_RESULT]
	local sprite
	local resultNum = #sidesDesc	
	local totalNum = {0, 0, 0, 0,0}
	for i, v in ipairs(sidesDesc) do
		row = i % RESULT_ROW
		col = MATH_CEIL(i / RESULT_ROW)
		if row == 0 then
			row = RESULT_ROW
		end
		
		if i > #self.resultSprites then
			sprite = self.resultSprites[1]:clone()
			sprite:setPosition(pos.x + (col-1)*43.5, pos.y - (row-1)*42)
			self.imgPop:addChild(sprite)

			table.insert(self.resultSprites, sprite)
		else				
			sprite = self.resultSprites[i]
			sprite:setVisible(true)
		end

		sprite:loadTexture(SpriteRes[v[1]])
		totalNum[v[1]] = totalNum[v[1]] + 1

		local icon = sprite:getChildByTag(100)
		if icon then
			icon:removeFromParent(true)
		end
		--是否明牌
		if v[2] then
			icon = cc.Sprite:create("resource/Dantiao/csbimages/iconMing_1.png")
			icon:setPosition(17, 17)
			sprite:addChild(icon, 1, 100)
		end

	end

	self.txtDiamondNum:setString(totalNum[1])
	self.txtClubNum:setString(totalNum[2])
	self.txtHeartNum:setString(totalNum[3])
	self.txtSpadeNum:setString(totalNum[4])
	self.txtJokerNum:setString(totalNum[5])
	self.txtGroupNum:setString("局数" .. resultNum)

	local percentDiamond = MATH_FLOOR(totalNum[1] / resultNum * 100)
	self.txtPercentDiamond:setString(percentDiamond .. "%")
	self.loadingbarDiamond:setPercent(percentDiamond)
	local x1, y1 = self.txtPercentDiamond:getPosition()
	local x2, y2 = self.loadingbarDiamond:getPosition()
	self.txtPercentDiamond:setPosition(x2 - self.loadingSize.width * (percentDiamond/100), y1)
	--[[if percentDiamond<6 then
		self.txtPercentDiamond:setVisible(false)
	end]]

	local percentClub = MATH_FLOOR(totalNum[2] / resultNum * 100)
	self.txtPercentClub:setString(percentClub .. "%")
	self.loadingbarClub:setPercent(percentClub)
	local x1, y1 = self.txtPercentClub:getPosition()
	local x2, y2 = self.loadingbarClub:getPosition()
	self.txtPercentClub:setPosition(x2 + self.loadingSize.width * (percentClub/100), y1)
	--[[if percentClub<6 then
		self.txtPercentClub:setVisible(false)
	end]]

	local percentHeart = MATH_FLOOR(totalNum[3] / resultNum * 100)
	self.txtPercentHeart:setString(percentHeart .. "%")
	self.loadingbarHeart:setPercent(percentHeart)
	local x1, y1 = self.txtPercentHeart:getPosition()
	local x2, y2 = self.loadingbarHeart:getPosition()
	self.txtPercentHeart:setPosition(x2 - self.loadingSize.width * (percentHeart/100), y1)
	--[[if percentHeart<6 then
		self.txtPercentHeart:setVisible(false)
	end]]

	local percentSpade = MATH_FLOOR(totalNum[4] / resultNum * 100)
	self.txtPercentSpade:setString(percentSpade .. "%")
	self.loadingbarSpade:setPercent(percentSpade)
	local x1, y1 = self.txtPercentSpade:getPosition()
	local x2, y2 = self.loadingbarSpade:getPosition()
	self.txtPercentSpade:setPosition(x2 + self.loadingSize.width * (percentSpade/100), y1)
	--[[if percentSpade<6 then
		self.txtPercentSpade:setVisible(false)
	end]]
	--self.imgText:setPosition(x2 + self.loadingSize.width * percent/100 + 30, y1)
	local spriteNum = #self.resultSprites
	if resultNum < spriteNum then
		for i = resultNum+1, spriteNum do
			self.resultSprites[i]:setVisible(false)
		end
	end

	if bAction then
		sprite = self.resultSprites[resultNum]
		local seq = cc.Sequence:create(cc.FadeOut:create(0.1), cc.DelayTime:create(0.3), cc.FadeIn:create(0.1), cc.DelayTime:create(0.3))
		sprite:runAction(cc.Repeat:create(seq, 3))
	end
end

--大路图
function prototype:updateDaluData(sidesDesc, bAction)
	bAction = bAction or false
	local row = 1
	local col = 1
	local pos = self.startPos[SHOW_INDEX.TYPE_DALU]
	local sprite
	local lastWidget
	local index = 1
	local lastSide = 0
	local txtNum = 0

	--记录大路数据的行和列，其他表需要用到
	--self.daluChartData = {0}

	local spriteNum = 0
	for i, side in ipairs(sidesDesc) do
		if i > 1 then
			if side[1] == lastSide then
				row = row + 1      --行
				if row >6 then
					col = col + 1      --列
					row = 1
				end
			else
				col = col + 1      --列
				row = 1
			end	
		end

		-- log("i:"..i..", row : "..row..", col : "..col)

		if index > #self.daluSprites then
			sprite = self.daluSprites[1]:clone()				
			self.imgPop:addChild(sprite)
			table.insert(self.daluSprites, sprite)
		else				
			sprite = self.daluSprites[index]
			sprite:setVisible(true)
		end

		sprite:setTag(col)

		if row > 6 then
			--超过好行数，在当前行往右移动
			sprite:setPosition(pos.x + (col-1 + row-6)*27.25, pos.y - (6-1)*27)
		else
			sprite:setPosition(pos.x + (col-1)*27.25, pos.y - (row-1)*27)
		end
		sprite:loadTexture(CircleRes[side[1]])

		lastWidget = sprite
		index = index + 1
		lastSide = side[1]

		--self.daluChartData[col] = row

		local icon = sprite:getChildByTag(100)
		if icon then
			icon:removeFromParent(true)
		end
		--是否明牌
		if side[2] then
			icon = cc.Sprite:create("resource/Dantiao/csbimages/iconMing_2.png")
			icon:setPosition(14, 14)
			sprite:addChild(icon, 1, 100)
		end

		spriteNum = spriteNum + 1
		
	end
	
	--判断是否超出表格，超出往左移动
	if col > DALU_COL then
		local offLeftCol = col - DALU_COL
		local x = 0 
		local y = 0	
		for i = 1, spriteNum do
			sprite = self.daluSprites[i]
			if (sprite:getTag() - offLeftCol) <= 0 then
				sprite:setVisible(false)
			else
				x, y = sprite:getPosition()
				sprite:setPositionX(x - offLeftCol*27.25)
			end
		end
	end

	if spriteNum < #self.daluSprites then
		for i = spriteNum+1, #self.daluSprites do
			self.daluSprites[i]:setVisible(false)
		end
	end

	if txtNum < #self.daluText then
		for i = txtNum+1, #self.daluText do
			self.daluText[i]:setVisible(false)
		end
	end

	if bAction and lastWidget then
		local seq = cc.Sequence:create(cc.FadeOut:create(0.1), cc.DelayTime:create(0.3), cc.FadeIn:create(0.1), cc.DelayTime:create(0.3))
		lastWidget:runAction(cc.Repeat:create(seq, 3))
	end
end

function prototype:onBtnAutoOpenClick()
	if self.isAutoOpen == 0 then
		self:setAutoOpen(1)
	else
		self:setAutoOpen(0)
	end

	db.var:setUsrVar("Dantiao_result_details", self.isAutoOpen)
end

function prototype:setAutoOpen(value)
	if value == nil then
		value = 1
	end

	self.isAutoOpen = value
	if self.isAutoOpen == 1 then
		self.imgAutoOpen:loadTexture("resource/Dantiao/csbimages/ResultDetails/autoOpen_1.png")
	else
		self.imgAutoOpen:loadTexture("resource/Dantiao/csbimages/ResultDetails/autoOpen_2.png")
	end
end

function prototype:isAutoOpen()
	return self.isAutoOpen
end

function prototype:show()
	if self.rootNode:isVisible() then
		return
	end

	self.rootNode:setPosition(self.pos.x, self.pos.y + self.size.height + 20)
	self.rootNode:setVisible(true)
	self.rootNode:runAction(cc.MoveTo:create(0.5, self.pos))
end

function prototype:hide()
	if self.rootNode:isVisible() == false then
		return
	end

	self.rootNode:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(self.pos.x, self.pos.y + self.size.height + 20)), cc.CallFunc:create(function() 
		self.rootNode:setVisible(false)
	end)))
end

function prototype:autoHide()
	if self.isAutoOpen == 1 then 
		self:hide()
	end
end

function prototype:onBtnCloseTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then 
		self:hide()
	end
end

function prototype:onTouch(sender, event)
	if event == ccui.TouchEventType.began then
		-- log("btn touchBeg")
		self.touchBeganPos = sender:getTouchBeganPosition()

	elseif event == ccui.TouchEventType.moved then
		-- log("btn touchMove")
		local pos = sender:getTouchMovePosition()

	elseif event == ccui.TouchEventType.ended then
		-- log("btn touchEnd")
		local pos = sender:getTouchEndPosition()
		if self.touchBeganPos and (pos.y-self.touchBeganPos.y) > 100 then
			self:hide()
		end

	elseif event == ccui.TouchEventType.canceled then
		-- log("btn touchCanl")
	end
end
