module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	self:bindUIEvent("Club.ClubHandleApply", "uiEvtClubHandleApply")

	self:bindModelEvent("Club.EVT.PUSH_CLUB_HANDLE_APPLY", "onPushClubHandleApply")

	local clubList = Model:get("Club"):getClubList()
	local applyList = {}
	for i, v in ipairs(clubList) do
		for m, n in ipairs(v.applyList) do
			local item = {}
			item.clubId = v.id
			item.clubName = v.name
			item.userId = n.userId
			item.userName = n.userName
			item.headImage = n.headImage
			applyList[#applyList + 1] = item
		end 
	end

	local param = 
	{
		data = applyList,
		ccsNameOrFunc = "Club/ApplyMsgViewItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.listview:createItems(param)

    self.applyList = applyList

    local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
end

function prototype:onPushClubHandleApply(memInfo)
	for i, v in ipairs(self.applyList) do
		if v.clubId == memInfo.clubId and v.userId == memInfo.userId then
			self.listview:deleteItem(v)
			table.remove(self.applyList, i)
			break
		end
	end

	if #(self.applyList) == 0 then
		local clubLayer = ui.mgr:getLayer("Club/ClubView")
		if clubLayer then
			clubLayer:onPushClubApplyList()
		end
	end
end

function prototype:uiEvtClubHandleApply(clubId, userId, bAgree)
	self.applyClubId = clubId
	self.applyUserId = userId
	Model:get("Club"):requestHandleApply(clubId, userId, bAgree)
end

function prototype:onImageCloseClick()
	self:close()
end

