--------------------------------------------------
-- 时间相关
--------------------------------------------------

module(..., package.seeall)

local singleton
function getSingleton(_)
	assert(singleton ~= nil)
	return singleton
end


class = objectlua.Object:subclass()


function class:initialize()
	super.initialize(self)

	assert(nil == singleton)
	singleton = self

	self:setSystemTime(os.time() * 1000)
end

function class:dispose()
	super.dispose(self)
end

--毫秒
function class:setSystemTime(time)
	self.recServerTime = time
	self.recLocalTime = TimeGetTime()
end

-- 取服务器时间（秒数）
function class:getTime()
	local time = self:getMilliTime()
	return math.floor(time / 1000)
end

function class:getMilliTime()
	local time = self.recServerTime + (TimeGetTime() - self.recLocalTime)
	return time
end


-- 取时间time_t结构
-- then date returns a table with the following fields:
-- year (four digits), month (1–12), day (1–31), 
-- hour (0–23), min (0–59), sec (0–61), 
-- wday (weekday, Sunday is 1), yday (day of the year), 
-- and isdst (daylight saving flag, a boolean). 
-- This last field may be absent if the information is not available. 
function class:getTimeDate(time)
	time = time or self:getTime()
	return os.date('*t', time)
end

-- 取与time同一天的特定时刻  如果是当天time就不用传了
function class:getDayTime(hour, min, sec, time)
	local time_t = self:getTimeDate(time)

	time = os.time({ year 	= time_t.year, 
					 month 	= time_t.month, 
					 day 	= time_t.day,
					 hour 	= hour or 0,
					 min 	= min or 0, 
					 sec 	= sec or 0 })
	return time
end

--　%a 星期几的简写
--　%A 星期几的全称
--　%b 月份的简写
--　%B 月份的全称
--　%c 标准的日期的时间串
--　%C 年份的后两位数字
--　%d 十进制表示的每月的第几天
--　%D 月/天/年
--　%e 在两字符域中，十进制表示的每月的第几天
--　%F 年-月-日
--　%g 年份的后两位数字，使用基于周的年
--　%G 年份，使用基于周的年
--　%h 简写的月份名
--　%H 24小时制的小时
--　%I 12小时制的小时
--　%j 十进制表示的每年的第几天
--　%m 十进制表示的月份
--　%M 十时制表示的分钟数
--　%n 新行符
--　%p 本地的AM或PM的等价显示
--　%r 12小时的时间
--　%R 显示小时和分钟：hh:mm
--　%S 十进制的秒数
--　%t 水平制表符
--　%T 显示时分秒：hh:mm:ss
--　%u 每周的第几天，星期一为第一天 （值从0到6，星期一为0）
--　%U 第年的第几周，把星期日作为第一天（值从0到53）
--　%V 每年的第几周，使用基于周的年
--　%w 十进制表示的星期几（值从0到6，星期天为0）
--　%W 每年的第几周，把星期一做为第一天（值从0到53）
--　%x 标准的日期串
--　%X 标准的时间串
--　%y 不带世纪的十进制年份（值从0到99）
--　%Y 带世纪部分的十制年份
--　%z，%Z 时区名称，如果不能得到时区名称则返回空字符。
--　%% 百分号

-- 取服务器时间格式化字串,fmtStr未填，则取默认格式
function class:getTimeStr(fmtStr, time)
	fmtStr = fmtStr or '%c'
	time = time or self:getTime()	

	return os.date(fmtStr, time)
end

-- 比较两个时间点,t1未填的情况下默认取ServerTime
-- t2晚于t1时，返回大于0的数
function class:diffTime(t2, t1)
	t1 = t1 or self:getTime()	

	return os.difftime(t2, t1)
end


------------时区相关------------
-- 获取当前时区时间戳差值
function class:getTimeZone()
    local now = os.time()
    return now - os.time(os.date("!*t", now))
end


-- 根据世界时间获取时间戳  用dateZero的年月日 如果没传用当前世界时间
function class:getWorldTime(hour, min, sec, dateZero)
	dateZero = dateZero or self:getWorldDate()

	local date = {
				year 	= dateZero.year, 
				month 	= dateZero.month, 
				day 	= dateZero.day,
				hour 	= hour or 0,
				min 	= min or 0, 
				sec 	= sec or 0
				}

	local _, time = self:timeZoneWorldToCur(date)
    return time
end

-- 根据时间戳获取世界时间 默认当前时间
function class:getWorldDate(time)
	time = time or self:getTime()
	local date = os.date("*t", time)

    return self:timeZoneCurToWorld(date)
end

-- 当前时区时间转世界时间(0时区)
function class:timeZoneCurToWorld(date)
	assert(date)

	local time = os.time(date)
    local dateZero = os.date("!*t", time)

    return dateZero, time
end

-- 世界时间(0时区)转当前时区时间
function class:timeZoneWorldToCur(dateZero)
	assert(dateZero)

	local time = os.time(dateZero)
    time = time + self:getTimeZone()

    local date = os.date("*t", time)
    return date, time
end



-- 取当前服务器时间月份第一天为星期几
function class:getMonthFirstWDay()
	local time_t = self:getTimeDate()
	time_t.day = 1
	
	return self:getTimeDate(os.time(time_t)).wday
end

-- 取当前服务器时间月份总天数
function class:getMonthDayCount()
	local days = 
	{
		[1] = 31,	[2] = 28, 	[3] = 31, 	[4] = 30, 
		[5] = 31, 	[6] = 30, 	[7] = 31, 	[8] = 31, 
		[9] = 30, 	[10] = 31, 	[11] = 30, 	[12] = 31 
	}

	local time_t = self:getTimeDate()
	if time_t.year % 400 == 0 
		or (time_t.year % 4 == 0 and time_t.year % 100 ~= 0) then
		days[2] = 29
	end
	
	return days[time_t.month]
end

function class:getMonthDayCount2(year, month)
	local days = 
	{
		[1] = 31,	[2] = 28, 	[3] = 31, 	[4] = 30, 
		[5] = 31, 	[6] = 30, 	[7] = 31, 	[8] = 31, 
		[9] = 30, 	[10] = 31, 	[11] = 30, 	[12] = 31 
	}

	if year % 400 == 0 or (year % 4 == 0 and year % 100 ~= 0) then
		days[2] = 29
	end
	
	return days[month]
end

-- 秒转换成时间格式（天，时，分，秒）
function class:secToDay(time)
	if time == nil then return { day = 0, hour = 0, min = 0, sec = 0 } end

	local time_t = { day 	= math.modf(time / (24 * 60 * 60)), 
					 hour 	= math.modf(time % (24 * 60 * 60) / (60 * 60)), 
					 min 	= math.modf(time % (60 * 60) / 60), 
					 sec 	= time % 60 }
	return time_t
end

