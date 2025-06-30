module (..., package.seeall)

prototype = Controller.prototype:subclass()

local SINGLE_SELECT = 1
local MULTI_SELECT = 2

local ImgIcon = {
	["gold"] = "resource/csbimages/Hall/CreateRoom/goldIcon.png",
}

function prototype:enter()

end

function prototype:getOptionNum()
	return 4
end

function prototype:setConfigParam(name, config, showStrTable, valueStrTable)
	self.txtName:setString(name)

	local beignIndex, endIndex = string.find(showStrTable[1], ",")
	if beignIndex then
		self.showStrTable = {}
		self.valueStrTable = {}
		for i, v in ipairs(showStrTable) do
			self.showStrTable[i] = string.split(v, ",")
		end

		for i, v in ipairs(valueStrTable) do
			self.valueStrTable[i] = string.split(v, ",")
		end

		showStrTable = self.showStrTable[config.default]
	else
		self.showStrTable = {showStrTable}
		self.valueStrTable = {valueStrTable}
	end

	self.event = config.event
	self.selectType = SINGLE_SELECT
	if config.selType ~= "single" then
		self.selectType = MULTI_SELECT
	end

	self:updateConfig(config.default, 1)
end

function prototype:updateConfig(defaultSel, showIndex, multiple)
	multiple = multiple or 1
	self.showIndex = showIndex

	local showStrTable = self.showStrTable[showIndex]
	local showNum = #showStrTable

	--复选框
	local selRes = "resource/csbimages/Common/checkboxSel_2.png"
	local unselRes = "resource/csbimages/Common/checkbox_2.png"
	--单选框
	local selRes2 = "resource/csbimages/Common/checkboxSel_1.png"
	local unselRes2 = "resource/csbimages/Common/checkbox_1.png"

	local optionNum = self:getOptionNum()
	self.showRow = math.ceil(showNum/(optionNum/2))
	self.showHeight = self.showRow * 50

	-- local posX = 140
	-- local posY = self.rootNode:getContentSize().height - 25
	local posX, posY = self.checkbox_1:getPosition()
	local labelName, checkboxName
	for index, value in ipairs(showStrTable) do
		labelName = "txtNum_" .. index
		checkboxName = "checkbox_" .. index

		if index == 1 then
			
		else
			if self[checkboxName] == nil then
				self[checkboxName] = self.checkbox_1:clone()
				self[checkboxName]:setPosition(posX, posY)
				self.rootNode:addChild(self[checkboxName])
			end
		end

		posX = posX + 30

		if self[labelName] ~= nil then
			self[labelName]:removeFromParent(true)
		end

		--解析字符串
		local tb = self:getRichCustomTb()
		local beignIndex, endIndex = string.find(value, "<")
		if beignIndex then
			local frontStr = string.sub(value, 1, beignIndex - 1)
			-- if multiple ~= 1 then
				local i, j = string.find(frontStr, "%d+")
				local num = tonumber(string.sub(frontStr, i, j))
				num = num * multiple
				frontStr = string.sub(frontStr, 1, i-1) .. Assist.NumberFormat:amount2Hundred(num)
			-- end
			table.insert(tb.list, {str = frontStr, link = index})

			local endStr = string.sub(value, endIndex + 1, -1)
			local arr = string.split(endStr, ">")
			local richType = self:getRichTypeStr(arr[1])
			table.insert(tb.list, richType)

			endStr = arr[2]
			table.insert(tb.list, {str = endStr})
		else
			table.insert(tb.list, {str = value, link = index})
		end

		--创建富文本 【默认链接文字颜色为 蓝色 ，KEY_ANCHOR_FONT_COLOR_STRING 修改字体颜色】
		local assistNode = Assist.RichText:createRichText(tb, {KEY_ANCHOR_FONT_COLOR_STRING = "#3e5b93"})
		assistNode:setWrapMode(RICHTEXT_WRAP_PER_CHAR)
		assistNode:ignoreContentAdaptWithSize(false)
		assistNode:setContentSize(cc.size(220, 50))
		self.rootNode:addChild(assistNode)

		local size = assistNode:getContentSize()

		posX = posX + size.width/2
		assistNode:setPosition(cc.p(posX, posY-tb.style.size/2))
		posX = posX + size.width

		-- log(assistNode:getRealSize())
		--设置回调
		assistNode:setOpenUrlHandler(function (url)
			self:onTextGroupClick(assistNode)
		end)

		self[labelName] = assistNode


		self[labelName]:setTag(index)		
		self[checkboxName]:setTag(index)
		self[checkboxName]:setEnabled(true)
		-- if defaultSel == index then
		-- 	self[checkboxName]:setSelected(true)
		-- 	if self.selectType == SINGLE_SELECT then
		-- 		self[checkboxName]:setEnabled(false)
		-- 	end
		-- else
		-- 	self[checkboxName]:setSelected(false)
		-- end

		if self.selectType == SINGLE_SELECT then
			--单选
			self[checkboxName]:loadTextures(unselRes2, unselRes2, selRes2, unselRes2, selRes2)
			if defaultSel == index then
				self[checkboxName]:setSelected(true)

				self[checkboxName]:setEnabled(false)
			else
				self[checkboxName]:setSelected(false)
			end
		else
			--多选
			self[checkboxName]:loadTextures(unselRes, unselRes, selRes, unselRes, selRes)
			if type(defaultSel) == "table" then
				self[checkboxName]:setSelected(false)
				for _, v in ipairs(defaultSel) do
					if v == index then
						self[checkboxName]:setSelected(true)
					end
				end
				-- if defaultSel[index] then
				-- 	self[checkboxName]:setSelected(true)
				-- else
				-- 	self[checkboxName]:setSelected(false)
				-- end
			else
				if defaultSel >= index then
					self[checkboxName]:setSelected(true)
				else
					self[checkboxName]:setSelected(false)
				end
			end
		end

		if index%2 == 1 then

		else
			posX = self.checkbox_1:getPosition()
			posY = posY - 50
		end
	end
end

function prototype:onCheckGroup(sender)
	local index = sender:getTag()
	self:setSelected(index, sender:isSelected())
end

function prototype:onTextGroupClick(sender)
	local index = sender:getTag()
	local var = self["checkbox_"..index]:isSelected()
	if self.selectType == SINGLE_SELECT and var == true then
		return
	end

	self["checkbox_"..index]:setSelected(not var)
	self:setSelected(index, not var)
end

function prototype:setSelected(index, var)
	if self.selectType == SINGLE_SELECT then
		local labelName, checkboxName
		local optionNum = self:getOptionNum()
		for i = 1, optionNum do
			labelName = "txtNum_" .. i
			checkboxName = "checkbox_" .. i
				if self[labelName] and self[checkboxName] then
				if i == index then
					-- self[labelName]:setEnabled(false)
					self[checkboxName]:setEnabled(false)
				else
					-- self[labelName]:setEnabled(true)
					self[checkboxName]:setEnabled(true)
					self[checkboxName]:setSelected(false)
				end
			end
		end
	end

	if self.event then
		self:fireUIEvent(self.event, index)
	end
end

function prototype:getShowValueTable()
	return self.showStrTable
end

function prototype:getValueConfig()
	local selectValueTab = {}
	local valueStrTable = self.valueStrTable[self.showIndex]
	local optionNum = self:getOptionNum()
	for index = 1, optionNum do
		if self["checkbox_"..index] and self["checkbox_"..index]:isSelected() == true then
			selectValueTab[#selectValueTab + 1] = valueStrTable[index]
		end
	end

	-- log(selectValueTab)
	return selectValueTab
end

function prototype:getKeyConfig()
	local selectKeyTab = {}
	local optionNum = self:getOptionNum()
	for index = 1, optionNum do
		if self["checkbox_"..index] and self["checkbox_"..index]:isSelected() == true then
			if self.selectType == SINGLE_SELECT then
				return index
			end
			selectKeyTab[#selectKeyTab + 1] = index
		end
	end

	return selectKeyTab
end

function prototype:getShowHeight()
	return self.showHeight
end

function prototype:getRichTypeStr(msg, index)
	local arr = string.split(msg, ":")
	if arr then
		if arr[1] == "img" then
			local res = ImgIcon[arr[2]]
			return {img  = res}
		else

		end
	end

	return {str = msg}
end

function prototype:getRichCustomTb(fontSize, color)
	local tb = {}
	color = color or "#3e5b93"
	local fontSize = fontSize or 21
	local style = {face = "resource/fonts/FZY4JW.TTF", size = fontSize, color = color, underLine = false}
	tb.style = style
	tb.list = {}

	return tb
end