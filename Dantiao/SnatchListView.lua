module (..., package.seeall)

prototype = Dialog.prototype:subclass()


function prototype:enter(data)
	self:bindModelEvent("Games/Dantiao.EVT.PUSH_SNATCHQUEUE", "onPushSnatchQueue")
	self:bindModelEvent("Games/Dantiao.EVT.PUSH_SNATCH", "onPushSnatch")

	if data~=nil then
		if data==114001 then
			self.imgTxt:loadTexture("resource/Dantiao/csbimages/snatchCoin.png")
		elseif data==114002 then
			self.imgTxt:loadTexture("resource/Dantiao/csbimages/snatchCoin_1.png")
		end
	end
	local dealerQueue = Model:get("Games/Dantiao"):getDealerQueue()
	--dump(dealerQueue,"OpenSnatchListView")
	self:dealDealerData(dealerQueue)
	local param = 
	{
		data = dealerQueue,
		ccsNameOrFunc = "Dantiao/SnatchListViewItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
	self.listview:createItems(param)

	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.imgBg, actionOver)
end

function prototype:onPushSnatchQueue()
	--log("onTransData")
	local dealerQueue = Model:get("Games/Dantiao"):getDealerQueue()
	--log(dealerQueue)
	self:dealDealerData(dealerQueue)
	local param = 
	{
		data = dealerQueue,
		ccsNameOrFunc = "Dantiao/SnatchListViewItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
	self.listview:refreshListView(dealerQueue)
end

function prototype:dealDealerData(dealerQueue)
	if self.snatchState==nil then --0,我要上庄,1取消上庄,2我要下庄
		self.snatchState=0
	end
	local userid = Model:get("Account"):getUserId()
	if userid== nil or dealerQueue==nil or table.nums(dealerQueue) == 0 then return end
	
	local selfInDealerQueue = false 
	for k,v in ipairs(dealerQueue) do
		if v.playerId == userid then
			selfInDealerQueue = true
			break
		end
	end
	if selfInDealerQueue == true then
		local imgBtn="resource/Dantiao/csbimages/cancleDealer.png"
		self.btnSnatch:loadTextureNormal(imgBtn)
		self.btnSnatch:loadTexturePressed(imgBtn)
		self.snatchState=1
	end

	if  dealerQueue[1].playerId == userid and dealerQueue[1].isDealer == true then
		local imgBtn="resource/Dantiao/csbimages/downDealer.png"
		self.btnSnatch:loadTextureNormal(imgBtn)
		self.btnSnatch:loadTexturePressed(imgBtn)
		self.snatchState=2
	end
	if self.snatchState==0 then
		local imgBtn="resource/Dantiao/csbimages/img_upDealer.png"
		self.btnSnatch:loadTextureNormal(imgBtn)
		self.btnSnatch:loadTexturePressed(imgBtn)
	end
end

function prototype:onPushSnatch()

end

function prototype:onBtnSnatchClick()
	--log("snatchListViewClick")
	if self.snatchState == 0 then
		self:fireUIEvent("Dantiao.Snatch")
		-- local imgBtn="resource/Dantiao/csbimages/cancleDealer.png"
		-- self.btnSnatch:loadTextureNormal(imgBtn)
		-- self.btnSnatch:loadTexturePressed(imgBtn)
	else
		self:fireUIEvent("Dantiao.Abandon")
		-- local imgBtn="resource/Dantiao/csbimages/img_upDealer.png"
		-- self.btnSnatch:loadTextureNormal(imgBtn)
		-- self.btnSnatch:loadTexturePressed(imgBtn)
		-- self.snatchState=0
	end
end

function prototype:onBtnCloseClick()
	self:close()
end

function prototype:hasBgMask()
    return false
end