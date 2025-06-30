module(..., package.seeall)


class = objectlua.Object:subclass()

function class:initialize(...)
	super.initialize(self)

	self.events = {}

	-- self.docPath = CVariableSystem:GetSingleton():GetSysVariable(GV_DOCPATH)
	local variable = CVariableSystem:GetSingleton()
	local patchPath = variable:GetSysVariable(GV_PATCHPATH)
	self.folder = "headRes/"
	self.imageHeadPath = patchPath .. self.folder
	CDirUtils:MkDir(self.imageHeadPath)
end

function class:dispose()
	super.dispose(self)
end

function class:unbind(callOrevent)
	for i, v in ipairs(self.events) do
		if v.event == callOrevent or v.call == callOrevent then
			table.remove(self.events, i)
			break
		end
	end
end

--加载头像通过events。否则可能返回后widget已经释放，导致出错
function class:loadHeadImage(userId, userName, imgUrl, callOrevent, widget)
	if not widget or not userId then
		log("init head image error ! widget is nil or userId is nil")
		return
	end

	imgUrl = imgUrl or ""
	-- log4misc:warn("imgUrl:"..imgUrl)
	if Model:get("Account"):isAccountLogin() then
		imgUrl = tonumber(imgUrl) or 1
		widget:loadTexture(string.format("resource/csbimages/User/headImages/touxiang_%d.png", imgUrl))
		return
	end

	if imgUrl == "" or imgUrl == "unknown" then
		widget:loadTexture("resource/csbimages/User/imgDefaultHead.png")
		return
	end

	if util:getPlatform() == "win32" then
		widget:loadTexture("resource/csbimages/User/imgDefaultHead.png")
		return
	end

	local fileName = util:md5(tostring(userId .. userName))
	fileName = string.format("icon_%s.png", tostring(fileName))
	-- log("headImage:: fileName : " .. fileName .. ", userId : " .. userId .. ", userName : " .. userName)

	local fullPath = self.imageHeadPath .. fileName
	if util:fileExist(fullPath) then
		widget:loadTexture(self.folder .. fileName)
		return
	end

	local call = type(callOrevent) == "function" and callOrevent or nil
	local event = call == nil and callOrevent or nil
	if event then
		event:bind(self)
	end

	local xhr = cc.XMLHttpRequest:new()
	-- self.xhr = xhr
	xhr.fileName = fileName
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", imgUrl)

	local item =
	{
		call 	= call,
		event	= event, 
		xhr 	= xhr,
	}
	table.insert(self.events, item)

	xhr:registerScriptHandler(function()
		local item
		for i, v in ipairs(self.events) do
			if v.xhr == xhr then
				item = self.events[i]
				table.remove(self.events, i)
				break
			end
		end

		if not item then
			xhr:unregisterScriptHandler()
			return
		end

		if item.event then
			item.event:unbind() 
		end

		local fileName = ""
		-- log("xhr.readyState is:" .. xhr.readyState .. " xhr.status is:" .. xhr.status)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local fileData = xhr.response
			local fullFileName = self.imageHeadPath .. xhr.fileName
			local file = io.open(fullFileName, "wb")
			file:write(fileData)
			file:close()

			-- widget:loadTexture(self.folder .. xhr.fileName)
			-- os.remove(fullFileName)
			fileName = self.folder .. xhr.fileName
		else
			-- widget:loadTexture("resource/csbimages/Common/none.png")
			fileName = "resource/csbimages/User/imgDefaultHead.png"
		end

		if item.call then
			item.call(fileName)
		elseif item.event then
			item.event:fire(fileName)
		end

		xhr:unregisterScriptHandler()
	end)
	xhr:send()
end

--设置头像（微信头像通过URL下载）
function class:getHeadImage(userId, userName, widget, imgUrl)
	if not widget or not userId then
		log("init head image error ! widget is nil or userId is nil")
		return
	end

	imgUrl = imgUrl or ""
	-- log4misc:warn("imgUrl:"..imgUrl)
	if imgUrl == "" or imgUrl == "unknown" then
		widget:loadTexture("resource/csbimages/User/headImages/touxiang_1.png")
		return
	end

	if Model:get("Account"):isAccountLogin() then
		imgUrl = tonumber(imgUrl) or 1
		widget:loadTexture(string.format("resource/csbimages/User/headImages/touxiang_%d.png", imgUrl))
		return
	end

	if util:getPlatform() == "win32" then
		widget:loadTexture("resource/csbimages/User/headImages/touxiang_1.png")
		return
	end

	local fileName = util:md5(tostring(userId .. userName))
	fileName = string.format("icon_%s.png", tostring(fileName))
	-- log("headImage:: fileName : " .. fileName .. ", userId : " .. userId .. ", userName : " .. userName)

	local fullPath = self.imageHeadPath .. fileName
	if util:fileExist(fullPath) then
		widget:loadTexture(self.folder .. fileName)
		return
	end

	-- local beignIndex, endIndex = string.find(imgUrl, "https")
	-- if not beignIndex then
	-- 	imgUrl = string.gsub(imgUrl, "http", "https")
	-- end

	-- log("img url : "..imgUrl)

	ui.mgr:open("Net/Connect")

	local xhr = cc.XMLHttpRequest:new()
	-- self.xhr = xhr
	xhr.fileName = fileName
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", imgUrl)

	xhr:registerScriptHandler(function()
		log("xhr.readyState is:" .. xhr.readyState .. " xhr.status is:" .. xhr.status)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local fileData = xhr.response
			local fullFileName = self.imageHeadPath .. xhr.fileName
			local file = io.open(fullFileName, "wb")
			file:write(fileData)
			file:close()

			widget:loadTexture(self.folder .. xhr.fileName)
			-- os.remove(fullFileName)
		else
			widget:loadTexture("resource/csbimages/Common/none.png")
		end

		ui.mgr:close("Net/Connect")

		xhr:unregisterScriptHandler()
	end)
	xhr:send()
end

