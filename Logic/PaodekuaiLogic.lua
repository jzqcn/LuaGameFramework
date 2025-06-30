module(..., package.seeall)

class = Logic.class:subclass()

local PaoDeKuai_pb = PaoDeKuai_pb

function class:initialize()
	super.initialize(self)

end

function class:sortCards(cardData)
	local function sortFunc(a, b)
		if a.value == b.value then
			return a.color > b.color
		else
			return a.value > b.value
		end
	end

	table.sort(cardData, sortFunc)
end

function class:removeCard(removeList, cardData)
	if removeList == nil or cardData == nil then
		return false
	end

	local iRemoveCount = #removeList
	local iCardCount = #cardData
	if iRemoveCount > iCardCount then
		return false
	end

	local iDeleteCount = 0
	for i = 1, iRemoveCount do
		for j = 1, #cardData do
			if removeList[i] and removeList[i].id == cardData[j].id then
				iDeleteCount = iDeleteCount + 1
				table.remove(cardData, j)
				break
			end
		end
	end
	if iDeleteCount ~= iRemoveCount then
		return false
	end

	return true
end

function class:tableContainsValue(tableData, value)
	if not tableData and #tableData == 0 then
		return false
	end

	for i, v in ipairs(tableData) do
		if v then
			if v.value == value then
				return true
			end
		else
			break
		end
	end

	return false
end

--分析扑克
function class:analyseCardData(cardData, bFourToThree)
	bFourToThree = bFourToThree or false
	--初始化
	local analyseResult = {}
	--炸弹、三条、对子、单牌对应数量
	analyseResult.iFourCount = 0
	analyseResult.iThreeCount = 0
	analyseResult.iDoubleCount = 0
	analyseResult.iSingleCount = 0

	--炸弹(最多4个)、三条（最多5）、对子（最多8）、单牌对应牌值
	analyseResult.fourLogicValues = {false, false, false, false}
	analyseResult.threeLogicValues = {false, false, false, false, false}
	analyseResult.doubleLogicValues = {false, false, false, false, false, false, false, false}
	analyseResult.singleLogicValues = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}

	--不同牌型对应扑克数据
	analyseResult.fourCardDatas = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	analyseResult.threeCardDatas = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	analyseResult.doubleCardDatas = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
	analyseResult.singleCardDatas = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}

	--扑克分析
	local i = 1
	while i <= #cardData do
		--变量定义
		local iSameCount = 1
		local sameCardDatas = {cardData[i], 0, 0, 0}
		local iLogicValue = cardData[i].value

		--获取同牌
		for j = i + 1, #cardData do
			--逻辑对比
			if cardData[j].value ~= iLogicValue then
				break
			end
			--设置扑克
			sameCardDatas[iSameCount + 1] = cardData[j]
			iSameCount = iSameCount + 1
		end

		--保存结果
		if iSameCount == 1 then 		--一张
			analyseResult.singleLogicValues[analyseResult.iSingleCount + 1] = iLogicValue
			analyseResult.singleCardDatas[analyseResult.iSingleCount + 1] = sameCardDatas[1]
			analyseResult.iSingleCount = analyseResult.iSingleCount + 1

		elseif iSameCount == 2 then 			--二张
			analyseResult.doubleLogicValues[analyseResult.iDoubleCount + 1] = iLogicValue
			for k = 1, 2 do
				analyseResult.doubleCardDatas[analyseResult.iDoubleCount*2 + k] = sameCardDatas[k]
			end
			analyseResult.iDoubleCount = analyseResult.iDoubleCount + 1

		elseif iSameCount == 3 then 			--三张
			analyseResult.threeLogicValues[analyseResult.iThreeCount + 1] = iLogicValue
			for k = 1, 3 do
				analyseResult.threeCardDatas[analyseResult.iThreeCount*3 + k] = sameCardDatas[k]
			end
			analyseResult.iThreeCount = analyseResult.iThreeCount + 1

		elseif iSameCount == 4 then 			--四张
			analyseResult.fourLogicValues[analyseResult.iFourCount + 1] = iLogicValue
			for k = 1, 4 do
				analyseResult.fourCardDatas[analyseResult.iFourCount*4 + k] = sameCardDatas[k]
			end
			analyseResult.iFourCount = analyseResult.iFourCount + 1

			if bFourToThree == true then
				analyseResult.threeLogicValues[analyseResult.iThreeCount + 1] = iLogicValue
				for k = 1, 3 do
					analyseResult.threeCardDatas[analyseResult.iThreeCount*3 + k] = sameCardDatas[k]
				end
				analyseResult.iThreeCount = analyseResult.iThreeCount + 1

				analyseResult.singleLogicValues[analyseResult.iSingleCount + 1] = iLogicValue
				analyseResult.singleCardDatas[analyseResult.iSingleCount + 1] = sameCardDatas[4]
				analyseResult.iSingleCount = analyseResult.iSingleCount + 1
			end
		end

		--设置递增
		i = i + iSameCount
	end

	return analyseResult
end

--获取扑克类型
function class:getCardType(cardData)
	local iCardCount = #cardData
	if iCardCount == 0 then
		return -1
	end

	--单牌
	if iCardCount == 1 then
		return PaoDeKuai_pb.SINGLE
	end

	--对子
	if iCardCount == 2 then
		if cardData[1].value == cardData[2].value then
			return PaoDeKuai_pb.ONEPAIR
		end

		return -1
	end

	self:sortCards(cardData)

	--分析扑克
	local analyseResult = self:analyseCardData(cardData, true)	

	--炸弹判断
	if analyseResult.iFourCount == 1 and iCardCount == 4 then
		return PaoDeKuai_pb.BOOM
	end

	--四带三
	if analyseResult.iFourCount == 1 and iCardCount > 4 then
		local iSingleCount = iCardCount - 4
		if iSingleCount == 3 then
			return PaoDeKuai_pb.FOURWITHTHREE
		elseif iSingleCount == 2 then
			return PaoDeKuai_pb.FOURWITHTHREE
		elseif iSingleCount == 1 then
			--四带一当做三带二处理
			return PaoDeKuai_pb.FULLHOUSE
		else
			
		end
	end

	--三牌判断
	if analyseResult.iThreeCount > 0 then
		--连牌判断(2不能加入飞机)
		local bSeriesCard = false
		if analyseResult.iThreeCount == 1 or analyseResult.threeLogicValues[1] ~= 15 then
			local iMaxThreeLine = 1
			local iThreeLine = 1
			-- local iThreeLineIndex = 1
			local i = 1
			while i < analyseResult.iThreeCount do
				if analyseResult.threeLogicValues[i] - analyseResult.threeLogicValues[i + 1] ~= 1 then
					iThreeLine = 1
					-- break
				else
					iThreeLine = iThreeLine + 1
				end

				if iMaxThreeLine < iThreeLine then
					iMaxThreeLine = iThreeLine
				end

				-- log("i:"..i..", iThreeLine:"..iThreeLine..", iMaxThreeLine:"..iMaxThreeLine)

				i = i + 1				
			end

			-- log("iMaxThreeLine:"..iMaxThreeLine)

			if iMaxThreeLine <= analyseResult.iThreeCount then
				bSeriesCard = true
			end

			--带牌判断
			if bSeriesCard == true then
				--剩余单牌数
				local iSingleCount = iCardCount - iMaxThreeLine*3 --analyseResult.iThreeCount*3
				--需带牌数（默认三带二）
				local iNeedWithCount = iMaxThreeLine*2 --analyseResult.iThreeCount * 2
				--类型分析 飞机、单个
				--if analyseResult.iThreeCount > 1 then
				if iMaxThreeLine > 1 then
					if iSingleCount <= iNeedWithCount then
						return PaoDeKuai_pb.PLANE
					else
						return -1
					end
				else
					if iSingleCount == 0 then
						return PaoDeKuai_pb.HOUSE
					elseif iSingleCount == iNeedWithCount then
						return PaoDeKuai_pb.FULLHOUSE
					elseif iSingleCount < iNeedWithCount then
						return PaoDeKuai_pb.ONEHOUSE
					else
						return -1
					end
				end
			end
		end
	end

	--两连判断
	if analyseResult.iDoubleCount > 1 then
		--连牌判断
		local bSeriesCard = false
		if analyseResult.doubleLogicValues[1] ~= 15 then
			local i = 1
			while i < analyseResult.iDoubleCount do
				if analyseResult.doubleLogicValues[i + 1] ~= analyseResult.doubleLogicValues[1] - i then
					break
				end
				i = i + 1
			end
			if i == analyseResult.iDoubleCount then
				bSeriesCard = true
			end
		end
		if bSeriesCard == true and analyseResult.iDoubleCount*2 == iCardCount then
			return PaoDeKuai_pb.CONTINUOUSPAIR
		end
	end

	--顺子判断
	if analyseResult.iSingleCount >= 5 and analyseResult.iSingleCount == iCardCount then
		--变量定义
		local bSeriesCard = false
		local iLogicValue = cardData[1].value
		--连牌判断
		if iLogicValue ~= 15 then
			local i = 1
			while i < analyseResult.iSingleCount do
				if cardData[i + 1].value ~= iLogicValue - i then
					break
				end
				i = i + 1
			end
			if i == analyseResult.iSingleCount then
				bSeriesCard = true
			end
		end

		--顺子判断
		if bSeriesCard == true then
			return PaoDeKuai_pb.FLUSH
		end
	end

	return -1
end

--对比扑克
function class:compareCards(firstList, nextList, firstType, nextType)
	if nil == firstList or nil == nextList then
		return false
	end

	local iFirstCount = #firstList
	local iNextCount = #nextList
	--获取类型
	local iFirstType = firstType
	if iFirstType == nil then
		iFirstType = self:getCardType(firstList)
	end

	if iFirstType == -1 then
		return false
	end

	local iNextType = nextType
	if iNextType == nil then
		iNextType = self:getCardType(nextList)
	end
	
	if iNextType == -1 then
		return true
	end

	--炸弹判断
	if iFirstType == PaoDeKuai_pb.BOOM and iNextType ~= PaoDeKuai_pb.BOOM then
		return true
	end
	if iFirstType ~= PaoDeKuai_pb.BOOM and iNextType == PaoDeKuai_pb.BOOM then
		return false
	end
	--规则判断
	if iFirstType ~= iNextType or iFirstCount ~= iNextCount then
		return false
	end
	
	--开始对比
	if iNextType == PaoDeKuai_pb.BOOM or iNextType == PaoDeKuai_pb.SINGLE or 
		iNextType == PaoDeKuai_pb.FLUSH or iNextType == PaoDeKuai_pb.CONTINUOUSPAIR or
		iNextType == PaoDeKuai_pb.ONEPAIR then
		local iNextLogicValue = nextList[1].value
		local iFirstLogicValue = firstList[1].value
		return iFirstLogicValue > iNextLogicValue

	elseif iNextType == PaoDeKuai_pb.FULLHOUSE or iNextType == PaoDeKuai_pb.HOUSE  then
		local nextResult = self:analyseCardData(nextList, true)
		local firstResult = self:analyseCardData(firstList, true)
		return firstResult.threeLogicValues[1] > nextResult.threeLogicValues[1]
	elseif iNextType == PaoDeKuai_pb.PLANE then
		local nextResult = self:analyseCardData(nextList, true)
		local firstResult = self:analyseCardData(firstList, true)
		local nextThreeLogicValues = nextResult.threeLogicValues
		local firstThreeLogicValues = firstResult.threeLogicValues
		
		local iNextThreeLineValue = 0
		for i = 1, nextResult.iThreeCount - 1 do
			if nextThreeLogicValues[i] - nextThreeLogicValues[i + 1] ~= 1 then

			else
				if iNextThreeLineValue < nextThreeLogicValues[i] then
					iNextThreeLineValue = nextThreeLogicValues[i]
				end
			end
		end

		local iFirstThreeLineValue = 0
		for i = 1, firstResult.iThreeCount - 1 do
			if firstThreeLogicValues[i] - firstThreeLogicValues[i + 1] ~= 1 then

			else
				if iFirstThreeLineValue < firstThreeLogicValues[i] then
					iFirstThreeLineValue = firstThreeLogicValues[i]
				end
			end
		end

		-- log("iFirstThreeLineValue:"..iFirstThreeLineValue..", iNextThreeLineValue:"..iNextThreeLineValue)
		
		return iFirstThreeLineValue > iNextThreeLineValue


	elseif iNextType == PaoDeKuai_pb.FOURWITHTHREE then
		local nextResult = self:analyseCardData(nextList)
		local firstResult = self:analyseCardData(firstList)
		return firstResult.fourLogicValues[1] > nextResult.fourLogicValues[1]
	end

	return false
end

--查找顺子
function class:seekOutFlush(cardData)
	local outCardResult = {}
	if nil == cardData then
		return outCardResult
	end

	local iTurnCardCount = 5
	local iCardCount = #cardData
	if iCardCount < iTurnCardCount then
		return outCardResult
	end

	self:sortCards(cardData)
	--搜索连牌
	for i = iCardCount, iTurnCardCount, -1 do
		local bBreak = false
		--获取数值
		local iHandLogicValue = cardData[i].value
		--搜索连牌
		local iLineCount = 0
		outCardResult = {}
		for j = i, 1, -1 do
			local iValue = cardData[j].value
			if iValue >= 15 then  	--构造判断
				break
			end
			if iValue - iLineCount == iHandLogicValue then
				--增加连数
				outCardResult[iLineCount + 1] = cardData[j]
				iLineCount = iLineCount + 1
				--完成判断
				if iLineCount >= iTurnCardCount then
					bBreak = true
				end
			end
		end

		if bBreak then
			break
		end
	end

	if #outCardResult < iTurnCardCount then
		outCardResult = {}
	end
	return outCardResult
end

function class:seekOutPairFlush(cardData)
	local outCardResult = {}
	if nil == cardData then
		return outCardResult
	end

	local iCardCount = #cardData
	if iCardCount < 5 then
		return outCardResult
	end

	self:sortCards(cardData)

	--搜索连牌
	local bBreak = false
	for i = iCardCount, 2, -1 do
		bBreak = false
		--获取数值
		local iHandLogicValue = cardData[i].value
		--搜索连牌
		local iLineCount = 0
		outCardResult = {}
		for j = i, 2, -1 do
			if cardData[j].value - iLineCount == iHandLogicValue and cardData[j - 1].value - iLineCount == iHandLogicValue then
				--增加连数
				outCardResult[iLineCount*2 + 1] = cardData[j]
				outCardResult[iLineCount*2 + 2] = cardData[j - 1]
				iLineCount = iLineCount + 1
				--完成判断
				if iLineCount >= 2 then
					bBreak = true
				end
			end
		end

		if bBreak then
			break
		end
	end

	if #outCardResult < 2 then
		outCardResult = {}
	end
	return outCardResult
end

function class:searchOutFlush(cardData, turnCardData)
	local outCardResult = {}
	if nil == cardData then
		return outCardResult
	end

	local iCardCount = #cardData
	local iTurnCardCount = #turnCardData
	if iCardCount < iTurnCardCount then
		return outCardResult
	end

	self:sortCards(cardData)
	self:sortCards(turnCardData)

	local iLogicValue = turnCardData[iTurnCardCount].value --最小值
	--搜索连牌
	for i = iCardCount, iTurnCardCount, -1 do
		local bBreak = false
		--获取数值
		local iHandLogicValue = cardData[i].value
		if iHandLogicValue > iLogicValue then
			--搜索连牌
			local iLineCount = 0
			outCardResult = {}
			for j = i, 1, -1 do
				local iValue = cardData[j].value
				if iValue >= 15 then  	--构造判断
					break
				end
				if iValue - iLineCount == iHandLogicValue then
					--增加连数
					outCardResult[iLineCount + 1] = cardData[j]
					iLineCount = iLineCount + 1
					--完成判断
					if iLineCount == iTurnCardCount then
						bBreak = true
						break
					end
				end
			end

			if bBreak then
				break
			end
		end
	end

	if #outCardResult < iTurnCardCount then
		outCardResult = {}
	end
	return outCardResult
end

--搜索可出之牌
function class:searchOutCard(cardData, turnCardData, turnOutType)
	--初始化结果
	local outCardResult = {}
	if nil == cardData or nil == turnCardData then
		return outCardResult
	end

	local bBreak = false
	local resultNum = 0
	local iCardCount = #cardData
	local iTurnCardCount = #turnCardData

	self:sortCards(cardData)
	self:sortCards(turnCardData)

	--长度判断
	if iTurnCardCount > iCardCount then
		--检查是否有炸弹
		for i = iCardCount , 4, -1 do
			bBreak = false
			--获取数值
			local iHandLogicValue = cardData[i].value
			--炸弹判断
			local j = i - 1
			while j >= i - 3 do
				if cardData[j].value ~= iHandLogicValue then
					break
				end
				j = j - 1
			end
			--完成处理
			if j == i - 4 then
				outCardResult = {cardData[i - 3], cardData[i - 2], cardData[i - 1], cardData[i]}
				-- i = i - 3
				bBreak = true
			end

			if bBreak then
				break
			end
		end

		return outCardResult, PaoDeKuai_pb.BOOM
	end

	local iTurnOutType
	if turnOutType ~= nil then
		iTurnOutType = turnOutType
	else
		iTurnOutType = self:getCardType(turnCardData)
	end

	--炸弹管非炸弹
	if iTurnOutType ~= PaoDeKuai_pb.BOOM then
		for i = iCardCount , 4, -1 do
			--获取数值
			local iHandLogicValue = cardData[i].value
			--炸弹判断
			local j = i - 1
			while j >= i - 3 do
				if cardData[j].value ~= iHandLogicValue then
					break
				end
				j = j - 1
			end
			--完成处理
			if j == i - 4 then
				outCardResult = {cardData[i - 3], cardData[i - 2], cardData[i - 1], cardData[i]}
				return outCardResult, PaoDeKuai_pb.BOOM
			end
		end
	end

	if iTurnOutType == PaoDeKuai_pb.SINGLE then 				--单张
		-- log("PaoDeKuai_pb.SINGLE")
		local iLogicValue = turnCardData[1].value

		for i = iCardCount, 1, -1 do
			if cardData[i].value > iLogicValue then
				outCardResult[#outCardResult + 1] = cardData[i]
				resultNum = resultNum + 1
				break
			end
		end

	elseif iTurnOutType == PaoDeKuai_pb.FLUSH then 			--顺子
		-- log("PaoDeKuai_pb.FLUSH")
		--获取数值
		local iLogicValue = turnCardData[iTurnCardCount].value --最小值
		--搜索连牌
		for i = iCardCount, iTurnCardCount, -1 do
			bBreak = false
			--获取数值
			local iHandLogicValue = cardData[i].value
			if iHandLogicValue > iLogicValue then
				--搜索连牌
				local iLineCount = 0
				for j = i, 1, -1 do
					local iValue = cardData[j].value
					if iValue >= 15 then  	--构造判断
						break
					end
					if iValue - iLineCount == iHandLogicValue then
						--增加连数
						outCardResult[iLineCount + 1] = cardData[j]
						iLineCount = iLineCount + 1
						--完成判断
						if iLineCount == iTurnCardCount then
							resultNum = resultNum + 1
							bBreak = true
							break
						end
					end
				end
			end
			if bBreak then
				break
			end
		end

	elseif iTurnOutType == PaoDeKuai_pb.CONTINUOUSPAIR or iTurnOutType == PaoDeKuai_pb.ONEPAIR then 		--连对
		-- log("CONTINUOUSPAIR or ONEPAIR")
		--获取数值
		local iLogicValue = turnCardData[iTurnCardCount].value --最小值
		-- log("iLogicValue : "..iLogicValue..", iTurnCardCount : "..iTurnCardCount)
		--搜索连牌
		for i = iCardCount, iTurnCardCount, -1 do
			bBreak = false
			--获取数值
			local iHandLogicValue = cardData[i].value
			--构造判断
			if iHandLogicValue > iLogicValue then
				--搜索连牌
				local iLineCount = 0
				for j = i, 2, -1 do
					if cardData[j].value - iLineCount == iHandLogicValue and cardData[j - 1].value - iLineCount == iHandLogicValue then
						--增加连数
						outCardResult[iLineCount*2 + 1] = cardData[j]
						outCardResult[iLineCount*2 + 2] = cardData[j - 1]
						iLineCount = iLineCount + 1
						--完成判断
						if iLineCount*2 == iTurnCardCount then
							resultNum = resultNum + 1
							bBreak = true
							break
						end
					end
				end
			end

			if bBreak then
				break
			end
		end

	elseif iTurnOutType == PaoDeKuai_pb.FULLHOUSE or iTurnOutType == PaoDeKuai_pb.PLANE then 		--三带二 或者飞机
		-- log("PaoDeKuai_pb.FULLHOUSE")
		--获取数值
		local iLogicValue = 0
		for i = iTurnCardCount, 3, -1 do
			iLogicValue = turnCardData[i].value
			if turnCardData[i-1].value == iLogicValue and	turnCardData[i-2].value == iLogicValue then
				break
			end
		end

		--属性数值
		local iTurnLineCount = iTurnCardCount / 5
		-- log("iLogicValue:"..iLogicValue..", iTurnLineCount:"..iTurnLineCount)
		--搜索连牌
		local iHandLogicValue = 0		
		for i = iCardCount, iTurnLineCount*3, -1 do
			bBreak = false
			--获取数值
			iHandLogicValue = cardData[i].value
			if iHandLogicValue > iLogicValue then
				--搜索连牌
				local iLineCount = 0
				local tempList = {}
				for j = i, 3, -1 do
					--三牌判断
					if cardData[j].value-iLineCount == iHandLogicValue and 
						cardData[j-1].value-iLineCount == iHandLogicValue and
						cardData[j-2].value-iLineCount == iHandLogicValue then
						--增加连数
						tempList[iLineCount*3 + 1] = cardData[j - 2]
						tempList[iLineCount*3 + 2] = cardData[j - 1]
						tempList[iLineCount*3 + 3] = cardData[j]

						iLineCount = iLineCount + 1
						--完成判断
						if iLineCount == iTurnLineCount then
							--连牌设置
							local addCardCount = iLineCount*3
							local leftCardData = table.clone(cardData)
							self:removeCard(tempList, leftCardData)
							--分析扑克
							local analyseResult = self:analyseCardData(leftCardData)
							--提取单牌
							for k = analyseResult.iSingleCount, 1, -1 do
								--终止判断
								if addCardCount == iTurnCardCount then
									break
								end
								--设置扑克
								local signedCard = analyseResult.singleCardDatas[k]
								tempList[#tempList + 1] = signedCard
								addCardCount = addCardCount + 1
							end
							--提取对牌
							for k = analyseResult.iDoubleCount*2, 1, -1 do
								--终止判断
								if addCardCount == iTurnCardCount then
									break
								end
								--设置扑克
								local signedCard = analyseResult.doubleCardDatas[k]
								tempList[#tempList + 1] = signedCard
								addCardCount = addCardCount + 1
							end
							--提取三牌
							for k = analyseResult.iThreeCount*3, 1, -1 do
								--终止判断
								if addCardCount == iTurnCardCount then
									break
								end
								--设置扑克
								local signedCard = analyseResult.threeCardDatas[k]
								tempList[#tempList + 1] = signedCard
								addCardCount = addCardCount + 1
							end

							--提取四牌
							for k = analyseResult.iFourCount*4, 1, -1 do
								--终止判断
								if addCardCount == iTurnCardCount then
									break
								end
								--设置扑克
								local signedCard = analyseResult.fourCardDatas[k]
								tempList[#tempList + 1] = signedCard
								addCardCount = addCardCount + 1
							end

							--完成判断
							if addCardCount ~= iTurnCardCount then
								resultNum = 0
							else
								outCardResult = tempList
								resultNum = resultNum + 1
							end
							bBreak = true
							break
						end
					end
				end
			end

			if bBreak then
				break
			end
		end

	elseif iTurnOutType == PaoDeKuai_pb.BOOM then 		--炸弹
		-- log("PaoDeKuai_pb.BOOM")
		--获取数值
		local iLogicValue = turnCardData[iTurnCardCount].value
		--搜索炸弹
		for i = iCardCount, 4, -1 do
			--获取数值
			local iHandLogicValue = cardData[i].value
			--构造判断
			if iHandLogicValue > iLogicValue then
				--炸弹判断
				local j = i - 1
				while j >= i - 3 do
					if cardData[j].value ~= iHandLogicValue then
						break
					end
					j = j - 1
				end
				--完成处理
				if j == i - 4 then
					local tempList = {cardData[i - 3], cardData[i - 2], cardData[i - 1], cardData[i]}
					outCardResult[#outCardResult + 1] = tempList
					resultNum = resultNum + 1
					i = i - 3
					break
				end
			end
		end
	end

	if resultNum == 0 then
		outCardResult = {}
	end

	return outCardResult, turnOutType
end

--搜索可出之牌（返回，所有可出牌型列表，用于提示）
function class:searchOutCardList(cardData, turnCardData, turnOutType)
	--初始化结果
	local outCardResult = {}
	-- outCardResult.cbCardCount = 0
	-- outCardResult.cbResultCard = {}
	if nil == cardData or nil == turnCardData then
		return outCardResult
	end

	local resultNum = 0
	local iCardCount = #cardData
	local iTurnCardCount = #turnCardData

	self:sortCards(cardData)
	self:sortCards(turnCardData)

	--长度判断
	if iTurnCardCount > iCardCount then
		--检查是否有炸弹
		for i = iCardCount , 4, -1 do
			--获取数值
			local iHandLogicValue = cardData[i].value
			--炸弹判断
			local j = i - 1
			while j >= i - 3 do
				if cardData[j].value ~= iHandLogicValue then
					break
				end
				j = j - 1
			end
			--完成处理
			if j == i - 4 then
				local tempList = {cardData[i - 3], cardData[i - 2], cardData[i - 1], cardData[i]}
				outCardResult[#outCardResult + 1] = tempList
				i = i - 3
			end
		end

		return outCardResult
	end

	local iTurnOutType
	if turnOutType ~= nil then
		iTurnOutType = turnOutType
	else
		iTurnOutType = self:getCardType(turnCardData)
	end

	if iTurnOutType == -1 then 			--错误类型（用于首出牌，出最小的牌）
		-- log("PaoDeKuaiLogic.ERROR")
		--获取数值
		local iLogicValue = cardData[iCardCount].value
		--多牌判断
		local iSameCount = 1
		for i = iCardCount - 1, 1, -1 do
			if cardData[i].value == iLogicValue then
				iSameCount = iSameCount + 1
			else
				break
			end
		end
		--完成处理
		for i = 1, iSameCount do
			outCardResult[#outCardResult + 1] = cardData[iCardCount - i + 1]
		end
		resultNum = 1

	elseif iTurnOutType == PaoDeKuai_pb.SINGLE then 				--单张
		-- log("PaoDeKuai_pb.SINGLE")
		local iLogicValue = turnCardData[1].value
		--分析扑克
		local analyseResult = self:analyseCardData(cardData)

		--提取单牌
		for k = analyseResult.iSingleCount, 1, -1 do
			local singleCard = analyseResult.singleCardDatas[k]
			if singleCard.value > iLogicValue then
				outCardResult[#outCardResult + 1] = {singleCard}
				resultNum = resultNum + 1
			end
		end

		--没有单张就从对子、三牌中提取
		if resultNum == 0 then
			--提取对牌
			for k = analyseResult.iDoubleCount*2, 1, -2 do			
				local singleCard = analyseResult.doubleCardDatas[k]
				if singleCard.value > iLogicValue then
					outCardResult[#outCardResult + 1] = {singleCard}
					resultNum = resultNum + 1
				end
			end

			--提取三牌
			for k = analyseResult.iThreeCount*3, 1, -3 do
				local singleCard = analyseResult.threeCardDatas[k]
				if singleCard.value > iLogicValue then
					outCardResult[#outCardResult + 1] = {singleCard}
					resultNum = resultNum + 1
				end
			end
		end

	elseif iTurnOutType == PaoDeKuai_pb.ONEPAIR then --对子
		-- log("PaoDeKuai_pb.ONEPAIR")
		--获取数值
		local iLogicValue = turnCardData[iTurnCardCount].value --最小值
		--分析扑克
		local analyseResult = self:analyseCardData(cardData)
		--提取对牌
		for k = analyseResult.iDoubleCount*2, 1, -2 do
			local doubleCardDatas = analyseResult.doubleCardDatas
			if doubleCardDatas[k].value > iLogicValue then
				outCardResult[#outCardResult + 1] = {doubleCardDatas[k], doubleCardDatas[k-1]}
				resultNum = resultNum + 1
			end
		end

		--提取三牌
		for k = analyseResult.iThreeCount*3, 1, -3 do
			local threeCardDatas = analyseResult.threeCardDatas
			if threeCardDatas[k].value > iLogicValue then
				outCardResult[#outCardResult + 1] = {threeCardDatas[k], threeCardDatas[k-1]}
				resultNum = resultNum + 1
			end
		end

	elseif iTurnOutType == PaoDeKuai_pb.FLUSH then 			--顺子
		-- log("PaoDeKuai_pb.FLUSH")
		--获取数值
		local iLogicValue = turnCardData[iTurnCardCount].value
		local iHandLogicValue
		local iLastStartValue
		local tempList
		--搜索连牌
		for i = iCardCount, iTurnCardCount, -1 do
			--获取数值
			iHandLogicValue = cardData[i].value
			-- log("index:"..i..", iHandLogicValue:"..iHandLogicValue..", iLogicValue:"..iLogicValue)
			if iHandLogicValue > iLogicValue then
				if i < iCardCount and cardData[i].value == cardData[i+1].value then

				else
					--搜索连牌
					local iValue
					local iLineCount = 0
					tempList = {}
					for j = i, 1, -1 do
						iValue = cardData[j].value
						if iValue < 15 and iValue - iLineCount == iHandLogicValue then
							--增加连数
							tempList[#tempList + 1] = cardData[j]
							iLineCount = iLineCount + 1
							--完成判断
							if iLineCount == iTurnCardCount then
								outCardResult[#outCardResult + 1] = tempList
								resultNum = resultNum + 1
								break
							end
						end
					end
				end
			end
		end

	elseif iTurnOutType == PaoDeKuai_pb.CONTINUOUSPAIR then 		--连对
		-- log("CONTINUOUSPAIR or ONEPAIR")
		--获取数值
		local iLogicValue = turnCardData[iTurnCardCount].value --最小值
		-- log("iLogicValue : "..iLogicValue..", iTurnCardCount : "..iTurnCardCount)
		--分析扑克
		local analyseResult = self:analyseCardData(cardData)
		--搜索连牌
		local tempList = {}
		local iStartValue = 0
		for i = iCardCount, iTurnCardCount, -1 do
			--获取数值
			local iHandLogicValue = cardData[i].value
			--构造判断
			if iHandLogicValue > iLogicValue and iHandLogicValue ~= iStartValue then
				--搜索连牌
				local iLineCount = 0
				local iValue = 0
				local iNextValue = 0
				tempList = {}
				for j = i, 2, -1 do
					iValue = cardData[j].value
					iNextValue = cardData[j-1].value
					if iValue-iLineCount == iHandLogicValue and iNextValue-iLineCount == iHandLogicValue and iNextValue ~= 15 and 
						self:tableContainsValue(analyseResult.fourCardDatas, iValue) == false then
						--增加连数
						tempList[iLineCount*2 + 1] = cardData[j]
						tempList[iLineCount*2 + 2] = cardData[j-1]

						iLineCount = iLineCount + 1
						--完成判断
						if iLineCount*2 == iTurnCardCount then
							outCardResult[#outCardResult + 1] = tempList
							iStartValue = tempList[1].value
							resultNum = resultNum + 1
							break
						end
					end
				end
			end
		end

	elseif iTurnOutType == PaoDeKuai_pb.FULLHOUSE or iTurnOutType == PaoDeKuai_pb.PLANE then 		--三带二 或者飞机
		-- log("PaoDeKuai_pb.FULLHOUSE")
		--获取数值
		local iLogicValue = 0
		for i = iTurnCardCount, 3, -1 do
			iLogicValue = turnCardData[i].value
			if turnCardData[i-1].value == iLogicValue and	turnCardData[i-2].value == iLogicValue then
				break
			end
		end

		--分析扑克
		local analyseResult = self:analyseCardData(cardData)

		--属性数值
		local iTurnLineCount = iTurnCardCount / 5
		-- log("iLogicValue:"..iLogicValue..", iTurnLineCount:"..iTurnLineCount)
		--搜索连牌
		local iHandLogicValue = 0
		local iStartValue = 0
		local tempList = {}
		for i = iCardCount, iTurnLineCount*3, -1 do
			--获取数值
			iHandLogicValue = cardData[i].value
			-- log("iHandLogicValue:"..iHandLogicValue..", iLogicValue:"..iLogicValue)
			if iHandLogicValue > iLogicValue and iHandLogicValue ~= iStartValue then
				--搜索连牌
				local iLineCount = 0
				tempList = {}
				for j = i, 3, -1 do
					--三牌判断
					-- log("j:"..j..", "..cardData[j].value..", "..cardData[j-1].value..", "..cardData[j-2].value)
					if cardData[j].value-iLineCount == iHandLogicValue and 
						cardData[j-1].value-iLineCount == iHandLogicValue and
						cardData[j-2].value-iLineCount == iHandLogicValue and 
						self:tableContainsValue(analyseResult.fourCardDatas, cardData[j].value) == false then
						--增加连数
						tempList[iLineCount*3 + 1] = cardData[j - 2]
						tempList[iLineCount*3 + 2] = cardData[j - 1]
						tempList[iLineCount*3 + 3] = cardData[j]

						iLineCount = iLineCount + 1
						--完成判断
						if iLineCount == iTurnLineCount then
							--连牌设置
							local addCardCount = iLineCount*3
							local leftCardData = table.clone(cardData)
							self:removeCard(tempList, leftCardData)
							--分析扑克
							local analyseResult2 = self:analyseCardData(leftCardData)
							if iLineCount == 1 and analyseResult2.iSingleCount == 1 and analyseResult2.iDoubleCount > 0 then
								--三带二，一张单牌比对子大，直接取对子
								local signedCard1 = analyseResult2.singleCardDatas[1]
								local signedCard2 = analyseResult2.doubleCardDatas[analyseResult2.iDoubleCount*2]
								if signedCard1.value > signedCard2.value then
									--提取对牌
									for k = analyseResult2.iDoubleCount*2, 1, -1 do
										--终止判断
										if addCardCount == iTurnCardCount then
											break
										end
										--设置扑克
										local signedCard = analyseResult2.doubleCardDatas[k]
										tempList[#tempList + 1] = signedCard
										addCardCount = addCardCount + 1
									end
								end
							end

							--提取单牌
							for k = analyseResult2.iSingleCount, 1, -1 do
								--终止判断
								if addCardCount == iTurnCardCount then
									break
								end
								--设置扑克
								local signedCard = analyseResult2.singleCardDatas[k]
								tempList[#tempList + 1] = signedCard
								addCardCount = addCardCount + 1
							end
							--提取对牌
							for k = analyseResult2.iDoubleCount*2, 1, -1 do
								--终止判断
								if addCardCount == iTurnCardCount then
									break
								end
								--设置扑克
								local signedCard = analyseResult2.doubleCardDatas[k]
								tempList[#tempList + 1] = signedCard
								addCardCount = addCardCount + 1
							end
							--提取三牌
							for k = analyseResult2.iThreeCount*3, 1, -1 do
								--终止判断
								if addCardCount == iTurnCardCount then
									break
								end
								--设置扑克
								local signedCard = analyseResult2.threeCardDatas[k]
								tempList[#tempList + 1] = signedCard
								addCardCount = addCardCount + 1
							end

							--提取四牌
							-- for k = analyseResult2.iFourCount*4, 1, -1 do
							-- 	--终止判断
							-- 	if addCardCount == iTurnCardCount then
							-- 		break
							-- 	end
							-- 	--设置扑克
							-- 	local signedCard = analyseResult2.fourCardDatas[k]
							-- 	tempList[#tempList + 1] = signedCard
							-- 	addCardCount = addCardCount + 1
							-- end

							--完成判断
							if addCardCount ~= iTurnCardCount then
								
							else
								outCardResult[#outCardResult + 1] = tempList
								iStartValue = tempList[1].value
								resultNum = resultNum + 1
							end
							break
						end
					end
				end
			end
		end

	elseif iTurnOutType == PaoDeKuai_pb.BOOM then 		--炸弹
		-- log("PaoDeKuai_pb.BOOM")
		--获取数值
		local iLogicValue = turnCardData[iTurnCardCount].value
		--搜索炸弹
		for i = iCardCount, 4, -1 do
			--获取数值
			local iHandLogicValue = cardData[i].value
			--构造判断
			if iHandLogicValue > iLogicValue then
				--炸弹判断
				local j = i - 1
				while j >= i - 3 do
					if cardData[j].value ~= iHandLogicValue then
						break
					end
					j = j - 1
				end
				--完成处理
				if j == i - 4 then
					local tempList = {cardData[i - 3], cardData[i - 2], cardData[i - 1], cardData[i]}
					outCardResult[#outCardResult + 1] = tempList
					resultNum = resultNum + 1
					i = i - 3
				end
			end
		end
	end

	--炸弹管非炸弹
	if iTurnOutType ~= PaoDeKuai_pb.BOOM then
		local iBombIndex = 1
		local bBomb = false
		for i = iCardCount , 4, -1 do
			--获取数值
			local iHandLogicValue = cardData[i].value
			--炸弹判断
			local j = i - 1
			while j >= i - 3 do
				if cardData[j].value ~= iHandLogicValue then
					break
				end
				j = j - 1
			end
			--完成处理
			if j == i - 4 then
				local tempList = {cardData[i - 3], cardData[i - 2], cardData[i - 1], cardData[i]}
				if not bBomb then
					local iBombValue = cardData[i].value
					for _, data in ipairs(outCardResult) do
						for __, v in ipairs(data) do
							if v.value == iBombValue then
								bBomb = true
								break
							end
						end
					end
				end

				if bBomb then
					table.insert(outCardResult, iBombIndex, tempList)
					iBombIndex = iBombIndex + 1
				else
					outCardResult[#outCardResult + 1] = tempList
				end
				i = i - 3
			end
		end
	end

	return outCardResult
end
