module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()

end

function prototype:refresh(data, index)
	for i, v in ipairs(data) do
		self["nodeItem_" .. i]:setRoleInfo(v)		
	end

	if #data < 2 then
		self.nodeItem_2:setVisible(false)
	end
end
