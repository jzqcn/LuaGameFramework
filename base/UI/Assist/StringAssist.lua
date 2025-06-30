--@todo
-- do return end


module("Assist.String", package.seeall)
-- Assist.String = _M

-----------------private--------------------
local function getEndPos(str, maxAmount)
    local amount = 0
    
    local i = 1
    while i <= #str do
        local byteAmount = getCodePointByteAmount(string.byte(str, i))
        i = i + byteAmount
        amount = amount + (byteAmount > 1 and 2 or 1)
        if amount >= maxAmount then
            return i - 1
        end
    end
    
    return #str
end

local function setString(str, fmTb, args)
    for k, s in ipairs(fmTb) do
        local i = string.find(s, "%%")
        local num = tonumber(string.sub(s, 0, i-1))
        local fm = string.sub(s, i, string.len(s))
        local fmStr = string.format(fm, args[num])
        local replaceStr = "#"..num.."%"..fm.."#END" 
        str = string.gsub(str, replaceStr, fmStr)
    end

    return str
end

-----------------private--------------------


--字符串格式化
--str, 原始字符串，格式 "this is a #1%s#END ,trans to #2%d#END string"
--     格式化的格式为 "#" + 数字key + 格式化格式 + "#END"
--args，格式化参数，为table数组格式，key 和str格式中的数字key相同
--使用方法 StringAssist:format("this is a #1%s#END ,trans to #2%d#END string",{"bird", "big bird"}})
-- local setString
function formatString(_, str, ...)
    local args = {...}
    if str == nil then
        log4misc:warn("str is nil")
        return ""
    end 
    
    if type(str) ~= "string" then
        log4misc:warn("str type is not string!")
        return ""
    end 
    
    if args == nil or type(args) ~= "table" or table.empty(args) then
        return string.format(string.gsub(str, "#%d*(.-)#END", "%1"), ...)
    end
    
    local fmTb = {}
    for fm in string.gmatch(str, "#(%d-%%.-)#END") do
        table.insert(fmTb, fm)
    end
    
    if table.empty(fmTb) then 
        return string.format(str, ...)
    end

    if #fmTb ~= #args then 
        log4misc:warn(" string format is error! ")
        return string.format(str, ...)
    end
    
    return  setString(str, fmTb, args)
end


--字符串截取,取字符串前N个字符,超过的用"..."代替
--支持utf8的文字长度截取
--str 原字符串  
--len 指定的获取字符串的长度
--replaceStr 超过长度的替换串，默认取"..."
--getSubStr
-- local getEndPos
function getLimitStrByLen(_, str, Len, replaceStr)
    local maxLen = Len or 12
    replaceStr = replaceStr or "..."
    if getStrShowWidth(str) > maxLen then
        local getEndPos = getEndPos(str, maxLen)
        str = string.sub(str, 1, getEndPos) .. replaceStr
    end

    return str
end



