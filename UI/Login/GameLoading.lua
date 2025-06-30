local PreLoad = require "UI.PreLoad"

module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:isFullWinodwMode()
	return true
end

function prototype:enter()
	util.timer:after(500, self:createEvent("preloadRes"))

	self:updateResPercent(0)
end

function prototype:preloadRes()
    local list = 
    {
        "resource/PackImgs/Common.png",
        "resource/PackImgs/Hall.png",
        "resource/PackImgs/Game.png",
        "resource/PackImgs/Poker.png",
    }

    PreLoad:loadImages(list, bind(self.loadImagesPercent, self), self.loadingBar)


    local particle = cc.ParticleSystemQuad:create("resource/particle/lightP.plist")
    self.imgSlid:addChild(particle)

    local size = self.imgSlid:getContentSize()
    particle:setPosition(cc.p(size.width/2 + 20, size.height/2))
    particle:setScale(0.5)

    -- util.timer:after(5000, function()
    -- 	StageMgr:chgStage("Hall") 
    -- end)
end

function prototype:loadImagesPercent(percent)
    self:updateResPercent(percent * 0.8)

    if percent >= 100 then
        --加载特效包
        CEffectManager:GetSingleton():loadEffectPack()

        self:loadPlistFile()
    end
end

function prototype:loadPlistFile()
    local plist = 
    {
        "resource/PackImgs/Common.plist",
        "resource/PackImgs/Hall.plist",
        "resource/PackImgs/Game.plist",
        "resource/PackImgs/Poker.plist",
    }

    local curIdx = 1
    local function LoadNextFile()
        local fileName = plist[curIdx]
        log("load plist file name : "..fileName)
        
        cc.SpriteFrameCache:getInstance():addSpriteFrames(fileName)

        local percent = 80 + (curIdx / #plist) * 100 * 0.2
        self:updateResPercent(percent)

        curIdx = curIdx + 1

        if curIdx > #plist then
            util.timer:unbind(LoadNextFile)
            return
        end
    end

    util.timer:repeats(1, LoadNextFile)
end

function prototype:updateResPercent(percent)
	-- log("GameLoading::updateResPercent percent ============ "..percent)
	self.loadingBar:setPercent(percent)
	self.txtLoading:setString(string.format("%d%%", math.floor(percent)))

	local x, y = self.loadingBar:getPosition()
	local size = self.loadingBar:getContentSize()
	self.imgSlid:setPosition(x - size.width/2 + percent/100 * size.width, y)

	if percent >= 100 then
		StageMgr:chgStage("Login", true)
	end
end
