----------------------------------------------
-- 2016/09/06
-- 通过代码 手动将ccs中的控件绑定到lua对象
--
-- 格式说明： 在窗口lua对象的initialize函数里 定义如下结构
--		支持的功能：控件名称、事件、大小适配、自定义类型
--[[
	self.RES_BIND =
	{
		--alias 绑定控件对象 并且重命名 如果不需改名字 则直接={}
		--只有alias后 lua里才会获得该控件
		["Node_1"] 		= { alias = "nodeTest" },

		--按钮click事件
		["Button_1"] 	= { method={type = "click", func = "onBtnClose"}},

		--alias + click  注意：如果控件有多层嵌套  用.隔开 (为了提高查找的速度)
		["Node_Building.Node_1.Button_1"] = { alias = "btnMainCity", method={type = "click", func = "onBtnMainCity"}},

		--  touch event事件  类似click  回调时参数多了个状态
		["Button_ScrollView"] 	= { method={type = "touch", func = "onTouchScrollView"}},
		["ScrollView_1"] 	= { alias = "scrollTest", className = "UI.Control.ScrollView",
								method = {type = "event", func = "onEvtScroll"} },

		-- className 将控件绑定到lua的特定对象上  支持控件对象的自定义扩展  可以很方便的扩展出自己特有的控件类型	
		["Text_Timer"] 	= { alias = "timTest", className = "UI.Control.Timer" },


		-- RelativeParent 支持控件的大小适配 (为了实现全屏窗口的控件自动适配窗口大小)
		-- 支持多个事件  一般一个就够了
		["ScrollView_1"] 	= { alias = "scrollMap", className = "UI.Control.ScrollView",
								attribute = { RelativeParent = {0,160}, },
								method = { { type = "event", func = "onEvtScroll"},
										   { type = "touch", func = "onTouchScroll"}} },

		-- 内部嵌套的子ccs对象
		["FileNode_1"] 	= { alias = "item1", className = "UITest.UITestTableViewIcon" },
	}
--]]

module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(loader)
	super.initialize(self)
	self.loader = loader
end

function class:loadLuaClass(proxy, layer)
	local binding = proxy.RES_BIND or {}
	for nodeName, nodeBinding in pairs(binding) do
		local node = layer
        local path = string.split(nodeName, '%.')
        for _, childName in ipairs(path) do
            node = node:getChildByName(childName)
            if nil == node then
                local tip = proxy.__NAME .. '(' .. nodeName .. ')'
                tip = tip .. ' do not have ' .. childName
                log4ui:warn(tip)
            end
        end

        if nodeBinding.className then
            self.loader:loadLuaClass(nodeBinding.className, node)    
        end

        local varname = nodeBinding.alias or nodeName
        proxy[varname] = node

		self:parseAttribute(proxy, node, nodeBinding.attribute)
        self:parseMethods(proxy, node, nodeBinding.method)
    end
end


function class:parseAttribute(proxy, node, attribute)
	if nil == attribute then
		return
	end

	local parent = node:getParent()
	local parentSize = parent:getContentSize()
	for k, v in pairs(attribute) do
		if k == "RelativeParent" then
			node:setContentSize(cc.size(parentSize.width - v[1], parentSize.height - v[2]))

		elseif k == "PercentParentFixH" then
			local nodeSize = node:getContentSize()
			local w = parentSize.width * v[1]
			local h = parentSize.height - v[2]
			node:setContentSize(cc.size(w, h))

		elseif k == "PercentParentFixW" then
			local nodeSize = node:getContentSize()
			local w = parentSize.width - v[1]
			local h = parentSize.height * v[2]
			node:setContentSize(cc.size(w, h))
		end
	end
end

function class:parseMethods(proxy, node, methods)
	if nil == methods then
		return
	end

	--单行
	if methods.type then
		self:parseMethod(proxy, node, methods)
		return
	end

	--数组
	for _, method in ipairs(methods) do
		self:parseMethod(proxy, node, method)
	end
end

function class:parseMethod(proxy, node, method)
	if nil == method then
		return
	end

	if not proxy[method.func] then
		log4ui:warn("do not find this method:" .. method.func)
		return
	end

	local widget = self.loader:castWidget(node)
	if nil == widget then
		return 
	end

	--常用eventtype
	--ccui.TouchEventType.ended
	--ccui.ScrollviewEventType.scrolling
	local cbk = bind(proxy[method.func], proxy)
    if method.type == "click" then
        widget:addClickEventListener(cbk)

    elseif method.type == "touch" then
        widget:addTouchEventListener(cbk)

    elseif method.type == "event" then
        widget:addCCSEventListener(cbk)
    end
end
