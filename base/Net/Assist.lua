local Protocol = require "Net.Protocol"

module(..., package.seeall)


local Reader = Protocol.Reader:subclass()
local Listener = objectlua.Object:subclass()

function decode(_, msgId, data, rule)
	local cmd = Protocol:getCmdSC(msgId)
	if cmd == nil then
		log4net:warn("can not find cmd by msgId:" .. msgId)
		return
	end

	local recvConfig = cmd[3]
	local lis = Listener:new(rule)

	return Reader:new(recvConfig, data, lis):getResult()
end

function Reader:initialize(config, data, listener)
	self.listener = listener 
	super.initialize(self, config, data)
end

function Reader:canRead(name)
	return self.listener:canRead(name)
end

function Reader:hasRead(name, value)
	self.listener:hasRead(name, value)
end

function Reader:read(config)
	local result = {}
	for _, info in ipairs(config) do
		local name = info[1]
		local value = info[2]
		local types = info[3]

		if self:canRead(name) then
			local v
			if types == "attr" then
				v = self:readProperty(value)
			elseif types == "array" then
				local lenType = info[4] or "ubyte"
				v = self:readArray(value, lenType)
			else
				assert(false)
			end

			result[name] = v
			self:hasRead(name, v)
		end
	end
	return result
end

---------------Listener-----------------
function Listener:initialize(rule)
	super.initialize(self)

	self.rule = rule 
	self.values = {}
	self.start = false
end

function Listener:canRead(name)
	if not self.start or not self.rule.ignore[name] then
		return true
	end

	return self.rule.check(self.values)
end

function Listener:hasRead(name, value)
	if name == self.rule.switch.start then
		self.start = true
		return
	elseif name == self.rule.switch.ends then
		self.start = false 
		return
	end

	if not self.start then
		return
	end

	if self.rule.key[name] then
		self.values[name] = value
	end
end




