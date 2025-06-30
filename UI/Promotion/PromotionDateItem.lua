module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:showSelectDate(false)

	local time_t = util.time:getTimeDate()
	local year = time_t.year
	local month = time_t.month
	local day = time_t.day
	-- self.curMonth = month
	-- self.curDay = day
	-- self.txtCurDate:setString(month.."月"..day.."日")

	
	self.dateTab = {}
	local nextDay = day - 1
	for i = 1, 7 do		
		if nextDay <= 0 then
			month = month - 1
			if month <= 0 then
				year = year - 1
				month = 12
				local dayCount = util.time:getMonthDayCount2(year, month)
				nextDay = dayCount
			else
				local dayCount = util.time:getMonthDayCount2(year, month)
				nextDay = dayCount
			end
		end

		self["txtDate_"..i]:setString(month.."月"..nextDay.."日")

		if i == 1 then
			self.txtCurDate:setString(month.."月"..nextDay.."日")
		end

		table.insert(self.dateTab, {year = year, month = month, day = nextDay})

		nextDay = nextDay - 1
	end
end

function prototype:showSelectDate(value)
	self.btnArrowDown:setVisible(not value)
	self.btnArrowUp:setVisible(value)
	self.panelDateSel:setVisible(value)
	self.panelBg:setVisible(value)
end

function prototype:onBtnArrowUpClick()
	self:showSelectDate(false)
end

function prototype:onBtnArrowDownClick()
	self:showSelectDate(true)
end

function prototype:onPanelHideClick()
	self:showSelectDate(false)
end

function prototype:onImgDateClick(sender)
	local index = tonumber(string.sub(sender:getName(), -1))
	if index >= 1 and index <= 7 then
		self:showSelectDate(false)

		self.txtCurDate:setString(self["txtDate_"..index]:getString())
		self:selectDateByIndex(index)		
	end
end

function prototype:selectDateByIndex(index)
	self:fireUIEvent("Promotion.ChangeDate", self.dateTab[index])
end
