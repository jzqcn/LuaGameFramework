module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("Club.EVT.PUSH_CLUB_MEMBERS_LIST", "onPushClubMembersList")
	self:bindModelEvent("Club.EVT.PUSH_CLUB_SET_MANAGER", "onPushClubSetManager")
	self:bindModelEvent("Club.EVT.PUSH_CLUB_CANCEL_MANAGER", "onPushClubCancelManager")
	self:bindModelEvent("Club.EVT.PUSH_CLUB_DELETE_MEMBER", "onPushClubDeleteMember")
	self:bindModelEvent("Club.EVT.PUSH_CLUB_ADD_MEMBERS", "onPushClubAddMember")

	local param = 
	{
		data = {},
		ccsName = "Club/ClubMembersNodeItem",
		dataCheckFunc = function (pageData, elem)
			return pageData == elem
		end
	}
	self.listpage:createPages(param)

	self.listpage:addEventListener(bind(self.pageTouch, self))
end

function prototype:pageTouch(sender, types)
	if types == PAGEVIEW_EVENT_TURNING then
		local curIdx = self.listpage:getCurrentPageIndex()
		log("turning curIdx:"..curIdx)
		local clubData = Model:get("Club"):getClubData(self.clubId)
		if clubData then
			local memsPageIndex = clubData.memsPageIndex
			local totalMemsNum = clubData.totalMemsNum
			local totalPageNum = math.ceil(totalMemsNum / 60)
			if memsPageIndex < totalPageNum then
				curIdx = curIdx + 1
				if curIdx == memsPageIndex*3-1 then
					Model:get("Club"):requestClubMemberList(self.clubId)

					self.currentPageIndex = curIdx
				end
			end

			-- if curIdx < (math.ceil(totalMemsNum / 20)-1) then
			-- 	self.btnRight:setVisible(true)
			-- else
			-- 	self.btnRight:setVisible(false)
			-- end
		end

		-- if curIdx > 0 then
		-- 	self.btnLeft:setVisible(true)
		-- else
		-- 	self.btnLeft:setVisible(false)
		-- end
	end
end

function prototype:refreshMembersData(clubId)
	self.clubId = clubId

	local clubData = Model:get("Club"):getClubData(self.clubId)
	if clubData then
		local memsPageIndex = clubData.memsPageIndex or 0
		-- local totalMemsNum = clubData.totalMemsNum or 0
		-- local membersNum = #(clubData.members)
		if memsPageIndex == 0 then
			Model:get("Club"):requestClubMemberList(clubId)
		else
			self:onPushClubMembersList()
		end
	end
end

--俱乐部成员列表
function prototype:onPushClubMembersList()
	local clubData = Model:get("Club"):getClubData(self.clubId)
	if clubData then
		local members = clubData.members
		local datas = {}
		local number = #members

		--每页20个数据
		local perPageSize = 20
		local pageNum = math.ceil(number / perPageSize)
		for i = 1, pageNum do
			local data = {}
			local startIndex = (i - 1) * perPageSize
			if i < pageNum then								
				for index = startIndex + 1, startIndex + perPageSize do
					data[#data + 1] = members[index]
				end
			else
				for index = startIndex + 1, number do
					data[#data + 1] = members[index]
				end
			end
			
			local perPageData = {
								data = data,
								ccsName = "Club/MemberInfoItem",
								dataCheckFunc = function (info, elem) return info == elem end,
								numPerLine = 4,
								interval = 1,		
							}
			datas[#datas + 1] = perPageData

		end

		local param = 
		{
			data = datas,
			ccsName = "Club/ClubMembersNodeItem",
			dataCheckFunc = function (pageData, elem)
				return pageData == elem
			end
		}
		self.listpage:recreatePageView(param)

		-- self.listpage:refreshPageView(datas)
		if self.currentPageIndex then
			self.listpage:setCurrentPageIndex(self.currentPageIndex)
		end

		-- if #datas > 1 then
		-- 	local curIdx = self.listpage:getCurrentPageIndex()
		-- 	if curIdx > 0 then
		-- 		self.btnLeft:setVisible(true)
		-- 	else
		-- 		self.btnLeft:setVisible(false)
		-- 	end

		-- 	if curIdx < #datas-1 then
		-- 		self.btnRight:setVisible(true)
		-- 	else
		-- 		self.btnRight:setVisible(false)
		-- 	end
		-- else
		-- 	self.btnLeft:setVisible(false)
		-- 	self.btnRight:setVisible(false)
		-- end
	end
end

-- function prototype:onBtnLeftClick()
-- 	local curIdx = self.listpage:getCurrentPageIndex()
-- 	if curIdx > 0 then
-- 		self.listpage:scrollToItem(curIdx - 1)
-- 	end
-- end

-- function prototype:onBtnRightClick()
-- 	local curIdx = self.listpage:getCurrentPageIndex()
-- 	local pages = self.listpage:getItems()
-- 	if curIdx < (#pages-1) then
-- 		self.listpage:scrollToItem(curIdx + 1)
-- 	end

-- end

--设置管理员
function prototype:onPushClubSetManager(memInfo)
	local curList = self.listpage:getCurList()
	if curList then
		local item = curList:getSubItem(memInfo)
		if item then
			item:refresh(memInfo)
		end
	end
end

--取消管理员
function prototype:onPushClubCancelManager(memInfo)
	local curList = self.listpage:getCurList()
	if curList then
		local item = curList:getSubItem(memInfo)
		if item then
			item:refresh(memInfo)
		end
	end
end

--踢出成员
function prototype:onPushClubDeleteMember(memInfo)
	local curList = self.listpage:getCurList()
	if curList then
		local line, idx = curList:getItemIndex(memInfo)
		curList:removeOneCellByIdxAndLayout(idx)
	end
end

function prototype:onPushClubAddMember(memInfo)
	if self.rootNode:isVisible() then
		local curList = self.listpage:getCurList()
		if curList then
			local allItems = curList:getAllItems()
			log(#allItems)

			if #allItems < 20 then
				curList:insertOneCell(memInfo)
			end
		end
	end
end

function prototype:onBtnReturnClick(sender, eventType)
	self:fireUIEvent("Club.HideMembers")
end

