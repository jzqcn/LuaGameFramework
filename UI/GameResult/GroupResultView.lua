module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter(data)
	if not data then
		return
	end

	-- log(data)

	local strRoomInfo = string.format("房间:%04d 局数:%d %s %s", data.roomId, data.groupConfig, data.strCurrencyType, data.strPayType)
	self.txtRoomInfo:setString(strRoomInfo)
	-- self.txtGroup:setString(string.format("局数:%d", data.groupConfig))

	local time = math.floor(data.time / 1000)
	local time_t = util.time:getTimeDate(time)
	self.txtTime:setString(string.format("%d-%02d-%02d %02d:%02d", time_t.year, time_t.month, time_t.day, time_t.hour, time_t.min))

	local accountInfo = Model:get("Account"):getUserInfo()
	local sex = accountInfo.sex or 1 --性别,1-男、2-女
	if sex == 1 then
		--self.imgBoy:setVisible(true)
		--self.imgGirl:setVisible(false)
	else
		--self.imgGirl:setVisible(true)
		--self.imgBoy:setVisible(false)
	end
	--self.nodeRole:hideShadow()

	local currencyType = data.currencyType
	local memDatas = data.memberInfos
	for i, v in ipairs(memDatas) do
		v.currencyType = currencyType
	end

	local param = 
	{
		data = memDatas,
		ccsNameOrFunc = "GameResult/GroupResultViewItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}

    self.listview:createItems(param)
end

function prototype:onBtnCloseTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		-- self:close()
		StageMgr:chgStage("Hall")
	end
end

function prototype:onBtnShareTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local accountLogin=Model:get("Account"):isAccountLogin()
		if accountLogin then
			util:captureScreenToCamera()
		else
			util:captureScreen()
		end
	end
end
