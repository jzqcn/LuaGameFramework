
module(..., package.seeall)

EVT = 
{
	["SEND"] 	= "SEND",
	["RESPOSE"] = "RESPOSE",
	["ERROR"] 	= "ERROR",
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



class = Events.class:subclass()

function class:initialize()
	super.initialize(self)
	
	self.listenList = {}
	self.showUIList = {}
	self.uiControl = classUIControl:new()
end

function class:dispose()
	super.dispose(self)
end

function class:setUIControl(obj)
	self.uiControl = obj
end

function class:send(data, event, showUI)
	showUI = showUI or true

	local httpReq = IHttp.Request()
	httpReq.strHost = data.ip
	httpReq.usPort = data.port or 80
	httpReq.strMethod = data.method or 'GET'
	httpReq.strAction = data.uri   --格式："/phppay/app/pay.php?goodsInfo=aaaaaa"  get和post都用这个
	httpReq.ucRetry = 0

	if data.filename then
		httpReq:SetDownloadFile(data.filename)
		httpReq:AddHeader('Range', string.format('bytes=%d-', httpReq.pBufferReader:GetInitFileSize()))
	end

	local reqId = httpReq.uReqId
	self:bindEvent(reqId, event)

	if showUI then
		self.showUIList[reqId] = true
		self.uiControl:block(true)
	end
	
	IHttp:GetInstance():SendRequest(httpReq)

	if data.listen then
		assert(data.filename, "must has download filename")
		self.listenList[reqId] = data.listen
		self:startListen()
	end

	local strDebug
	if IsDevMode() then  --方便失败后定位是哪里的功能
		local what = debug.getinfo(2)
		strDebug = string.format("file:%s line:%d", what.short_src, what.currentline)
	end
	self:fireEvent(EVT.SEND, reqId, strDebug)

	log4http:info("[[http send:" .. tostring(data) .. (strDebug or ""))
	return reqId
end

function class:onRespose(reqId, data)
	log4http:warn("[[http respose:" .. reqId .. " \ndata:" .. tostring(data))

	if self.showUIList[reqId] then
		self.showUIList[reqId] = false
		self.uiControl:block(false)
	end

	self:fireEvent(EVT.RESPOSE, reqId, data)

	self.listenList[reqId] = nil
	self:fireEvent(reqId, 0, data)
	self:endListen()
end


-- enum 
-- {
-- 	ERR_SUCC,   --0
-- 	ERR_CREATE_THREAD,
-- 	ERR_HEADER_FORMAT,
-- 	ERR_CREATE_SOCKET,
-- 	ERR_GETHOSTBYNAME,
-- 	ERR_CONNECT,
-- 	ERR_SEND,
-- 	ERR_RECV,
-- 	ERR_TIMEOUT,
-- 	ERR_DECODE,
-- 	ERR_CONN_RESET,
-- };
function class:onError(reqId, code)
	log4http:info("[[http error:" .. reqId .. " code:" .. code)
	if self.showUIList[reqId] then
		self.showUIList[reqId] = false
		self.uiControl:block(false)
	end

	self:fireEvent(EVT.ERROR, reqId, code)

	self.listenList[reqId] = nil
	self:fireEvent(reqId, code ~= 0 and code or -1)
	self:endListen()
end

--取文件下载进度 nRecvSize nTotalSize
function class:getDownloadInfo(reqId)
	local info = IHttp:GetInstance():GetDownloadInfo(reqId)
	if nil == info then
		return 0, 1
	end
	return info.nRecvSize, info.nTotalSize
end

--getUrl(host, [port = 80,] uri)
function class:getUrl(host, port, uri)
	if uri == nil then
		port, uri = 80, port
	end
	return string.format("http://%s:%d%s", host, port, uri or "/")
end

function class:getUri(data, key)
	if type(data) ~= 'table' then
		log4net:warn('error data for uri')
		return ''
	end

	local index = table.indices(data)
	table.sort(index)

	local str = ''
	for _, name in ipairs(index) do
		str = str .. name .. '=' .. (data[name] or '') .. '&'
	end

	local sign = key and ('&sign=' .. util:md5(str .. key)) or ''
	return '?' .. string.sub(str, 1, #str -1) .. sign
end


-----------internal-------------
function class:startListen()
	if self.lisEvent then
		return
	end

	self.lisEvent = self:createEvent("progressCall")
	util.timer:repeats(50, self.lisEvent)
end

function class:endListen()
	if nil == self.lisEvent or
	  not table.empty(self.listenList) then
		return
	end

	self.lisEvent:unbind()
	self.lisEvent = nil
end

function class:progressCall()
	for reqId, callback in pairs(self.listenList) do
		local recv, total = self:getDownloadInfo(reqId)
		callback(recv, total)
	end
end
