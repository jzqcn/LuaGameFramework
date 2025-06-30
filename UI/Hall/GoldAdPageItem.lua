module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_USER_CUSTOM_SERVICE_NUMBERS", "onPushCustomServiceNumbers")
	self.btnCopy:addTouchEventListener(bind(self.onCopyWeiXinClick,self))  --多个按钮时根据 data再refresh写多个
	local action1=cc.Sequence:create(cc.CallFunc:create(function(sender) sender:setVisible(true) end),cc.DelayTime:create(1),cc.CallFunc:create(function(sender) sender:setVisible(false) end),cc.DelayTime:create(1))
	local action2=cc.Sequence:create(cc.CallFunc:create(function(sender) sender:setVisible(false) end),cc.DelayTime:create(1),cc.CallFunc:create(function(sender) sender:setVisible(true) end),cc.DelayTime:create(1))
	self.imgFlash_1:runAction(cc.RepeatForever:create(action1))
	self.imgFlash_2:runAction(cc.RepeatForever:create(action2))
end

function prototype:refresh(data)
	self.data=data
	local sceneImage = string.format("resource/csbimages/Hall/adPage/ad_page_%d.png",data[1][1])
	self.imgBg:loadTexture(sceneImage)
	if data[1][2]~=nil then
		self.txtWeiXin:setString(data[1][2])
	end
end
function prototype:onCopyWeiXinClick(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtWeiXin:getString())
	end
end

function prototype:getData()
	return self.data
end


function prototype:onPushCustomServiceNumbers(datas)
	if datas == nil or #datas == 0 then
		return
	end
	local pageIndex=self.data[1][1]
	local data
	if datas[pageIndex]~=nil then
		data = {{pageIndex,datas[pageIndex]}}
	else
		data = {{pageIndex,datas[1]}}
	end
	self:refresh(data)
end


