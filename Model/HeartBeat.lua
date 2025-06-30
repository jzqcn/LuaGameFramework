module(..., package.seeall)

class = Model.class:subclass()

local CHECK_HEART_TIME = 15

function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_HeartBeat, self:createEvent("onHeartBeatData"))

    local EVT = Net.Mgr.EVT
	net.mgr:on(EVT.CLOSE, self:createEvent("onNetworkClose"))

	self.timeHeart = 0
end

function class:onNetworkClose()
	self:stopUpdateHeart()
end

function class:startUpdateHeart()
	local scheduler = cc.Director:getInstance():getScheduler()
	if self.scheduleID then
		scheduler:unscheduleScriptEntry(self.scheduleID)
	end
	self.scheduleID = scheduler:scheduleScriptFunc(bind(self.updateHeartMsg, self), 5.0, false)
	self.timeHeart = 0
end

function class:stopUpdateHeart()
	if self.scheduleID then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.scheduleID)
		self.scheduleID = nil
	end
	self.timeHeart = 0
end

function class:updateHeartMsg(interval)
	-- log(interval)
	-- log("send heart beat msg ! msg id : "..MsgDef_pb.MSG_HeartBeat)
	net.msg:sendCommonMsg(MsgDef_pb.MSG_HeartBeat)

	self.timeHeart = self.timeHeart + interval
	--检测心跳是否超时
	if self.timeHeart >= CHECK_HEART_TIME then
		log("update heart time out !!!!!!!!!!")
		net.mgr:onConnectTimeOut()
	end
end

function class:onHeartBeatData(data)
	-- log("on receive heart beat data")
	self.timeHeart = 0
end