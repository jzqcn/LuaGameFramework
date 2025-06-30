require "Protol.Club_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_CLUB_LIST_MSG",
	"PUSH_CLUB_ROOM_LIST",
	"PUSH_CLUB_MEMBERS_LIST",
	"PUSH_CLUB_APPLY_LIST",
	"PUSH_JOIN_CLUB_RESULT",
	"PUSH_CLUB_HANDLE_APPLY",
	"PUSH_CLUB_SET_MANAGER",
	"PUSH_CLUB_CANCEL_MANAGER",
	"PUSH_CLUB_DELETE_MEMBER",
	"PUSH_CLUB_REQUEST_LEAVE",
	"PUSH_CLUB_ADD_MEMBERS",
	"PUSH_CLUB_GET_INCOME",
	"PUSH_CLUB_DISSOLVE",
	"PUSH_CLUB_SET_DRAW",
}

class = Model.class:subclass()

Club_pb = Club_pb

--俱乐部
function class:initialize()
    super.initialize(self)

    self.clubList = {}
    net.msg:on(MsgDef_pb.MSG_CLUB, self:createEvent("onClubData"))
end

function class:clear()
	self.clubList = {}
	self.setManagerMsg = nil
	self.cancelManagerMsg = nil
end

function class:requestClubList()
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_List

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--创建
function class:requestCreateClub(clubName)
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_Create
	request.createRequest.name = clubName

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--解散
function class:requestDeleteClub(clubId)
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_Cancel
	request.id = clubId

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--设置、取消管理员权限
function class:requestClubManager(clubId, userId, bCancel)
	bCancel = bCancel or false
	local request = Club_pb.ClubRequest()
	if bCancel then
		request.type = Club_pb.Request_CancelManager
		request.cancelManagerRequest.userId = userId
		self.cancelManagerMsg = {clubId = clubId, userId = userId}
	else
		request.type = Club_pb.Request_SetManager
		request.setManagerRequest.userId = userId
		self.setManagerMsg = {clubId = clubId, userId = userId}
	end
	request.id = clubId

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--俱乐部房间列表
function class:requestClubRoomList(clubId)
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_Room_List
	request.id = clubId
	
	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--申请加入俱乐部
function class:requestJoinClub(clubId)
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_Apply
	request.id = clubId

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--退出俱乐部
function class:requestLeaveClub(clubId)
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_Leave
	request.id = clubId

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--请求加载申请列表
function class:requestClubApplyList(clubId)
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_List_Apply
	request.id = clubId

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--处理申请
function class:requestHandleApply(clubId, userId, bAgree)
	bAgree = bAgree or false
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_Handle_Apply
	request.id = clubId
	request.handleApplyRequest.userId = userId
	request.handleApplyRequest.type = bAgree and Club_pb.Agree or Club_pb.Refuse

	self.handleApplyMsg = {clubId = clubId, userId = userId, bAgree = bAgree}

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--请求俱乐部成员数据
function class:requestClubMemberList(clubId, pageIndex, pageSize)
	local clubData = self:getClubData(clubId)
	local lastPageIndex = clubData.memsPageIndex or 0
	pageSize = pageSize or 60
	pageIndex = lastPageIndex + 1

	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_Member_Page
	request.id = clubId
	request.memberPageRequest.pageSize = pageSize --每页数量
	request.memberPageRequest.pageNum = pageIndex --页数

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())

	self.requestMemClubId = clubId
end

--删除成员
function class:requestDeleteMember(clubId, userId)
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_Member_del
	request.id = clubId
	request.memberDelRequest.userId = userId

	self.deleteMemberMsg = {clubId = clubId, userId = userId}

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--查询成员数据
function class:requestQueryMemberMsg(clubId, userId)
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_Member_Query_ForId
	request.id = clubId
	request.memberQueryForIdRequest.userId = userId

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--提取收入
function class:requestPickupIncome(clubId)
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_PickUp_Income
	request.id = clubId

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--设置抽水值
function class:requestSetDraw(clubId, value)
	-- log("clubId:" .. clubId .. ", value : " .. value)
	
	local request = Club_pb.ClubRequest()
	request.type = Club_pb.Request_Set_Draw
	request.id = clubId
	request.setDrawRequest.baseDraw = value

	net.msg:send(MsgDef_pb.MSG_CLUB, request:SerializeToString())
end

--数据请求返回
function class:onClubData(data)
	local response = Club_pb.ClubResponse()
	response:ParseFromString(data)

	if not response.type then
		log4model:error("[Club::onClubData] parse data error ! response type is nil !")
		return
	end

	local isSuccess = response.isSuccess
	-- log("[Club::onClubData] response type : "..response.type..", isSuccess : "..(isSuccess and 1 or 0))
	if isSuccess then
		if response.type == Club_pb.Request_Cancel then
			--解散俱乐部
			self:fireEvent(EVT.PUSH_CLUB_DISSOLVE)

		elseif response.type == Club_pb.Request_Create or response.type == Club_pb.Request_List or response.type == Club_pb.Request_Apply then
			if response.type == Club_pb.Request_List then
				--请求列表重置
				self.clubList = {}
			end

			local updateNum = 0
			local clubInfos = response.listResponse.clubInfos
			local info
			local userId = Model:get("Account"):getUserId()
			for i, v in ipairs(clubInfos) do
				info = {}
				info.id = v.id
				info.name = v.name
				info.memberNum = v.memberNum
				info.createTime = tonumber(v.createTime)
				info.joinTime = tonumber(v.joinTime)
				info.ownerProfit = tonumber(v.ownerProfit) or 0 --俱乐部主未提取收益
				info.totalOwnerProfit = tonumber(v.totalOwnerProfit) or 0 --俱乐疗主总收益（包括已提取和未提取）
				info.baseDraw = v.baseDraw --基本抽水值
				info.baseDrawList = {} --基本抽水值列表
				info.cardNum = v.cardNum --房卡

				for _, m in ipairs(v.baseDraws) do
					table.insert(info.baseDrawList, m)
				end

				info.isOwner = false
				info.isManager = false
				--成员数据
				info.members = {}
				local mem
				for _, m in ipairs(v.members) do
					mem = {}
					mem.userId = m.userId
					mem.userName = m.userName
					mem.headImage = m.headImage
					mem.isOwner = m.isOwner
					mem.isManager = m.isManager
					mem.clubId = info.id
					table.insert(info.members, mem)

					if m.userId == userId then
						info.isOwner = mem.isOwner
						info.isManager = mem.isManager
					end
				end

				info.roomList = {}
				info.applyList = {}

				self:updateClubData(info)

				updateNum = updateNum + 1
			end

			self:fireEvent(EVT.PUSH_CLUB_LIST_MSG, self.clubList)

		elseif response.type == Club_pb.Request_SetManager then
			--设置管理员
			if self.setManagerMsg then
				local clubData = self:getClubData(self.setManagerMsg.clubId)
				if clubData then
					for i, v in ipairs(clubData.members) do
						if v.userId == self.setManagerMsg.userId then
							v.isManager = true

							self:fireEvent(EVT.PUSH_CLUB_SET_MANAGER, v)
							self.setManagerMsg = nil
							break
						end
					end
				end
			end

		elseif response.type == Club_pb.Request_CancelManager then
			--取消管理员
			if self.cancelManagerMsg then
				local clubData = self:getClubData(self.cancelManagerMsg.clubId)
				if clubData then
					for i, v in ipairs(clubData.members) do
						if v.userId == self.cancelManagerMsg.userId then
							v.isManager = false

							self:fireEvent(EVT.PUSH_CLUB_CANCEL_MANAGER, v)
							self.cancelManagerMsg = nil
							break
						end
					end
				end
			end

		elseif response.type == Club_pb.Request_Handle_Apply then
			--处理申请
			if self.handleApplyMsg then
				local clubId = self.handleApplyMsg.clubId
				local clubData = self:getClubData(clubId)
				if clubData then
					for i, v in ipairs(clubData.applyList) do
						if v.userId == self.handleApplyMsg.userId then
							table.remove(clubData.applyList, i)
							self:fireEvent(EVT.PUSH_CLUB_HANDLE_APPLY, v, self.handleApplyMsg.bAgree)							

							local memsPageIndex = clubData.memsPageIndex or 0
							if self.handleApplyMsg.bAgree == true and memsPageIndex <= 1 then
								--添加成员
								local mem = {}
								mem.userId = v.userId
								mem.userName = v.userName
								mem.headImage = v.headImage
								mem.isOwner = false
								mem.isManager = false
								mem.clubId = clubData.id
								table.insert(clubData.members, mem)

								self:fireEvent(EVT.PUSH_CLUB_ADD_MEMBERS, mem)
							end

							self.handleApplyMsg = nil
							break
						end
					end
				end
			end

		elseif response.type == Club_pb.Request_Member_Page then
			--俱乐部成员数据			
			local memberPageResponse = response.memberPageResponse
			local totalMemsNum = memberPageResponse.total
			local totalMemsPage = memberPageResponse.totalPage
			local pageIndex = memberPageResponse.pageNum
			local pageSize = memberPageResponse.pageSize

			local userId = Model:get("Account"):getUserId()
			local isOwner = false
			local isManager = false
			local member = memberPageResponse.member
			local members = {}
			for i, v in ipairs(member) do
				local mem = {}
				mem.userId = v.userId
				mem.userName = v.userName
				mem.headImage = v.headImage
				mem.isOwner = v.isOwner
				mem.isManager = v.isManager
				mem.clubId = self.requestMemClubId
				if userId == mem.userId then
					isOwner = mem.isOwner
					isManager = mem.isManager
				end

				table.insert(members, mem)
			end

			-- log("pageIndex:"..pageIndex..", pageSize:"..pageSize..", totalMemsNum:"..totalMemsNum..", totalMemsPage:"..totalMemsPage)
			-- log(members)

			if #members > 0 then
				local clubData = self:getClubData(self.requestMemClubId)
				if clubData then
					clubData.memsPageIndex = pageIndex
					clubData.memsPageSize = pageSize
					clubData.totalMemsNum = totalMemsNum
					clubData.totalMemsPage = totalMemsPage
					clubData.isOwner = isOwner
					clubData.isManager = isManager

					if pageIndex == 1 then
						clubData.members = {}
					end
					--加入成员列表
					table.insertto(clubData.members, members)
				end

				self:fireEvent(EVT.PUSH_CLUB_MEMBERS_LIST)
			end

		elseif response.type == Club_pb.Request_Member_del then
			--踢出成员
			if self.deleteMemberMsg then
				local clubData = self:getClubData(self.deleteMemberMsg.clubId)
				if clubData then
					for i, v in ipairs(clubData.members) do
						if v.userId == self.deleteMemberMsg.userId then
							v.isManager = false

							self:fireEvent(EVT.PUSH_CLUB_DELETE_MEMBER, v)
							table.remove(clubData.members, i)
							self.deleteMemberMsg = nil
							break
						end
					end
				end
			end

		elseif response.type == Club_pb.Request_Member_Query_ForId then


		elseif response.type == Club_pb.Request_Room_List then
			--俱乐部房间数据
			local roomList = {}
			local clubId = response.roomListResponse.id
			local roomData = response.roomListResponse.roomInfo
			for i, v in ipairs(roomData) do
				local item = {}
				item.roomId = v.roomId
				item.typeId = v.typeId
				item.playId = v.playId
				item.gameName = v.gameName
				item.baseChip = v.baseChip
				item.desc = v.desc
				item.createTime = v.createTime
				item.scorePayType = v.scorePayType
				item.groupConfig = v.groupConfig
				--房间成员
				item.members = {}

				local member = v.member
				for _, m in ipairs(member) do
					local mem = {}
					mem.userId = m.userId
					mem.userName = m.userName
					mem.headImage = m.headImage
					mem.isOwner = m.isOwner
					mem.isManager = m.isManager
					table.insert(item.members, mem)
				end

				roomList[#roomList + 1] = item
			end

			if #roomList > 0 then
				local clubData = self:getClubData(clubId)
				if clubData then
					clubData.roomList = roomList
				end
			end
			
			self:fireEvent(EVT.PUSH_CLUB_ROOM_LIST, roomList, clubId)

		elseif response.type == Club_pb.Request_Leave then
			--离开俱乐部
			self:fireEvent(EVT.PUSH_CLUB_REQUEST_LEAVE)

		elseif response.type == Club_pb.Request_List_Apply then
			--申请列表数据
			local applyList = {}
			local clubId = response.applyListResponse.id
			local applyData = response.applyListResponse.applyPlayer
			for i, v in ipairs(applyData) do
				local item = {}
				item.userId = v.userId
				item.userName = v.userName
				item.headImage = v.headImage
				item.clubId = clubId
				applyList[#applyList + 1] = item
			end

			if #applyList > 0 then
				local clubData = self:getClubData(clubId)
				if clubData then
					clubData.applyList = applyList

					-- log(clubData)
				end
			end

			--申请加入俱乐部请求列表
			self:fireEvent(EVT.PUSH_CLUB_APPLY_LIST, applyList, clubId)

		elseif response.type == Club_pb.Apply_Push then
			--申请消息推送
			local applyList = {}
			local clubId = response.applyListResponse.id
			local applyData = response.applyListResponse.applyPlayer
			
			local clubData = self:getClubData(clubId)
			local userId = Model:get("Account"):getUserId()
			for i, v in ipairs(applyData) do
				local item = {}
				item.userId = v.userId
				item.userName = v.userName
				item.headImage = v.headImage
				item.clubId = clubId
				if v.userId ~= userId then
					local isAdded = false
					for _, info in ipairs(clubData.applyList) do
						if v.userId == info.userId then
							isAdded = true
							break
						end
					end

					if not isAdded then
						applyList[#applyList + 1] = item
					end
					
				end
			end

			if #applyList > 0 then				
				if clubData then
					table.insertto(clubData.applyList, applyList)
				end

				self:fireEvent(EVT.PUSH_CLUB_APPLY_LIST, applyList, clubId)
			end

		elseif response.type == Club_pb.Apply_Result_Push then
			--申请加入俱乐部结果
			-- log("Apply_Result_Push")

		elseif response.type == Club_pb.Request_PickUp_Income then
			--提现
			self:fireEvent(EVT.PUSH_CLUB_GET_INCOME)
		elseif response.type == Club_pb.Request_Set_Draw then
			self:fireEvent(EVT.PUSH_CLUB_SET_DRAW)

		else
			log("[Club::onClubData] error type !")
		end
	else
		if response.type == Club_pb.Request_List_Apply then

		elseif response.type == Club_pb.Apply_Result_Push then
			
		else
			local data = {
				content = response.tips
			}
			ui.mgr:open("Dialog/DialogView", data)
		end
	end

	if response.type == Club_pb.Request_Apply then
		self:fireEvent(EVT.PUSH_JOIN_CLUB_RESULT, response.isSuccess)
	end
end

function class:parseClubMsgInfo()

end

function class:updateClubData(info)
	local isNewMsg = true
	for i, v in ipairs(self.clubList) do
		if v.id == info.id then
			self.clubList[i] = info

			isNewMsg = false
			break
		end
	end

	if isNewMsg then
		if info.isOwner then
			table.insert(self.clubList, 1, info)
		else
			table.insert(self.clubList, info)
		end
	end

	-- log(self.clubList)
end

function class:removeClubData(clubId)
	for i, v in ipairs(self.clubList) do
		if v.id == clubId then
			table.remove(self.clubList, i)
			break
		end
	end
end

function class:removeUserClubMsg(clubId, userId)
	for i, v in ipairs(self.clubList) do
		if v.id == clubId then
			for m, n in ipairs(v.applyList) do
				if n.userId == userId then
					table.remove(v.applyList, m)
					break
				end
			end

			break
		end
	end
end

function class:getClubList()
	return self.clubList
end

function class:getClubData(clubId)
	for i, v in ipairs(self.clubList) do
		if v.id == clubId then
			return v
		end
	end

	return nil
end


