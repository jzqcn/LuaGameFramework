module(..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:setRoomInfo(info)
	if not info then
		log4ui:error("[RoomInfo::setRoomInfo] room info is nil !!!")
		return
	end

	local strInfo = table.concat(info, " ")
	self.txtInfo:setString(strInfo)

	local size = self.txtInfo:getContentSize()
	self.imgBg:setContentSize(cc.size(size.width+40, 35))

	-- local x, y = self.txtInfo_1:getPosition()

	-- for i, v in ipairs(info) do
	-- 	local name = "txtInfo_"..i
	-- 	if self[name] then
	-- 		self[name]:setString(v)
	-- 	else
	-- 		self[name] = self.txtInfo_1:clone()
	-- 		self[name]:setString(v)
	-- 		self[name]:setPosition(cc.p(x, y - (i-1)*40))

	-- 		self["imgLine_"..i] = self.imgLine_1:clone()			
	-- 		self["imgLine_"..i]:setPosition(cc.p(x, y-20 - (i-1)*40))
	-- 		self.rootNode:addChild(self[name])
	-- 		self.rootNode:addChild(self["imgLine_"..i])
	-- 	end
	-- end

	-- self.imgBg:setContentSize(cc.size(200, #info*45))
end