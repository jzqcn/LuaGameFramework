module (..., package.seeall)

prototype = Controller.prototype:subclass()

local SHOW_STATE = 
{
	"resource/Longhudou/csbimages/txt_bet.png",
	"resource/Longhudou/csbimages/txt_deal.png",
	"resource/Longhudou/csbimages/txt_settlement.png",
}

function prototype:enter()
	
end

function prototype:start(countdown, state)
	self.rootNode:setVisible(true)
	self.rootNode:stopAllActions()

	self.countdown = countdown
	if countdown >= 0 then
		self.imgClock:setVisible(true)
		self.fntCountdown:setVisible(true)
		self.fntCountdown:setString(tostring(countdown))

		self.rootNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function ()
			self.countdown = self.countdown - 1
			if self.countdown <= 0 then
				self.countdown = 0
				self.rootNode:stopAllActions()
			end

			self.fntCountdown:setString(tostring(self.countdown))
		end))))
	else		
		self.imgClock:setVisible(false)
		self.fntCountdown:setVisible(false)
	end

	self.imgTip:loadTexture(SHOW_STATE[state])
end

function prototype:stop()
	self.rootNode:setVisible(false)
	self.rootNode:stopAllActions()
end
