module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter(type)
	self.currencyType = type

	-- ui.mgr:setSceneImageBg(self.imgBg, true)

	local goldItemTable = Model:get("Hall"):getGoldItemTable()
	local data = {}
	local rowItems = {currencyType = type, items = {}}
	--每一行放4个图标
	for i, v in ipairs(goldItemTable) do
		table.insert(rowItems.items, v)
		if #rowItems.items == 4 then
			data[#data + 1] = rowItems
			rowItems = {currencyType = type, items = {}}
		end
	end

	if #rowItems.items > 0 then
		data[#data + 1] = rowItems
	end

	local param = 
	{
		data = data,
		ccsNameOrFunc = "Hall/GoldGameViewItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}

    self.listview:createItems(param)

    if self.currencyType == Common_pb.Gold then
    	self.imgTypeName:loadTexture("resource/csbimages/Hall/typeGold.png")
    else
    	self.imgTypeName:loadTexture("resource/csbimages/Hall/typeSilver.png")
    end
end

function prototype:onBtnCloseClick(sender, eventType)
	self:close()
end
