module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter(data)
	self.data =data
	local agreeTab = data.agreeTab
	self.items = table.values(agreeTab)

	local param = 
	{
		data = self.items,
		ccsNameOrFunc = "Games/Common/DissolveRoomViewItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}

    self.listview:createItems(param)

    self.countDown = data.countDown

    self.time = 0
    if self.countDown > 0 then
	    self.rootNode:scheduleUpdateWithPriorityLua(bind(self.update, self), 0)
	else
		self.countDown = 0
	end

	self.clock:start(self.countDown, 0)
	local userId = Model:get("Account"):getUserId()
	for k, v in pairs(agreeTab) do
		if userId == k and v.isAgree == 1 then
			self.btnAgree:setVisible(false)
			self.btnRefuse:setVisible(false)
		end
	end

	local tb = {} 
	tb.style = {face = "resource/fonts/FZY4JW.TTF", size = 24, color = "#FFFF00"}
	tb.list = {
		{str = "玩家【"},
		{												-- 如果设置不同字体的，可嵌套
			style = {size = 24, color = "#FF0000"},
			list = {
				{str = data.requestPlayerName},
			}
		},
		{str = "】申请解散房间"},
	}

	local assistNode = Assist.RichText:createRichText(tb)
	assistNode:setWrapMode(RICHTEXT_WRAP_PER_CHAR)
	assistNode:ignoreContentAdaptWithSize(false)
	assistNode:setContentSize(cc.size(500, 40))
	self.imgPop:addChild(assistNode)

	assistNode:setPosition(cc.p(550, 315))
end

function prototype:refreshAgreeState(id, countDown)
	for i, v in ipairs(self.items) do
		if v.id == id then
			local item = self.listview:getSubItemByIdx(i)
			item:setState(true)
			break
		end
	end

	if countDown then
		self.countDown = countDown
	end
end

function prototype:onBtnAgreeClick()
	local modelName = self.data.modelName
	if modelName then
		Model:get(modelName):requestAgreeDissolve(true)
	end

	self.btnAgree:setVisible(false)
	self.btnRefuse:setVisible(false)

	local userId = Model:get("Account"):getUserId()
	self:refreshAgreeState(userId)
end

function prototype:onBtnRefuseClick()
	local modelName = self.data.modelName
	if modelName then
		Model:get(modelName):requestAgreeDissolve(false)
	end

	self:close()
end

function prototype:update(delta)
	self.time = self.time + delta
	if self.time >= 1 then
		self.time = 0
		self.countDown = self.countDown - 1
		self.clock:start(self.countDown, 0)
		if self.countDown <= 0 then
			-- self.rootNode:unscheduleUpdate()
			self:close()
		end
	end
end
