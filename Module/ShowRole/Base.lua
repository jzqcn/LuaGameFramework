local Avatar = require "Avatar.Avatar"
local SkillData = require "ShowRole.SkillData"

module(..., package.seeall)

STATUS = enum
{
	"STAND",
	"MOVING",
	"ATTACK",
}

class = objectlua.Object:subclass()
class:include(Events.ReceiveClass)

function class:initialize(id, roleType)
    super.initialize(self)
    Events.ReceiveClass.initialize(self)

    self.id = id
    self.status = STATUS.STAND
    self.roleType = roleType
    self.target = nil
    self.buffList = {}
end

function class:dispose()
	Events.ReceiveClass.dispose(self)
    super.dispose(self)
end

function class:getId()
	return self.id
end

function class:setRoleType(type)
	self.roleType = type
end

function class:getRoleType()
	return self.roleType or Define.ROLE_TYPE.HERO
end

function class:getBindPos(bindPoint)
	return 0, 0
end

function class:setTarget(target)
	self.target = target
end

function class:playSkill(skillId)
	local data = SkillData:get(skillId, self)
	for skillType, skillInfo in pairs(data.info) do
		if type(skillInfo) == "table" and not  table.empty(skillInfo) then
			if skillType == "heroData" then
				self:playHeroEff(skillInfo)
			elseif skillType == "bullet" then
				self:playBulletEff(skillInfo)
			elseif skillType == "sceneData" then
				self:playSceneEff(skillInfo)
			elseif skillType == "armyData" then
				self:playArmyEff(skillInfo) 
			end
		end
	end
end
-----------------特效播放---------------------
--玩家自身技能特效
function class:playHeroEff(skillInfo)
	if table.empty(skillInfo) then 
		return 
	end

	local effList = skillInfo.effList
	self:play(skillInfo.aniName)

	for _, effInfo in pairs(effList) do
		self:playEff(effInfo)
	end
end

function class:playEff(effInfo)
	local eff = UI.EffectLoader:load(effInfo.effId, nil, bind(self.playEffEndBack, self))
    if nil == eff then
        log4map:w(eff, "effect not exist:" .. effectPath)
    else
    	local bindX, bindY = self:getBindPos(effInfo.bindPoint)
        eff:setPosition(cc.p(effInfo.x + bindX, effInfo.y + bindY))
        self.avatar:getViewNode():addChild(eff, effInfo.zOrder)
        util.timer:after(effInfo.delay, self:createEvent("eff"..effInfo.effId, function()
        	eff:play(0, false)
        end))
    end
end

function class:playEffEndBack()

end


--播放子弹特效
function class:playBulletEff(skillInfo)
	for _, bulletInfo in pairs(skillInfo) do
		self:playBullet(bulletInfo)
	end	
end

function class:playBullet(bulletInfo)
	local effInfo = bulletInfo.effList[1]

	local bulletNode = cc.Node:create()
	local eff = UI.EffectLoader:load(effInfo.effId, nil, nil)
    if nil == eff then
        log4map:w(eff, "effect not exist:" .. effectPath)
    else
        eff:setPosition(cc.p(effInfo.x, effInfo.y))
        bulletNode:addChild(eff, effInfo.zOrder)
        util.timer:after(effInfo.delay, self:createEvent("effBullet"..effInfo.effId, function()
        eff:play(0, false)
        end))
    end

    local bindX, bindY = self:getBindPos(bulletInfo.bindPoint)
    local sx, sy = self:getPos()
    local startPos = cc.p(sx + bindX, sy + bindY)

    local endPos = startPos
    if self.target then
    	local tx, ty = self.target:getPos()
    	local aimBindX , aimBindY = self.target:getBindPos(bulletInfo.aimBindPoint)
    	endPos = cc.p(tx + aimBindX, ty + aimBindY)
    end
    self.parentNode:addChild(bulletNode)

    --子弹需要根据敌人所处的位置改变方向
    local randian = cc.pToAngleSelf(cc.pSub(endPos, startPos))
    local angle = math.radian2angle(randian)
    bulletNode:setRotation(angle)

    bulletNode:setPosition(startPos)
    local dis = cc.pGetDistance(startPos, endPos)
    local time = dis/bulletInfo.speed
    local moveTo = cc.MoveTo:create(time, endPos)
    local delay = cc.DelayTime:create(bulletInfo.delayTime)
    local callEnd = cc.CallFunc:create(function()
    			bulletNode:removeFromParent(true)
    			log4temp:debug("bullet end")
        end)
    local action = cc.Sequence:create({delay, moveTo, callEnd})
    bulletNode:runAction(action)
end

--播放场景特效

function class:playSceneEff(skillInfo)
	local effList = skillInfo.effList or {}

	for _, effInfo in pairs(effList) do
		self:playScene(effInfo)
	end	
end

function class:playScene(effInfo)
	local sceneNode = cc.Node:create()
	local eff = UI.EffectLoader:load(effInfo.effId, nil, bind(self.playSceneEffEnd, self))
    if nil == eff then
        log4map:w(eff, "effect not exist:" .. effectPath)
    else
    	local bindX, bindY = self:getBindPos(effInfo.bindPoint)
        eff:setPosition(cc.p(effInfo.x + bindX, effInfo.y + bindY))
        sceneNode:addChild(eff, effInfo.zOrder)
        util.timer:after(effInfo.delay, self:createEvent("sceneEff"..effInfo.effId ,function()
        eff:play(0, false)
        end))
    end

    local startPos = cc.p(self.avatar:getPosition())
    local endPos = self.target and cc.p(self.target:getPos()) or cc.p(startPos.x + 200, 0)
    --根据攻击者所处的距离进行判断
    sceneNode:setPosition(endPos)
    self.parentNode:addChild(sceneNode)	
end

function class:playSceneEffEnd( ... )
	
end

--播放受击特效

function class:playArmyEff(skillInfo)

	if self.target then
		self.target:playBeAttack(skillInfo)
	end
end 

function class:playBeAttack(skillInfo)
	
end

--buff特效

function class:addBuff(buffId)
	self.buffList = self.buffList or {}
	if self.buffList[buffId] then 
		return
	end 

	self.buffList[buffId] = buffId
	self:playBuff(buffId)
end

function class:playBuffList()
	for _, buffId in pairs(self.buffList) do 
		self:playBuff(buffId)
	end
end

function class:playBuff(buffId)
	--通过buffId读表获取buff参数
	local buffInfo = {effId = 20003, order = 0}

	local eff = UI.EffectLoader:load(buffInfo.effId, nil, nil)
    if nil == eff then
        log4map:w(eff, "effect not exist")
    else
    	local bindX, bindY = self:getBindPos("foot")
        eff:setPosition(cc.p(bindX, bindY))
        self.avatar:getViewNode():addChild(eff,buffInfo.order)
        eff:play(0, false)
    end
end
---------------------

---------------------
--avatar part
--role的删除 必须通过map的deleteObj接口 而非直接调用这里
function class:removeSelf()
	if self.avatar then
		self.avatar:removeFromParent(true)
	end
	self:dispose()
end

function class:createAvatar(name, parent)
	self.parentNode = parent
    self.avatar = Avatar:create(name, parent, bind(self.actionCallback, self))
    self.avatar:stand()
end

function class:getAvatar()
	return self.avatar
end

function class:setPos(x, y)
	self.avatar:setPosition(cc.p(x, y))
end

function class:getPos()
	local x, y = self.avatar:getPosition()
	x = math.ceil(x)
    y = math.ceil(y)
    return x, y
end

function class:setLocalZOrder(order)
	self.avatar:setLocalZOrder(order)
end

function class:getLocalZOrder()
	return self.avatar:getLocalZOrder()
end

function class:setWeapon( ... )
	self.avatar:setWeapon(...)
end

function class:setMount( ... )
	self.avatar:setMount(...)
end

function class:setWing( ... )
	self.avatar:setWing(...)
end

function class:setOpacity( ... )
	self.avatar:setOpacity(...)
end

function class:setDir(dir)
	self.avatar:setDir(dir)
end

function class:play(actionName)
	self.avatar:play(actionName)
end

function class:setCallBack(callBack)
	self.callBack = callBack
end

function class:actionCallback(state, name)
	if state == "end" and name ~= "die" then
		self:play("idle")
	end
	
	if self.callBack then
		self.callBack(self.id, state, name)
	end
end


--
---------------------
