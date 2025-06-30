module(..., package.seeall)
class = Logic.class:subclass()
local ShiSanShui_pb = ShiSanShui_pb

function class:initialize()
	super.initialize(self)
    --排序类型
    self.enDescend = 0						--降序类型  从大到小
    self.enAscend = 1						--升序类型
    --索引变量
    --特殊类型
    -- ShiSanShui_pb.NOT_SPECIALTYPE							--非特殊牌
    --ShiSanShui_pb.THREE_FLUSH								--三同花
    --ShiSanShui_pb.THREE_STRAIGHT								--三顺子
    --ShiSanShui_pb.SIXPAIR							--六对半
    -- ShiSanShui_pb.FOUR_THREE					--四套冲三						
    --ShiSanShui_pb.THREE_BOOM   --三套炸弹
    --ShiSanShui_pb.THREE_STRAIGHT_FLUSH	--三同花顺
    --ShiSanShui_pb.THIRTEEN							--十三水
    --ShiSanShui_pb.THIRTEEN_FLUSH							--至尊清龙
    --扑克类型
    self.CARD_TYPE = 
    {
	    CT_INVALID						= 0,			--错误类型
	    CT_SINGLE						= 1,			--单牌类型
	    CT_ONE_DOUBLE					= 2,			--只有一对
	    CT_FIVE_TWO_DOUBLE				= 3,			--两对牌型
	    CT_THREE						= 4,			--三张牌型
	    CT_FIVE_MIXED_STRAIGHT_NO_A		= 5,			--没A杂顺
	    CT_FIVE_MIXED_STRAIGHT_FIRST_A	= 6,			--A在前顺子
	    CT_FIVE_MIXED_STRAIGHT_BACK_A	= 7,			--A在后顺子
	    CT_FIVE_FLUSH					= 8,			--同花五牌
	    CT_FIVE_FLUSH_ONE_DOUBLE		= 9,			--同花带一对
	    CT_FIVE_FLUSH_TWO_DOUBLE		= 10,			--同花带两对
	    CT_FIVE_THREE_DEOUBLE			= 11,			--三条一对
	    CT_FIVE_FOUR_ONE				= 12,			--四带一张
	    CT_FIVE_STRAIGHT_FLUSH_NO_A		= 13,			--没A同花顺
	    CT_FIVE_STRAIGHT_FLUSH_FIRST_A	= 14,			--A在前同花顺
	    CT_FIVE_STRAIGHT_FLUSH_BACK_A	= 15,			--A在后同花顺
	    CT_FIVE 						= 16,			--五同

	    --特殊牌型	
	    CT_THREE_STRAIGHT               = 20,			--三顺子	
	    CT_THREE_FLUSH                  = 21,			--三同花
	    CT_SIXPAIR                      = 22,			--六对半
	    CT_FIVEPAIR_THREE               = 23,			--五对冲三
	    CT_FOUR_THREESAME               = 24,			--四套冲三
	    --CT_SAME_COLOR                   = 19,			--凑一色(全是 黑桃、梅花 或者 红桃、方块)
	    CT_ALL_RED_ONE_BLACK			= 25,			--全红一点黑
	    CT_ALL_BLACK_ONE_RED			= 26,			--全黑一点红	
	    CT_ALL_RED						= 27,			--全红
	    CT_ALL_BLACK					= 28,			--全黑
	    -- CT_ALL_SMALL                    = 29,			--全小
	    -- CT_ALL_BIG                      = 30,			--全大
	    CT_THREE_BOMB                   = 31,			--三炸弹
	    CT_THREE_STRAIGHTFLUSH          = 32,			--三同花顺
	    CT_TWELVE_KING                  = 33,			--十二皇族
	    CT_THIRTEEN 					= 34,			--十三水
	    CT_THIRTEEN_FLUSH 				= 35,			--同花十三水

    }

end

--搜索结果
function class:getSearchCardResult()
	return
	{
		cbSearchCount = 0,	--结果数目
		cbCardCount = {0,0,0,0,0,0,0,0,0,0,0,0,0},	--扑克数目
		cbResultCard = {{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  	{0,0,0,0,0,0,0,0,0,0,0,0,0}}	--扑克列表	
	}
end

--逻辑值排序
function class:SortCardList( cbCardData, cbCardCount, cbSortType)
    if cbCardCount == 0 or cbCardCount > 13 then
		return
	end

	local cbSortValue = {}
	for i=1,cbCardCount do
        table.insert(cbSortValue, i, cbCardData[i].value)
    end
	
	--排序操作
	if self.enDescend == cbSortType then
		local bSorted = true
		local cbLast = cbCardCount - 1
		repeat
			bSorted = true
			for i=1,cbLast do
				if (cbSortValue[i] < cbSortValue[i+1]) or (cbSortValue[i] == cbSortValue[i + 1]) then
					--设置标志
					bSorted = false

					--扑克数据
					cbCardData[i], cbCardData[i + 1] = cbCardData[i + 1], cbCardData[i]				

					--排序权位
					cbSortValue[i], cbSortValue[i + 1] = cbSortValue[i + 1], cbSortValue[i]
				end
			end
			cbLast = cbLast - 1
		until bSorted ~= false
	elseif self.enAscend == cbSortType then
		local bSorted = true
		local cbLast = cbCardCount - 1
		repeat
			bSorted = true
			for i=1,cbLast do
				if (cbSortValue[i] > cbSortValue[i+1]) or (cbSortValue[i] == cbSortValue[i + 1])  then
					--设置标志
					bSorted = false

					--扑克数据
					cbCardData[i], cbCardData[i + 1] = cbCardData[i + 1], cbCardData[i]				

					--排序权位
					cbSortValue[i], cbSortValue[i + 1] = cbSortValue[i + 1], cbSortValue[i]
				end
			end
			cbLast = cbLast - 1
		until bSorted ~= false           
	end
end
--花色排序
function class:SortCardListColor(cbCardData, cbCardCount)
    --黑,红,梅,方,4,3,2,1
    --log("i am ok =============================")
    if cbCardCount == 0 or cbCardCount > 13 then
		return
	end
	local cbSortColor = {}
	for i=1,cbCardCount do
        table.insert(cbSortColor, i, cbCardData[i].color)      
    end
	--排序操作
		local bSorted = true
		local cbLast = cbCardCount - 1
		repeat
			bSorted = true
			for i=1,cbLast do
				if (cbSortColor[i] < cbSortColor[i+1])then
					--设置标志
					bSorted = false
					--扑克数据
					cbCardData[i], cbCardData[i + 1] = cbCardData[i + 1], cbCardData[i]				
					--排序权位
					cbSortColor[i], cbSortColor[i + 1] = cbSortColor[i + 1], cbSortColor[i]
				end
			end
			cbLast = cbLast - 1
		until bSorted ~= false
        --花色相同的牌越多,越排在前面
        local cbCardB={} 
        local cbCardM={}
        local cbCardH={} 
        local cbCardF={}
              for i=1,cbCardCount do
                   if cbCardData[i].color==4 then
                        table.insert(cbCardB,cbCardData[i])
                    elseif cbCardData[i].color==3 then
                        table.insert(cbCardM,cbCardData[i])
                    elseif cbCardData[i].color==2 then
                        table.insert(cbCardH,cbCardData[i])
                    elseif cbCardData[i].color==1 then
                        table.insert(cbCardF,cbCardData[i])
                   end
              end
              local sortCbcard={cbCardB,cbCardM,cbCardH,cbCardF}
              table.sort(sortCbcard,function (a,b)
                                 return table.nums(a)>table.nums(b)
                                   end)
              local cbCardData={}
                   for k,v in ipairs(sortCbcard) do
                       for k1,v1 in ipairs(v) do
                            table.insert(cbCardData,v1)
                        end
                   end
             sortCbcard={}
             return cbCardData
	
end
--花色排序2 1,2,3,4
function class:SortCardListColor2(cbCardData, cbCardCount)
    --黑,红,梅,方,   1,2,3,4
    --log("i am ok =============================")
    if cbCardCount == 0 or cbCardCount > 13 then
		return
	end
	local cbSortColor = {}
	for i=1,cbCardCount do
        table.insert(cbSortColor, i, cbCardData[i].color)      
    end
	--排序操作
		local bSorted = true
		local cbLast = cbCardCount - 1
		repeat
			bSorted = true
			for i=1,cbLast do
				if (cbSortColor[i] > cbSortColor[i+1])then
					--设置标志
					bSorted = false
					--扑克数据
					cbCardData[i], cbCardData[i + 1] = cbCardData[i + 1], cbCardData[i]				
					--排序权位
					cbSortColor[i], cbSortColor[i + 1] = cbSortColor[i + 1], cbSortColor[i]
				end
			end
			cbLast = cbLast - 1
		until bSorted ~= false
        --花色相同的牌越多,越排在前面
        local cbCardB={} 
        local cbCardM={}
        local cbCardH={} 
        local cbCardF={}
              for i=1,cbCardCount do
                   if cbCardData[i].color==4 then
                        table.insert(cbCardB,cbCardData[i])
                    elseif cbCardData[i].color==3 then
                        table.insert(cbCardM,cbCardData[i])
                    elseif cbCardData[i].color==2 then
                        table.insert(cbCardH,cbCardData[i])
                    elseif cbCardData[i].color==1 then
                        table.insert(cbCardF,cbCardData[i])
                   end
              end
              local sortCbcard={cbCardB,cbCardM,cbCardH,cbCardF}
              table.sort(sortCbcard,function (a,b)
                                 return table.nums(a)>table.nums(b)
                                   end)
              local cbCardData={}
                   for k,v in ipairs(sortCbcard) do
                       for k1,v1 in ipairs(v) do
                            table.insert(cbCardData,v1)
                        end
                   end
             sortCbcard={}
             return cbCardData
	
end
--逻辑值排序2
function class:SortCardList2( cbCardData, cbCardCount, cbSortType)
    if cbCardCount == 0 or cbCardCount > 13 then
		return
	end

	local cbSortValue = {}
	for i=1,cbCardCount do
        table.insert(cbSortValue, i, cbCardData[i].value)
    end
    local tempT2 = { } --把A当16
    for k, v in ipairs(cbSortValue) do
        if v == 1 then
            table.insert(tempT2, k)
        end
    end
    for k, v in ipairs(tempT2) do
        cbSortValue[v] = 16
    end
	--排序操作
	if self.enDescend == cbSortType then  --降序类型
		local bSorted = true
		local cbLast = cbCardCount - 1
		repeat
			bSorted = true
			for i=1,cbLast do
				if (cbSortValue[i] < cbSortValue[i+1])then
					--设置标志
					bSorted = false

					--扑克数据
					cbCardData[i], cbCardData[i + 1] = cbCardData[i + 1], cbCardData[i]				

					--排序权位
					cbSortValue[i], cbSortValue[i + 1] = cbSortValue[i + 1], cbSortValue[i]
				end
			end
			cbLast = cbLast - 1
		until bSorted ~= false
	elseif self.enAscend == cbSortType then
		local bSorted = true
		local cbLast = cbCardCount - 1
		repeat
			bSorted = true
			for i=1,cbLast do
				if (cbSortValue[i] > cbSortValue[i+1])then
					--设置标志
					bSorted = false

					--扑克数据
					cbCardData[i], cbCardData[i + 1] = cbCardData[i + 1], cbCardData[i]				

					--排序权位
					cbSortValue[i], cbSortValue[i + 1] = cbSortValue[i + 1], cbSortValue[i]
				end
			end
			cbLast = cbLast - 1
		until bSorted ~= false
     end      
end



function class:SearchSameCardByhh(cbHandCardData, cbHandCardCount)
        local havaTwo = false
        local count = 1;
        local cbBlockCount, cbCardData
        local cbBlockCount = { 0, 0, 0, 0 }
        local cbCardData = { { }, { }, { }, { } }
        if cbHandCardCount <= 1 then
            cbBlockCount = { 1, 0, 0, 0 }
            cbCardData [1]=cbHandCardData[1]
            return cbBlockCount, cbCardData
        end
          self:SortCardList2(cbHandCardData,cbHandCardCount,0)
         -- dump(cbHandCardData)
         

          local card = clone(cbHandCardData[1])
          card.value = 999
          card.color = 999
           table.insert(cbHandCardData,card)  ----插入一个数,让最后一个数可以比较
          for i=1,cbHandCardCount do
               if cbHandCardData[i].value==cbHandCardData[i+1].value then
                   havaTwo=true
                   count=count+1
             else
                   if havaTwo==true then
                      if count==2 then
                          cbBlockCount[2]=cbBlockCount[2]+1
                          cbCardData[2][cbBlockCount[2]*2-1]=cbHandCardData[i-1]
                          cbCardData[2][cbBlockCount[2]*2]=cbHandCardData[i]
                       elseif count==3 then
                          cbBlockCount[3]=cbBlockCount[3]+1
                          cbCardData[3][cbBlockCount[3]*3-2]=cbHandCardData[i-2]
                          cbCardData[3][cbBlockCount[3]*3-1]=cbHandCardData[i-1]
                          cbCardData[3][cbBlockCount[3]*3]=cbHandCardData[i]
                       elseif count==4 then
                          cbBlockCount[4]=cbBlockCount[4]+1
                          cbCardData[4][cbBlockCount[4]*4-3]=cbHandCardData[i-3]
                          cbCardData[4][cbBlockCount[4]*4-2]=cbHandCardData[i-2]
                          cbCardData[4][cbBlockCount[4]*4-1]=cbHandCardData[i-1]
                          cbCardData[4][cbBlockCount[4]*4]=cbHandCardData[i]
                      end
                      havaTwo=false
                      count=1                          
                   else
                          cbBlockCount[1]=cbBlockCount[1]+1
                          cbCardData[1][cbBlockCount[1]]=cbHandCardData[i]
                  end
              end
          end
         -- log("============ delete")
          --dump(table.remove(cbHandCardData))
          table.remove(cbHandCardData)
	return cbBlockCount, cbCardData
end
--搜索顺子
function class:SearchLineCardType(cbHandCardData, cbHandCardCount)
         local pSearchCardResult={}
		local cbSearchCount = 0	--结果数目
		pSearchCardResult.cbCardCount = {0,0,0,0,0,0,0,0,0,0}	--扑克数目
		local cbResultCard = {{},{},{},{},{},{},{},{},{},{}}	--扑克列表	

	 if cbHandCardCount <= 4 then
        return 0,pSearchCardResult
      end 
      local count=1
      self:SortCardList(cbHandCardData, cbHandCardCount, 1)--排序后K在最前面
      local TempHandCardData=clone(cbHandCardData)
      --为了使A,k,q,j,10生效,先复制A为14,最后替换回去
      local canReplace=false
        local function findValue(arg)
            for k, v in ipairs(TempHandCardData) do-- 有A,k,q,j,10时,才替换
                    if v.value==arg then
                       return true
                    end
            end
        end
      if findValue(13) and findValue(12) and findValue(11) and  findValue(10) and findValue(1) then
         canReplace=true
      end

      if canReplace==true then
          for k,v in ipairs(TempHandCardData) do  --只替换了最前面的一张A        
                   if v.value==1 then
                       local fakeCard=clone(TempHandCardData[k])
                       fakeCard.value=14
                      table.insert(TempHandCardData,fakeCard)
                      break
                   end           
          end
      end

        self:SortCardList(TempHandCardData, table.nums(TempHandCardData), 1)
        --dump(TempHandCardData)
        for i = 1, 12 do
            if #TempHandCardData <=4 then
                break
            end
            local tempValue = TempHandCardData[#TempHandCardData].value - 1
            local temp = { }
            temp[1] = table.remove(TempHandCardData)
            for j = #TempHandCardData, 1, -1 do
                if tempValue == TempHandCardData[j].value then
                    temp[#temp + 1] = table.remove(TempHandCardData,j)
                    tempValue = tempValue - 1
                else
                    if j == 1 then
                        break
                    end
                end
            end
            local tempCardNums=table.nums(temp)
            if tempCardNums == 5 then
                cbResultCard[count] = clone(temp)
                pSearchCardResult.cbCardCount[count] = table.nums(temp)
                count=count+1
            elseif tempCardNums>5 then
                   for k=1,tempCardNums-5+1 do
                        for length=1,5 do
                          cbResultCard[count][length]=clone(temp[length+k-1])                          
                        end
                        pSearchCardResult.cbCardCount[count] = 5
                        count=count+1
                   end
            end
        end
        for k,v in ipairs(pSearchCardResult.cbCardCount)do
            if v~=0 then
                cbSearchCount=cbSearchCount+1
            end
        end
    -- 还原A
    if canReplace==true then
        for k, v in ipairs(cbResultCard) do
            if table.nums(v) ~= 0 then
                for k1, v1 in ipairs(v) do
                    if v1.value == 14 then
                        v1.value = 1
                    end
                end
            end
        end
    end
    for i=10,1,-1 do--移除空的表
        if table.nums(cbResultCard[i])==0 then
            table.remove(cbResultCard)
        else
        end
    end
    --把 A顺子 排在前面
    local noATable = { }
    for i= table.nums(cbResultCard),1,-1 do
        if cbResultCard[i][1].value == 1 or cbResultCard[i][5].value == 1 then
            local temp = table.remove(cbResultCard, i)
            table.insert(noATable, temp)
        end
    end
     for i= table.nums(noATable),1,-1 do
        table.insert(cbResultCard,1, noATable[i])
    end

    pSearchCardResult.cbSearchCount=cbSearchCount
    pSearchCardResult.cbResultCard=cbResultCard
	return pSearchCardResult.cbSearchCount ,pSearchCardResult
end

--搜索同花
function class:SearchSameColorType(cbHandCardData, cbHandCardCount, cbSameCount)
	local cbResultCount = 0
	local cbCardData = clone(cbHandCardData)
	self:SortCardList(cbCardData, cbHandCardCount,self.enAscend)

	local cbSameCardCount = {0, 0, 0, 0}
	local cbSameCardData = {{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  		{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  		{0,0,0,0,0,0,0,0,0,0,0,0,0},
					  		{0,0,0,0,0,0,0,0,0,0,0,0,0}}

	for i=1,cbHandCardCount do
		--获取花色
		local cbCardColor = cbCardData[i].color
		--原牌数目
		local cbCount = cbSameCardCount[cbCardColor]
		--追加扑克
		cbSameCardData[cbCardColor][cbCount+1] = cbCardData[i]
		cbSameCardCount[cbCardColor] = cbSameCardCount[cbCardColor] + 1
	end
	local pSearchCardResult = self:getSearchCardResult()
	--判断是否满cbSameCount

	for i=1,4 do
		if cbSameCardCount[i] >= cbSameCount then
			for j=1,math.mod(cbSameCardCount[i], cbSameCount)+1 do
				pSearchCardResult.cbCardCount[cbResultCount+1] = cbSameCount
				for same=1,cbSameCount do
					pSearchCardResult.cbResultCard[cbResultCount+1][same] = cbSameCardData[i][j+same-1]
				end
				cbResultCount = cbResultCount + 1
			end
		end
	end
	pSearchCardResult.cbSearchCount = cbResultCount
	return cbResultCount, pSearchCardResult
end

--搜索同花顺
function class:SearchSameColorLineType(cbHandCardData, cbHandCardCount, cbLineCount)
	local cbResultCount = 0
	if cbHandCardCount < cbLineCount then
		return cbResultCount
	end

	--搜索同花
	local cbCardData = clone(cbHandCardData)
	self:SortCardList(cbCardData, cbHandCardCount,1)

	local cbSameCardCount = {0, 0, 0, 0}
	local cbSameCardData = {{},
					  		{},
					  		{},
					  		{}}

	for i=1,cbHandCardCount do
		--获取花色
		local cbCardColor =cbCardData[i].color
		--原牌数目
		local cbCount = cbSameCardCount[cbCardColor]
		--追加扑克
		table.insert(cbSameCardData[cbCardColor],cbCardData[i])
		cbSameCardCount[cbCardColor] = cbSameCardCount[cbCardColor] + 1
	end

	local pSearchCardResult = self:getSearchCardResult()
	for i=1,4 do
		if cbSameCardCount[i] >= cbLineCount then
			local cbLineResultCount, tagTempResult = self:SearchLineCardType(cbSameCardData[i], cbSameCardCount[i])
			if cbLineResultCount > 0 then
				for i=1,cbLineResultCount do
					pSearchCardResult.cbCardCount[cbResultCount+1] = cbLineCount
					pSearchCardResult.cbResultCard[cbResultCount+1] = clone(tagTempResult.cbResultCard[i])
					cbResultCount = cbResultCount + 1
				end
			end
		end
	end
	pSearchCardResult.cbSearchCount = cbResultCount
	return cbResultCount, pSearchCardResult
end

--[[比较扑克比较比牌--hhhh
function class:CompareCard(bInFirstList, bInNextList, bFirstCount, bNextCount)
	     --1.前墩大于后墩,2.符合,3牌不够
           --1.前墩大于后墩,2.符合,3牌不够
        local cbBlockCount1=bFirstCount
        local cbCardData1=clone(bInFirstList)
        local cbBlockCount2=bNextCount
        local cbCardData2=clone(bInNextList)
        for i=cbBlockCount1,1,-1 do--把A替换成14
                if cbCardData1[i].value==1 then
                    cbCardData1[i].value=14
                end
            end     
            for i=cbBlockCount2,1,-1 do--把A替换成14
                if cbCardData2[i].value==1 then
                    cbCardData2[i].value=14
                end
            end         
        local function findFront(bInNextList, bNextCount)
            local SearchCardCountj, SearchCardResultj = self:SearchSameCardByhh(bInNextList, bNextCount)
            if SearchCardCountj[3]~=0 then
                return 3
                -- 三条
            end
            if SearchCardCountj[2]==2 then
                return 2
                -- 两对
            end
            if SearchCardCountj[2]==1 then
                return 1
                -- 对子
            end
            
            return 0-- 单牌

        end
        local  function findCardType(bInNextList,bNextCount)
               if self:IsLinkCardhh(bInNextList,bNextCount) and self:IsSameColorCard(bInNextList,bNextCount) then
                   return 8--同花顺
               end
                if self:IsFourOneCount(bInNextList,bNextCount)  then
                   return 7--铁支
               end
                if self:IsHuLu(bInNextList,bNextCount)  then
                   return 6--葫芦
               end
               if self:IsSameColorCard(bInNextList,bNextCount)  then
                   return 5--同花
               end
               if self:IsLinkCardhh(bInNextList,bNextCount)  then
                   return 4--顺子
               end
               return findFront(bInNextList, bNextCount)
        end;
        local function Com(cbCardData1, cbCardData2, bFirstCount, bNextCount)--单牌比较  
              self:SortCardList(cbCardData1, table.nums(cbCardData1),0) 
              self:SortCardList(cbCardData2, table.nums(cbCardData2),0)
              --dump(cbCardData1,"cbCardData1") 
              --dump(cbCardData2,"cbCardData2")                           
              local min=math.min(bFirstCount,bNextCount)
              local equal=0
              for i=1,min do
                  if cbCardData1[i].value<cbCardData2[i].value then
                     return 2
                    elseif cbCardData1[i].value==cbCardData2[i].value then
                            equal=equal+1
                    else
                        return 1
                  end
              end
              if equal==min then
                 return 2
              end
          
        end
	     if bFirstCount==3 and bNextCount==5 then
            local front = findFront(cbCardData1, cbBlockCount1)
            local body = findCardType(cbCardData2, cbBlockCount2)
                if body > front then
                    return 2
                elseif body < front then
                    return 1
                elseif body == front then                    
                       return Com(cbCardData1, cbCardData2, bFirstCount, bNextCount)                  
               end 
        elseif bFirstCount==5 and bNextCount==5 then
            local body = findCardType(cbCardData1, cbBlockCount1)
            local tail = findCardType(cbCardData2, cbBlockCount2)
            --log("body牌型 "..body)
           -- log("tail牌型 "..tail)
            if tail > body then
                    return 2
            elseif tail < body then
                    return 1
            elseif  tail == body then                    
                       return Com(cbCardData1, cbCardData2, bFirstCount, bNextCount)                  
               end 
        end
end
]]
--分析扑克
function class:analyseCard(cardData, cardCount)
    --dump(cardData,"analyseCard")
	local info = 
	{
		bFlush = false,			--是否同花
		oneCount = 0,			--单张数目
		twoCount = 0,			--两张数目 
		threeCount = 0,			--三张数目
		fourCount = 0,			--四张数目

		oneFirst = {},			--单牌位置
		twoFirst = {},			--对牌位置
		threeFirst = {},		--三条位置
		fourFirst = {},			--四张位置
	}

	local sameCount = 1
	local sameColorCount = 1
	local firstCardIndex = 1
	local logicValue = cardData[1].value
	local cardColor = cardData[1].color
	local cardTempValue = 0
	for i = 2, cardCount do
		cardTempValue = cardData[i].value
		if cardTempValue == logicValue then
			sameCount = sameCount + 1
		end

		--保存结果
		if cardTempValue ~= logicValue or i == cardCount then
			if sameCount == 1 then
			
			elseif sameCount == 2 then				
				table.insert(info.twoFirst, firstCardIndex)
				info.twoCount = info.twoCount + 1
			elseif sameCount == 3 then
				table.insert(info.threeFirst, firstCardIndex)
				info.threeCount = info.threeCount + 1
			elseif sameCount == 4 then
				table.insert(info.fourFirst, firstCardIndex)
				info.fourCount = info.fourCount + 1
			end
		end

		--设置变量
		if cardTempValue  ~= logicValue then
			if sameCount == 1 then
				if i ~= cardCount then
					info.oneCount = info.oneCount + 1
					table.insert(info.oneFirst, firstCardIndex)
				else
					info.oneCount = info.oneCount + 1
					table.insert(info.oneFirst, firstCardIndex)
					info.oneCount = info.oneCount + 1
					table.insert(info.oneFirst, i)
				end
			else
				if i == cardCount then
					info.oneCount = info.oneCount + 1
					table.insert(info.oneFirst, i)
				end
			end

			--重置数据
			sameCount = 1
			logicValue = cardTempValue
			firstCardIndex = i
		end

		--判断同花
		if cardData[i].color ~= cardColor then
			sameColorCount = 1
		else
			sameColorCount =  sameColorCount + 1
		end
	end

	if sameColorCount == cardCount then
		info.bFlush = true
	end

	return info
end

--获取类型
function class:getCardType(cardData, cardCount, analyseData, specialCard)
    
	cardCount = cardCount or #cardData
	-- if cardCount ~= 3 and cardCount ~= 5 and cardCount ~= 13 then
	-- 	return self.CARD_TYPE.CT_INVALID
	-- end
	if cardCount <= 0 then
		return self.CARD_TYPE.CT_INVALID
	end
	--dump(cardData, "CardHandle:getCardType :: cardData")
    --dump(analyseData,"analyseData")
    --dump(cardData,"getCardType")
	local analyseData = analyseData or self:analyseCard(cardData, cardCount)
    --dump(analyseData,"analyseData2222222")
	--dump(analyseData, "CardHandle:getCardType :: analyseData")

	if cardCount <= 3 then
		--单牌类型
		if analyseData.oneCount == cardCount then
			return self.CARD_TYPE.CT_SINGLE 
		end

		--对带一张
		if analyseData.twoCount == 1 and analyseData.oneCount == 1 then
			return self.CARD_TYPE.CT_ONE_DOUBLE
		end

		--三条
		if analyseData.threeCount == 1 then
			return self.CARD_TYPE.CT_THREE
		end

		--错误
		return self.CARD_TYPE.CT_INVALID

    elseif cardCount <= 5 then
        local isStraight=true
        for index = 1,4 do
            if (cardData[index].value - cardData[index + 1].value) ~= 1 then
                isStraight=false
                break
            end
        end
        if cardData[1].value==14 and cardData[2].value==5 and cardData[3].value==4 and cardData[4].value==3 and         cardData[5].value==2 then
            isStraight=true
        end
        if isStraight==true then
            local bStraightNoA	= true
            local bStraightFirstA = false
            local bStraightBackA = false

            if cardCount == 5 then
                --A连在后
                local firstValue = cardData[1].value
                local lastValue = cardData[5].value
                --[[if firstValue == 10 and lastValue == 14 then
                    bStraightBackA = true
                else
                    bStraightNoA = true
                end
                if  bStraightBackA == false then
                    if firstValue == 2 and lastValue == 14 then 
                        bStraightBackA = true
                    else
                        bStraightNoA = true
                    end
                end
                
                for index = 1, 3 do
                    if (cardData[index].value - cardData[index + 1].value) ~= 1 then
                        bStraightBackA = false
                        bStraightNoA = false
                        break
                    end
                end]]
                --A连在前
                if  firstValue == 14 then
                    bStraightFirstA =  true
                    for index = 2, 4 do
                        if (cardData[index].value - cardData[index + 1].value) ~= 1 then
                            bStraightFirstA = false
                            break
                        end
                    end
                    if lastValue == 2 or lastValue == 10 then

                    else
                        bStraightFirstA = false
                    end
                    
                end
            end
            if bStraightFirstA==false then
                local bStraightNoA	= true
            else
                local bStraightNoA	= false
            end
            --同花五牌
            
            if bStraightNoA == true then
                if analyseData.bFlush == false then
                    --杂顺类型
                    return self.CARD_TYPE.CT_FIVE_MIXED_STRAIGHT_NO_A
                else
                    --同花顺牌
                    return self.CARD_TYPE.CT_FIVE_STRAIGHT_FLUSH_NO_A
                end
            elseif bStraightFirstA == true then
                if analyseData.bFlush == false then
                    --杂顺类型
                    return self.CARD_TYPE.CT_FIVE_MIXED_STRAIGHT_FIRST_A
                else
                    --同花顺牌
                    return self.CARD_TYPE.CT_FIVE_STRAIGHT_FLUSH_FIRST_A
                end
            elseif bStraightBackA == true then
                if analyseData.bFlush == false then
                    --杂顺类型
                    return self.CARD_TYPE.CT_FIVE_MIXED_STRAIGHT_BACK_A
                else
                    --同花顺牌
                    return self.CARD_TYPE.CT_FIVE_STRAIGHT_FLUSH_BACK_A
                end
            end
        end
        if self:IsSameColorCard(cardData, cardCount) then --同花
            return self.CARD_TYPE.CT_FIVE_FLUSH
        end
		--四带单张
		if analyseData.fourCount==1 and analyseData.oneCount==1 then
			return self.CARD_TYPE.CT_FIVE_FOUR_ONE
		end

		--三条一对
		if analyseData.threeCount==1 and analyseData.twoCount==1 then
			return self.CARD_TYPE.CT_FIVE_THREE_DEOUBLE
		end
		
		--三条带单
		if analyseData.threeCount==1 and analyseData.oneCount==2 then
			return self.CARD_TYPE.CT_THREE
		end
		
		--两对牌型
		if analyseData.twoCount==2 and analyseData.oneCount==1 then
			return self.CARD_TYPE.CT_FIVE_TWO_DOUBLE
		end
		
		--只有一对
		if analyseData.twoCount==1 and analyseData.oneCount==3 then
			return self.CARD_TYPE.CT_ONE_DOUBLE
		end
		
		--单牌类型
		if analyseData.bFlush==false and analyseData.oneCount==cardCount then
			return self.CARD_TYPE.CT_SINGLE
		end

		--错误
		return self.CARD_TYPE.CT_INVALID

	elseif cardCount == 13 then
		--13张特殊牌型
		--五对冲三
		if (5==analyseData.twoCount and 1==analyseData.threeCount) or (3==analyseData.twoCount and 1==analyseData.fourCount and 1==analyseData.threeCount)
				or (1==analyseData.twoCount and 2==analyseData.fourCount and 1==analyseData.threeCount) then
			specialCard = specialCard or {}
			specialCard[1] = {11, 12, 13}
			specialCard[2] = {6, 7, 8, 9, 10}
			specialCard[3] = {1, 2, 3, 4, 5}
			-- local twoFirst = analyseData.twoFirst
			-- local fourFirst = analyseData.fourFirst
			-- local threeFirst = analyseData.threeFirst
			-- if 5 == analyseData.twoCount then
			-- 	specialCard = specialCard or {}
			-- 	specialCard[1] = {twoFirst[3], twoFirst[3]+1, twoFirst[4]}
			-- 	specialCard[2] = {twoFirst[1], twoFirst[1]+1, twoFirst[2], twoFirst[2]+1, twoFirst[4]+1}
			-- 	specialCard[3] = {threeFirst[1], threeFirst[1]+1, threeFirst[1]+2, twoFirst[5], twoFirst[5]+1}
			-- elseif 3 == analyseData.twoCount then
			-- 	specialCard = specialCard or {}
			-- 	specialCard[1] = {twoFirst[1], twoFirst[1]+1, twoFirst[3]+1}
			-- 	specialCard[2] = {threeFirst[1], threeFirst[1]+1, threeFirst[1]+2, twoFirst[2]+1, twoFirst[2]+1}
			-- 	specialCard[3] = {fourFirst[1], fourFirst[1]+1, fourFirst[1]+2, fourFirst[1]+3, twoFirst[3]}
			-- else
			-- 	specialCard = specialCard or {}
			-- 	specialCard[1] = {threeFirst[1], threeFirst[1]+1, threeFirst[1]+2}
			-- 	specialCard[2] = {fourFirst[2], fourFirst[2]+1, fourFirst[2]+2, fourFirst[2]+3, twoFirst[1]}
			-- 	specialCard[3] = {fourFirst[1], fourFirst[1]+1, fourFirst[1]+2, fourFirst[1]+3, twoFirst[1]}
			-- end

			return self.CARD_TYPE.CT_SIXPAIR
		end

		--六对半(五对冲三也当六对半)
		if (6==analyseData.twoCount) or (4==analyseData.twoCount and 1==analyseData.fourCount) or (2==analyseData.twoCount and 2==analyseData.fourCount) then
			specialCard = specialCard or {}
			specialCard[1] = {11, 12, 13}
			specialCard[2] = {6, 7, 8, 9, 10}
			specialCard[3] = {1, 2, 3, 4, 5}
			-- local twoFirst = analyseData.twoFirst
			-- local fourFirst = analyseData.fourFirst
			-- if 6==analyseData.twoCount then
			-- 	specialCard = specialCard or {}
			-- 	specialCard[1] = {twoFirst[5], twoFirst[5]+1, analyseData.oneFirst[1]}
			-- 	specialCard[2] = {twoFirst[3], twoFirst[3]+1, twoFirst[4], twoFirst[4]+1, twoFirst[6]+1}
			-- 	specialCard[3] = {twoFirst[1], twoFirst[1]+1, twoFirst[2], twoFirst[2]+1, twoFirst[6]}
			-- elseif 4==analyseData.twoCount then
			-- 	specialCard = specialCard or {}
			-- 	specialCard[1] = {twoFirst[3], twoFirst[3]+1, analyseData.oneFirst[1]}
			-- 	specialCard[2] = {twoFirst[1], twoFirst[1]+1, twoFirst[2], twoFirst[2]+1, twoFirst[4]+1}
			-- 	specialCard[3] = {fourFirst[1], fourFirst[1]+1, fourFirst[1]+2, fourFirst[1]+3, twoFirst[4]}
			-- else
			-- 	specialCard = specialCard or {}
			-- 	specialCard[1] = {twoFirst[1], twoFirst[1]+1, analyseData.oneFirst[1]}
			-- 	specialCard[2] = {fourFirst[2], fourFirst[2]+1, fourFirst[2]+2, fourFirst[2]+3, twoFirst[2]+1}
			-- 	specialCard[3] = {fourFirst[1], fourFirst[1]+1, fourFirst[1]+2, fourFirst[1]+3, twoFirst[2]}
			-- end

			return self.CARD_TYPE.CT_SIXPAIR
        end
    end
	return self.CARD_TYPE.CT_INVALID
end
function class:transATo14(cardData)
         for k,v in ipairs(cardData)do
             if v.value==1 then
                v.value=14
             end
         end

end
function class:trans14ToA()
         for k,v in ipairs(cardData)do
             if v.value==14 then
                v.value=1
             end
         end
end
function class:compareCard(firstList, nextList, firstCount, nextCount)
    local firstList=clone(firstList)
    local nextList=clone(nextList)
    self:transATo14(firstList)
    self:transATo14(nextList)
    self:SortCardList(firstList,firstCount,0)
    self:SortCardList(nextList,nextCount,0) 
	local firstAnalyseData = self:analyseCard(firstList, firstCount)
	local nextAnalyseData = self:analyseCard(nextList, nextCount)
	local firstType = self:getCardType(firstList, firstCount, firstAnalyseData)
	local nextType = self:getCardType(nextList, nextCount, nextAnalyseData)
	--log("compareCard =======> firstType:"..firstType..", nextType:"..nextType)
	if firstType == self.CARD_TYPE.CT_INVALID or nextType == self.CARD_TYPE.CT_INVALID then
		return false
	end

	if firstType == nextType then
		if firstType == self.CARD_TYPE.CT_SINGLE then
			--单牌类型
			local allSame = true
			for i = 1, firstCount do
				if firstList[i].value ~= nextList[i].value then
					allSame = false
					break
				end
			end

            if allSame then --比较花色
                for i = 1, firstCount do
                    if firstList[i].color ~= nextList[i].color then
                        return nextList[i].color > firstList[i].color
                    end
                end
			else
				for i = 1, firstCount do
					if firstList[i].value ~= nextList[i].value then
						return nextList[i].value > firstList[i].value
					end
				end
			end

			return nextCount > firstCount

		elseif firstType == self.CARD_TYPE.CT_ONE_DOUBLE then
			--对带一张
			if nextList[nextAnalyseData.twoFirst[1]].value == firstList[firstAnalyseData.twoFirst[1]].value then
				if nextList[nextAnalyseData.oneFirst[1]].value ~= firstList[firstAnalyseData.oneFirst[1]].value then
					return nextList[nextAnalyseData.oneFirst[1]].value > firstList[firstAnalyseData.oneFirst[1]].value
				else
					return nextList[nextAnalyseData.twoFirst[1]].color > firstList[firstAnalyseData.twoFirst[1]].color
				end
			else
				return nextList[nextAnalyseData.twoFirst[1]].value > firstList[firstAnalyseData.twoFirst[1]].value
			end
			return nextCount > firstCount
		elseif firstType == self.CARD_TYPE.CT_FIVE_TWO_DOUBLE then
			--两对牌型
			if nextList[nextAnalyseData.twoFirst[1]].value == firstList[firstAnalyseData.twoFirst[1]].value then
				if nextList[nextAnalyseData.twoFirst[2]].value == firstList[firstAnalyseData.twoFirst[2]].value then
					--对子相等，比较单牌
					if nextList[nextAnalyseData.oneFirst[1]].value ~= firstList[firstAnalyseData.oneFirst[1]].value then
						return nextList[nextAnalyseData.oneFirst[1]].value > firstList[firstAnalyseData.oneFirst[1]].value
					else
						return nextList[nextAnalyseData.twoFirst[1]].color > firstList[firstAnalyseData.twoFirst[1]].color --比较花色
					end
				else
					return nextList[nextAnalyseData.twoFirst[2]].value > firstList[firstAnalyseData.twoFirst[2]].value
				end
			else
				return nextList[nextAnalyseData.twoFirst[1]].value > firstList[firstAnalyseData.twoFirst[1]].value
			end

		elseif firstType == self.CARD_TYPE.CT_THREE then
			--三张牌型
			return nextList[nextAnalyseData.threeFirst[1]].value > firstList[firstAnalyseData.threeFirst[1]].value

		elseif firstType==self.CARD_TYPE.CT_FIVE_MIXED_STRAIGHT_FIRST_A or firstType==self.CARD_TYPE.CT_FIVE_MIXED_STRAIGHT_NO_A or firstType==self.CARD_TYPE.CT_FIVE_MIXED_STRAIGHT_BACK_A then
			--A在前顺子 没A杂顺 A在后顺子
			if nextList[1].value == firstList[1].value then
				return nextList[1].color > firstList[1].color
			else
				return nextList[1].value > firstList[1].value
			end
		elseif firstType == self.CARD_TYPE.CT_FIVE_FLUSH then
			--同花
			for i = 1, 5 do
				if nextList[i].value ~= firstList[i].value then
					return nextList[i].value > firstList[i].value
				end
			end

			return nextList[1].color > firstList[1].color
		elseif firstType == self.CARD_TYPE.CT_FIVE_THREE_DEOUBLE then
			--三条一对
			return nextList[nextAnalyseData.threeFirst[1]].value > firstList[firstAnalyseData.threeFirst[1]].value
		elseif firstType == self.CARD_TYPE.CT_FIVE_FOUR_ONE then
			--四带一张
			return nextList[nextAnalyseData.fourFirst[1]].value > firstList[firstAnalyseData.fourFirst[1]].value
		elseif firstType==self.CARD_TYPE.CT_FIVE_STRAIGHT_FLUSH_NO_A or firstType==self.CARD_TYPE.CT_FIVE_STRAIGHT_FLUSH_FIRST_A or firstType==self.CARD_TYPE.CT_FIVE_STRAIGHT_FLUSH_BACK_A then
			--没A同花顺 A在前同花顺 A在后同花顺
			for i = 1, 5 do
				if nextList[i].value ~= firstList[i].value then
					return nextList[i].value > firstList[i].value
				end
			end

			return nextList[1].color > firstList[1].color
		else
			return false
		end
	else
		return nextType > firstType
	end

	return false
end
--[[
--是否铁支  
function class:IsFourOneCount(cbCardData, cbCardCount)
        self:SortCardList(cbCardData, cbCardCount, 1)
        if cbCardData[1].value==cbCardData[2].value then
            if cbCardData[1].value==cbCardData[3].value and cbCardData[1].value==cbCardData[4].value then
                return true
            else
                return false
            end
        elseif cbCardData[4].value==cbCardData[5].value then
                if cbCardData[2].value == cbCardData[5].value and cbCardData[3].value == cbCardData[5].value then
                    return true
                else
                    return false
                end
        else
            return false
        end
end
--是否葫芦  
function class:IsHuLu(cbCardData, cbCardCount)
        self:SortCardList(cbCardData, cbCardCount, 1)
        if cbCardData[1].value==cbCardData[2].value and cbCardData[2].value==cbCardData[3].value then
            if cbCardData[4].value==cbCardData[5].value  then
                return true
            else
                return false
            end
        elseif cbCardData[5].value==cbCardData[4].value and cbCardData[4].value==cbCardData[3].value  then
                if cbCardData[1].value == cbCardData[2].value  then
                    return true
                else
                    return false
                end
        else
            return false
        end
end
]]
--是否顺子  
function class:IsLinkCardhh(cbCardData, cbCardCount)
    self:SortCardList(cbCardData, cbCardCount, 1)--从小到大
      local function findValue(arg)
            for k, v in ipairs(cbCardData) do-- 有A,k,q,j,10时,才替换
                    if v.value==arg then
                       return true
                    end
            end
        end      
    for i=1,cbCardCount-1 do
        if cbCardData[i].value+1==cbCardData[i+1].value then
            if i==cbCardCount-1 then
                return true
            end
        else
        if findValue(2) and findValue(3) and findValue(4) and findValue(5) and findValue(14) then
            return true
        end
            return false
        end
    end
end

--是否同花
function class:IsSameColorCardhh(cbCardData, cbCardCount)
    for k, v in ipairs(cbCardData) do
        if v.color == cbCardData[1].color then
            if k == cbCardCount then
                return true
            end
        else
            return false
        end
    end
end

--是否三同花
function class:IsSanTongHua(cbCardData, cbCardCount)
         if cbCardCount~=13 then return end
         local cbColorData=self:SortCardListColor(cbCardData, cbCardCount)
         --特殊情形   8个牌一种颜色,5个牌另一种颜色(,10个牌一种颜色,3个牌另一种颜色,摆牌有错误
         local exceptionalCase=true
         for i=1,8 do
            if  cbColorData[1].color~=cbColorData[i].color then
                exceptionalCase=false
                break
            end
         end
          for j=9,13 do
            if  cbColorData[9].color~=cbColorData[j].color then
                exceptionalCase=false
                break
            end
         end
         if exceptionalCase==true then return true end
         for i=1,5 do
            if  cbColorData[1].color~=cbColorData[i].color then
                return false
            end
         end
          for j=6,10 do
            if  cbColorData[6].color~=cbColorData[j].color then
                return false
            end
         end
          for j=11,13 do
            if  cbColorData[11].color~=cbColorData[j].color then
                return false
            end
         end
         return true
end
--是否顺子(只判断3张或者5张牌)
function class:isStraight(cardData)
	--dump(cardData, "isStraight cardData")
	local cardCount = #cardData
	assert(cardCount==3 or cardCount==5, string.format("isStraight error with invalid card count : \"%d\"", cardCount))

	table.sort(cardData, function (a, b)
		if a.value == b.value then
			return a.color > b.color
		else
			return a.value > b.value
		end
	end)

	if cardCount == 3 then
		if cardData[1].value == cardData[2].value+1 and cardData[1].value == cardData[3].value+2 then
			return true
		end

		if cardData[1].value==14 and cardData[2].value == 3 and cardData[3].value == 2 then
			return true
		end

		return false
	end

	if cardData[1].value == 14 then
		if cardData[2].value==5 and cardData[3].value==4 and cardData[4].value==3 and cardData[5].value==2 then
			return true
		end
	end
	
	if cardData[1].value==cardData[2].value+1 and cardData[1].value==cardData[3].value+2 and cardData[1].value==cardData[4].value+3 and cardData[1].value==cardData[5].value+4 then
		return true
	end

	return false
end
--是否三顺子
function class:isThreeStraight(cbCardData, cbCardCount)  --hhhh
    local cardData=clone(cbCardData)
    for i=cbCardCount,1,-1 do
        if cardData[i].value==1 then
            cardData[i].value=14
        end
    end
    self:SortCardList(cardData, cbCardCount, 0)
   -- dump(cardData,"cardData")
    local specialData={}
	local specialCardData = nil
	local count = 0
	local isBeganA = false --是否A开头 (A开头：A2345或A23)
	local isThreeStraight = false
	while(count < 2) do
		--分两步，1：判断非A开头，2：判断A开头
		specialCardData = {[1] = {}, [2] = {}, [3] = {}}
		--print("count ########### "..count)
		local tempCardData = {}
		for i, v in ipairs(cardData) do
			table.insert(tempCardData, {index = i, value = v.value, color = v.color})
		end

		local tempTab = {}

		if self:getDifferentDataArray(tempCardData, tempTab, 5, isBeganA)==true and self:isStraight(tempTab)==true then
			self:removeCard(tempCardData, tempTab)
			specialCardData[2] = clone(tempTab)
			--print("count:"..count..", isBeganA:"..(isBeganA and 1 or 0))

			if self:getDifferentDataArray(tempCardData, tempTab, 5, isBeganA)==true and self:isStraight(tempTab)==true then
				local temp = clone(tempCardData)
				self:removeCard(temp, tempTab)
				specialCardData[3] = clone(tempTab)
				if self:isStraight(temp) then
					--存在三顺子
					specialCardData[1] = clone(temp)
					isThreeStraight = true
					break
				end
			end

			if self:getDifferentDataArray(tempCardData, tempTab, 3, isBeganA)==true and self:isStraight(tempTab)==true then
				local temp = clone(tempCardData)
				self:removeCard(temp, tempTab)
				specialCardData[1] = clone(tempTab)
				if self:isStraight(temp) then
					--存在三顺子
					specialCardData[3] = clone(temp)
					isThreeStraight = true
					break
				end
			end

			if self:getDifferentDataArray(tempCardData, tempTab, 5, not isBeganA)==true and self:isStraight(tempTab)==true then
				local temp = clone(tempCardData)
				self:removeCard(temp, tempTab)
				specialCardData[3] = clone(tempTab)
				if self:isStraight(temp) then
					--存在三顺子
					specialCardData[1] = clone(temp)
					isThreeStraight = true
					break
				end
			end

			if self:getDifferentDataArray(tempCardData, tempTab, 3, not isBeganA)==true and self:isStraight(tempTab)==true then
				local temp = clone(tempCardData)
				self:removeCard(temp, tempTab)
				specialCardData[1] = clone(tempTab)
				if self:isStraight(temp) then
					--存在三顺子
					specialCardData[3] = clone(temp)
					isThreeStraight = true
					break
				end
			end
		end

		tempCardData = {}
		for i, v in ipairs(cardData) do
			table.insert(tempCardData, {index = i, value = v.value, color = v.color})
		end
		if self:getDifferentDataArray(tempCardData, tempTab, 3, isBeganA)==true and self:isStraight(tempTab)==true then
			--考虑3张情况
			self:removeCard(tempCardData, tempTab)
			specialCardData[1] = clone(tempTab)
			if self:getDifferentDataArray(tempCardData, tempTab, 5, isBeganA)==true and self:isStraight(tempTab)==true then
				local temp = clone(tempCardData)
				self:removeCard(temp, tempTab)
				specialCardData[2] = clone(tempTab)
				if self:isStraight(temp) then
					--存在三顺子
					specialCardData[3] = clone(temp)
					isThreeStraight = true
					break
				end
			end

			if self:getDifferentDataArray(tempCardData, tempTab, 5, not isBeganA)==true and self:isStraight(tempTab)==true then
				local temp = clone(tempCardData)
				self:removeCard(temp, tempTab)
				specialCardData[2] = clone(tempTab)
				if self:isStraight(temp) then
					--存在三顺子
					specialCardData[3] = clone(temp)
					isThreeStraight = true
					break
				end
			else

			end
		
		else
			--尼玛，跑这里应该就不存在三顺子了
			
		end
		isBeganA = true
		count = count + 1
	end

	specialData = specialData or {}
	for i, v in ipairs(specialCardData) do
		specialData[i] = {}
		for m, n in ipairs(v) do
			table.insert(specialData[i], n.index)
		end
	end
    local allShunzi={{},{},{}}
    for k, v in ipairs(specialData) do
        for k1, v1 in ipairs(v) do
            table.insert(allShunzi[k], cardData[v1])
        end
    end
    --dump(allShunzi,"allShunzi")
    for k, v in ipairs(allShunzi) do
        for k1, v1 in ipairs(v) do
            if v1.value == 14 then
                v1.value = 1
            end
        end
    end
       -- dump(allShunzi,"allShunzi1")
       -- dump(isThreeStraight,"isThreeStraight")
	return isThreeStraight,allShunzi
end
--数组里查找N的长度的不同数据装进数组 isBeganA:是否A开头，A开头：A2345; 非A开头：AKQJ10
function class:getDifferentDataArray(srcArray, targetArray, targetNum, isBeganA)
	local srcCount = #srcArray
	if srcCount < targetNum then
		return false
	end

	for i = #targetArray, 1, -1 do
		table.remove(targetArray, i)
	end

	local count = 0
	if isBeganA == false then
		for i = 1, srcCount-1 do
			if count < targetNum then 
				if srcArray[i].value ~= srcArray[i+1].value then
					targetArray[#targetArray + 1] = srcArray[i]
					count = count + 1
					
					if i == srcCount-1 and count < targetNum then
						targetArray[#targetArray + 1] = srcArray[i+1]
						count = count + 1
					end
				else
					if i == srcCount-1 then
						targetArray[#targetArray + 1] = srcArray[i+1]
						count = count + 1
					end
				end
			else
				break
			end
		end
	else
		--dump(srcArray, "isBeganA == true")
		if srcArray[1].value == 14 then
			targetArray[1] = srcArray[1]
			count = count + 1
			for i = srcCount, 2, -1 do
				if count < targetNum then 
					if srcArray[i].value ~= srcArray[i-1].value then
						targetArray[#targetArray + 1] = srcArray[i]
						count = count + 1
						
						-- if i == 2 and count < targetNum then
						-- 	targetArray[#targetArray + 1] = srcArray[i-1]
						-- 	count = count + 1
						-- end
					else
						-- if i == 2 then
						-- 	targetArray[#targetArray + 1] = srcArray[i-1]
						-- 	count = count + 1
						-- end
					end
				else
					break
				end
			end

			table.sort(targetArray, function (a, b)
				if a.value == b.value then
					return a.color > b.color
				else
					return a.value > b.value
				end
			end)
		else
			return false
		end

		--dump(targetArray, "isBeganA == true")
	end

	--dump(targetArray, "getDifferentDataArray")
	return count == targetNum
end

--移除数组中部分数据
function class:removeCard(srcArray, targetArray)
	local c = 0
	for i = 1, #targetArray do
		for j = 1, #srcArray do
			-- if srcArray[j].value == targetArray[i].value and srcArray[j].color == targetArray[i].color then
			if srcArray[j].index == targetArray[i].index then
				table.remove(srcArray, j)
				c = c + 1
				break
			end
		end
	end
	-- local c, i, max = 0, 1, #srcArray
	-- while i <= max do
	-- 	for index = 1, #targetArray do
	-- 		if srcArray[i].value == targetArray[index].value and srcArray[i].color == targetArray[index].color then
	-- 			table.remove(srcArray, i)
	-- 			c = c + 1
	-- 			i = i - 1
	-- 			max = max - 1

	-- 			table.remove(targetArray, index)
	-- 			break
	-- 		end
	-- 	end

	-- 	i = i + 1
	-- end
	--print("removeCard num : "..c)
	return c
end


--是否同花
function class:IsSameColorCard(cbCardData, cbCardCount)
	if cbCardCount <= 0 then
		return false
	end
	local bRet = true
	local cbFirstCardColor = cbCardData[1].color
	for i=2,cbCardCount do
		local cbNextCardColor = cbCardData[i].color
		if cbFirstCardColor ~= cbNextCardColor then
			return false
		end
	end

	return bRet
end
--三同花顺
function class:IsSanTongHuaShun(cbHandCardData,cbHandCardCount)
          --即是三顺子,又是三同花,却不是三同花顺
          --1,1,1,1,1,4,1,4,1,4,1  ,1,1
          --2,3,4,6,7,8,8,9,9,10,10,j,q
           if  self:IsSanTongHua(cbHandCardData,cbHandCardCount)  and  self:isThreeStraight(cbHandCardData,cbHandCardCount) then --三同花顺
               -- dump(cbHandCardData, "三同花顺初始牌")
                self:SortCardList(cbHandCardData, cbHandCardCount, 1)
                local cardData = clone(cbHandCardData)
              --[[  local function findValue(arg)  当三同花顺有比较大小时继续搞
                    local count = 0
                    for k, v in ipairs(cardData) do
                        -- 有A,k,q,j,10时,才替换
                        if v.value == arg then
                            count = count + 1
                        end
                    end
                    return count,v.color
                end
                local Fcount1,Fcolor1=findValue(1)
                local Fcount13,Fcolor13=findValue(13)
                local Fcount12,Fcolor12=findValue(12)
               
                local needANum = math.min()
                for i = table.nums(cardData), 1, -1 do
                    if cardData[i].value == 1 and needANum > 0 then                       
                            cardData[i].value = 14
                            needANum = needANum - 1
                    end
                end
                 self:SortCardList(cardData, table.nums(cardData), 1)
                dump(cardData, "14的数量")
                ]]
                local allShunzi = { }
                for i = 1, 13 do
                    local CardCount = table.nums(cardData)
                    if CardCount == 0 then break end
                    allShunzi[i] = { }
                    local constNum = cardData[CardCount].value
                    local constColor = cardData[CardCount].color
                    for j = CardCount, 1, -1 do
                        if constNum == cardData[j].value and constColor==cardData[j].color then
                            table.insert(allShunzi[i], table.remove(cardData, j))
                            constNum = constNum - 1
                             if table.nums(allShunzi[i])>=5 then
                                break
                             end 
                        end
                    end
                end
                --dump(allShunzi,"allShunzi")
                if table.nums(allShunzi) == 3 then
                    return true,allShunzi
                else
                    return false
                end
            end
            return false

end

--判断特殊牌型，必须为13张
function class:GetSpecialType(cbHandCardData, cbHandCardCount)
	if cbHandCardCount ~= 13 then 
        --log("no 13 counts pai")
        return 
    end
	local cbLineCardData = {{},
                            {},
                            {}
    }
    local function CardDataPush(CardData,line) --一个数字不要在这里插入,只插入table
          for k,v in ipairs(CardData) do
                  table.insert(cbLineCardData[line],v)
              if line==1 and k==3 then
                 break
              end
              if line==2 or line==3 then
                if k==5 then
                    break
                end
              end
          end
    end 
                           
    --同花十三水
        self:SortCardList(cbHandCardData,cbHandCardCount,1)  --升序
        if self:IsLinkCardhh(cbHandCardData,cbHandCardCount)==true  and  self:IsSameColorCardhh(cbHandCardData,cbHandCardCount)==true then  --同花十三水
            CardDataPush( { cbHandCardData[1], cbHandCardData[2], cbHandCardData[3] }, 1)
            CardDataPush( { cbHandCardData[4], cbHandCardData[5], cbHandCardData[6], cbHandCardData[7], cbHandCardData[8] }, 2)
            CardDataPush( { cbHandCardData[9], cbHandCardData[10], cbHandCardData[11], cbHandCardData[12] , cbHandCardData[13] }, 3)
            return ShiSanShui_pb.THIRTEEN_FLUSH,cbLineCardData
        end
       if self:IsLinkCardhh(cbHandCardData,cbHandCardCount)==true  then  --十三水
            CardDataPush( { cbHandCardData[1], cbHandCardData[2], cbHandCardData[3] }, 1)
            CardDataPush( { cbHandCardData[4], cbHandCardData[5], cbHandCardData[6] , cbHandCardData[7], cbHandCardData[8] }, 2)
            CardDataPush( { cbHandCardData[9], cbHandCardData[10], cbHandCardData[11], cbHandCardData[12] , cbHandCardData[13] }, 3)
            return ShiSanShui_pb.THIRTEEN,cbLineCardData
        end 
        
        local cbBlockCount, cbCardData= self:SearchSameCardByhh(cbHandCardData,cbHandCardCount)--三套炸弹
        --dump(cbBlockCount,"cbBlockCount",5)
        --dump(cbCardData,"cbCardData",5)
        if cbBlockCount[4]==3 then
            CardDataPush( { cbCardData[4][1], cbCardData[4][2], cbCardData[4][3],cbCardData[4][4],cbCardData[4][12] }, 3)
            CardDataPush( { cbCardData[4][5], cbCardData[4][6], cbCardData[4][7],cbCardData[4][8],cbCardData[4][11] }, 2)
            CardDataPush( { cbCardData[4][9], cbCardData[4][10],cbCardData[1][1]}, 1)
           -- dump(cbLineCardData,"3 boom")
            return ShiSanShui_pb.THREE_BOOM , cbLineCardData
        end        
        if cbBlockCount[3]==4 then          --4个三条
            CardDataPush( { cbCardData[3][1], cbCardData[3][2], cbCardData[3][3],cbCardData[3][11],cbCardData[3][12] }, 3)
            CardDataPush( { cbCardData[3][4], cbCardData[3][5], cbCardData[3][6],cbCardData[3][10],cbCardData[3][9] }, 2)
            CardDataPush( { cbCardData[3][7], cbCardData[3][8],cbCardData[1][1]}, 1)
           -- dump(cbLineCardData,"4 ge 3 tiao")
            return ShiSanShui_pb.FOUR_THREE, cbLineCardData
        end
        if cbBlockCount[3]==3 and  cbBlockCount[4]==1 then          --4个三条
            CardDataPush( { cbCardData[4][1], cbCardData[4][2], cbCardData[4][3],cbCardData[4][4],cbCardData[3][9] }, 3)
            CardDataPush( { cbCardData[3][1], cbCardData[3][2], cbCardData[3][3],cbCardData[3][8],cbCardData[3][7] }, 2)
            CardDataPush( { cbCardData[3][4], cbCardData[3][5],cbCardData[3][6]}, 1)
            --dump(cbLineCardData,"四个三条")
            return ShiSanShui_pb.FOUR_THREE, cbLineCardData
        end
        if self.CARD_TYPE.CT_SIXPAIR==self:getCardType(cbHandCardData,cbHandCardCount) then
            cbCardData=clone(cbHandCardData)
           -- dump(cbCardData,"sixbehand")
            CardDataPush( { cbCardData[9], cbCardData[10], cbCardData[11] }, 1)
            CardDataPush( { cbCardData[5], cbCardData[6], cbCardData[7],cbCardData[8],cbCardData[12] }, 2)
            CardDataPush( { cbCardData[1], cbCardData[2], cbCardData[3],cbCardData[4],cbCardData[13]},3)
            --dump(cbLineCardData,"SIXPAIR and one")
            return ShiSanShui_pb.SIXPAIR, cbLineCardData
        end

        local resultSanTongHuaShun, allSanTongHuaShun = self:IsSanTongHuaShun(cbHandCardData, cbHandCardCount) 
        if resultSanTongHuaShun then-- 三同花顺
        local s1=table.nums(allSanTongHuaShun[1])
        local s2=table.nums(allSanTongHuaShun[2])
        local s3=table.nums(allSanTongHuaShun[3])
        if s1==3 then
            
        elseif s2==3 then
            allSanTongHuaShun[1],allSanTongHuaShun[2]=allSanTongHuaShun[2],allSanTongHuaShun[1]
        elseif s3==3 then
            allSanTongHuaShun[1],allSanTongHuaShun[3]=allSanTongHuaShun[3],allSanTongHuaShun[1]
        end

        local code=self:compareCard(allSanTongHuaShun[2], allSanTongHuaShun[3],5,5)      
        if  code==false then
            CardDataPush(allSanTongHuaShun[2], 3)
            CardDataPush(allSanTongHuaShun[3], 2)
        else
            CardDataPush(allSanTongHuaShun[2], 2)
            CardDataPush(allSanTongHuaShun[3], 3)
        end
        CardDataPush(allSanTongHuaShun[1], 1)  
            --dump(cbLineCardData,"cbLineCardData")  
            
            return ShiSanShui_pb.THREE_STRAIGHT_FLUSH, cbLineCardData
        end

        if  self:IsSanTongHua(cbHandCardData,cbHandCardCount) then  --三同花
            local cbHandCardData=self:SortCardListColor(cbHandCardData,cbHandCardCount)
            --dump(cbHandCardData)
            local exceptionalCase = true
            for i = 1, 8 do
                if cbHandCardData[1].color ~= cbHandCardData[i].color then
                    exceptionalCase = false
                    break
                end
            end
            for j = 9, 13 do
                if cbHandCardData[9].color ~= cbHandCardData[j].color then
                    exceptionalCase = false
                    break
                end
            end
            if exceptionalCase == true then
                CardDataPush( { cbHandCardData[1], cbHandCardData[2], cbHandCardData[3] }, 1)
                CardDataPush( { cbHandCardData[4], cbHandCardData[5], cbHandCardData[6], cbHandCardData[7], cbHandCardData[8] }, 2)
                CardDataPush( { cbHandCardData[9], cbHandCardData[10], cbHandCardData[11], cbHandCardData[12], cbHandCardData[13] }, 3)
                local code=self:compareCard(cbLineCardData[2], cbLineCardData[3],5,5)      
                    if  code==false then
                        cbLineCardData[2], cbLineCardData[3]=cbLineCardData[3], cbLineCardData[2]                     
                    end
                return ShiSanShui_pb.THREE_FLUSH, cbLineCardData
            else
                CardDataPush( { cbHandCardData[11], cbHandCardData[12], cbHandCardData[13] }, 1)
                CardDataPush( { cbHandCardData[6], cbHandCardData[7], cbHandCardData[8], cbHandCardData[9], cbHandCardData[10] }, 2)
                CardDataPush( { cbHandCardData[1], cbHandCardData[2], cbHandCardData[3], cbHandCardData[4], cbHandCardData[5] }, 3)
                local code=self:compareCard(cbLineCardData[2], cbLineCardData[3],5,5)      
                    if  code==false then
                        cbLineCardData[2], cbLineCardData[3]=cbLineCardData[3], cbLineCardData[2]                     
                    end
                return ShiSanShui_pb.THREE_FLUSH, cbLineCardData
            end
        end

            local resultSanShunZi, allSanShunZi = self:isThreeStraight(cbHandCardData, cbHandCardCount)--三顺子hhhh
           -- dump(allSanShunZi,"allSanShunZi2")
            if resultSanShunZi then   
                local code=self:compareCard(allSanShunZi[2], allSanShunZi[3],5,5)      
                if  code==false then
                    CardDataPush(allSanShunZi[2], 3)
                    CardDataPush(allSanShunZi[3], 2)
                else
                    CardDataPush(allSanShunZi[2], 2)
                    CardDataPush(allSanShunZi[3], 3)
                end
                CardDataPush(allSanShunZi[1], 1) 
                --log("San Shun zi------------") 
                --dump(cbLineCardData,"cbLineCardData")     
                return ShiSanShui_pb.THREE_STRAIGHT, cbLineCardData
            end

            return ShiSanShui_pb.NOT_SPECIALTYPE, cbLineCardData
	
end

--找出所有牌型
function class:sortAllCarsType(cbCardData,cbCardCount)
    local SortResult = {}
	local SortRecord = {}

	if cbCardCount == 0  then
		return
	end

    local function cardReverse(cards, cardCount)  --反转牌序
        for i = 1, cardCount do
            if i < cardCount / 2 + 1 then
                cards[i], cards[cardCount - i + 1] = cards[cardCount - i + 1], cards[i]
            end
        end
    end

     local function cardReverse2(cards,start,finish)
                local cardCount = finish - start + 1    
                for i = start, cardCount do
                    if i < cardCount / 2 + start then
                        cards[i], cards[finish - i + start] = cards[finish - i + start], cards[i]
                    end
                end
         end 
	-- 一对
	SortResult.bTwoCount = false
	SortResult.cbTwoList = {}

	--两对
	SortResult.bTwoDouleCount = false
	SortResult.cbTwoDoubleList = {}

	--三条 
	SortResult.bThreeCount = false
	SortResult.cbThreeList = {}

	--顺子
	SortResult.bLineCount = false
	SortResult.cbLineList = {}

	--同花
	SortResult.bSameColorCount = false
	SortResult.cbSameColorList = {}

	--葫芦
	SortResult.bThreeDouleCount = false
	SortResult.cbThreeDouleList = {}

	--铁支
	SortResult.bFourOneCount  = false
	SortResult.cbFourOneList = {}

	--同花顺
	SortResult.bFiveFlushCount = false
	SortResult.cbFiveFlushList = {}

	local SearchCardCountj,SearchCardResultj = self:SearchSameCardByhh(cbCardData, cbCardCount)
    local singleCards=SearchCardResultj[1]
    cardReverse(singleCards,table.nums(singleCards))
	--一对    
    local function twoHelp()
            local two = { }
            if SearchCardCountj[2] > 0 then
                SortResult.bTwoCount = true
                two = SearchCardResultj[2]
            else
                return
            end           
            for i = 1, table.nums(two) / 2 do
                local temp = { }
                table.insert(temp, two[i * 2 - 1])
                table.insert(temp, two[i * 2])
                local temp2=clone(temp)  
                if table.nums(singleCards)==0 then  --如果没有单牌 
                   table.insert(SortResult.cbTwoList, temp)
                end
                for j=1,table.nums(singleCards) do        --双重循环,第二层    
                    table.insert(temp2, singleCards[j])
                    if singleCards[j+1]~=nil then
                        table.insert(temp2, singleCards[j+1])
                    else
                        table.insert(SortResult.cbTwoList, temp2)
                        break
                    end
                    if singleCards[j+2]~=nil then
                        table.insert(temp2, singleCards[j+2])
                        table.insert(SortResult.cbTwoList, temp2)
                        temp2=clone(temp)  
                    else
                        table.insert(SortResult.cbTwoList, temp2)
                        break
                    end
                    break --只要三张牌
                end 
            end                                                                        
    end
    twoHelp()

	--两对
    local function TwoDouleHelp()
            local TwoDoule = { }
            if SearchCardCountj[2] > 1 then
                SortResult.bTwoDouleCount = true
                TwoDoule = SearchCardResultj[2]
            else
                return
            end 
            local  TwoDouleNums=  table.nums(TwoDoule)
                for j=1,TwoDouleNums-3,2 do
                    local temp = { }
                    table.insert(temp, TwoDoule[TwoDouleNums-1])
                    table.insert(temp, TwoDoule[TwoDouleNums])
                    table.insert(temp, TwoDoule[j])  --一对最大,加一对最小,加最小单牌
                    table.insert(temp, TwoDoule[j+1])
                    if table.nums(singleCards) == 0 then
                        -- 如果没有单牌
                        table.insert(SortResult.cbFourOneList, temp)
                    else
                    --for k = 1, table.nums(singleCards) do
                        local temp2 = clone(temp)
                        table.insert(temp2, singleCards[1])
                        table.insert(SortResult.cbTwoDoubleList, temp2)
                    end

                end
    end
    TwoDouleHelp()
	--三条
    local function threeHelp()
            local three = { }
            if SearchCardCountj[3] > 0 then
                SortResult.bThreeCount = true
                three = SearchCardResultj[3]
            else
                return
            end            
            for i = 1, table.nums(three) / 3 do
                local temp = { }
                table.insert(temp, three[i * 3-2])
                table.insert(temp, three[i * 3-1])
                table.insert(temp, three[i * 3])
                local temp2=clone(temp)  
                if table.nums(singleCards)==0 then  --如果没有单牌 
                   table.insert(SortResult.cbTwoList, temp2)
                else
                    table.insert(temp2, singleCards[1])
                    if singleCards[2]~=nil then
                        table.insert(temp2, singleCards[2])
                        table.insert(SortResult.cbThreeList, temp2)
                        temp2=clone(temp) 
                    else
                        table.insert(SortResult.cbThreeList, temp2)
                    end               
                end
            end
    end
    threeHelp()
	--顺子
    local function ShunZiHelp()
        
        local line = {}
        local SearchCardCount
        local SearchCardResult
	    SearchCardCount,SearchCardResult = self:SearchLineCardType(cbCardData, cbCardCount)
	    if SearchCardCount > 0 then
		    SortResult.bLineCount =  true
		    for i=1, SearchCardCount do			       
			    table.insert(SortResult.cbLineList, SearchCardResult.cbResultCard[i])
		    end
	    end       
    end
    ShunZiHelp()
	--同花
    local function TongHuaHelp()
     local SearchCardCount
        local SearchCardResult
        SearchCardCount, SearchCardResult = self:SearchSameColorType(cbCardData, cbCardCount, 5)
        if SearchCardCount > 0 then
            SortResult.bSameColorCount = true
            for i = 1, SearchCardCount do
                local samecolor = { }
                for j = 1, SearchCardResult.cbCardCount[i] do
                    table.insert(samecolor, SearchCardResult.cbResultCard[i][j])
                end
                table.insert(SortResult.cbSameColorList, samecolor)
            end  
        end
        local num=table.nums(SortResult.cbSameColorList)
        if num>1 then
            for i=1,num-1 do
                local code=self:compareCard(SortResult.cbSameColorList[i], SortResult.cbSameColorList[i+1], 5,5)
                if code==true then
                    SortResult.cbSameColorList[i], SortResult.cbSameColorList[i+1]=SortResult.cbSameColorList[i+1], SortResult.cbSameColorList[i]
                end
            end
        end

    end
	TongHuaHelp()

	--葫芦
    local function ThreeDouleHelp()
            local ThreeDoule = {}
            if SearchCardCountj[2] > 0 and SearchCardCountj[3] > 0 then
                SortResult.bThreeDouleCount = true
                ThreeDoule = SearchCardResultj[3]
            else
                return
            end     
            local  two=SearchCardResultj[2];       
            for i = 1, table.nums(ThreeDoule) / 3 do
                local temp = { }
                table.insert(temp, ThreeDoule[i * 3-2])
                table.insert(temp, ThreeDoule[i * 3-1])
                table.insert(temp, ThreeDoule[i * 3])
                for j =table.nums(two),1,-2 do   --先带最小的对子
                    local temp2=clone(temp)  
                    table.insert(temp2, two[j])
                    table.insert(temp2, two[j-1])
                    table.insert(SortResult.cbThreeDouleList, temp2)  
                end
            end
    end
    ThreeDouleHelp()
	
	--铁支

     local function fourHelp()
            local four = {}
            if SearchCardCountj[4] > 0 then
                SortResult.bFourOneCount = true
                four = SearchCardResultj[4]
            else
                return
            end
            --dump(four,"four")            
            for i = 1, table.nums(four) / 4 do
                local temp = { }
                table.insert(temp, four[i * 4 - 3])
                table.insert(temp, four[i * 4-2])
                table.insert(temp, four[i * 4-1])
                table.insert(temp, four[i * 4])
                if table.nums(singleCards)==0 then  --如果没有单牌 
                   table.insert(SortResult.cbFourOneList, temp)
                else
                    table.insert(temp,singleCards[1])
                    table.insert(SortResult.cbFourOneList, temp)
                end
            end          
    end
    fourHelp()
	--dump(SortResult.cbFourOneList,"SortResult.cbFourOneList")
 	--同花顺
    local function FiveFlushHelp()
        local SearchCardCount
        local SearchCardResult
        SearchCardCount, SearchCardResult = self:SearchSameColorLineType(cbCardData, cbCardCount, 5)
        if SearchCardCount > 0 then
            SortResult.bFiveFlushCount = true
            for i = 1, SearchCardCount do
                local fiveflush = { }
                for j = 1, SearchCardResult.cbCardCount[i] do
                    table.insert(fiveflush, SearchCardResult.cbResultCard[i][j])
                end
                table.insert(SortResult.cbFiveFlushList, fiveflush)
            end
        end
    end
    FiveFlushHelp()
	table.insert(SortRecord,{bTag=SortResult.bTwoCount,list=SortResult.cbTwoList})
	table.insert(SortRecord,{bTag=SortResult.bTwoDouleCount,list=SortResult.cbTwoDoubleList})
	table.insert(SortRecord,{bTag=SortResult.bThreeCount,list=SortResult.cbThreeList})
	table.insert(SortRecord,{bTag=SortResult.bLineCount,list=SortResult.cbLineList})
	table.insert(SortRecord,{bTag=SortResult.bSameColorCount,list=SortResult.cbSameColorList})
	table.insert(SortRecord,{bTag=SortResult.bThreeDouleCount,list=SortResult.cbThreeDouleList})
	table.insert(SortRecord,{bTag=SortResult.bFourOneCount,list=SortResult.cbFourOneList})
	table.insert(SortRecord,{bTag=SortResult.bFiveFlushCount,list=SortResult.cbFiveFlushList})

	return SortResult,SortRecord
end



