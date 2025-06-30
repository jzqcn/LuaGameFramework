require "Protol.Room_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_ROOM_INFO",
}

class = Model.class:subclass()

local Room_pb = Room_pb

function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_ROOM, self:createEvent("onRoomData"))
end

--请求加入房间
function class:requestAddRoomById(roomId)
	local request = Room_pb.RoomRequest()
	request.requestType = Room_pb.Request_Find_TypeId
	request.findTypeIdRequest.roomId = roomId

	net.msg:send(MsgDef_pb.MSG_ROOM, request:SerializeToString())
end

function class:onRoomData(data)
	local response = Room_pb.RoomResponse()
	response:ParseFromString(data)
	local isSuccess = response.isSuccess
	if isSuccess == true then
		local roomId = response.findTypeIdResponse.roomId
		local playId = response.findTypeIdResponse.playId
		local typeId = response.findTypeIdResponse.typeId
		
		log("[Room::onRoomData] roomId : "..roomId..", playId : "..playId..", typeId : "..typeId)

		--服务器返回房间相关数据，请求加入房间
		local item = Model:get("Hall"):getCardItem(typeId)
		if item then
			Model:get("Games/"..item.itemName):requestEnterRoom(playId, typeId, Common_pb.RsCard, roomId)
		else
			log4model:error("[Room::onRoomData] get card item data failed ! type id == "..typeId)
		end
	else
		local data = {
			content = response.tips
		}
		ui.mgr:open("Dialog/DialogView", data)

		self:fireEvent(EVT.PUSH_ROOM_INFO)
	end
end