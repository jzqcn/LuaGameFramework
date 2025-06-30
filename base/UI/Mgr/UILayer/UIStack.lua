
--ui栈

local UIStack = {data = {}}
function UIStack:new(checkFunc)
	local t = {data={}, checkFunc = checkFunc}
	setmetatable(t, self)
	self.__index = self
	return t
end

function UIStack:add(value)
	table.insert(self.data, value)
end

function UIStack:get(key)
	for i = #self.data, 1, -1 do
		local elem = self.data[i]
		if self.checkFunc(key, elem) then
			return elem, i
		end
	end
	return nil, nil
end

function UIStack:getByIdx(idx)
	return self.data[idx]
end

function UIStack:size()
	return #self.data
end

function UIStack:empty()
	return 0 == self:size()
end

function UIStack:top()
	return self.data[#self.data]
end

function UIStack:moveToTop(key)
	local info, i = self:get(key)
	if nil == info then
		return false
	end

	table.remove(self.data, i)
	table.insert(self.data, info)
	return true
end

function UIStack:foreach(call)
	for elem in list.elems(self.data) do
		call(elem)
	end
end

function UIStack:del(key)
	local info, i = self:get(key)
	if nil == info then
		return false, nil
	end

	table.remove(self.data, i)
	return true, i
end

function UIStack:clear()
	self.data = {}
end

function UIStack:dump()
	log4temp:debug("------dump uistack-------")
	for _, v in ipairs(self.data) do
		log4temp:debug(tostring(v))
	end
end

return UIStack
