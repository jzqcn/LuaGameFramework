require "Protol.PlayBack_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_PLAYBACK_LIST_DATA",
	"PUSH_PLAYBACK_DETAIL_DATA",
}

class = Model.class:subclass()

local PlayBack_pb = PlayBack_pb

function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_PLAYBACK, self:createEvent("onPlayBackData"))
end

function class:requestRecordList()
	local request = PlayBack_pb.PlayBackRequest()
	request.type = PlayBack_pb.Request_PbList
	net.msg:send(MsgDef_pb.MSG_PLAYBACK, request:SerializeToString())
end

function class:requestRecordDetail(id, groupIndex)
	local request = PlayBack_pb.PlayBackRequest()
	request.type = PlayBack_pb.Request_PbDetail
	request.detailRequest.id = id
	request.detailRequest.index = groupIndex
	net.msg:send(MsgDef_pb.MSG_PLAYBACK, request:SerializeToString())
end

function class:onPlayBackData(data)
	local response = PlayBack_pb.PlayBackResponse()
	response:ParseFromString(data)
	if response.isSuccess then
		if response.type == PlayBack_pb.Request_PbList then
			local pblistResponse = response.pblistResponse
			local item
			local playbackList = {}
			for i, v in ipairs(pblistResponse) do
				item = {}
				item.id = v.id
				item.gameName = v.gameName
				item.roomId = v.roomId
				item.playId = v.playId
				item.typeId = v.typeId
				item.time = v.time				

				--玩家信息
				item.playerData = {}
				for m, n in ipairs(v.playerInfo) do
					local info = {}
					info.playerId = n.playerId
					info.nickName = n.nickName
					info.headImage = n.headImage
					info.seatIndex = n.index

					item.playerData[info.playerId] = info
					-- table.insert(item.playerData, info)
				end

				--每一局
				item.groupData = {}
				for m, n in ipairs(v.group) do
					local info = {}
					info.index = n.index
					info.playerGroup = {}
					info.gameName = item.gameName

					local playerGroup = n.playerGroup
					for _, k in ipairs(playerGroup) do
						local playerInfo = {}
						playerInfo.playerId = k.playerId						
						playerInfo.bp = tonumber(k.bp)
						playerInfo.totalPb = tonumber(k.totalPb)
						playerInfo.initCards = k.initCards
						playerInfo.cardKind = k.cardKind
						playerInfo.result = k.result --结果，根据不同游戏存储不同的
						playerInfo.seatIndex = item.playerData[k.playerId].seatIndex
						playerInfo.nickName = item.playerData[k.playerId].nickName
						playerInfo.headImage = item.playerData[k.playerId].headImage

						table.insert(info.playerGroup, playerInfo)
					end

					item.groupData[info.index] = info
					-- table.insert(item.groupData, info)
				end

				table.insert(playbackList, item)
			end

			local function sortFunc(a, b)
				return a.time > b.time
			end

			table.sort(playbackList, sortFunc)

			-- log(playbackList)

			self.playbackList = playbackList

			ui.mgr:open("GameRecord/GameRecordView", playbackList)
			-- self:fireEvent(EVT.PUSH_PLAYBACK_LIST_DATA, playbackList)

		elseif response.type == PlayBack_pb.Request_PbDetail then
			local pbDetailResponse = response.pbDetailResponse
			local id = pbDetailResponse.id
			local detail = pbDetailResponse.detail
			detail = json.decode(detail)
			-- log(detail)

			self:fireEvent(EVT.PUSH_PLAYBACK_DETAIL_DATA, detail)
		end

	else
		if response.tips and response.tips ~= "" then
			local data = {
				content = response.tips
			}
			ui.mgr:open("Dialog/ConfirmView", data)
		else
			local data = {
				content = "该局数回放不存在"
			}
			ui.mgr:open("Dialog/ConfirmView", data)
			-- log("[PlayBack::onPlayBackData] get playback list failed !")
		end
	end
end

function class:getPlaybackList()
	return self.playbackList
end

function class:setPlaybackInfo(info)
	self.playbackInfo = info
end

function class:getPlaybackInfo()
	return self.playbackInfo
end
