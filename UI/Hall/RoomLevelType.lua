module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	local param = 
	{
		data = {},
		ccsNameOrFunc = "Hall/RoomLevelTypeItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}

    self.listview:createItems(param)

    self.listview:setScrollBarEnabled(false)
end

function prototype:setLevelConfigData(data)
    self.listview:refreshListView(data)

    if #data > 6 then
    	self.btnRight:setVisible(true)
    	self.btnLeft:setVisible(false)

    	self.btnRight:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.6), cc.FadeOut:create(0.6))))
    	self.btnLeft:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.6), cc.FadeOut:create(0.6))))
    else
    	self.btnRight:setVisible(false)
    	self.btnLeft:setVisible(false)
    end

    self:playActionTime(0, true)
end

function prototype:setSelectItem(playType)
	local items = self.listview:getAllItems()
	for i, v in ipairs(items) do
		v:setSelectedType(playType, i == #items)
	end
end

function prototype:onBtnRightClick()
	self.listview:jumpToRight()
	self.btnLeft:setVisible(true)
	self.btnRight:setVisible(false)
end

function prototype:onBtnLeftClick()
	self.listview:jumpToLeft()
	self.btnLeft:setVisible(false)
	self.btnRight:setVisible(true)
end

