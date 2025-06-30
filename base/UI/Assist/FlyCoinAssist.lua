module("Assist.FlyCoin", package.seeall)

local CoinImageRes = {
	"resource/csbimages/Hall/goldIcon.png",
	"resource/csbimages/Hall/moneyIcon.png",
	"resource/csbimages/Hall/goldIcon.png",
}

local function getMoveAction(startPos, endPos)
	local pos = cc.p(startPos.x + (endPos.x-startPos.x)/2, startPos.y + (endPos.y-startPos.y)/2 + 100)
	local bezier = {
        startPos,
        pos,
        endPos
    }

    local action = cc.BezierTo:create(1.0, bezier)
    local function doRemoveFromParent(sender)
    	sender:removeFromParent(true)
    end
	local seq =  cc.Sequence:create(cc.EaseExponentialOut:create(action), cc.CallFunc:create(doRemoveFromParent))
	return seq
end

function create(_, type, from, to, delay, parent)
	local coinNum = math.random(12, 15)
	for i = 1, coinNum do
		-- log(CoinImageRes[tonumber(type)])
		local coin = cc.Sprite:create(CoinImageRes[tonumber(type)])
		coin:setPosition(from)
		coin:setVisible(false)

		local delayTime1 = cc.DelayTime:create(delay)
		local delayTime2 = cc.DelayTime:create(math.random()*0.3)
		local callFunc = cc.CallFunc:create(function()
			coin:setVisible(true)
			coin:runAction(getMoveAction(from, to))
	    end)

		coin:runAction(cc.Sequence:create(delayTime1, delayTime2, callFunc))

		parent:addChild(coin, i)
	end

	-- sys.sound:playEffect("COINS_FLY")
end


