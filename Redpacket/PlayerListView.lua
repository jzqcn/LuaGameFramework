module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter()
	local roomMember = Model:get("Games/Redpacket"):getRoomMember()
	local memberList = table.values(roomMember)
	table.sort(memberList, function (a, b)
        return a.coin > b.coin
    end)

	local data = {}
    local item = {}
    for i, v in ipairs(memberList) do
    	item[#item + 1] = v
    	if #item == 2 then
    		data[#data + 1] = item
    		item = {}
    	end
    end

    if #item > 0 then
    	data[#data + 1] = item
    end

	local param = 
	{
		data = data,
		ccsNameOrFunc = "Redpacket/PlayerListItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}

    self.listview:createItems(param)

    local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
end

function prototype:onBtnCloseClick()
	self:close()
end

