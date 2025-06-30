local Spine = require "Spine.Spine"
local SkillData = require "ShowRole.SkillData"
local SpineDefine = require "Spine.Define"

module(..., package.seeall)

STATUS = enum
{
	"STAND",
	"MOVING",
	"ATTACK",
}

TARGET_DISTANCE = 300	--直线范围,距离玩家300距离的点
LOCAL_SPEED	= 200 		--玩家行动速度
DIR_ORI = math.pow(2, 4) -- 16方向

class = objectlua.Object:subclass()
class:include(Events.ReceiveClass)

function class:initialize(id, map, roleType)
    super.initialize(self)
    Events.ReceiveClass.initialize(self)

    self.rootNode = cc.Node:create()
    self.rootNode:setCascadeOpacityEnabled(true)
    local subCross = cc.Sprite:create("resource/csbimages/Common/cross.png")
    self.rootNode:addChild(subCross)

    self.rootNode:scheduleUpdateWithPriorityLua(bind(self.update, self), 0)
    self.playerEffList = {}
    self.actionList = {}

    self.id = id
    self.map = map
    self.status = STATUS.STAND
    self.speed = LOCAL_SPEED  -- logic length per second
    self.roleType = roleType
    self.movePath = {}
    self.normalAttackTime = nil -- 普通攻击事件间隔
    self.eCbk = {}
    self.bHideEff = false
    self.target = nil

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
	local pos = self.spine:getBindPos(bindPoint)
	return pos.x, pos.y
end

function class:setTarget(target)
	if self.target == target then
		return 
	end
	if self.target then
		self.target:setChoose(false)

	end
	self.target = target
	self.target:setChoose(true)
end

function class:removeTarget()
	if self.target then
		self.target:setChoose(false)
	end
	self.target = nil
end

function class:setParentNode(parent)
	self.parentNode = parent
end


function class:hileEff(bHide)
	self.bHideEff = bHide

	self:hideBuff(bHide)
end

------------角色移动-----------------
--path move
function class:moveByPath(path)
	self:stopMove()
	if table.empty(path or {}) then
		self:stopMove(true)
		return
	end

	self.movePath = list.reverse(self:filterPath(path))
	--self.movePath = list.reverse(path)
	self:stepMove()
end

function class:stepMove()
	local cellIdx = table.remove(self.movePath)
	self:moveToCell(self.map:maskIndex2cell(cellIdx))
end

function class:moveToCell(cellx, celly)
	local x, y = self.map:maskCell2world(cellx, celly)
	self:moveTo(x, y)
end

function class:moveTo(x, y)
	local dir = self:computeDir(x, y)
	self:setDir(dir)

	if self.status ~= STATUS.MOVING then
		self:play("run")
		self.status = STATUS.MOVING
	end
	
    local callEnd = cc.CallFunc:create(function()
    		if table.empty(self.movePath) then
				self:play("idle")
	    		self.status = STATUS.STAND
	    	else
	    		self:stepMove()
    		end
        end)

    local dis = cc.pGetDistance(cc.p(self:getPos()), cc.p(x, y))
    local time = dis / self.speed
    local moveto = cc.MoveTo:create(time, cc.p(x, y))
    
    local action = cc.Sequence:create({moveto, callEnd})
    self.action = cc.Speed:create(action, 1)
    self.rootNode:runAction(self.action)
end

function class:filterPath(movePath)
	local sx, sy = self:getPosCell()
	local selfIndex = self.map:maskCell2index(sx, sy)
	local startCell = selfIndex

	local i = 0
	local pathList = {}
	while true do
		--最远点遍历,如果直线,直接返回
		local bDirect = false
		for j = #movePath, i + 1, -1 do 
			local endCell = movePath[j]
			local isDirect = self:isPathDirect(startCell, endCell)
			if isDirect then
				startCell = movePath[j]
				table.insert(pathList, endCell)
				i = j
				bDirect = true
				break
			end
		end

		if not bDirect then
			i = i + 1
			startCell = movePath[i]
			table.insert(pathList, startCell)
		end

		if i == #movePath then
			return pathList
		end
	end

	return pathList
end

function class:isPathDirect(startCell, endCell)
	local startCellx, startCelly = self.map:maskIndex2cell(startCell)
	local startx, starty =  self.map:maskCell2world(startCellx, startCelly)
	local endCellx, endCelly = self.map:maskIndex2cell(endCell)
	local endx, endy =  self.map:maskCell2world(endCellx, endCelly)
	local blockCellList = self.map:getBlockCellList(startx, starty, startCellx, startCelly, endCellx, endCelly, endx, endy)

	return table.empty(blockCellList)
end

-- dir move
--x,y  控制杆的控制坐标，通过坐标计算方向
function class:jockstick(pos, centerPos)
	local jockstickDir = self:computeJockstickDir(pos.x, pos.y, centerPos.x, centerPos.y)
	if(self.jockstickDir == jockstickDir) then
		return 
	else
		if(not self.jockstickDir ) then
			self.jockstickDir = jockstickDir
			self:moveByJoystick(pos.x - centerPos.x, pos.y - centerPos.y, jockstickDir)
		else
			self.jockstickDir = jockstickDir 
			self:moveByJoystick(pos.x - centerPos.x, pos.y - centerPos.y, jockstickDir)
		end
	end
end

function class:moveByJoystick(x, y, dir)
	self:stopMove()
	self:jockstickMove(x, y, dir)
end

function class:jockstickMove(x, y, dir)
	local sx, sy = self:getPos()
	local nx = sx + x
	local ny = sy + y 
	local avatarDir = self:computeDir(nx, ny)
	self:setDir(avatarDir)

	local randian = self:getRandianByJockstickDir(dir)
	local dis, endPosx, endPosy = self:getTargetCell(randian, TARGET_DISTANCE)
	if(dis <= 10) then
		self:stopMove(true)
		return
	end

	if self.status ~= STATUS.MOVING then
		self:play("run")
	end
    local callEnd = cc.CallFunc:create(function()
    			self:jockstickMove(x, y, dir)
        end)

    local time = dis / self.speed
    local moveto = cc.MoveTo:create(time, cc.p(endPosx, endPosy))
    
    local action = cc.Sequence:create({moveto, callEnd})
    self.action = cc.Speed:create(action, 1)
    self.rootNode:runAction(self.action)
    self.status = STATUS.MOVING
end

--朝向目标的直向运动, 打怪时不在范围内,自动移动到攻击范围
function class:moveBytarget(targetPos, moveDis)
	self:stopMove(true)
	self:targMove(targetPos, moveDis)
end

function class:targMove(targetPos, moveDis)
	local sx, sy = self:getPos()
	local tx = targetPos.x
	local ty = targetPos.y
	local dir = self:computeDir(tx, ty)
	self:setDir(dir)

	local randian = cc.pToAngleSelf(cc.pSub({x = tx, y = ty}, {x = sx, y = sy}))
	local dis, endPosx, endPosy = self:getTargetCell(randian, moveDis)
	if dis < moveDis and dis < 10 then 
		self:stopMove(true)
		return
	end

	dis = math.min(dis, moveDis)
	if self.status ~= STATUS.MOVING then
		self:play("run")
	end
    local callEnd = cc.CallFunc:create(function()
    			self:stopMove(true)
        end)
    local time = dis / self.speed
    local moveto = cc.MoveTo:create(time, cc.p(endPosx, endPosy))
    
    local action = cc.Sequence:create({moveto, callEnd})
    self.action = cc.Speed:create(action, 1)
    self.rootNode:runAction(self.action)
    self.status = STATUS.MOVING
end

function class:standMoving()
	self.rootNode:stopAction(self.action)
	self.action = nil

	self:play("run")
	self.status = STATUS.MOVING
end

function class:getTargetCell(randian, targetDis)
	local bPosx, bPosy = self:getPos()
	local cellx1, celly1 = self:getPosCell()
	local cellx2, celly2, ePosx, ePosy = self:getEndCellByDir(randian, targetDis, bPosx, bPosy)

	local blockCellList = self.map:getBlockCellList(bPosx, bPosy, cellx1, celly1, cellx2, celly2, ePosx, ePosy)

	local realEndx, realEndy
	--未找到blockcell, 返回最远点
	if(table.empty(blockCellList)) then
		realEndx = ePosx 
		realEndy = ePosy
	else
		local minDisList  = {}
		--获取距离角色最近的blockCell
		for index, cell in pairs(blockCellList) do
			local x, y = self.map:maskCell2world(cell.x, cell.y)
			local dis = math.abs(cellx1 - cell.x) + math.abs(celly1 - cell.y)
			table.insert(minDisList, {dis = dis, cell = cell})
		end
		table.sort(minDisList, function(a,b) return a.dis < b.dis end)

		for _, cell in ipairs(minDisList) do
			local minCell = cell.cell
			local hasLine, intersectPos = self.map:getCtrlLine(minCell.x, minCell.y, cc.p(bPosx, bPosy), cc.p(ePosx, ePosy))
			if(hasLine and intersectPos) then
				realEndx, realEndy = self:correctPosByDir(randian, intersectPos)
				break
			elseif(not hasLine and (minCell.x ~= cellx1 or minCell.y ~= celly1)) then
				local bIntersect, cellIntersectPos = self.map:getBlockIntersectPos(minCell.x, minCell.y, cc.p(bPosx, bPosy), cc.p(ePosx, ePosy))
				--cell相交点会出现未相交情况
				if bIntersect then
					realEndx, realEndy = self:correctPosByDir(randian, cellIntersectPos)
					break
				end
			end
		end

		if(not realEndx or not realEndy) then
			realEndx = ePosx 
			realEndy = ePosy
		end
	end

	local minDis = cc.pGetDistance(cc.p(bPosx, bPosy), cc.p(realEndx, realEndy))
	return minDis, realEndx, realEndy
end

function class:correctPosByDir(randian, intersectPos)
	local correctPosx,correctPosy
	correctPosx = math.ceil(intersectPos.x - math.cos(randian) * 10)
	correctPosy = math.ceil(intersectPos.y - math.sin(randian) * 10)

	return correctPosx, correctPosy
end

function class:getEndCellByDir(randian, dis, sx, sy)
	local endPosx, endPosy;
	endPosx = math.ceil(sx + dis * math.cos(randian))
	endPosy = math.ceil(sy + dis * math.sin(randian))

	local cellx, celly = self.map:maskWorld2cell(endPosx, endPosy)

	return cellx, celly, endPosx, endPosy
end

function class:jumpTo(cellx, celly)
	self:setPosCell(cellx, celly)
end

function class:stopMove(toIdle)
	self.movePath = {}
	if nil == toIdle then
		toIdle = false 
	end
	if self.action then
		self.rootNode:stopAction(self.action)
		self.action = nil
	end

	if toIdle and self.status ~= STATUS.STAND then
		self:play("idle")
		self.status = STATUS.STAND
		self.jockstickDir = nil
	end

end

function class:computeDir(x, y)
	local target = {x = x, y = y}
	local curx, cury = self:getPos()
	local cur = {x = curx, y = cury}

	local randian = cc.pToAngleSelf(cc.pSub(target, cur))
	-- local angle = math.radian2angle(randian)

	if randian < 0 then
		randian = randian + 2 * math.pi
	end



	local partCircle = 2 * math.pi * 1 / 16
	local dir = "down"
	if (randian >= 0 and randian <= 4 * partCircle) or
		(randian > 12 * partCircle and randian < 16 * partCircle) then
		dir = "right"
	else
		dir = "left"
	end
	return dir
end

--计算摇杆方向
function class:computeJockstickDir(x, y, posx, posy)
	local target = {x = x, y = y}
	local curx = posx
	local cury = posy
	local cur = {x = curx, y = cury}

	local randian = cc.pToAngleSelf(cc.pSub(target, cur))

	if randian < 0 then
		randian = randian + 2 * math.pi
	end

	local partCircle = 2 * math.pi * 1 / (DIR_ORI * 2)
	local dir = 1
	if (randian >= 0 and randian <= partCircle) or 
		(randian > (DIR_ORI * 2 - 1) * partCircle and randian < (DIR_ORI * 2) * partCircle) then
		dir = 1
	else 
		for i = 3, (DIR_ORI * 2 - 1), 2 do 
			if randian > (i - 2) * partCircle and randian <= i * partCircle then
				dir = (i+ 1)/2
				break
			end
 		end
 	end

	return dir
end
--计算方向弧度
function class:getRandianByJockstickDir(dir)
	local partCircle = 2 * math.pi * 1 / (DIR_ORI * 2)
	local randian = (dir - 1) * 2 * partCircle
	return randian
end
---------------------

---------------------
--avatar part
--role的删除 必须通过map的deleteObj接口 而非直接调用这里
function class:removeSelf()
	if self.spine then
		self.spine:removeFromParent(true)
	end
	self:dispose()
end

function class:createSpine(name, parent)
    self.spine = Spine:create(name, self.rootNode, bind(self.actionCallback, self))
    if parent then
    	self.parentNode = parent
    	parent:addChild(self.rootNode)
    end
    self.spine:stand()
end

function class:getSpine()
	return self.spine
end

function class:setPos(x, y)
	self.rootNode:setPosition(cc.p(x, y))
end

function class:setPosCell(cellx, celly)
	local x, y = self.map:maskCell2world(cellx, celly)
	self:setPos(x, y)
end

function class:getPos()
	local x, y = self.rootNode:getPosition()
	x = math.ceil(x)
    y = math.ceil(y)
    return x, y
end

function class:getPosition()
	return self.rootNode:getPosition()
end

function class:setPosition(x, y)
	self.rootNode:setPosition(cc.p(x, y))
end

function class:setVisible(visible)
	self.rootNode:setVisible(visible)
end

function class:isVisible()
	return self.rootNode:isVisible()
end

function class:setLocalZOrder(order)
	self.rootNode:setLocalZOrder(order)
end

function class:getLocalZOrder()
	return self.rootNode:getLocalZOrder()
end

function class:getPosCell()
	local x, y = self:getPos()
	return self.map:maskWorld2cell(x, y)
end

function class:setOpacity( ... )
	self.rootNode:setOpacity(...)
end

function class:setDir(dir)
	self.spine:setDir(dir)
end

function class:play(actName, loop)
	local preActionLoop = SpineDefine.SpineLoopAction[self.actionName] or false
	if preActionLoop then
		local index = self:getActionIndex(self.actionName)
		self.spine:play(index, self.actionName, false)
	end

	local index = self:getActionIndex(actName)

	if index == SpineDefine.SpineActionIndex.AA_ATTACK then
		table.insert(self.actionList, {index = index, action = actName})
	end
	local isLoop = SpineDefine.SpineLoopAction[actName] or false

	loop = loop == nil and isLoop or loop
	self.spine:play(index, actName, loop)
end

function class:setCallBack(callBack)
	self.callBack = callBack
end

function class:actionCallback(state, event)
	if state == "start" then
		self.actionName = event.animation
		self.actionIndex = event.trackIndex
	end

	if state == "end" and event.trackIndex == SpineDefine.SpineActionIndex.AA_ATTACK then
		table.remove(self.actionList, 1)
		if table.empty(self.actionList) then
			self:play("idle", true)
		end
	end
	
	if self.callBack then
		self.callBack(self.id, state, event)
	end
end

function class:getActionIndex(actName)
	if SpineDefine.SpineAction[actName] then
		return SpineDefine.SpineAction[actName]
	end

	return SpineDefine.SpineActionIndex.AA_NONE
end

-----------------技能特效播放---------------------
function class:playSkill(skillId)
	--改变角色方向,向敌人方向
	if self.target then
		local dir = self:computeDir(self.target:getPosition())
		self:setDir(dir)
	end

	local time = util.time:getMilliTime()

	local data = SkillData:get(skillId, self)
	if data.info.heroData then
		self:playHeroEff(data.info.heroData, time, skillId)
	end

	if data.info.sceneData then
		self:playSceneEff(data.info.sceneData, time, skillId)
	end

	if data.info.bullet then
		if self:playBulletEff(data.info.bullet, time, data.info) then
			return
		end
	end

	if data.info.armyData then
		self:playArmyEff(data.info.armyData, time, skillId)
	end
end

function class:update(dt)
	for _, effInfo in pairs(self.playerEffList) do
		local bindX, bindY = self:getBindPos(effInfo.info.bindPoint)
        effInfo.node:setPosition(cc.p(effInfo.info.x + bindX, effInfo.info.y + bindY))
	end
end

--玩家自身技能特效
function class:playHeroEff(effInfo, time, skillId)
	if table.empty(effInfo) then 
		return 
	end

	local effList = effInfo.effList or {}
	self:stopMove(true)
	local curvelist = {}
	curvelist.loopCurve = effInfo.loopCurve or nil
	curvelist.scaleCurve = effInfo.scaleCurve or nil
	curvelist.speedCurve = effInfo.speedCurve or nil
    if self.id == 1001 then
    	self.spine:setCurveInfo(curvelist)
    end

	self:play(effInfo.aniName, false)

	local key = "selfEff"..self.id..time
	for index, info in pairs(effList) do
		self:playEff(info, key..index, skillId, true)
	end
end

function class:playEff(effInfo, key, skillId, bAttacker)
	local eff = UI.EffectLoader:load(effInfo.effId, nil, bind(self.playEffEndBack, self), key)
    if nil == eff then
        log4map:w(eff, "effect not exist:" .. effInfo.effId)
       	return 
    else
    	self.playerEffList[key] = {node = eff, info = effInfo}

    	eff:setVisible(not self.bHideEff)
    	local bindX, bindY = self:getBindPos(effInfo.bindPoint)
        eff:setPosition(cc.p(effInfo.x + bindX, effInfo.y + bindY))
        self.rootNode:addChild(eff, effInfo.zOrder)
        eff:delayPlay(effInfo.delay, 0, false)

        --攻击特效改变方向
        if bAttacker then
	        local startPos = cc.p(self:getPos())
	        local endPos= cc.p(self.target:getPos())
		    local randian = cc.pToAngleSelf(cc.pSub(endPos, startPos))
		    local angle = math.radian2angle(randian)
		    eff:setRotation(-angle)
		end

        if effInfo.sCbk then
        	util.timer:after(effInfo.delay*1000, self:createEvent("sCbk"..key, function()
        		self:startEffCbk(effInfo.sCbkArg, skillId)
        	end))
        end

        if effInfo.eCbk then
        	self.eCbk = self.eCbk or {}
        	self.eCbk["eCbk"..key] =  function()  
        				self:endEffCbk(effInfo.eCbkArg, skillId)
        				end
        end

        if effInfo.deCbk then
        	util.timer:after((effInfo.delay + effInfo.deCbkTime) * 1000, self:createEvent("deCbk"..key, function()
        		self:delayEffCbk(effInfo.deCbkArg, skillId)
        	end))
        end
    end
end

--特效结束回调
function class:playEffEndBack(id, key)
	self.playerEffList[key] = nil 
	local eKey = "eCbk"..key
	if self.eCbk[eKey] then
		self.eCbk[eKey]()
		self.eCbk[eKey] = nil
	end
end


--播放子弹特效
function class:playBulletEff(effInfo, time, skillInfo)
	local key = "bullet"..self.id..time
	local hasBullet = false
	for index, bulletInfo in pairs(effInfo) do
		if self:playBullet(bulletInfo, key..index, skillInfo, time) then
			hasBullet = true
		end
	end

	return hasBullet
end

function class:playBullet(bulletInfo, key, skillInfo, sysTime)
	local effInfo = bulletInfo.effList[1]

	local bulletNode = cc.Node:create()
	local eff = UI.EffectLoader:load(effInfo.effId, nil, nil)
    if nil == eff then
        log4map:w(eff, "effect not exist:" .. effInfo.effId)
        return false
    else
    	eff:setVisible(not self.bHideEff)
        eff:setPosition(cc.p(effInfo.x, effInfo.y))
        bulletNode:addChild(eff, effInfo.zOrder)
        eff:delayPlay(effInfo.delay, 0, false)
    end

    local bindX, bindY = self:getBindPos(bulletInfo.bindPoint)
    local sx, sy = self:getPos()
    local startPos = cc.p(sx + bindX, sy + bindY)

    local endPos = cc.p(sx -500, sy -500)
    if self.target then
    	local tx, ty = self.target:getPos()
    	local aimBindX , aimBindY = self.target:getBindPos(bulletInfo.aimBindPoint)
    	endPos = cc.p(tx + aimBindX, ty + aimBindY)
    end
    self.parentNode:addMapEffect(key ,bulletNode)

    --子弹需要根据敌人所处的位置改变方向
    local randian = cc.pToAngleSelf(cc.pSub(endPos, startPos))
    local angle = math.radian2angle(randian)
    bulletNode:setRotation(-angle)


    bulletNode:setPosition(startPos)
    local dis = cc.pGetDistance(startPos, endPos)
    local time = dis/bulletInfo.speed

    local actList = {}

    local delay = cc.DelayTime:create(bulletInfo.delayTime)
    table.insert(actList, delay)
    if effInfo.sCbk then
    	table.insert(actList, cc.CallFunc:create(function ()
    			--bulletNode:setPosition(startPos)
    			self:startEffCbk(effInfo.sCbkArg, skillInfo.skillId)
    	end))
    end

    local moveTo = cc.MoveTo:create(time, endPos)

    local spawn
    if effInfo.deCbk then
    	local deCbkSqe = cc.Sequence:create({
			cc.DelayTime:create(effInfo.deCbkTime),
    		cc.CallFunc:create(function ()
    			self:delayEffCbk(effInfo.deCbkArg, skillInfo.skillId)
    		end),
    		nil,
    		})
    	table.insert(actList, cc.Spawn:create(moveto, deCbkSqe))
    else
    	table.insert(actList, moveTo)
    end

    local callEnd = cc.CallFunc:create(function()
    			self.parentNode:delMapEffect(key)
    			if effInfo.ecbk then
    				self:endEffCbk(effInfo.eCbkArg, skillInfo.skillId)
    			end
    			if skillInfo.armyData then
    				self:playArmyEff(skillInfo.armyData, sysTime, skillInfo.skillId)
    			end
        end)
    table.insert(actList, callEnd)
    local action = cc.Sequence:create(actList)
    bulletNode:runAction(action)

    return true
end

--播放场景特效

function class:playSceneEff(effInfo, time, skillId)
	local effList = effInfo.effList or {}

	local key = "scene"..self.id..time
	for index, info in pairs(effList) do
		self:playScene(info, key..index, skillId)
	end	
end

function class:playScene(effInfo, key, skillId)
	local sceneNode = cc.Node:create()
	local eff = UI.EffectLoader:load(effInfo.effId, nil, bind(self.playSceneEffEnd, self), key)
    if nil == eff then
        log4map:w(eff, "effect not exist:" .. effInfo.effId)
        return
    else
    	eff:setVisible(not self.bHideEff)

    	local bindX, bindY = self:getBindPos(effInfo.bindPoint)
        eff:setPosition(cc.p(effInfo.x + bindX, effInfo.y + bindY))
        sceneNode:addChild(eff, effInfo.zOrder)
        eff:delayPlay(effInfo.delay, 0, false)
    end

    local startPos = cc.p(self.avatar:getPosition())
    local endPos = self.target and cc.p(self.target:getPos()) or cc.p(startPos.x + 200, 0)
    --根据攻击者所处的距离进行判断
    sceneNode:setPosition(endPos)

    if effInfo.sCbk or effInfo.deCbk then
	    local actList = {}
	    table.insert(actList, cc.DelayTime:create(effInfo.delay))
	    if effInfo.sCbk then
	    	table.insert(actList, cc.CallFunc:create(function ()
	    			self:startEffCbk(effInfo.sCbkArg, skillInfo.skillId)
	    	end))
	    end
	    table.insert(actList, cc.DelayTime:create(effInfo.deCbkTime))
	    table.insert(actList, cc.CallFunc:create(function ()
	    			self:delayEffCbk(effInfo.deCbkArg, skillInfo.skillId)
	    	end))

	    local action = cc.Sequence:create(actList)
	    sceneNode:runAction(action)
	end
    if effInfo.eCbk then
    	self.eCbk = self.eCbk or {}
    	self.eCbk["eCbk"..key] =  function()  
    				self:endEffCbk(effInfo.eCbkArg, skillId)
    				end
    end


    self.parentNode:addMapEffect(self.id..effInfo.effId, sceneNode)	
end

function class:playSceneEffEnd(effId, key)
	self.parentNode:delMapEffect(key)

	local eKey = "eCbk"..key
	if self.eCbk[ekey] then
		self.eCbk[eKey]()
		self.eCbk[eKey] = nil
	end
end

--播放受击特效

function class:playArmyEff(effInfo, time ,skillId)
	if self.target then
		local key = "army"..self.id..time
		self.target:playBeAttack(effInfo, key, skillId)
	end
end 

function class:playBeAttack(effInfo, key, skillId)
	if table.empty(effInfo) then 
		return 
	end

	local effList = effInfo.effList or {}

	for index, info in pairs(effList) do
		self:playEff(info, key..index, skillId, false)
	end
end

--buff特效
function class:addBuff(buffId)
	self.buffList = self.buffList or {}
	if self.buffList[buffId] then 
		return
	end 

	self:playBuff(buffId)
end

function class:isBuffExist(buffId)
	return self.buffList and self.buffList[buffId]
end

function class:delBuffById(buffId)
	if self.buffList[buffId] then
		self.buffList[buffId]:removeFromParent(true)
		self.buffList[buffId] = nil
	end
end

function class:clearBuffList()
	if not self.buffList then
		return
	end

	for _, node in pairs(self.buffList) do 
		node:removeFromParent(true)
	end

	self.buffList = {}
end

function class:hideBuff(bHide)
	if not self.buffList then
		return
	end

	for _, node in pairs(self.buffList) do 
		node:setVisible(not bHide)
	end
end

function class:playBuffList()
	for _, buffId in pairs(self.buffList) do 
		self:playBuff(buffId)
	end
end

function class:playBuff(buffId)
	--通过buffId读表获取buff参数
	local buffInfo = {effId = buffId, order = 100}

	local eff = UI.EffectLoader:load(buffInfo.effId, nil, nil)
    if nil == eff then
        log4map:w(eff, "effect not exist:"..buffInfo.effId)
        return
    else
    	local bindX, bindY = self:getBindPos("foot")
        eff:setPosition(cc.p(bindX, bindY))
        self.rootNode:addChild(eff, buffInfo.order)
        eff:play(0, false)
        self.buffList[buffId] = eff
    end
end

function class:setChoose(bChoose)
	local node = self.rootNode:getChildByTag(110)
	if not node then
		node = cc.Node:create()
		self.rootNode:addChild(node, -100, 110)
		node:setPosition(cc.p(0 ,0))
	end

	if bChoose then
		if node:getChildrenCount() == 0 then
			local eff = UI.EffectLoader:load(20025, nil, nil)
			if nil == eff then
				log4map:w(eff, "effect not exist:"..buffInfo.effId)
				return
			end

			node:addChild(eff, 0, 1)
			eff:play(0, false)
			return
		else
			node:setVisible(true)
		end
	else 
		if node:getChildrenCount() == 0 then
			return
		else 
			node:setVisible(false)
		end
	end
end

--npc特效
function class:addNpcEff(effId, posx, posy, order)
	local eff = UI.EffectLoader:load(effId, nil, nil)
    if nil == eff then
        log4map:w(eff, "effect not exist: "..effId)
    	return
    else
        eff:setPosition(cc.p(posx, posy))
        self.rootNode:addChild(eff, order)
        eff:play(0, false)
    end	
end

--特效开始回调
function class:startEffCbk(args, skillId)
	self:effCallBackFunc(args)
end

--特效结束回调
function class:endEffCbk(args, skillId)
	self:effCallBackFunc(args)
end

--特效延时回调
function class:delayEffCbk(args, skillId)
	self:effCallBackFunc(args)
end

function class:effCallBackFunc(args)

end
---------------------