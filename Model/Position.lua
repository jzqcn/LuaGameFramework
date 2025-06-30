require "Protol.Position_pb"

module(..., package.seeall)

class = Model.class:subclass()

local Position_pb = Position_pb

function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_POSITION, self:createEvent("onPositionData"))

    self.userPosInfo = {}
    self.userPosInfo.longitude = ""
    self.userPosInfo.latitude = ""
    self.userPosInfo.address = ""
    self.userPosInfo.ip = ""

    self.playerPosInfo = {}
end

function class:requestRolePos(longitude, latitude, ip)
	if StageMgr:isStage("Hall") or StageMgr:isStage("Game") then
		local request = Position_pb.PositionRequest()
		request.ip = ip or ""
		request.longitude = longitude or ""
		request.latitude = latitude or ""
		net.msg:send(MsgDef_pb.MSG_POSITION, request:SerializeToString())
	end
end

function class:onPositionData(data)
	local response = Position_pb.PositionResponse()
	response:ParseFromString(data)

	if response.isSuccess == false then
		--保存不成功
		log4model:warn("position request failed !!!")
	end	
end

function class:getUserPosition()
	return self.userPosInfo
end

function class:updateLocationMsg()
	--ip、经纬度等信息
	if util:getPlatform() ~= "win32" then
		util:fireCoreEvent(REFLECT_EVENT_GET_LOCATION_MSG, 0, 0, "")
		-- util:fireCoreEvent(REFLECT_EVENT_GET_IP_ADDRESS, 0, 0, "")
	end
end

function class:setUserPosition(longitude, latitude)
	self.userPosInfo.longitude = longitude
	self.userPosInfo.latitude = latitude

	self:requestRolePos(longitude, latitude)

	getPlayerAddress(longitude, latitude, bind(self.setUserAddress, self))
end

function class:setUserAddress(address)
	self.userPosInfo.address = address
	log("setUserAddress::"..address)
end

function class:setUserIpAddress(ip)
	self.userPosInfo.ip = ip

	log("user ip : "..ip)
end

function class:getUserIpAddress()
	return self.userPosInfo.ip
end

function class:clearPlayerPosInfo()
	self.playerPosInfo = {}
end

function class:setPlayerPosInfo(playerId, info)
	if not playerId then
		return
	end

	local data = self.playerPosInfo[playerId]
	if not data then
		self.playerPosInfo[playerId] = info
	else
		if data.latitude == info.latitude and data.longitude == info.longitude then
			return
		end

		self.playerPosInfo[playerId] = info
	end
end

function class:getPlayerPosInfo(playerId)
	return self.playerPosInfo[playerId]
end

function class:setPlayerAddress(playerId, strWidget)
	if util:getPlatform() ~= "win32" then
		local data = self.playerPosInfo[playerId]
		if data then
			if data.address and data.address ~= "" then
				strWidget:setString(data.address)
			else
				local function updateAddress(str)
					data.address = str
					strWidget:setString(str)
				end
				getPlayerAddress(data.longitude, data.latitude, updateAddress)
			end
		end
	end
end
