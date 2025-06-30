module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()
	
end

function prototype:refresh(groupInfo, index)
	self.txtGroupNum:setString("第"..groupInfo.index.."局")

	local gameName = string.lower(groupInfo.gameName)
	if string.find(gameName, "paodekuai") then
		self.btnDetail:setVisible(false)
	elseif string.find(gameName, "mushiwang") then
		self.btnPlayBack:setVisible(false)
	end

	local name = ""
	for i, v in ipairs(groupInfo.playerGroup) do
		if v.seatIndex <= 5 then
			name = "txtValue_"..v.seatIndex
			self[name]:setString(Assist.NumberFormat:amount2TrillionText(v.bp))
			if v.bp > 0 then
				self[name]:setTextColor(cc.c3b(255, 255, 0))
			else
				self[name]:setTextColor(cc.c3b(108, 246, 255))
			end
		end
	end

	local playerNum = #(groupInfo.playerGroup)
	for i = playerNum + 1, 5 do
		self["txtValue_"..i]:setVisible(false)
	end

	self.groupInfo = groupInfo

	self:playAction(index)
end

--回放
function prototype:onBtnPlaybackClick()
	self:fireUIEvent("PlayBack.RequestDetail", self.groupInfo.index)
end

--详情
function prototype:onBtnDetailsClick()
	local gameName = self.groupInfo.gameName
	if not gameName then
		return
	end

	-- log(self.groupInfo)
	self.groupInfo.isPlayBack = true
	if string.find(gameName, "mushiwang") then
		ui.mgr:open('Mushiwang/ResultView', self.groupInfo)
	end
	-- log(gameName)	
end

function prototype:playAction(index)
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.rootNode:setVisible(false)

	local action = self:createListItemBezierConfig(self.rootNode, actionOver, 0.5, 0.15+0.1*index)
	self.action = action
end
