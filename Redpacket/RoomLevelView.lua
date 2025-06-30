module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter(data)
	-- log(data)
	for i, v in ipairs(data) do
		if i > 4 then
			break
		end

		self["nodeItem_" .. i]:initWithInfo(math.ceil(i/2), v)
	end

	local num = #data
	if num < 4 then
		for i = num + 1, 4 do
			self["nodeItem_" .. i]:hide()
		end
	end
end

function prototype:onBtnCloseClick()
	self:close()
end



