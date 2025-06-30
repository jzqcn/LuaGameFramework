module(..., package.seeall)


class = Events.class:subclass()

function class:initialize(rule)
	super.initialize(self)

	self.http = {}
	self.ignoreList = {}
	self:start()
end

function class:addIgnore(reqId)
	self.ignoreList[reqId] = true
end

function class:isIgnore(reqId)
	return self.ignoreList[reqId]
end

function class:start()
	local EVT = Net.Http.EVT
	net.http:bindEvent(EVT.SEND, self:createEvent("httpSend"))
	net.http:bindEvent(EVT.RESPOSE, self:createEvent("httpRespose"))
	net.http:bindEvent(EVT.ERROR, self:createEvent("httpError"))
end

function class:httpSend(reqId, strDebug)
	if self:isIgnore(reqId) then
		return
	end
	self.http[reqId] = {strDebug = strDebug}
end

function class:httpRespose(reqId, data)
	if self:isIgnore(reqId) then
		return
	end
	self.http[reqId] = nil
end

function class:httpError(reqId, code)
	if self:isIgnore(reqId) then
		return
	end
	
	local info = self.http[reqId]
	if nil == info then
		return
	end
	self.http[reqId] = nil

	local tip = string.format("亲，网络不给力哦\n请检查一下网络吧(错误号:%s)", code)
	if info.strDebug then
		tip = tip .. '\n' .. info.strDebug
		log4net:warn(tip)
	end
	ui.confirm:open(tip)
end


