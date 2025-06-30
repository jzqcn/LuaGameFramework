module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:refresh(data, index)
	for i, v in ipairs(data) do
		self["nodeHead_" .. i]:setItemInfo(v)
	end
end

function prototype:setSelectedIndex(index)
	local name = ""
	for i = 1, 6 do
		name = "nodeHead_" .. i
		if self[name]:getImageIndex() == index then
			self[name]:setSelected(true)
		else
			self[name]:setSelected(false)
		end
	end
end

