local Base = require "UI.Control.Base"

module(..., package.seeall)



prototype = Base.prototype:subclass()


function prototype:enter()
    self.formatStr = "%s"
    self.endTime = 0
    self.cbTime = {}
end

--------------label显示相关-----------------
-- 本生就是Label控件 可以直接调用api函数
-- 如：
-- self.timTest:enableOutline(cc.c4b(1, 100, 1, 255), 2)
-- self.timTest:enableShadow()
--
function prototype:setStringEx(str)
    self.rootNode:setString(string.format(self.formatStr, str))
end

function prototype:setFormatString(formatStr)
    assert(formatStr ~= nil)
    self.formatStr = formatStr
end
--
------------------------------------------



--------------时间设置和回调相关-----------------
--
--单位：秒
function prototype:setEndTime(time, callback)
    if not self:isExistScheduler("tick") then
        self:registerScheduler("tick", bind(self.tick, self))
    end

    self.endTime = time 
    self.callback = callback
end

function prototype:addCallbackTime(time, name)
    name = name or tostring(time)
    self.cbTime[name] = {time=time}
end

function prototype:removeCallbackTime(name)
    self.cbTime[name] = nil
end


function prototype:tick()
    local curTime = util.time:getMilliTime() / 1000
    if curTime >= self.endTime then
        if self.callback then
            self.callback("end")
        end
        self:stop()
        return
    end

    for name, info in pairs(self.cbTime) do
        if curTime > info.time then
            self.cbTime[name] = nil
            self.callback("internal", name)
            break
        end
    end

    local str = Assist.NumberFormat:time2TextFormat((self.endTime - curTime) * 1000)
    self:setStringEx(str)
end

function prototype:stop()
    self:unregisterScheduler("tick")
    self:setStringEx("")
    self.cbTime = {}
    self.endTime = 0
end
--
------------------------------------------

