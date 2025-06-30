module (..., package.seeall)

local ItemText = require "Hall/CreateRoom/ItemText"

module(..., package.seeall)

prototype = ItemText.prototype:subclass()

-- local OPTION_NUM = 4
-- local SINGLE_SELECT = 1
-- local MULTI_SELECT = 2

function prototype:enter()

end

function prototype:getOptionNum()
	return 4
end

function prototype:setConfigParam(name, config, showStrTable, valueStrTable)
	super.setConfigParam(self, name, config, showStrTable, valueStrTable)
end

-- function prototype:setConfigParam(name, config, showStrTable, valueStrTable)
-- 	self.txtName:setString(name)

-- 	local defaultSel = config.default
-- 	local showNum = #showStrTable

-- 	local selRes = "resource/csbimages/Hall/CreateRoom/checkbox_sel_1.png"
-- 	local unselRes = "resource/csbimages/Hall/CreateRoom/checkbox_unsel_1.png"

-- 	local selRes2 = "resource/csbimages/Hall/CreateRoom/checkbox_sel_2.png"
-- 	local unselRes2 = "resource/csbimages/Hall/CreateRoom/checkbox_unsel_2.png"

-- 	-- local menu = cc.Menu:create()

-- 	-- for i, v in ipairs(showStrTable) do
-- 	-- 	local 
-- 	-- 	local label = cc.Label:createWithTTF("Tint", "fonts/Marker Felt.ttf", 20.0)
-- 	-- 	label:setAnchorPoint(cc.p(0, 0.5))
-- 	-- 	local menuItem = cc.MenuItemLabel:create(label)
-- 	-- 	menuItem:setPosition()
-- 	-- end

-- 	self.valueStrTable = valueStrTable
-- 	self.selectType = SINGLE_SELECT
-- 	if config.selType ~= "single" then
-- 		self.selectType = MULTI_SELECT
-- 	end

-- 	self.showRow = math.ceil(showNum/2)
-- 	self.showHeight = self.showRow * 60

-- 	local labelName, checkboxName
-- 	for index = 1, OPTION_NUM do
-- 		labelName = "txtNum_" .. index
-- 		checkboxName = "checkbox_" .. index
-- 		self[labelName]:setTag(index)
-- 		self[labelName]:setEnabled(true)
-- 		self[checkboxName]:setTag(index)
-- 		self[checkboxName]:setSelected(false)
-- 		self[checkboxName]:setEnabled(true)

-- 		if index <= showNum then
-- 			self[labelName]:setString(showStrTable[index])
-- 			-- log("selType:"..config.selType..", defaultSel:"..defaultSel)
-- 			if self.selectType == SINGLE_SELECT then
-- 				--单选
-- 				self[checkboxName]:loadTextures(unselRes2, unselRes2, selRes2, unselRes2, selRes2)
-- 				if defaultSel == index then
-- 					self[checkboxName]:setSelected(true)

-- 					self[checkboxName]:setEnabled(false)
-- 					self[labelName]:setEnabled(false)
-- 				else
-- 					self[checkboxName]:setSelected(false)
-- 				end
-- 			else
-- 				--多选
-- 				self[checkboxName]:loadTextures(unselRes, unselRes, selRes, unselRes, selRes)
-- 				if defaultSel >= index then
-- 					self[checkboxName]:setSelected(true)
-- 				else
-- 					self[checkboxName]:setSelected(false)
-- 				end
-- 			end

-- 			self[labelName]:setVisible(true)
-- 			self[checkboxName]:setVisible(true)
-- 		else
-- 			self[labelName]:setVisible(false)
-- 			self[checkboxName]:setVisible(false)
-- 		end
-- 	end
-- end

-- function prototype:onCheckGroup(sender)
-- 	local index = sender:getTag()
-- 	self:setSelected(index, sender:isSelected())
-- end

-- function prototype:onTextGroupClick(sender)
-- 	local index = sender:getTag()
-- 	local var = self["checkbox_"..index]:isSelected()
-- 	self["checkbox_"..index]:setSelected(not var)
-- 	self:setSelected(index, not var)
-- end

-- function prototype:setSelected(index, var)
-- 	if self.selectType == SINGLE_SELECT then
-- 		local labelName, checkboxName
-- 		for i = 1, OPTION_NUM do
-- 			labelName = "txtNum_" .. i
-- 			checkboxName = "checkbox_" .. i
-- 			if i == index then
-- 				self[labelName]:setEnabled(false)
-- 				self[checkboxName]:setEnabled(false)
-- 			else
-- 				self[labelName]:setEnabled(true)
-- 				self[checkboxName]:setEnabled(true)
-- 				self[checkboxName]:setSelected(false)
-- 			end
-- 		end
-- 	end
-- end

-- function prototype:getShowHeight()
-- 	return self.showHeight
-- end