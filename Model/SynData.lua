require "Protol.SynData_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_SYN_USER_DATA",
}

class = Model.class:subclass()

function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_SYN_DATA, self:createEvent("onPushSynResponse"))
end

function class:onPushSynResponse(data)
	local response = SynData_pb.PushSynData()
	response:ParseFromString(data)

	local synType = response.synType
	local synData = {}
	synData.silver = tonumber(response.sliver)
	synData.gold = tonumber(response.gold)
	synData.vip = tonumber(response.vipLv)
	synData.cardNum = tonumber(response.card)

	-- if synType == SynData_pb.Syn_Score then
	
	-- elseif synType == SynData_pb.Syn_Sliver then
		
	-- elseif synType == SynData_pb.Syn_Gold then
		
	-- elseif synType == SynData_pb.Syn_Vip then
		
	-- elseif synType == SynData_pb.Syn_Card then

	-- end

	-- log(synData)

	Model:get("Account"):updateUserInfo(synData)

	self:fireEvent(EVT.PUSH_SYN_USER_DATA, synData)
end