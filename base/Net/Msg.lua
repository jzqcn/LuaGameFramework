local Protocol = require "Net.Protocol"

module(..., package.seeall)

EVT = Enum
{
	"RECEIVE_MSG",
	"SEND_MSG",
}

classUIControl = objectlua.Object:subclass()

function classUIControl:initialize()
	self.count = 0
end

function classUIControl:block(block)
	if self.count == 0 and block then
		pcall(self.doBlock, self, true)
	end
	
	self.count = self.count + (block and 1 or -1)
	
	if self.count == 0 then
		pcall(self.doBlock, self, false)
	end
end

--virtual
function classUIControl:doBlock(block)
end


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

	self.autoDecodeMsg = {}

	self.showUIList = {}
	-- self:importData()
end

function class:dispose()
	super.dispose(self)
end

--事件注册
function class:onEvent(name, event)
	self:bindEvent(name, event)
end

--消息注册 走事件机制 可扩展额外功能
function class:on(msgId, event, autoDecode)
	autoDecode = nil == autoDecode and true or false
	self.autoDecodeMsg[msgId] = autoDecode
	self:onEvent(msgId, event)
end

function class:onReceived(data)
	local msgResponse = response_pb.Response()
	msgResponse:ParseFromString(data)
	
	local msgId = msgResponse.header.command
	local bodyData = msgResponse.serialized_content
	-- log("[Lua - Network] msg onReceived :: command id:"..msgId)
	if bodyData then
		self:fireEvent(msgId, bodyData, msgId)
	else
		log4net:error("[Lua - Network] msg onReceived :: bodyData is nil !!!")
	end

	if self.showUIList[msgId] then
		self.showUIList[msgId] = false
		ui.mgr:close("Net/Connect")
	end

	-- local newMsgId 
	-- if msgId == Protocol.JSON_PROTOCAL_SC then
	-- 	local mod, cmd
	-- 	data, mod, cmd = Protocol:decodeJson(data)
	-- 	msgId = mod .. cmd
	-- else
	-- 	if self.autoDecodeMsg[msgId] then
	-- 		data = Protocol:decode(msgId, data)
	-- 	end
	-- end

	-- self:fireEvent(msgId, data, msgId)
end

function class:send(msgId, data, showUI)
	showUI = showUI or true
	
	local requestMsg = request_pb.Request()
	requestMsg.header.command = msgId
	requestMsg.header.userId = "916"
	requestMsg.header.token = "abcdefg"
	requestMsg.header.seqID = net.mgr:getSeqId()
	requestMsg.body.serialized_content = data
	requestMsg.num = 1

	net.mgr:send(msgId, requestMsg:SerializeToString())

	if showUI then
		self.showUIList[msgId] = true
		ui.mgr:open("Net/Connect")
	end

	-- data = Protocol:encode(msgId, data)
	-- net.mgr:send(msgId, data)
end

function class:sendCommonMsg(msgId)
	local requestMsg = request_pb.Request()
	requestMsg.header.command = msgId
	requestMsg.header.userId = "916"
	requestMsg.header.token = "abcdefg"
	requestMsg.header.seqID = 16
	requestMsg.body.serialized_content = ""
	requestMsg.num = 1

	net.mgr:send(msgId, requestMsg:SerializeToString())
end

function class:sendJson(modId, cmdId, data)
	data = Protocol:encodeJson(modId, cmdId, data)
	net.mgr:send(Protocol.JSON_PROTOCAL_CS, data)
end


function class:importData()
	----------------------------------------------------------------------------
	-- MsgXXX methods
	local module_mt = {}
	module_mt.__index = module_mt
	function module_mt:on(cmd, event, autoDecode)
		local msgId
		local cmdId = self.cmdsSC[cmd][1]
		if self.protocolType == "json" then
			msgId = self.id .. cmdId
		else
			msgId = self.id + cmdId
		end

		net.msg:on(msgId, event, autoDecode)
	end
	
	function module_mt:post(cmd, data)
		local msgId
		local cmdId = self.cmdsCS[cmd][1]
		log(cmd)
		log(data)
		log(cmdId)
		if self.protocolType == "json" then
			net.msg:sendJson(self.id, cmdId, data)
		else
			msgId = self.id + cmdId
			net.msg:send(msgId, data)
		end
	end

	function module_mt:typeDef(name)
		return self.types[name]
	end

	function module_mt:getMsgId(id)
		return MsgDef_pb[id]
	end
	----------------------------------------------------------------------------


	local fenv = { enum = enum, }
	function fenv.array(name, data, lenType)
		return { name, data, "array", lenType}
	end

	function fenv.attr(name, types)
		return { name, types, "attr"}
	end

	self.import = function(self, name, source)
		local id, cmdsSC, cmdsCS, types, protocolType = setfenv(source, fenv)()
		protocolType = protocolType or "binary"
		local modMsg = { id = id, cmdsSC = cmdsSC, cmdsCS = cmdsCS, types = types, name = name, 
						protocolType = protocolType, }
		
		setmetatable(modMsg, module_mt)
		rawset(_G, name, modMsg)

		Protocol:import(name, modMsg)
	end

	require ("NetModules")
	self.import = nil
end

