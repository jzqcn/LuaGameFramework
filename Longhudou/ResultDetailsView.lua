module (..., package.seeall)

prototype = Controller.prototype:subclass()

local RESULT_ROW = 6
local RESULT_COL = 10
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
	"TYPE_DAYANZAI",
	"TYPE_XIAOLU",
	"TYPE_YUEYOU"
}

local SpriteRes = {
	"resource/Longhudou/csbimages/img_long.png",
	"resource/Longhudou/csbimages/img_hu.png",
	"resource/Longhudou/csbimages/img_he.png",
}

local CircleRes = {
	"resource/Longhudou/csbimages/ResultDetails/blue.png",
	"resource/Longhudou/csbimages/ResultDetails/red.png",
	"resource/Longhudou/csbimages/ResultDetails/green.png",
}

local SmallCircleRes = {
	"resource/Longhudou/csbimages/ResultDetails/blue_s.png",
	"resource/Longhudou/csbimages/ResultDetails/red_s.png",
}

local PointRes = {
	"resource/Longhudou/csbimages/ResultDetails/blue_point.png",
	"resource/Longhudou/csbimages/ResultDetails/red_point.png",
}

local LineRes = {
	"resource/Longhudou/csbimages/ResultDetails/blue_l.png",
	"resource/Longhudou/csbimages/ResultDetails/red_l.png",
}

function prototype:enter()
	self.rootNode:setVisible(false)
	self.pos = cc.p(self.rootNode:getPosition())
	self.size = self.imgBg:getContentSize()
	self.loadingSize = self.loadingbarLeft:getContentSize()

	self.imgBg:addTouchEventListener(bind(self.onTouch, self))

	local value = tonumber(db.var:getUsrVar("Longhudou_result_details"))
	self:setAutoOpen(value)

	--龙虎结果、大路、大眼仔、小路、曱甴路
	self.resultSprites = {self.imgResult_1}
	self.daluSprites = {self.imgDalu_1}
	self.dayanSprites = {self.imgDayan_1}
	self.xiaoluSprites = {self.imgXiaolu_1}
	self.yueyouSprites = {self.imgYueyou_1}
	self.daluText = {}

	self.startPos = {
		cc.p(self.imgResult_1:getPosition()),
		cc.p(self.imgDalu_1:getPosition()),
		cc.p(self.imgDayan_1:getPosition()),
		cc.p(self.imgXiaolu_1:getPosition()),
		cc.p(self.imgYueyou_1:getPosition()),
	}
end

function prototype:clearStates()
	for i, v in ipairs(self.resultSprites) do
		v:setVisible(false)
	end

	for i, v in ipairs(self.daluSprites) do
		v:setVisible(false)
	end

	for i, v in ipairs(self.xiaoluSprites) do
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
	end
end

function prototype:initData(sixtySideResult)
	self:clearStates()
	if not sixtySideResult or #sixtySideResult == 0 then
		return
	end

	self:updateResultData(sixtySideResult)
	self:updateDaluData(sixtySideResult)
	self:updateDayanzaiData()
	self:updateXiaoluData()
	self:updateYueyouData()
end

function prototype:refreshData(sixtySideResult, isMing)
	isMing = isMing or false
	if not sixtySideResult or #sixtySideResult == 0 then
		self:clearStates()
		return
	end

	self:updateResultData(sixtySideResult, true)
	self:updateDaluData(sixtySideResult, true)
	self:updateDayanzaiData(true)
	self:updateXiaoluData(true)
	self:updateYueyouData(true)

	if isMing == false and self.isAutoOpen == 1 then
		self:show()
	end
end

--右下角龙虎结果
function prototype:updateResultData(sidesDesc, bAction)
	bAction = bAction or false
	local row = 0
	local col = 0
	local pos = self.startPos[SHOW_INDEX.TYPE_RESULT]
	local sprite
	local resultNum = #sidesDesc	
	local totalNum = {0, 0, 0, 0}
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
			icon = cc.Sprite:create("resource/Longhudou/csbimages/iconMing_1.png")
			icon:setPosition(17, 17)
			sprite:addChild(icon, 1, 100)

			totalNum[4] = totalNum[4] + 1
		end

	end

	self.txtLongNum:setString("龙" .. totalNum[1])
	self.txtHuNum:setString("虎" .. totalNum[2])
	self.txtHeNum:setString("和" .. totalNum[3])
	self.txtMingNum:setString("明" .. totalNum[4])
	self.txtGroupNum:setString("局数" .. resultNum)

	local percent = MATH_FLOOR(totalNum[1] / (totalNum[1] + totalNum[2]) * 100)
	self.txtPercentLeft:setString(percent .. "%")
	self.loadingbarLeft:setPercent(percent)
	self.txtPercentRight:setString((100 - percent) .. "%")
	self.loadingbarLeft:setPercent(percent)
	self.loadingbarRight:setPercent(100-percent)

	local x1, y1 = self.txtPercentLeft:getPosition()
	local x2, y2 = self.loadingbarLeft:getPosition()
	self.txtPercentLeft:setPosition(x2 + self.loadingSize.width/2 * percent/100, y1)

	self.imgText:setPosition(x2 + self.loadingSize.width * percent/100 + 30, y1)

	x1, y1 = self.txtPercentRight:getPosition()
	x2, y2 = self.loadingbarRight:getPosition()
	self.txtPercentRight:setPosition(x2 - self.loadingSize.width/2 * (100-percent)/100, y1)

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
	local heNum = 0
	local txtNum = 0

	--记录大路数据的行和列，其他表需要用到
	self.daluChartData = {0}

	local spriteNum = 0
	for i, side in ipairs(sidesDesc) do
		if side[1] == 3 then
			--和
			-- log("he  index : "..i..", row : "..row..", col : "..col)
			if i == 1 or (i > 1 and sidesDesc[i-1][1] ~= side[1]) then
				txtNum = txtNum + 1
			end
			heNum = heNum + 1
			-- log("txtNum:" .. txtNum .. ", heNum:" .. heNum .. ", " .. #self.daluText)

			if txtNum > #self.daluText then
				sprite = cc.Label:createWithTTF(tostring(heNum), "resource/fonts/FZY4JW.TTF", 24)
				sprite:setScale(0.7)
				sprite:setTextColor(cc.c3b(6, 170, 6))
				sprite:setAnchorPoint(cc.p(0.5, 0.5))
				self.imgPop:addChild(sprite)

				table.insert(self.daluText, sprite)			
			else
				sprite = self.daluText[txtNum]
				sprite:setString(tostring(heNum))
				sprite:setVisible(true)
			end

			sprite:setTag(col)

			-- if row > 6 then
			-- 	--超过好行数，在当前行往右移动
			-- 	sprite:setPosition(pos.x + (col-1 + row-6)*27.25, pos.y - (6-1)*27 - 2)
			-- else
			-- 	sprite:setPosition(pos.x + (col-1)*27.25, pos.y - (row-1)*27 - 2)
			-- end
			sprite:setPosition(pos.x + (col-1)*27.25, pos.y - (row-1)*27 - 2)
		else
			heNum = 0
			if i > 1 then
				if side[1] == lastSide then
					row = row + 1			
				else
					col = col + 1
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

			if row > 6 then
				row = 1
				col = col + 1
				--超过好行数，在当前行往右移动
				-- sprite:setPosition(pos.x + (col-1 + row-6)*27.25, pos.y - (6-1)*27)
			-- else
				-- sprite:setPosition(pos.x + (col-1)*27.25, pos.y - (row-1)*27)
			end

			sprite:setTag(col)

			sprite:setPosition(pos.x + (col-1)*27.25, pos.y - (row-1)*27)

			sprite:loadTexture(CircleRes[side[1]])

			lastWidget = sprite
			index = index + 1
			lastSide = side[1]

			self.daluChartData[col] = row

			local icon = sprite:getChildByTag(100)
			if icon then
				icon:removeFromParent(true)
			end
			--是否明牌
			if side[2] then
				icon = cc.Sprite:create("resource/Longhudou/csbimages/iconMing_2.png")
				icon:setPosition(10, 10)
				sprite:addChild(icon, 1, 100)
			end

			spriteNum = spriteNum + 1
		end
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

--大眼仔
function prototype:updateDayanzaiData(bAction)
	local bStart = false
	local row = 1
	local col = 1
	local data = self.daluChartData
	local bRed = false
	local lastState = false
	local index = 1
	local sprite
	local pos = self.startPos[SHOW_INDEX.TYPE_DAYANZAI]
	for i, v in ipairs(data) do
		if not bStart then
			if i >= 2 and v >= 2 then
				--第二行第二列开始算
				bStart = true
			elseif i == 3 then
				bStart = true
			end
			-- log("row : " .. v .. ", col : " .. i)
		end

		if bStart then
			--每一列的数据	
			for r = (i==2 and 2 or 1), v do
				bRed = false
				-- log("col : " .. i ..", row : " .. r)
				if r == 1 then 
					--判断是否齐整，前列和前前列，每列红和蓝的个数是否相等
					if data[i-1] == data[i-2] then
						bRed = true
					end
				else
					--判断碰点 前一列同一行有数值
					if data[i-1] >= r then
						bRed = true
					elseif r - data[i-1] == 1 then
						bRed = false			
					else
						--判断重复 非碰点后，前一列没有数值
						bRed = true			
					end
				end
				
				if index > #self.dayanSprites then
					sprite = self.dayanSprites[1]:clone()				
					self.imgPop:addChild(sprite)

					table.insert(self.dayanSprites, sprite)
				else				
					sprite = self.dayanSprites[index]
					sprite:setVisible(true)
				end

				if bRed then
					sprite:loadTexture(SmallCircleRes[2])
				else
					sprite:loadTexture(SmallCircleRes[1])
				end

				if index > 1 then
					if lastState == bRed then
						row = row + 1
					else
						row = 1
						col = col + 1
					end
				end

				if row > 6 then
					row = 1
					col = col + 1
					--超过好行数，在当前行往右移动
					-- sprite:setPosition(pos.x + (col-1 + row-6)*13.56, pos.y - (6-1)*13.56)
				-- else
					-- sprite:setPosition(pos.x + (col-1)*13.56, pos.y - (row-1)*13.56)
				end

				sprite:setTag(col)

				sprite:setPosition(pos.x + (col-1)*13.56, pos.y - (row-1)*13.56)

				lastState = bRed
				index = index + 1
			end
		end
	end

	--判断是否超出表格，超出往左移动
	if col > DALU_COL then
		local offLeftCol = col - DALU_COL
		local x = 0 
		local y = 0	
		for i = 1, index-1 do
			sprite = self.dayanSprites[i]
			if sprite:getTag() - offLeftCol <= 0 then
				sprite:setVisible(false)
			else
				x, y = sprite:getPosition()
				sprite:setPositionX(x - offLeftCol*13.56)
			end
		end
	end

	if index <= #self.dayanSprites then
		for i = index, #self.dayanSprites do
			self.dayanSprites[i]:setVisible(false)
		end
	end

	if bAction and sprite then
		local seq = cc.Sequence:create(cc.FadeOut:create(0.1), cc.DelayTime:create(0.3), cc.FadeIn:create(0.1), cc.DelayTime:create(0.3))
		sprite:runAction(cc.Repeat:create(seq, 3))
	end
end

--小路
function prototype:updateXiaoluData(bAction)
	local bStart = false
	local row = 1
	local col = 1
	local data = self.daluChartData
	local bRed = false
	local lastState = false
	local index = 1
	local sprite
	local pos = self.startPos[SHOW_INDEX.TYPE_XIAOLU]
	for i, v in ipairs(data) do
		if not bStart then
			if i >= 3 and v >= 2 then
				--第二行第二列开始算
				bStart = true
			elseif i == 4 then
				bStart = true
			end
			-- log("row : " .. v .. ", col : " .. i)
		end

		if bStart then
			--每一列的数据	
			for r = (i==3 and 2 or 1), v do
				bRed = false
				-- log("col : " .. i ..", row : " .. r)
				if r == 1 then 
					--判断是否齐整，前列和前前列，每列红和蓝的个数是否相等
					if data[i-1] == data[i-3] then
						bRed = true
					end
				else
					--判断碰点 前一列同一行有数值
					if data[i-2] >= r then
						bRed = true
					elseif r - data[i-2] == 1 then
						bRed = false			
					else
						--判断重复 非碰点后，前一列没有数值
						bRed = true			
					end
				end
				
				if index > #self.xiaoluSprites then
					sprite = self.xiaoluSprites[1]:clone()				
					self.imgPop:addChild(sprite)

					table.insert(self.xiaoluSprites, sprite)
				else				
					sprite = self.xiaoluSprites[index]
					sprite:setVisible(true)
				end

				if bRed then
					sprite:loadTexture(PointRes[2])
				else
					sprite:loadTexture(PointRes[1])
				end

				if index > 1 then
					if lastState == bRed then
						row = row + 1
					else
						row = 1
						col = col + 1
					end
				end

				if row > 6 then
					row = 1
					col = col + 1
					--超过好行数，在当前行往右移动
				-- 	sprite:setPosition(pos.x + (col-1 + row-6)*13.5, pos.y - (6-1)*13.5)
				-- else
				-- 	sprite:setPosition(pos.x + (col-1)*13.5, pos.y - (row-1)*13.5)
				end

				sprite:setTag(col)

				sprite:setPosition(pos.x + (col-1)*13.5, pos.y - (row-1)*13.5)

				lastState = bRed
				index = index + 1
			end
		end
	end

	--判断是否超出表格，超出往左移动
	if col > DALU_COL then
		local offLeftCol = col - DALU_COL
		local x = 0 
		local y = 0	
		for i = 1, index-1 do
			sprite = self.xiaoluSprites[i]
			if sprite:getTag() - offLeftCol <= 0 then
				sprite:setVisible(false)
			else
				x, y = sprite:getPosition()
				sprite:setPositionX(x - offLeftCol*13.5)
			end
		end
	end

	if index <= #self.xiaoluSprites then
		for i = index, #self.xiaoluSprites do
			self.xiaoluSprites[i]:setVisible(false)
		end
	end

	if bAction and sprite then
		local seq = cc.Sequence:create(cc.FadeOut:create(0.1), cc.DelayTime:create(0.3), cc.FadeIn:create(0.1), cc.DelayTime:create(0.3))
		sprite:runAction(cc.Repeat:create(seq, 3))
	end
end

--曱甴路
function prototype:updateYueyouData(bAction)
	local bStart = false
	local row = 1
	local col = 1
	local data = self.daluChartData
	local bRed = false
	local lastState = false
	local index = 1
	local sprite
	local pos = self.startPos[SHOW_INDEX.TYPE_YUEYOU]
	for i, v in ipairs(data) do
		if not bStart then
			if i >= 4 and v >= 2 then
				--第二行第二列开始算
				bStart = true
			elseif i == 5 then
				bStart = true
			end
			-- log("row : " .. v .. ", col : " .. i)
		end

		if bStart then
			--每一列的数据	
			for r = (i==4 and 2 or 1), v do
				bRed = false
				-- log("col : " .. i ..", row : " .. r)
				if r == 1 then 
					--判断是否齐整，前列和前前列，每列红和蓝的个数是否相等
					if data[i-1] == data[i-4] then
						bRed = true
					end
				else
					--判断碰点 前一列同一行有数值
					if data[i-3] >= r then
						bRed = true
					elseif r - data[i-3] == 1 then
						bRed = false			
					else
						--判断重复 非碰点后，前一列没有数值
						bRed = true			
					end
				end
				
				if index > #self.yueyouSprites then
					sprite = self.yueyouSprites[1]:clone()				
					self.imgPop:addChild(sprite)

					table.insert(self.yueyouSprites, sprite)
				else				
					sprite = self.yueyouSprites[index]
					sprite:setVisible(true)
				end

				if bRed then
					sprite:loadTexture(LineRes[2])
				else
					sprite:loadTexture(LineRes[1])
				end

				if index > 1 then
					if lastState == bRed then
						row = row + 1
					else
						row = 1
						col = col + 1
					end
				end

				if row > 6 then
					row = 1
					col = col + 1
					--超过好行数，在当前行往右移动
				-- 	sprite:setPosition(pos.x + (col-1 + row-6)*13.56, pos.y - (6-1)*13.56)
				-- else
				-- 	sprite:setPosition(pos.x + (col-1)*13.56, pos.y - (row-1)*13.56)
				end

				sprite:setTag(col)

				sprite:setPosition(pos.x + (col-1)*13.56, pos.y - (row-1)*13.56)

				lastState = bRed
				index = index + 1
			end
		end
	end

	--判断是否超出表格，超出往左移动
	if col > DALU_COL then
		local offLeftCol = col - DALU_COL
		local x = 0
		local y = 0
		for i = 1, index-1 do
			sprite = self.yueyouSprites[i]
			if sprite:getTag() - offLeftCol <= 0 then
				sprite:setVisible(false)
			else
				x, y = sprite:getPosition()
				sprite:setPositionX(x - offLeftCol*13.56)
			end
		end
	end

	if index <= #self.yueyouSprites then
		for i = index, #self.yueyouSprites do
			self.yueyouSprites[i]:setVisible(false)
		end
	end

	if bAction and sprite then
		local seq = cc.Sequence:create(cc.FadeOut:create(0.1), cc.DelayTime:create(0.3), cc.FadeIn:create(0.1), cc.DelayTime:create(0.3))
		sprite:runAction(cc.Repeat:create(seq, 3))
	end
end

function prototype:onBtnAutoOpenClick()
	if self.isAutoOpen == 0 then
		self:setAutoOpen(1)
	else
		self:setAutoOpen(0)
	end

	db.var:setUsrVar("Longhudou_result_details", self.isAutoOpen)
end

function prototype:setAutoOpen(value)
	if value == nil then
		value = 1
	end

	self.isAutoOpen = value
	if self.isAutoOpen == 1 then
		self.imgAutoOpen:loadTexture("resource/Longhudou/csbimages/ResultDetails/autoOpen_1.png")
	else
		self.imgAutoOpen:loadTexture("resource/Longhudou/csbimages/ResultDetails/autoOpen_2.png")
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
