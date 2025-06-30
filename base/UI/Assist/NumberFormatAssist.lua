module("Assist.NumberFormat", package.seeall)

--11111 ==> 11.1K
-- ps. string.format('%.2f', 1.9999999999) 结果会为2.00 而不是1.99
function amount2KMGTP(_, amount)
    amount = tonumber(amount)
    if amount == nil then
        return "0"
    end

    local getNumberText = function (num, exp)
        local str = tostring(num / math.pow(10, exp))
        local numText = str:match('(%d-%.%d)')
        return numText or str
    end

    local amountStr = ''
    if amount >= math.pow(10, 15) then
        amountStr = ('%sP'):format(getNumberText(amount, 15))
    elseif amount >= math.pow(10, 12) then
        amountStr = ('%sT'):format(getNumberText(amount, 12))
    elseif amount >= math.pow(10, 9) then
        amountStr = ('%sG'):format(getNumberText(amount, 9))
    elseif amount >= math.pow(10, 6) then
        amountStr = ('%sM'):format(getNumberText(amount, 6))
    elseif amount >= math.pow(10, 3) then
        amountStr = ('%sK'):format(getNumberText(amount, 3))
    else
        amountStr = tostring(amount)
    end

    return amountStr
end

function amount2TrillionText(_, amount)
    amount = tonumber(amount)
    if amount == nil then
        return "0"
    end

    amount = amount / 100
    local amountStr = string.format('%.2f', amount)

    return amountStr

    --[[local getNumberText = function (num, exp)
        local str = tostring(num / math.pow(10, exp))
        local numText = str:match('(%d-%.%d%d)')
        return numText or str
    end

    -- local amountStr = ''
    -- if amount >= math.pow(10, 9) then
    --     amountStr = ("%s亿"):format(getNumberText(amount, 9))
    -- elseif amount >= math.pow(10, 4) then
    --     amountStr = ("%s万"):format(getNumberText(amount, 4))
    -- else
    --     amountStr = tostring(amount)
    -- end

    local amountStr = ("%s"):format(getNumberText(amount, 2))
    
    return amountStr--]]
end

function amount2Hundred(_, amount)
    amount = tonumber(amount)
    if amount == nil then
        return "0"
    end

    amount = amount / 100
    local amountStr = tostring(amount) --string.format('%.2f', amount)

    return amountStr
end

--1325232 ===> 1,325,232
function number2ComFormat(_, number)
    local tab = {}

    local numberStr = tostring(number)
    while #numberStr > 3 do
        local subStr = numberStr:sub(-3)
        table.insert(tab, 1, subStr)
        numberStr = numberStr:sub(1, -4)
    end

    table.insert(tab, 1, numberStr)

    return table.concat(tab, ',')
end

--时间戳 转字符串 47:20:31 或 1d 23:20:31
--noDay为true ==> 47:20:31  false ==> 1d 23:20:31
function time2TextFormat(_, diffTime, noDay)
    local leftTime = util.time:secToDay(math.floor(diffTime / 1000))

    leftTime.min = leftTime.sec > 59 and leftTime.min + 1 or leftTime.min
    leftTime.sec = leftTime.sec > 59 and 0 or leftTime.sec

    if leftTime.day > 0 then
        if noDay ~= true then
            return ('%dd %02d:%02d:%02d'):format(
                        leftTime.day,
                        leftTime.hour,
                        leftTime.min,
                        leftTime.sec)
        end

        leftTime.hour = leftTime.day * 24 + leftTime.hour
    end

    return ('%02d:%02d:%02d'):format(
                    leftTime.hour,
                    leftTime.min,
                    leftTime.sec)
end

--commonIcon 专用的
function amountTo2Float(_, amount)
    amount = tonumber(amount)
    if amount == nil then
        return "0"
    end
    local amountStr = ''
    if amount >= math.pow(10, 15) then
        local pow = amount/math.pow(10, 15)

        if pow == math.ceil(pow) then
            amountStr = ('%sP'):format(string.format('%.1f', pow))
        else
            amountStr = ('%sP'):format(string.format(pow))
        end
    elseif amount >= math.pow(10, 12) then
        local pow = amount/math.pow(10, 12)
        if pow == math.ceil(pow) then
            amountStr = ('%sT'):format(string.format('%.1f', pow))
        else
            amountStr = ('%sT'):format(string.format(pow))
        end
    elseif amount >= math.pow(10, 9) then
        local pow = amount/math.pow(10, 9)
        if pow == math.ceil(pow) then
            amountStr = ('%sG'):format(string.format('%.1f', pow))
        else
            amountStr = ('%sG'):format(string.format(pow))
        end
    elseif amount >= math.pow(10, 6) then
        local pow = amount/math.pow(10, 6)
        if pow == math.ceil(pow) then
            amountStr = ('%sM'):format(string.format('%.1f', pow))
        else
            amountStr = ('%sM'):format(string.format(pow))
        end
    elseif amount >= math.pow(10, 3) then
        local pow = amount/math.pow(10, 3)
        if pow == math.ceil(pow) then
            amountStr = ('%sK'):format(string.format('%.1f', pow))
        else
            amountStr = ('%sK'):format(string.format(pow))
        end
    else
        amountStr = tostring(amount)
    end
    return amountStr
end

--小数转 xx.x%
-- 参数1传入小数，参数2 小数点后保留的位数
-- ps. string.format('%.2f', 1.9999999999) 结果会为2.00 而不是1.99
function dig2Percent(_, number, bits)
    bits = bits or 1

    if bits == 0 then
        return math.floor(number) .. '%'
    end
    local numberText = tostring(number * 100)
    local idx = numberText:find('%.')
    if idx == nil then
        return numberText .. '%'
    end

    return numberText:sub(1, idx+bits) .. '%'
end
