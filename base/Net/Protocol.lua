----------------------------------------------
-- 消息内容 自动pack unpack
----------------------------------------------
module(..., package.seeall)

require "struct_ext"


JSON_PROTOCAL_CS = 0x20+0x01
JSON_PROTOCAL_SC = 0x20+0x16

local CMD_PROTOCAL_CS = 0x10+0x0e

local internal = {}



function import(_, ...)
	return internal:import(...)
end

function encode(_, msgId, data)
	return internal:encode(msgId, data)
end

function decode(_, msgId, data)
	return internal:decode(msgId, data)
end

function encodeJson(_, modId, cmdId, data)
	return internal:encodeJson(modId, cmdId, data)
end

function decodeJson(_, data)
	return internal:decodeJson(data)
end

function getCmdSC(_, msgId)
	return internal:getCmdSC(msgId)
end

function getCmdCS(_, msgId)
	return internal:getCmdCS(msgId)
end


-----------游戏自定义的消息解析格式------------------
--
local structmt = structex.mt
function structmt:readString(fmt)
    local len = fmt and self:unpack(fmt) or self:readShort()
    local str
    if len == 1 then
    	str = ""
    else
    	str = self:unpack("c" .. (len-1))
    end

    self:unpack("c1")  --服务器多写了一个\0  其实没这个必要
    return str
end

function structmt:readWString()
	local len = self:readShort("u")

	local tmp = {}
	local char = 0
    for i = 1, len do
    	local v = self:readShort("u")
    	if v <= 0x007F then
    		char = bit.band(0xFF, v)
    		table.insert(tmp, string.char(char))
    	elseif v <= 0x07FF then
    		char = bit.band(v, 0x07C0)
    		char = bit.rshift(char, 6)
    		char = bit.bor(0xC0, char)
    		table.insert(tmp, string.char(char))

    		char = bit.band(v, 0x003F)
    		char = bit.bor(0x80, char)
    		table.insert(tmp, string.char(char))
    	else
    		char = bit.band(v, 0xF000)
    		char = bit.rshift(char, 12)
    		char = bit.bor(0xE0, char)
    		table.insert(tmp, string.char(char))

    		char = bit.band(v, 0x0FC0)
    		char = bit.rshift(char, 6)
    		char = bit.bor(0x80, char)
    		table.insert(tmp, string.char(char))

    		char = bit.band(v, 0x003F)
    		char = bit.bor(0x80, char)
    		table.insert(tmp, string.char(char))
    	end
    end
    return table.concat(tmp)
end

function structmt:writeWString(value)
	self:writeString(value)
end

function structmt:readLongString()
    local data = self:readBytes(8)
    data = Util.Struct.ReadLongString(data)
    return data
end

function structmt:writeLongString(value)
	local data = Util.Struct.WriteLongString(value)
	self:writeBytes(data, 8)
end
--
-----------------------------------------------------





Reader = objectlua.Object:subclass()

function Reader:initialize(config, data)
	super.initialize(self)
	self.data = structex:new({data = data})
	self.result = self:read(config)
end

function Reader:getResult()
	return self.result
end

function Reader:readProperty(types)
	local v
	if types == "int" then
		v = self.data:readInt("s")

	elseif types == "uint" then
		v = self.data:readInt("u")

	elseif types == "string" then
		v = self.data:readString()
		-- v = Tw.Utf8.ToAnsi(v)

	elseif types == "wstring" then
		v = self.data:readWString()
		-- v = Tw.Utf8.ToAnsi(v)

	elseif types == "long" then
		v = self.data:readLong()

	elseif types == "int64" then
		v = self.data:readLong()

	elseif types == "short" then
		v = self.data:readShort("s")

	elseif types == "ushort" then
		v = self.data:readShort("s")

	elseif types == "byte" then
		v = self.data:readByte("s")

	elseif types == "ubyte" then
		v = self.data:readByte("u")

	elseif types == "longstring" then
		v = self.data:readLongString()

	else
		assert(false)
	end

	return v
end

function Reader:readArray(value, lenType)
	assert(type(value) == "table")
	local num = self:readProperty(lenType)
	local array = {}
	for i = 1, num do
		local v = self:read(value)
		table.insert(array, v)
	end
	return array
end

function Reader:read(config)
	local result = {}
	for _, info in ipairs(config) do
		local name = info[1]
		local value = info[2]
		local types = info[3]

		if types == "attr" then
			v = self:readProperty(value)
		elseif types == "array" then
			local lenType = info[4] or "ubyte"
			v = self:readArray(value, lenType)
		else
			assert(false)
		end

		result[name] = v
	end
	return result
end




Writer = objectlua.Object:subclass()

function Writer:initialize(config, info)
	super.initialize(self)
	self.data = structex:new({})
	self:write(config, info)
end

function Writer:getResult()
	return self.data:getPackData()
end

function Writer:writeProperty(types, value)
	if types == "int" then
		self.data:writeInt(value, "s")

	elseif types == "uint" then
		self.data:writeInt(value, "u")

	elseif types == "string" then
		-- value = Tw.Utf8.FromAnsi(value)
		self.data:writeString(value)

	elseif types == "wstring" then
		-- value = Tw.Utf8.FromAnsi(value)
		self.data:writeWString(value)

	elseif types == "int64" then
		self.data:writeLong(value, "s")

	elseif types == "short" then
		self.data:writeShort(value, "s")

	elseif types == "ushort" then
		self.data:writeShort(value, "u")

	elseif types == "byte" then
		self.data:writeByte(value, "s")

	elseif types == "ubyte" then
		self.data:writeByte(value, "u")

	elseif types == "longstring" then
		self.data:writeLongString(value)

	else
		assert(false)
	end
end

function Writer:writeArray(config, value)
	assert(type(value) == "table" and type(config) == "table")
	local num = #value
	self:writeByte(num)
	self:write(config, value)
end

function Writer:write(config, data)
	for _, info in ipairs(config) do
		local name = info[1]
		local value = info[2]
		local types = info[3]

		local v
		if types == "attr" then
			v = self:writeProperty(value, data[name])
		elseif types == "array" then
			v = self:writeArray(value, data[name])
		else
			assert(false)
		end
	end
end


--------------------------------------------------------------------------------
--
JsonReader = objectlua.Object:subclass()

function JsonReader:initialize(info)
	super.initialize(self)
	self.data = structex:new({data = info})
	self.result, self.modId, self.cmdId = self:read()
end

function JsonReader:getResult()
	return self.result, self.modId, self.cmdId
end

function JsonReader:read()
	local modId = self.data:readString()
	local cmdId = self.data:readString()
	local isZip = tonumber(self.data:readByte("s")) == 1

	log4net:info("JsonReader:read mod:" .. modId .. " cmd:" .. cmdId
					.. (isZip and " zip:true" or " zip:false"))

	local data
	if isZip then
		local len = self.data:readInt()
		data = self.data:readBytes(len)
		data = util.zip:unzip(data)
	else
		data = self.data:readString()
	end
	data = json.decode(data)

	return data, modId, cmdId
end


JsonWriter = objectlua.Object:subclass()

function JsonWriter:initialize(modId, cmdId, info)
	super.initialize(self)
	self.data = structex:new({})

	self.data:writeString(modId)
	self.data:writeString(cmdId)
	self:write(info)
end

function JsonWriter:getResult()
	return self.data:getPackData()
end

function JsonWriter:write(info)
	local str = json.encode(info)
	if #str > 200 then
		log4net:info("JsonWriter:write zip:true")
		self.data:writeByte(1)  --isZip
		str = util.zip:zip(str)

		local len = #str
		self.data:writeInt(len)
		self.data:writeBytes(str, len)
	else
		log4net:info("JsonWriter:write zip:false")
		self.data:writeByte(0)  --isZip
		self.data:writeString(str)
	end
end


--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--
CmdWriter = objectlua.Object:subclass()

function CmdWriter:initialize(info)
	super.initialize(self)
	self.data = structex:new({})
	self:write(info)
end

function CmdWriter:getResult()
	return self.data:getPackData()
end

function CmdWriter:write(info)
	assert(info and #info.command > 0)
	self.data:writeString(table.concat(info, ":"))
end

--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--
internal.mods = {}
internal.name2type = {}
internal.msgId2CmdSC = {}
internal.msgId2CmdCS = {}

function internal:import(name, modMsg)
	self.mods[name] = modMsg
	self:parseType(modMsg)
	self:parseCmds(modMsg)
end

function internal:parseType(modMsg)
	local name2type = self.name2type
	for k, v in pairs(modMsg.types) do
		local full = string.format("%s.%s", modMsg.name, k)
		name2type[full] = v
	end
end

function internal:getType(name)
	return self.name2type[name]
end

function internal:getCmdCS(msgId)
	return self.msgId2CmdCS[msgId]
end

function internal:getCmdSC(msgId)
	return self.msgId2CmdSC[msgId]
end

function internal:parseCmds(modMsg)
	if modMsg.protocolType == "json" then
		return
	end

	local modId = modMsg.id
	local msgId2CmdSC = self.msgId2CmdSC
	for _, cmd in pairs(modMsg.cmdsSC) do
		local msgId = modId + cmd[1]
		msgId2CmdSC[msgId] = cmd
	end

	local msgId2CmdCS = self.msgId2CmdCS
	for _, cmd in pairs(modMsg.cmdsCS) do
		local msgId = modId + cmd[1]
		msgId2CmdCS[msgId] = cmd
	end
end

function internal:encode(msgId, data)
	if msgId == CMD_PROTOCAL_CS then
		return CmdWriter:new(data):getResult()
	end

	local cmd = self.msgId2CmdCS[msgId]
	local sendConfig = cmd[2]
	data = Writer:new(sendConfig , data):getResult()
	return data
end

function internal:decode(msgId, data)
	local cmd = self.msgId2CmdSC[msgId]
	if cmd == nil then
		log4net:warn("can not find cmd by msgId:" .. msgId)
		return
	end

	local recvConfig = cmd[2]
	data = Reader:new(recvConfig, data):getResult()
	return data
end

function internal:encodeJson(modId, cmdId, data)
	return JsonWriter:new(modId, cmdId, data):getResult()
end

function internal:decodeJson(data)
	return JsonReader:new(data):getResult()
end

rawset(_G, 'MsgType', bind(internal.getType, internal))

