module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:setIsSelected(false)
end

function prototype:refresh(data, index)
	self.clubData = data
	self.index = index
	self.txtClubName:setString(data.name)
	self.txtClubId:setString("ID:"..data.id)

	local members = data.members
	if #members > 0 then
		local index = 1
		while(index <= #members) do
			local memInfo = members[index]
			if memInfo.isOwner then
				if util:getPlatform() == "win32" then
					sdk.account:getHeadImage(memInfo.userId, memInfo.userName, self.headIcon)
				else
					-- sdk.account:getHeadImage(memInfo.userId, memInfo.userName, self.headIcon, memInfo.headImage)
					if self:existEvent('LOAD_HEAD_IMG') then
						self:cancelEvent('LOAD_HEAD_IMG')
					end
					sdk.account:loadHeadImage(memInfo.userId, memInfo.userName, memInfo.headImage, 
						self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.headIcon)
				end
				break
			end
			index = index + 1
		end
	end

	self:setIsSelected(false)
end

function prototype:onLoadHeadImage(filename)
	self.headIcon:loadTexture(filename)
end

function prototype:setIsSelected(var)
	self.imgNor:setVisible(not var)
	self.imgSel:setVisible(var)
end

function prototype:onImageSelClick()
	self:fireUIEvent("Club.SelectClub", self.clubData, self.index)
end