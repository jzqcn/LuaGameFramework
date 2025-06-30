

function getCodePointByteAmount(byte)
	assert(0 <= byte and byte < 253)
	
	if byte < 192 then
		return 1
	end
	
	if byte < 224 then
		return 2
	end
	
	if byte < 240 then
		return 3
	end
	
	if byte < 248 then
		return 4
	end
	
	if byte < 252 then
		return 5
	end
	
	return 6
end

function getCodePointAmount(s)
	local amount = 0
	
	local i = 1
	while i <= #s do
		amount = amount + 1
		i = i + getCodePointByteAmount(string.byte(s, i))
	end
	
	return amount
end

function getStrShowWidth(s)
	local amount = 0
	
	local i = 1
	local byteAmount = 1
	while i <= #s do
		byteAmount = getCodePointByteAmount(string.byte(s, i))
		amount = amount + (byteAmount > 1 and 2 or 1)
		i = i + byteAmount
	end
	
	return amount
end

function getSubString(s, begPos, endPos)
	begPos = begPos or 1
	endPos = endPos or getCodePointAmount(s)
	
	local i = 1
	local from = 1
	local amount = 0
	while i <= #s do
		amount = amount + 1
		if amount == begPos then
			from = i
		end

		i = i + getCodePointByteAmount(string.byte(s, i))
		if amount >= endPos then
			return string.sub(s, from, i-1)
		end
	end

	return string.sub(s, from, #s)
end

function getSubANSIString(s)
	if nil == s then return end

	return string.gsub(s, ".", function(c)
		if string.byte(c) < 0 or string.byte(c) > 127 then return "" end
		return c
	end)
end

--替换字符串中的制表符
function ReplaceStringTab(str)
	str = string.gsub(str, "\\n", "\n")
	str = string.gsub(str, "\\t", "\t")
	return str
end

function addStringAsNumber(l, r)
	local lValue, rValue = string.reverse(l), string.reverse(r)
	local lLen, rLen = string.len(lValue), string.len(rValue)

	local ret = ''
	local carry = 0
	for i = 1, (lLen > rLen and lLen or rLen) do
		local lNumber = tonumber(string.sub(lValue, i, i)) or 0
		local rNumber = tonumber(string.sub(rValue, i, i)) or 0
		local sum = lNumber + rNumber + carry
		carry = math.floor(sum / 10) 
		ret = (sum % 10) .. ret
	end
	
	ret = (carry == 0 and '' or carry) .. ret
	return ret
end

function subStringAsNumber(l, r)
	local lValue, rValue = string.reverse(l), string.reverse(r)
	local lLen, rLen = string.len(lValue), string.len(rValue)

	local negative = (lLen == rLen) and (l < r) or (lLen < rLen)
	if negative then
		lLen, rLen = rLen, lLen
		lValue, rValue = rValue, lValue
	end

	local ret = ''
	local carry = 0
	for i = 1, lLen do
		local lNumber = tonumber(string.sub(lValue, i, i)) or 0
		local rNumber = tonumber(string.sub(rValue, i, i)) or 0
		local sum = lNumber - rNumber + carry
		carry = math.floor(sum / 10)
		ret = (sum % 10) .. ret
	end

	ret = string.ltrim(ret, '0+')
	return (negative and '-' or '') .. ret
end

function multiplyStringAsNumber(l, r)
	local lValue, rValue = string.reverse(l), string.reverse(r)
	local lLen, rLen = string.len(lValue), string.len(rValue)

	local ret = ''
	for i = 1, lLen do 
		local retTemp = ''
		local carry = 0
		local lNumber = tonumber(string.sub(lValue, i, i)) or 0
		for j = 1, rLen do 
			local rNumber = tonumber(string.sub(rValue, j, j)) or 0
			local sum = lNumber * rNumber + carry
			carry = math.floor(sum / 10) 
			retTemp = (sum % 10) .. retTemp
		end

		retTemp = (carry == 0 and '' or carry) .. retTemp 
		retTemp = retTemp .. table.concat(list.rep({0}, i-1))
		ret = addStringAsNumber(ret, retTemp)
	end

	return ret
end

