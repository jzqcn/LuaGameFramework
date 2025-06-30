module (..., package.seeall)

prototype = Controller.prototype:subclass()

local SINGLE_SELECT = 1
local MULTI_SELECT = 2

local ImgIcon = {
	["gold"] = "resource/csbimages/Common/goldIcon.png",
}

function prototype:enter()
end

function prototype:getOptionNum()
	return 6
end

function prototype:setConfigParam(name, config, showStrTable, valueStrTable)
	self.txtName:setString(name)

	local beignIndex, endIndex = string.find(showStrTable[1], ",")
	if beignIndex then
		self.showStrTable = {}
		self.valueStrTable = {}
		for i, v in ipairs(showStrTable) do
			self.showStrTable[i] = string.split(v, ",")
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

function prototype:updateConfig(defaultSel, showIndex)
	self.showIndex = showIndex

	local showStrTable = self.showStrTable[showIndex]
	local showNum = #showStrTable
	--复选框
	local selRes = "resource/csbimages/Common/redDot.png"
	local unselRes = "resource/csbimages/Common/redDotBg.png"
	--单选框
	local selRes2 = "resource/csbimages/Common/redDot.png"
	local unselRes2 = "resource/csbimages/Common/redDotBg.png"

	local optionNum = self:getOptionNum()
	self.showRow = math.ceil(showNum/(optionNum/2))
	self.showHeight = self.showRow * 50

	local labelName, checkboxName	
	for index = 1, optionNum do
		labelName = "txtNum_" .. index
		checkboxName = "checkbox_" .. index
		self[labelName]:setTag(index)
		self[labelName]:setEnabled(true)
		self[checkboxName]:setTag(index)
		self[checkboxName]:setSelected(false)
		self[checkboxName]:setEnabled(true)

		if index <= showNum then
			local showStr = showStrTable[index]
			--判断是否中间显示图片 用'_'分割
			local beignIndex, endIndex = string.find(showStr, "_")
			local img = nil
			if beignIndex then
				local arr = string.split(showStr, "_")
				showStr = arr[1]
				img = ImgIcon[arr[2]]
			end
			self[labelName]:setString(showStr)
			if img then
				local labelSize = self[labelName]:getContentSize()
				local x, y = self[labelName]:getPosition()
				if self["imgIcon_"..index] then
					self["imgIcon_"..index]:loadTexture(img)
					self["imgIcon_"..index]:setVisible(true)
				else
					local sprite = ccui.ImageView:create(img)
					self.rootNode:addChild(sprite)
	    			self["imgIcon_"..index] = sprite
	    		end
	    		local iconSize = self["imgIcon_"..index]:getContentSize()
	    		self["imgIcon_"..index]:setPosition(cc.p(x + labelSize.width/2 + iconSize.width, y))
	    	else
	    		if self["imgIcon_"..index] then
					self["imgIcon_"..index]:setVisible(false)
				end
			end
			if self.selectType == SINGLE_SELECT then
				--单选
				self[checkboxName]:loadTextures(unselRes2, unselRes2, selRes2, unselRes2, selRes2)
				if defaultSel == index then
					self[checkboxName]:setSelected(true)

					self[checkboxName]:setEnabled(false)
					self[labelName]:setEnabled(false)
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

			self[labelName]:setVisible(true)
			self[checkboxName]:setVisible(true)
		else
			self[labelName]:setVisible(false)
			self[checkboxName]:setVisible(false)
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
			if i == index then
				self[labelName]:setEnabled(false)
				self[checkboxName]:setEnabled(false)
			else
				self[labelName]:setEnabled(true)
				self[checkboxName]:setEnabled(true)
				self[checkboxName]:setSelected(false)
			end
		end
	end

	if self.event then
		local valueStrTable = self.valueStrTable[self.showIndex]
		self:fireUIEvent(self.event, valueStrTable[index])
	end
end

function prototype:getShowValueTable()
	return self.showStrTable
end

-- function prototype:getSelectedIndex()
-- 	local selectedIndex = {}
-- 	local optionNum = self:getOptionNum()
-- 	local checkboxName	
-- 	for index = 1, optionNum do
-- 		checkboxName = "checkbox_" .. index
-- 		if self[checkboxName]:isSelected() then
-- 			selectedIndex[#selectedIndex] = index
-- 		end
-- 	end

-- 	return selectedIndex
-- end

function prototype:getValueConfig()
	local selectValueTab = {}
	local valueStrTable = self.valueStrTable[self.showIndex]
	local optionNum = self:getOptionNum()
	for index = 1, optionNum do
		if self["checkbox_"..index]:isSelected() == true then
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
		if self["checkbox_"..index]:isSelected() == true then
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