require "Protol.GMService_pb"

module(..., package.seeall)

class = Model.class:subclass()

function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_GM, self:createEvent("onGMResponse"))
end

function class:requestGmMsg(content, gmType)
	local request = GMService_pb.MsgGMRequest()
	request.gmType = gmType or GMService_pb.GM_COMMAND
	request.content = content

	net.msg:send(MsgDef_pb.MSG_GM, request:SerializeToString())
end

function class:onGMResponse(data)
	local response = GMService_pb.MsgGMResponse()
	response:ParseFromString(data)

end