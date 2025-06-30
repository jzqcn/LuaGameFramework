
module (..., package.seeall)

class = objectlua.Object:subclass()

local _spriteMap = {}
function create(_, name, parentNode, callback)
	local ani = class:new(name, parentNode, callback)
	return ani
end


function loadCache(_, framePlist, aniPlist)
	local frameCache = cc.SpriteFrameCache:getInstance()
	local animationCache = cc.AnimationCache:getInstance()

    frameCache:addSpriteFrames("resource/armature/" .. framePlist .. ".plist")
    animationCache:addAnimations("resource/armature/" .. aniPlist .. ".ani")
end

function existAction(_, name)
	return _spriteMap[name] ~= nil
end

function loadByAction(_, name)
	local plist = _spriteMap[name]
	assert(plist, "find plist failed:" .. name)
	local plist = string.gsub(plist, ".plist", "")
	local ani = plist
	loadCache(_, plist, ani)
end

function loadSpriteMap()
	local path = "resource/armature/spriteMap.lst"
	local data = util:openFile(path)	
	local status, info = pcall(loadstring(data))
    assert(status) 
    _spriteMap = info
end

function preLoad(_)
	loadSpriteMap()
	-- loadCache(_, "ship01/ship01", "ship01/ship01")
end




-----------------class--------------------

function class:initialize(name, parentNode, callback)
    super.initialize(self)

    self.name = name
    self.callback = callback

    local sprite = cc.Sprite:create()
    if parentNode then
    	parentNode:addChild(sprite)
    	Assist:centerNode(sprite, parentNode)
    end

    self.sprite = sprite 
    -- sprite:setAnchorPoint(cc.p(0, 0))
end

function class:dispose()
	super:dispose()
end

function class:retain()
	self.sprite:retain()
end

function class:release()
	self.sprite:release()
end

function class:setCallback(callback)
	self.callback = callback
end


----------------model------------------------
--
function class:getViewNode()
	return self.sprite
end

function class:flip()
	local scalex = self.sprite:getScaleX()
	self.sprite:setScaleX(-1 * scalex)
end

function class:setFlip(flip)
	self.sprite:setScaleX(flip and -1 or 1)
end

function class:setPosition(pos)
	self.sprite:setPosition(pos)
end

function class:setNormalizedPosition(pos)
	self.sprite:setNormalizedPosition(pos)
end

function class:setLocalZOrder(order)
	self.sprite:setLocalZOrder(order)
end

function class:runAction( ... )
	self.sprite:runAction(...)
end

-----------------action----------------------
--
function class:play(actionName, loop)
	self:stop()

	local fullName = self.name .. "/" .. actionName
	UI.Animation:loadByAction(fullName)

	local animationCache = cc.AnimationCache:getInstance()
	local ani = animationCache:getAnimation(fullName)
	assert(ani)

    local animation = cc.Animate:create(ani)
    local cbStart = cc.CallFunc:create(function()
	        if self.callback then
	            self.callback("start", actionName)
	        end
        end)

    local cbStop = cc.CallFunc:create(function()
	        if self.callback then
	            self.callback(loop and "loop" or "end", actionName)
	        end
        end)
    
    local action = cc.Sequence:create({cbStart, animation, cbStop})
    if loop then
        action = cc.RepeatForever:create(action)
    end

    self.action = cc.Speed:create(action, 1)
    self.sprite:runAction(self.action)
end

function class:pause()
	self.sprite:pauseSchedulerAndActions()
end

function class:resume()
	self.sprite:resumeSchedulerAndActions()
end

function class:stop()
	if not self.action then
		return
	end

	self.sprite:stopAction(self.action)
	self.action = nil
end







