module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindUIEvent("Promotion.ChangeDate", "uiEvtChangeDate")

	local data = {}
	local param = 
	{
		data = data,
		ccsNameOrFunc = "Promotion/PromotionDetailItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}

	self.listview:createItems(param)

	-- self.txtNumB:setString("0")
	-- self.txtNumC:setString("0")
	-- self.txtNumD:setString("0")

	-- self.txtRevenueB:setString("0")
	-- self.txtRewardB:setString("0")

	-- self.txtRevenueC:setString("0")
	-- self.txtRewardC:setString("0")

	-- self.txtRevenueD:setString("0")
	-- self.txtRewardD:setString("0")
end

function prototype:setPromotionInfo(info)
	-- local promoteNumCount = info.promoteNumCount
	-- local first = promoteNumCount.first
	-- local second = promoteNumCount.second
	-- local third = promoteNumCount.third

	-- -------------------B-------------------
	-- --总人数
	-- local totalJoiner = first.totalJoiner or 0
	-- self.txtNumB:setString(totalJoiner)
	-- --税收总奖励
	-- local totalLevelDraw = first.totalLevelDraw or 0
	-- self.txtRewardB:setString(totalLevelDraw)
	-- --税收总额
	-- local totalDraw = first.totalDraw or 0
	-- self.txtRevenueB:setString(totalDraw)

	-- ------------------C-------------------
	-- totalJoiner = second.totalJoiner or 0
	-- self.txtNumC:setString(totalJoiner)
	-- --税收总奖励
	-- totalLevelDraw = second.totalLevelDraw or 0
	-- self.txtRewardC:setString(totalLevelDraw)
	-- --税收总额
	-- totalDraw = second.totalDraw or 0
	-- self.txtRevenueC:setString(totalDraw)

	-- ------------------D---------------------
	-- totalJoiner = third.totalJoiner or 0
	-- self.txtNumD:setString(totalJoiner)
	-- --税收总奖励
	-- totalLevelDraw = third.totalLevelDraw or 0
	-- self.txtRewardD:setString(totalLevelDraw)
	-- --税收总额
	-- totalDraw = third.totalDraw or 0
	-- self.txtRevenueD:setString(totalDraw)

	local lastWeekDrawDetail = info.lastWeekDrawDetail
	if lastWeekDrawDetail then
		local data = {}
		for k, v in pairs(lastWeekDrawDetail) do
			local detailInfo = {}
			local tab = string.split(k, "-")
			local date = {year = tonumber(tab[1]), month = tonumber(tab[2]), day = tonumber(tab[3])}
			detailInfo.date = date

			local memInfo = {}
			for _, m in ipairs(v) do
				local item = {}
				item.userId = m.userId
				item.userName = m.userName
				-- item.totalDraw = m.totalDraw or 0 --税收
				item.totalLevelDraw = m.totalAllocDraw or 0 --税收奖励
				item.drawDate = m.drawDate
				memInfo[#memInfo + 1] = item
			end

			detailInfo.mem = memInfo

			data[#data + 1] = detailInfo
		end

		local function sortfunction(a, b)
			if a.date.year == a.date.year then
				if a.date.month == b.date.month then
					return a.date.day > b.date.day
				else
					return a.date.month > b.date.month
				end
			else
				return a.date.year > b.date.year
			end 
		end
		table.sort(data, sortfunction)

		-- log(data)

		self.detailData = data

		if #data > 0 then
			self.listview:refreshListView(data[1].mem)
		end

		self.nodeDate:selectDateByIndex(1)
	end
end

function prototype:uiEvtChangeDate(SelDate)
	if not SelDate then
		return
	end

	-- log(SelDate)

	if self.detailData then
		local isFind = false
		local date
		for k, v in ipairs(self.detailData) do
			date = v.date
			if date.year==SelDate.year and date.month==SelDate.month and date.day==SelDate.day then
				-- log(v.mem)
				self.listview:refreshListView(v.mem)
				isFind = true
				break
			end
		end

		if not isFind then
			self.listview:refreshListView({})
		end
	end	
end

function prototype:closeSelectDate()
	self.nodeDate:showSelectDate(false)
end
