local Chat = require "Model.Chat"

module (..., package.seeall)

prototype = Dialog.prototype:subclass()

-- local actions = {
-- 	{name = "action_tomato", frames = 14, isRotate = true},
-- 	{name = "action_flower", frames = 23, isRotate = false},
-- 	{name = "action_chicken", frames = 17, isRotate = false},
-- 	{name = "action_foot", frames = 10, isRotate = true},
-- 	{name = "action_bomb", frames = 20, isRotate = true},
-- }

local getPlayerAddress = getPlayerAddress

-- function prototype:addBgMask()

-- end

function prototype:hasBgMask()
	return false
end

function prototype:enter(data)
	self:bindUIEvent("Game.SelectActionId", "uiEvtSelectActionId")

	self.info = data.info
	self.txtName:setString(self.info.playerName)
	
	local currencyType = data.currencyType
	-- local x, y = self.numCoin:getPosition()
	-- if currencyType == Common_pb.Score then
	-- 	self.imgCoinIcon:setVisible(false)
	-- 	self.numCoin:setPosition(cc.p(x-30, y))
	-- else
	-- 	self.imgCoinIcon:setVisible(true)		
	-- 	self.numCoin:setPosition(cc.p(x, y))
	-- end

	if currencyType == Common_pb.Score then
		self.numCoin:setString(self.info.coin)
		self.imgCoinIcon:loadTexture("resource/csbimages/User/scoreIcon.png")
	else
		self.numCoin:setString(Assist.NumberFormat:amount2Hundred(self.info.coin))
		self.imgCoinIcon:loadTexture("resource/csbimages/Common/goldIcon.png")
	end

	sdk.account:getHeadImage(self.info.playerId, self.info.playerName, self.imgHead, self.info.headimage)

	if self.info.sex == 1 then
		self.imgSex:loadTexture("resource/csbimages/Common/sex_boy.png")
	else
		self.imgSex:loadTexture("resource/csbimages/Common/sex_girl.png")
	end

	self.txtPos:setString("")
	-- self.imgIp:setVisible(false)
	-- self.txtIp:setVisible(false)

	if Model:get("Account"):getUserId() ~= self.info.playerId then
		local actions = Chat.ACTION_INFO
		local param = 
		{
			data = actions,
			ccsNameOrFunc = "Games/Common/PlayerInfoViewItem",
			dataCheckFunc = function (info, elem) return info == elem end
		}

	    self.actionList:createItems(param)

	    local posInfo = self.info.positionInfo

	    local function updateAddress(str)
			self.txtPos:setString(str)
		end
		getPlayerAddress(posInfo.longitude, posInfo.latitude, updateAddress)
	    -- Model:get("Position"):setPlayerAddress(self.info.playerId, self.txtPos)
	else
		local posInfo = Model:get("Position"):getUserPosition()
		self.txtPos:setString(posInfo.address)
	end
	-- self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))

	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
end

function prototype:onBtnCloseClick()
	self:close()
end

function prototype:uiEvtSelectActionId(data)
	Model:get("Chat"):requestActionMsg(data.name, self.info.playerId)

	self:close()
end