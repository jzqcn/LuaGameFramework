module (..., package.seeall)

prototype = Controller.prototype:subclass()

local ResultType = {
	"resource/csbimages/Games/Kadang/kafei.png",
	"resource/csbimages/Games/Kadang/kazhong.png",
	"resource/csbimages/Games/Kadang/kadang.png",
	"resource/csbimages/Games/Kadang/kabaozi.png",
}

function prototype:enter()
	-- self.fontWinNum:setVisible(false)
	-- self.fontLoseNum:setVisible(false)
end

function prototype:showResult(isWin, value, mutiple, resultType)
	mutiple = mutiple or 1
	resultType = resultType or 1
	-- local function showValue()
	-- 	if self.isWin == KaDang_pb.Win then
	-- 		self.fontWinNum:setVisible(true)
	-- 		self.fontLoseNum:setVisible(false)
	-- 		self.fontWinNum:setString("+"..self.value)
	-- 	elseif self.isWin == KaDang_pb.Lose then
	-- 		self.fontWinNum:setVisible(false)
	-- 		self.fontLoseNum:setVisible(true)
	-- 		self.fontLoseNum:setString("-"..self.value)
	-- 	elseif self.isWin == KaDang_pb.Abandon then
	-- 		self.fontWinNum:setVisible(true)
	-- 		self.fontLoseNum:setVisible(false)
	-- 		self.fontWinNum:setString("+0")
	-- 	end
	-- end

	local function hideResultType()
		self.rootNode:setVisible(false)
	end

	self.isWin = isWin
	self.value = value

	-- self.fontWinNum:setVisible(false)
	-- self.fontLoseNum:setVisible(false)
	self.imgType:loadTexture(ResultType[tonumber(resultType)])
	self.fontMul:setString("X"..mutiple)
	self.rootNode:setVisible(true)

	if self.isWin == KaDang_pb.Abandon then
		hideResultType()
		-- showValue()
	else
		local seq = cc.Sequence:create(cc.EaseIn:create(cc.ScaleTo:create(0.15, 2.5), 2.5), cc.EaseOut:create(cc.ScaleTo:create(0.15, 1), 2.5), 
			cc.DelayTime:create(1.5), cc.CallFunc:create(hideResultType))

		self.panelResult:runAction(seq)
	end
end