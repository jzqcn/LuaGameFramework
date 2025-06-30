local Body = require "Avatar.Component.Body"
local Wing = require "Avatar.Component.Wing"
local Weapon = require "Avatar.Component.Weapon"
local Mount = require "Avatar.Component.Mount"
local Define = require "Avatar.Define"
local Shader = require "Avatar.Shader"



module (..., package.seeall)


local DEBUG_MODE = false 
local PART_CLASS = 
{
	["body"] = Body,
	["wing"] = Wing,
	["weapon"] = Weapon,
	["mount"] = Mount,
}

class = objectlua.Object:subclass()


function create(_, name, parentNode, callback)
	local avatar = class:new(name, callback)
	if parentNode then
		parentNode:addChild(avatar:getViewNode())
		Assist:centerNode(avatar:getViewNode(), parentNode)
	end
	return avatar
end


function class:initialize(name, callback)
    super.initialize(self)

    self.shader = Shader.class:new(self)
    self.callback = callback
    self.rootNode = cc.Node:create()
    self.rootNode:setCascadeOpacityEnabled(true)
    self.rootNode:setContentSize(cc.size(50, 50))
    --添加标识线，方便测试
    local subCross = cc.Sprite:create("resource/csbimages/Common/cross.png")
    self.rootNode:addChild(subCross)
    
    self.dir = "down"
    self.actionName = "idle"
    self.component = {}
    self.componentName = {}

    local roleOffset = 
    {
    	["role1"] = {x = 0, y = 23},
    	["role2"] = {x = 0, y = 23},
	}

    self.avatarNode = cc.Node:create()
    self.avatarNode:setCascadeOpacityEnabled(true)
    self.rootNode:addChild(self.avatarNode, 0)
    if roleOffset[name] then
    	self.avatarNode:setPosition(roleOffset[name])
    end

    self:setBody(name)
    self:setCallBack()

    if DEBUG_MODE then
		self:showBlock()
	end
end

function class:dispose()
	self.shader:dispose()
    super.dispose(self)
end

function class:getViewNode()
	return self.rootNode
end

function class:setCallBack()
	if self.component.body then
		self.component.body:setCallback(bind(self.actionCallback, self))
	end
end

function class:actionCallback(...)
	if self.callback then
		self.callback(...)
	end
end

function class:setDir(dir)
	if self.dir == dir then
		return
	end
	
	assert(Define.dir[dir])
	self.dir = Define.dir[dir]

	self:refreshComponent()
end

function class:setBody(name)
	self:setComponentByName(name, "body")
end

function class:setMount(name)
	self:setComponentByName(name, "mount")
end

function class:setWeapon(name)
	self:setComponentByName(name, "weapon")
end

function class:setWing(name)
	self:setComponentByName(name, "wing")
end

function class:setFlip(flip)
	for _, part in pairs(self.component) do
		part:setFlip(flip)
	end
end

function class:play(actionName)
	assert(Define.action[actionName])
	self.actionName = actionName

	self:refreshComponent()
end

function class:stand()
	self:play("idle")
end

function class:run()
	self:play("run")
end

--------------node----------------------
function class:removeFromParent(flag)
	self.rootNode:removeFromParent(flag)
end

function class:runAction(action)
	self.rootNode:runAction(action)
end

function class:stopAction(action)
	self.rootNode:stopAction(action)
end

function class:stopAllActions()
	self.rootNode:stopAllActions()
end

function class:setPosition(pos)
	self.rootNode:setPosition(pos)
end

function class:setNormalizedPosition(pos)
	self.rootNode:setNormalizedPosition(pos)
end

function class:getPosition()
	return self.rootNode:getPosition()
end

function class:setOpacity(value)
	self.rootNode:setOpacity(value)
end

function class:setLocalZOrder(order)
	self.rootNode:setLocalZOrder(order)
end

function class:getLocalZOrder( ... )
	return self.rootNode:getLocalZOrder()
end

function class:setVisible(visible)
	self.rootNode:setVisible(visible)
end

function class:isVisible()
	return self.rootNode:isVisible()
end

----------------compoent private-----------------
function class:setComponentByName(resName, partName)
	local lastName = self.componentName[partName]
	if lastName == resName then
		return
	end

	self.componentName[partName] = resName
	self:removeComponent(partName)
	if nil == resName then
		self:refreshComponent()
		return
	end
	
	local PartClass = PART_CLASS[partName]
	local part = PartClass.class:new(resName)
	self:addComponent(partName, part)
end

function class:removeComponent(partName)
	local part = self.component[partName]
	if nil == part then
		return
	end

	local node = part:getViewNode()
	self.avatarNode:removeChild(node, true)
	self.component[partName] = nil
	part:dispose()
end

function class:addComponent(partName, part)
	local node = part:getViewNode()

	self.avatarNode:addChild(node)
	self.component[partName] = part

	self:refreshComponent()
	self.shader:addComponent(part)
end

function class:mapComponent(call)
	for _, part in pairs(self.component) do
		call(part)
	end
end

function class:refreshComponent()
	local actionName = self.actionName
	local loop = Define.loopAction[actionName]
	actionName = self:getRealAction(actionName)

	local flip = Define.flip[self.dir]
	local dir = self:getImageDir(self.dir)
	for name, part in pairs(self.component) do
		part:playAction(actionName, dir, loop)
		part:setFlip(flip)
	end

	self:refreshPosition()
	self:refreshOrder()
end

function class:refreshPosition()
	local imgDir = self:getImageDir(self.dir)
	local flip = Define.flip[self.dir]

	local function setPos(partName, component)
		if nil == component then
			return
		end

		local map = Define.offset[partName]
		if nil == map then
			return
		end

		local pos = map[imgDir]
		if nil == pos then
			return
		end

		local x = (flip and -1 or 1) * pos.x
		local y = pos.y
		component:setPosition(cc.p(x, y))
	end

	local hasMount = self.component.mount ~= nil
	setPos(hasMount and "mount_body" or "body", self.component.body)
	setPos("mount", self.component.mount)
	setPos("weapon", self.component.weapon)
end

function class:refreshOrder()
	local order = Define.order[self.dir] or Define.order["default"]
	for name, part in pairs(self.component) do
		part:setLocalZOrder(order[name])
	end
end

function class:getRealAction(actionName)
	if nil == self.component.mount then
		return actionName
	end

	local mountAction = Define.mountAction[actionName]
	return mountAction or actionName
end

function class:getImageDir(dir)
	return Define.imageDir[dir]
end

function class:showBlock()
	local node = cc.LayerColor:create(cc.c4b(255, 0, 0, 100))
	node:setContentSize(self.rootNode:getContentSize())
	-- node:setColor(cc.c3b(255, 0, 0))
	-- node:setOpacity(100)
	self.rootNode:addChild(node, 999)
end
--
----------------compoent private-----------------


----------------shader-----------------
--
function class:setShader(name, ...)
	assert(Define.shader[name])
	self.shader:setShader(name, ...)
end









