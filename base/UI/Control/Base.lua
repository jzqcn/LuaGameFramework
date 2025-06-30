--------------------------------------------------
-- cocos控件扩展  更灵活 支持不同项目需求
--
-- 2016.8.20
--------------------------------------------------

module(..., package.seeall)


prototype = Controller.prototype:subclass()

function prototype:initialize(...)
    super.initialize(self, ...)

    self.scheduleFunc = {}
    self.isStartSchedule = false

    self.bindCall = {}
end

function prototype:dispose()
    self.rootNode:unscheduleUpdate()
    super.dispose(self)
end

function prototype:startSchedule()
    self.isStartSchedule = true
	self.rootNode:scheduleUpdateWithPriorityLua(bind(self.scheduleFunction, self), 0)
end

function prototype:scheduleFunction(delta)
    for key, func in pairs(self.scheduleFunc) do
        func(delta)
    end
end

function prototype:registerScheduler(scheduleName, func)
    assert(self.scheduleFunc[scheduleName] == nil)
    self.scheduleFunc[scheduleName] = func

    if not self.isStartSchedule then
        self:startSchedule()
    end
end

function prototype:unregisterScheduler(scheduleName)
    self.scheduleFunc[scheduleName] = nil
    if table.size(self.scheduleFunc) == 0 then
        self.rootNode:unscheduleUpdate()
        self.isStartSchedule = false
    end
end

function prototype:isExistScheduler(scheduleName)
    return self.scheduleFunc[scheduleName] ~= nil
end

function prototype:bindCallback(name, func)
    self.bindCall[name] = func
end

function prototype:unbindCallback(name, func)
    self.bindCall[name] = nil
end

function prototype:execBindCall(name, ...)
    local func = self.bindCall[name]
    if func then
        func(...)
    else
        log4system:warn("not find bind callback:" .. name)
    end
end