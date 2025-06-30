module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.size = self.rootNode:getContentSize()
end

function prototype:refresh(data)
	self.data = data
	self.txtName:setString(Assist.String:getLimitStrByLen(data.userName, 8))
	self.txtId:setString(data.userId)

	if data.isOwner or data.isManager then
		self.imgManager:setVisible(true)
	else
		self.imgManager:setVisible(false)
	end


	-- sdk.account:getHeadImage(data.userId, data.userName, self.headIcon, data.headImage)
	if self:existEvent('LOAD_HEAD_IMG') then
		self:cancelEvent('LOAD_HEAD_IMG')
	end
	sdk.account:loadHeadImage(data.userId, data.userName, data.headImage, 
		self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.headIcon)
end

function prototype:onLoadHeadImage(filename)
	self.headIcon:loadTexture(filename)
end

function prototype:onBtnImageClick()
	local clubData = Model:get("Club"):getClubData(self.data.clubId)
	if not self.data.isOwner then
		if clubData.isOwner or (clubData.isManager and not self.data.isManager) then
			--俱乐部主或者管理员才弹出菜单
			local x, y = self.rootNode:getPosition()
			local pos = self.rootNode:getWorldPosition()

			local eglView = cc.Director:getInstance():getOpenGLView()
			local frameSize = eglView:getFrameSize()
			local screenScale = frameSize.width / frameSize.height
			local defaultScale = 1334 / 750

			if x > 500 and screenScale <= defaultScale then
				pos.x = pos.x + self.size.width/2+50
			else
				pos.x = pos.x + self.size.width
			end
			pos.y = pos.y * screenScale/defaultScale
			-- pos = cc.pMul(pos, screenScale/defaultScale)

			local layer = ui.mgr:open("Club/MemberInfoPopItemView", {data = self.data, isOwner = clubData.isOwner, isManager = clubData.isManager})
			if layer then
				layer:setMenuPos(pos)
			end
		end
	end
end
