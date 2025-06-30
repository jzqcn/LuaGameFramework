----------------------------------------------
-- 2016/09/06
-- 通过在cocos studio中配置控件内容
-- 来自动将控件名称 事件 类型 适配方式等绑定到lua对象
-- 名称：只有小写开头的才会自动映射到lua中来
-- 回调方法: click touch event 直接配置 要同时配置 调用事件的函数名称
-- 帧事件: ccs动画相关 不是静态使用的  可以为某个动画帧配置上该值 现实帧回调
	-- 方法一：每个配置的帧数据 都会回调
	-- self:setFrameEventCallFunc(bind(self.frameEventCallback, self))
	-- 注意：回调函数中的参数
	-- function prototype:frameEventCallback(frame)
	-- 	local name = frame:getEvent()   --这个name是编辑器中配置的值
	-- end
	-- 方法二: 动画帧完成后 自动回调
	-- self:setLastFrameCallFunc(function () log("gameloading framecallback2:last frame") end)
	
-- 用户数据：用来扩展控件的功能  
	-- 支持：扩展类型Type 以及大小适配RelativeParent等
	-- 如果有多个内容 用;隔开  如："Type:GridView;RelativeParent:[0,160]"
	--
	--与父节点的大小关系
	-- RelativeParent:[w,h]   w h父节点固定差额
	-- RelativeParentFixH:[w,0]   w:父节点固定差额 h:不变 为了保持格式不变(填0)
	-- RelativeParentFixW:[0,h]   h:父节点固定差额 w:不变 为了保持格式不变(填0)
	-- PercentParentFixH:[w,h] w:是父节点的百分比大小 h:固定差额
	-- PercentParentFixW:[w,h] w:固定差额 h:是父节点的百分比大小 
--
-- 注意：
-- 	1 窗口的自定义类需要设置为Widget
-- 	2 只有重命名(小写开头)后的控件 才会自动识别绑定事件和扩展功能
--
----------------------------------------------
module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(loader)
	super.initialize(self)
	self.loader = loader
end

function class:loadLuaClass(proxy, layer)
	self:parseControlVariable(proxy, layer)
    self:parseLocateCallback(proxy, layer)
end


function class:parseControlVariable(proxy, layer)
	local widget = self.loader:castWidget(layer)
	if not widget then
		return
	end

	local bindChildName = widget:getChildBindName()
	for name, node in pairs(bindChildName) do
		-- log("------------------> bind child name:"..name)
		proxy[name] = node
		self:parseProjectNode(node, name)
		self:parseCustomProperty(node, name)
	end
end

function class:parseLocateCallback(proxy, layer)
	local widget = self.loader:castWidget(layer)
	if not widget then
		return
	end

	local tcbk = bind(proxy["onLocateTouchCallback"], proxy)
	widget:addLocateTouchCallback(tcbk)

	local cbk = bind(proxy["onLocateCallback"], proxy)
    widget:addLocateEventCallback(cbk)

    local clickCb = function (...)
    	self.loader:onLocateClick(...)
    	cbk(...)
    end
    widget:addLocateClickCallback(clickCb)
end

function class:parseProjectNode(node, ccsname)
	local widget = self.loader:castWidget(node)
	if nil == widget then
		log4ui:warn("ProjectNode must set class as Widget in CocosBuilder:" .. ccsname)
		return
	end

	local filePath = widget:getFilePath()
	if filePath == "" then
		-- log4ui:warn("ProjectNode file path is null ! ccsName:" .. ccsname)
		return
	end

	-- log("parseProjectNode:: filePath ====== "..filePath)
	--"resource/csb/UITest/UITestControlItem.csb"	
	local className = string.match(filePath, "resource/csb/(.+)%.csb")
	if not className then
		className = string.match(filePath, "resource/(.+)%.csb")
	end
	local actionTime = cc.CSLoader:createTimeline(filePath)
	if actionTime then
		actionTime:retain()
	end
	-- log("parseProjectNode:: className ========= "..className)
	self.loader:loadLuaClass(className, widget, actionTime)    
end

--用户数据
function class:parseCustomProperty(node, ccsname)
	local widget = self.loader:castWidget(node)
	if nil == widget then
		-- log4ui:warn("CustomProperty must set class as Widget in CocosBuilder:" .. ccsname)
		return
	end

	local property = widget:getCustomProperty()
	if property == "" then
		return
	end

	--Type:GridView;RelativeParent:[0,160]
	if property[#property] ~= ";" then
		property =  property .. ";"
	end

	local attribute = {}
	for s in string.gmatch(property, "(.-);") do
		local k, v = string.match(s, "(.-):(.+)")
		-- log("s:"..s..", k:"..k..", v:"..v)
		assert(k and v, "property format error:" .. property)
		attribute[k] = v
	end

	self:parseAttribute(widget, attribute)
end

function class:parseAttribute(widget, attribute)
	for k, v in pairs(attribute) do
		if k == "Type" then
			self.loader:loadLuaClass("UI.Control." .. v, widget)

		elseif k == "RelativeParent" or k == "PercentParentFixH" or k == "PercentParentFixW" or k == "RelativeParentFixH" or k == "RelativeParentFixW" then
			local w, h = string.match(v, "%[(.+),(.+)%]")
			w = tonumber(w)
			h = tonumber(h)

			local parent = widget:getParent()
			local parentSize = parent:getContentSize()
			local nodeSize = widget:getContentSize()

			if k == "RelativeParent" then
				widget:setContentSize(cc.size(parentSize.width - w, parentSize.height - h))

			elseif k == "PercentParentFixH" then
				local wNew = parentSize.width * w
				local hNew = parentSize.height - h
				widget:setContentSize(cc.size(wNew, hNew))

			elseif k == "PercentParentFixW" then
				local wNew = parentSize.width - w
				local hNew = parentSize.height * h
				widget:setContentSize(cc.size(wNew, hNew))

			elseif k == "RelativeParentFixH" then
				widget:setContentSize(cc.size(parentSize.width - w, nodeSize.height))

			elseif k == "RelativeParentFixW" then
				widget:setContentSize(cc.size(nodeSize.width, parentSize.height - h))
			end
		end
	end
end




