require "struct"

module(..., package.seeall)


local internal = {}

SOCKET_ID = Enum
{
	"GAME_SERVER"
}

EVT = Enum
{
	"CONN", 
	"READ", 
	"SEND", 
	"CLOSE", 
}

STATUS = Enum
{
	"CLOSE",
	"CONNECT",
	"WORK",
}

local CONNECT_TIME_OUT = 10 * 1000--连接超时时间   @todo本地调试可以多加些时间 便于服务器断点
local DUMP_MSG = false

NET_SHOW_MSG = 
{
	["UN_CONNECT_SERVER"] = "无法连接服务器！请检查网络是否畅通！",
	["DISCONNECT_SERVER"] = "与服务器断开连接！请检查网络是否畅通！",
	["CONNECT_SERVER_FAILED"] = "网络不给力，连接服务器失败！是否重新连接？",
	["CONNECT_SERVER_TIME_OUT"] = "连接服务器超时！是否重新连接？"
}
--------------------------------------------------------------------------------
-- NetMgr

local singleton
function getSingleton(_)
	assert(singleton ~= nil)
	return singleton
end

class = Events.class:subclass()

function class:initialize()
	super.initialize(self)
	
	assert(nil == singleton)
	singleton = self

	self.socketId = SOCKET_ID.GAME_SERVER
	self.status = STATUS.CLOSE
	self.seqId = 0
end

function class:dispose()
	super.dispose(self)
end

function class:isReady()
	return self.status == STATUS.WORK
end

function class:getSeqId()
	return self.seqId
end

function class:on(type, event)
	self:bindEvent(type, event)
end


function class:connect(host, port)
	if self.status ~= STATUS.CLOSE then
		self:disconnect()
	end

	log4net:info("NET:connect host:" .. host .. " port:" .. port)

	if self:existEvent('CON_TIMEOUT_TIMER') then
		self:cancelEvent('CON_TIMEOUT_TIMER')
	end

	self.status = STATUS.CONNECT
	self:setSecretKey(0)

	util.timer:after(CONNECT_TIME_OUT, self:createEvent('CON_TIMEOUT_TIMER', 'onConnectTimeOut'))
	return CNetMgr:GetSingleton():Connect(self.socketId, host, port)
end

function class:disconnect()
	log4net:info("NET:disconnect")

	self:cancelEvent('CON_TIMEOUT_TIMER')
	self.status = STATUS.CLOSE
	-- self.seqId = 0
	CNetMgr:GetSingleton():Disconnect(self.socketId)

	sdk.yvVoice:logout()
end

function class:onConnectTimeOut()
	self:disconnect()
	self:onNetworkConnect(self.socketId, false)
end

function class:onNetworkConnect(socketId, succ)
	log4net:info("NET:onNetworkConnect socketId:" .. socketId .. " suc:" .. (succ and "true" or "false"))
	assert(self.socketId == socketId)
	self:cancelEvent('CON_TIMEOUT_TIMER')

	if succ then
		self.status = STATUS.WORK
		self.seqId = 0
	end
	self:fireEvent(EVT.CONN, succ)
end

function class:onNetworkRead(socketId, data)
	
	-- local msgId = struct.unpack(">!1B", data, 1)
	-- local body = string.sub(data, 2)

	-- log4net:warn("NET:onNetworkRead msgId:" .. msgId .. " len:" .. #data)

	net.msg:onReceived(data)

	-- if DUMP_MSG then
	-- 	log4temp:debug("receive msg:" .. msgId)
	-- 	log4temp:debug(string.dumpex(data))
	-- end

	-- self:fireEvent(EVT.READ, {id = msgId, data = body})
	-- net.msg:onReceived(msgId, body)
end

function class:onNetworkClosed(socketId)
	log4net:info("NET:onNetworkClosed socketid:" .. socketId)
	self.ready = false
	-- self.seqId = 0
	self:fireEvent(EVT.CLOSE)
end

function class:send(msgId, data)
	-- log4net:info("NET:send msgId:" .. msgId)
	self:fireEvent(EVT.SEND, msgId)

	-- local msg = struct.pack('>!1b', msgId)
	-- msg = msg .. data

	-- if DUMP_MSG then
	-- 	log4temp:debug("send:" .. msgId, string.len(msg))
	-- 	log4temp:debug(string.dumpex(msg))
	-- end
	self.seqId = self.seqId + 1

	return CNetMgr.SendMsg(self.socketId, data)
end

function class:setSecretKey(key)
	CNetMgr:GetSingleton():SetSecretKey(key)
end