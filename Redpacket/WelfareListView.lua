module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local eglView		= cc.Director:getInstance():getOpenGLView()
local frameSize		= eglView:getFrameSize()
local scaleX = frameSize.width / 1334
local scaleY = frameSize.height / 750

function prototype:hasBgMask()
    return false
end

function prototype:enter()
	-- self:bindModelEvent("Games/Redpacket.EVT.PUSH_BONUS", "onPushBonus")
	self:bindModelEvent("Games/Redpacket.EVT.PUSH_BONUS_TAKE", "onPushBonusTake")

	self:bindUIEvent("Redpacket.WelfareClick", "uiEvtWelfareClick")

	local listData = Model:get("Games/Redpacket"):getWelfareList()
	-- log(listData)

	local param = 
	{
		data = listData,
		ccsNameOrFunc = "Redpacket/WelfareListItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.listview:createItems(param)

	local x, y = self.imgPop:getPosition()
	local size = self.imgPop:getContentSize()
	self.pos = cc.p(x, y)
	self.size = size

	self.imgPop:setPosition(x+size.width, y)

	self.imgBg:setEnabled(false)
	self.imgPop:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(-size.width, 0)), cc.CallFunc:create(function()
		self.imgBg:setEnabled(true)
	end)))
end

function prototype:exit()
	local itemAnimation = self.snatchAnimation
	if itemAnimation then
		itemAnimation:removeFromParent()
		itemAnimation:dispose()
	end
end

function prototype:uiEvtWelfareClick(data, index, widget)
	-- if self.isPlayingAnim then
	-- 	return
	-- end

	-- log(data)
	-- log(index)

	self.target = widget
	self.welfareValue = tonumber(data)
	Model:get("Games/Redpacket"):requestBonusTake(index)

	self.listview:setEnabled(false)
end

function prototype:onPushBonusTake(isSuccess)
	if not isSuccess then
		
	else
		local widget = self.target
		self:playSnatchAnimation(widget)

		local label
		local resultCoin = self.welfareValue
		if resultCoin >= 0 then
			label = cc.Label:createWithBMFont("resource/Redpacket/bmFonts/font_win.fnt", "+" .. Assist.NumberFormat:amount2TrillionText(resultCoin))
		else
			label = cc.Label:createWithBMFont("resource/Redpacket/bmFonts/font_lose.fnt", Assist.NumberFormat:amount2TrillionText(resultCoin))
		end

		-- local scaleX = frameSize.width / 1334
		-- local scaleY = frameSize.height / 750
		local x, y = self.imgPop:getPosition()
		local pos = widget:getWorldPosition()
		local size = widget:getContentSize()
		label:setPosition(x, pos.y - 60)

		self.rootNode:addChild(label, 3, 100)

		label:runAction(cc.Sequence:create(
			cc.MoveBy:create(0.5, cc.p(0, 60)), 
			cc.DelayTime:create(1.0), 
			cc.FadeOut:create(0.5), 
			cc.CallFunc:create(function(sender)
				sender:removeFromParent()
			end)))


		local bonusList = Model:get("Games/Redpacket"):getWelfareList()
		self.listview:refreshListView(bonusList)
	end

	self.listview:setEnabled(true)
end

--播放抢红包特效
function prototype:playSnatchAnimation(widget)
	local armatureDisplay = self.snatchAnimation
	if armatureDisplay == nil then
		local factory = dragonBones.CCFactory:getFactory()
		factory:loadDragonBonesData("resource/Redpacket/anim/qianghongbao_ske.dbbin", "snatchAnimation")
	    factory:loadTextureAtlasData("resource/Redpacket/anim/qianghongbao_tex.json", "snatchAnimation")

	    armatureDisplay = factory:buildArmatureDisplay("armatureName", "snatchAnimation")
	    if armatureDisplay then
	    	--监听播放完成事件
	    	local function eventCustomListener(event)
		    	armatureDisplay:retain()
		    	armatureDisplay:removeFromParent(false)

		    	-- self.isPlayingAnim = false
		    	-- self.listview:setEnabled(true)
		    end

		    local listener = cc.EventListenerCustom:create("complete", eventCustomListener)
		    armatureDisplay:getEventDispatcher():setEnabled(true)
			armatureDisplay:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

		    self.snatchAnimation = armatureDisplay
		end
	end

	-- local scaleX = frameSize.width / 1334
	-- local scaleY = frameSize.height / 750
	local x, y = self.imgPop:getPosition()
	local pos = widget:getWorldPosition()
	local size = widget:getContentSize()
	armatureDisplay:setPosition(x, pos.y)
    -- armatureDisplay:setPosition(pos.x, pos.y)
    armatureDisplay:setScale(0.8)
    --动画播放。只播放一次
    armatureDisplay:getAnimation():play("qianghongbao", 1)

    if not armatureDisplay:getParent() then
    	self.rootNode:addChild(armatureDisplay, 1)
    end

    -- self.isPlayingAnim = true
end

function prototype:onImageCloseClick()
	self.imgPop:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(self.size.width, 0)), cc.CallFunc:create(function()
		self:close()
	end)))
end


