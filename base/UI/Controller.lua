
module (..., package.seeall)


prototype = objectlua.Object:subclass()

--只有监听功能 不能发送事件
prototype:include(Events.ReceiveClass)

function prototype:initialize(name, layer)
	super.initialize(self)
	Events.ReceiveClass.initialize(self)

	self.rootNode = layer
	self.__NAME = name

	self.enableTouchScale = true

	--RES_BIND 手动绑定控件名称 事件 扩展功能(继承类型、屏幕设配等)
	--具体格式查看 Loader.Manual.lua
	--注：现在已经支持ccs里配置 完成自动绑定了 如无特殊情况 基本不需要手动来绑定
	--	  详情查看 Loader.Auto.lua
	self.RES_BIND = self.RES_BIND or {}
	self:initResBind(self.RES_BIND)
end

function prototype:dispose()
	-- log4ui:i("=UI:Controller:dispose:" .. self.__NAME)
	Events.ReceiveClass.dispose(self)
	super.dispose(self)

	if self._actionTime ~= nil then
		self._actionTime:release()
	end
end

function prototype:initResBind(resBind)
end

function prototype:isFullWinodwMode()
	return false
end

function prototype:addToParent(parentNode, zOrder)
	log4ui:i("[=UI:Controller:addToParent") 
	parentNode:addChild(self.rootNode, zOrder)
	Assist:centerNode(self.rootNode, parentNode)
end

function prototype:removeSelf(cleanup)
	log4ui:i("[=UI:Controller:removeSelf") 
	self.rootNode:removeFromParent(cleanup)
end

function prototype:enter( ... )
	log4ui:i("=UI:Controller:enter:" .. self.__NAME)
end

function prototype:exit()
	log4ui:i("=UI:Controller:exit:" .. self.__NAME)
end

function prototype:exitTransitionStart()
end

function prototype:enterTransitionFinish()
end

function prototype:cleanup()
	log4ui:i("=UI:Controller:cleanup:" .. self.__NAME)
	self:dispose()
end

function prototype:getLoader()
	return UI.Loader:getSingleton()
end

function prototype:getRootNode()
	return self.rootNode
end

function prototype:getName()
	return self.__NAME
end

function prototype:isWindow()
	return false
end


function prototype:bindModelEvent(text, uiEventName)
	local name, enum, evtName = string.match(text, "^(.-)%.(.-)%.(.-)$") 
	assert(name and enum and evtName)	

	local obj, chunk = Model:get(name)
	local eventId = chunk[enum][evtName]
	-- log4ui:warn("Controller::bindModelEvent --> name:"..name..", enum:"..enum..", evtName:"..evtName..", eventId:"..eventId)
	obj:bindEvent(eventId, self:createEvent(uiEventName))
end


--from (true)
--from loop
--from to loop
--from to curframe loop
function prototype:playActionTime(...)
	if nil == self._actionTime then
		log4ui:w("Controller :: play action time error! _actionTime is nil !")
		return
	end

	if not self._addedActionTime then
		self._addedActionTime = true
		self.rootNode:runAction(self._actionTime)
	end

	local arg = {...}
	if type(arg[1]) == "number" then
		self._actionTime:gotoFrameAndPlay(...)
	elseif type(arg[1]) == "string" then
		self._actionTime:play(...)
	else
		assert(false)
	end
end

function prototype:pauseActionTime()
	if nil == self._actionTime then
		return
	end

	self._actionTime:pause()
end

function prototype:resumeActionTime()
	if nil == self._actionTime then
		return
	end

	self._actionTime:resume()
end

function prototype:setFrameEventCallFunc(callback)
	if nil == self._actionTime then
		return
	end
	self._actionTime:setFrameEventCallFunc(callback)
end

function prototype:setLastFrameCallFunc(callback)
	if nil == self._actionTime then
		return
	end
	self._actionTime:setLastFrameCallFunc(callback)
end


--从子面板到父窗口结束 不会跨窗口乱发
function prototype:fireUIEvent(name, ...)
	local isWindow = function ()
		if nil == self.isWindow then
			return false
		end
		return self:isWindow()
	end

	local cbFunc
	local parentLayer = self.rootNode:getParent()
	while nil ~= parentLayer do
		local parentProxy = tolua.getpeer(parentLayer)
		if parentProxy and parentProxy.getUIEvent then
			cbFunc = parentProxy:getUIEvent(name)
			if cbFunc or isWindow(parentProxy) then
				break
			end
		end

		parentLayer = parentLayer:getParent()
	end

	if cbFunc then
		cbFunc(...)
	else
		log4ui:w("[=fireUIEvent event not found:" .. name)
	end
end

function prototype:setEnableTouchScale(var)
	self.enableTouchScale = var
end

function prototype:onLocateTouchCallback(name, ...)
	if self[name] then
		--点击缩放效果
		if self.enableTouchScale == true then
			local arg = {...}
			local widget = arg[1]
			local eventType = arg[2]
			if widget then
				if eventType == ccui.TouchEventType.began then
					-- widget:setScale(1.1)
					local size = widget:getContentSize()
					if size.width > 250 or size.height > 250 then						
						widget:runAction(cc.ScaleTo:create(0.2, 1.05))
					else
						widget:runAction(cc.ScaleTo:create(0.2, 1.1))
					end
					
					sys.sound:playEffect("CLICK")
				elseif eventType == ccui.TouchEventType.moved then
					
				else
					-- widget:setScale(1.0)
					widget:runAction(cc.ScaleTo:create(0.2, 1.0))
				end
		    end
		end

		self[name](self, ...)
	end
end

function prototype:onLocateCallback(name, ...)
	if self[name] then
		self[name](self, ...)

		-- local arg = {...}
		-- local widget = arg[1]
		-- if widget then
		-- 	local types = self.getLoader():getType(widget)
	 --    	if types == "ui::Button" then
	 --    		widget:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.1, 1.0)))
	 --    	end
	 --    end
	end
end

--show
function prototype:createJumpOutBezierConfig(widget, callback, duration, delay)
	local bc = {}
	bc.startPoint = 0.5
	bc.endPoint = 1.0
	bc.ctrlPoint_1 = 0.9
	bc.ctrlPoint_2 = 0.8
	duration = duration or 0.2
	delay = delay or 0

	local action = require ("UI.Mgr.BezierScale").class:new(widget, bc, duration, delay, callback)
	action:restart()
	widget:scheduleUpdateWithPriorityLua(bind(action.update, action), 0)

	return action
end

--hide
function prototype:createJumpInBezierConfig(widget, callback, duration, delay)
	local bc = {}
	bc.startPoint = 1.0
	bc.endPoint = 0.5
	bc.ctrlPoint_1 = 0.9
	bc.ctrlPoint_2 = 0.8
	duration = duration or 0.2
	delay = delay or 0

	local action = require ("UI.Mgr.BezierScale").class:new(widget, bc, duration, delay, callback)
	action:restart()
	widget:scheduleUpdateWithPriorityLua(bind(action.update, action), 0)

	return action
end

function prototype:createListItemBezierConfig(widget, callback, duration, delay)
	local bc = {}
	bc.startPoint = 0.6
	bc.endPoint = 1.0
	bc.ctrlPoint_1 = 1.1
	bc.ctrlPoint_2 = 1.2
	duration = duration or 0.2
	delay = delay or 0

	local action = require ("UI.Mgr.BezierScale").class:new(widget, bc, duration, delay, callback)
	action:restart()
	widget:scheduleUpdateWithPriorityLua(bind(action.update, action), 0)

	return action
end

function prototype:createOpacityBezierAction(widget, callback, duration, delay)
	local bc = {}
	bc.startPoint = 0.2
	bc.endPoint = 1.0
	bc.ctrlPoint_1 = 1.1
	bc.ctrlPoint_2 = 1.2
	duration = duration or 0.2
	delay = delay or 0

	local action = require ("UI.Mgr.BezierOpacity").class:new(widget, bc, duration, delay, callback)
	action:restart()
	widget:scheduleUpdateWithPriorityLua(bind(action.update, action), 0)

	return action
end
