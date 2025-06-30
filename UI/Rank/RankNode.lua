module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("Rank.EVT.PUSH_RANK_DATA", "onPushRankData")

	self.imgHeadIcon_1:setVisible(false)
	self.imgHeadIcon_2:setVisible(false)
	self.imgHeadIcon_3:setVisible(false)

	local data = Model:get("Rank"):getRankData(Ranking_pb.GoldRank)
	if data and #data > 0 then
		self:onPushRankData(Ranking_pb.GoldRank, data)
	else
		Model:get("Rank"):requestGoldRankData()
	end
	
	util.timer:after(200, self:createEvent("playAction"))
end

function prototype:playAction()
	self:playActionTime(0, true)
end

function prototype:onImageRankClick()
	ui.mgr:open("Rank/RankView")
end

function prototype:onPushRankData(rankType, rankData)
	if not rankData then
		return
	end

	local item
	for i = 1, 3 do
		item = rankData[i]
		if item then				
			sdk.account:getHeadImage(item.playerId, item.name, self["imgHeadIcon_"..i], item.headImage)
		
			self["imgHeadIcon_"..i]:setVisible(true)
		end
	end
end


