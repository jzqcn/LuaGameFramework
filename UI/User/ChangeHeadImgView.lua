module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local HeadImgNum = 12

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	self:bindUIEvent("ChangeHeadImgView.Selected", "uiEvtSelectedImage")

	local accountInfo = Model:get("Account"):getUserInfo()
	local headImageIndex = tonumber(accountInfo.headImage) or 1
	self.imgHead:loadTexture(string.format("resource/csbimages/User/headImages/touxiang_%d.png", headImageIndex))

	self.headImageIndex = headImageIndex
	self.selectedIndex = headImageIndex

	local data = {}
	local item = {}
	local typeNum = HeadImgNum / 2
	local index = 1
	for i = 1, 2 do
		for j = 1, typeNum do
			index = j + (i-1)*10
			item[#item + 1] = {index = index, sex = i, sign = index==headImageIndex}

			if #item == 6 then
				data[#data + 1] = item
				item = {}
			end
		end
	end

	if #item > 0 then
		data[#data + 1] = item
	end

	local param = 
	{
		data = data,
		ccsNameOrFunc = "User/HeadImageViewItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.listview:createItems(param)
	self.listview:setScrollBarEnabled(false)

	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
end

function prototype:uiEvtSelectedImage(info)
	if self.selectedIndex == info.index then
		return
	end

	local items = self.listview:getAllItems()
	for i, v in ipairs(items) do
		v:setSelectedIndex(info.index)
	end

	self.selectedIndex = info.index
end

function prototype:onBtnConfirmClick()
	if self.headImageIndex == self.selectedIndex then
		self:close()
		return
	end

	log("selectedIndex:"..self.selectedIndex)
	Model:get("User"):requestChangeHeadImg(self.selectedIndex)

	local accountInfo = Model:get("Account"):getUserInfo()
	accountInfo.headImageIndex = self.selectedIndex

	self:close()
end

function prototype:onBtnCloseClick()
	self:close()
end
