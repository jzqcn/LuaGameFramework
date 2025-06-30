local Layer   = require "Map.Layer"
local DynamicModel = require "Map.Strategy.DynamicModel"
local Pool    = require "Pool"
local Define = require "Map.Define"
module(..., package.seeall)


class = Layer.class:subclass()

function class:initialize(map, camera, data)
    super.initialize(self, map, camera, data)
    self.layerName = "ControlMapLayer"
    self.showAllBlocks = false

    self.objects = {}  
    self.jumpPoint = {}
    self.player = nil;
    self.data.controlModel = {}

    local viewSize = camera:getViewSize()
    data.blockSize = { w = math.ceil(viewSize.width / 3), h = math.ceil(viewSize.height / 3)}
    data.blockExtend = {w = 1, h = 1}
    data.preloadExtend = {w = 3, h = 3}

    local mapInfo = map:getInfo()
    data.blockNum = {w = math.ceil(mapInfo.w / data.blockSize.w), h = math.ceil(mapInfo.h / data.blockSize.h)}
end

function class:dispose()
    self:clearObj()
    --self.pool:dispose()
    super.dispose(self)
end

function class:viewportChanged(x, y)
    self.strategy:update(x, y)
    self:updateMapObj()
    self:updatePlayer()
end

--更新地图元素
--静态模型
function class:addMapModel(id, modelInfo)
    self.data.models[id] = modelInfo
end

function class:delMapModel(id)
    self.strategy:delModle(id)
    self.data.models[id] = nil
end

function class:setPlayer(role)
    self.player = role
    self.strategy:addPlayer(role)
end

function class:startCreate()
    self.strategy = DynamicModel.class:new(self.map, self.node, self.camera, self.data, function(index, parent)
        local item = self.data.models[index]
        if item == nil then
            return nil
        end

        if item.type == Define.MAP_STATIC_MODEL.ITEM then           
            return self:addMapItem(index, item, parent)
        elseif item.type == Define.MAP_STATIC_MODEL.ROLE then
            return self:addMapNpcRole(index, item, parent)
        end
    end, --end creator
    function(index, node)
        local item = self.data.models[index]
        if item == nil then 
            return 
        end

        if item.type == Define.MAP_STATIC_MODEL.ITEM then
            node:removeFromParent(true)
            return
        elseif item.type == Define.MAP_STATIC_MODEL.ROLE then
            self:deleteObj(index)
        end
    end )-- end delelte
end

--地图元素
function class:addMapItem(index, item, parent)
    local imgPath, effectPath = item:getImgPath()
    local node = cc.Node:create()
    node:setScaleX(item.info.scaleX or 1)
    node:setScaleY(item.info.scaleY or 1)
    node:setRotation(item.info.rotation or 0)

    node:setPosition(cc.p(item.info.x, item.info.y))
    node:setTag(item.info.childTag or -1)

    local sprite = cc.Sprite:create(imgPath)
    sprite:setOpacity(item.info.alpha or 255)
    sprite:setAnchorPoint(cc.p(item.info.anchorX, item.info.anchorY))
    node:addChild(sprite, 2)

    --地图跳转节点
    if item.info.jumpMapName ~= "" then
        local pointInfo = {}
        pointInfo.type = "warp"
        pointInfo.jumpName = item.info.jumpMapName
        pointInfo.x = item.info.x
        pointInfo.y = item.info.y 
        pointInfo.w = 128
        pointInfo.h = 64
        pointInfo.node = node
        self.jumpPoint[index] = pointInfo
    end

    --特效
    if nil ~= effectPath then
        local order = item.info.effectUpImg and 3 or 1
        local eff = UI.EffectLoader:loadAndRun(effectPath, nil, nil, true)
        if nil == eff then
            log4map:w(eff, "effect not exist:" .. effectPath)
        else
            node:addChild(eff, order)
            eff:setPosition(cc.p(item.info.effectPosX, item.info.effectPosY))
        end
    end

    parent:addChild(node)
    return node
end

--地图npc
function class:addMapNpcRole(index ,item, parent)
    local modelName, mount, wing, weapon = item:getItemNpcName()
    local role = self:createObj("npc", modelName, index, parent)
    role:setDir(item.dir)
    role:setWeapon(weapon)
    role:setWing(wing)
    role:setMount(mount)
    local pos = item:getNpcPosition()
    role:setPos(cc.p(pos.x, pos.y))

    local effectPath = item:getEffPath()
    if nil ~= effectPath then
        local order = item.info.effectUpImg and 1 or 3
        role:addNpcEff(effectPath, item.info.effectPosX, item.info.effectPosY, order)
    end

    return role:getAvatar():getViewNode()
end

--地图玩家角色
function class:addMapRole(roleInfo)
    local role = self:createObj("hero", roleInfo.modelName, roleInfo.id, self.strategy:getParentNode())

    self.data.controlModel[roleInfo.id] = {type = Define.MAP_CONTROL_MODEL.ROLE, node = role}
    self.strategy:addControlModel(roleInfo.id, role:getAvatar():getViewNode())

    return role
end

function class:delMapRole(id)
    self:deleteObj(id)
    self.data.controlModel[id] = nil
    self.strategy:delControlModel(id)
end

--地图掉落
function class:addMapDropItem(id, node)
    self.strategy:getParentNode():addChild(node)

    self.data.controlModel[id] = {type = Define.MAP_CONTROL_MODEL.DROP_ITEM, node = node}
    self.strategy:addControlModel(id, node)
end

function class:delMapDropItem(id)
    if not self.data.controlModel[id] then
        return 
    end

    self.data.controlModel[id].node:removeFromParent(true)
    self.data.controlModel[id] = nil
    self.strategy:delControlModel(id)
end

--技能特效
function class:addMapEffect(id, node)
    self.strategy:getParentNode():addChild(node)

    self.data.controlModel[id] = {type = Define.MAP_CONTROL_MODEL.EFFECT, node = node}
    self.strategy:addControlModel(id, node)
end

function class:delMapEffect(id)
    if not self.data.controlModel[id] then
        return 
    end

    self.data.controlModel[id].node:removeFromParent(true)
    self.data.controlModel[id] = nil
    self.strategy:delControlModel(id)
end


--------------------------
--map object
local _objIdx = 1000
local function getObjIdx()
    _objIdx = _objIdx + 1
    return _objIdx
end

local _mapObjType =
{
    ["player"]    = {obj = "Role.Player",   type = Define.ROLE_TYPE.PLAYER},
    ["pet"]       = {obj = "Role.Pet",      type = Define.ROLE_TYPE.PET},
    ["monster"]   = {obj = "Role.Monster",  type = Define.ROLE_TYPE.MONSTER},
    ["hero"]      = {obj = "Role.Hero",     type = Define.ROLE_TYPE.HERO},
    ["npc"]       = {obj = "Role.Npc",      type = Define.ROLE_TYPE.NPC},
}



function class:createObj(typename, modelname, index, parent)
    local objTypes = _mapObjType[typename].obj
    local roleTypes = _mapObjType[typename].type
    assert(objTypes, "wrong object type:" .. typename)

    local id = index or getObjIdx()
    local obj = require(objTypes).class:new(id, self.map, roleTypes)
    obj:setParentNode(self)
    self.objects[id] = obj

    if modelname then
        parent = parent or self.strategy:getParentNode()
        obj:createAvatar(modelname, parent)
    end
    return obj
end

function class:getObj(id)
    return self.objects[id]
end

function class:deleteObj(id)
    local obj = self.objects[id]
    assert(obj, "id not exist:" .. id)
    obj:removeSelf()
    self.objects[id] = nil

    local followObj = self.camera:getFollowObj()
    if followObj and followObj:getId() == id then
        self.camera:setFollowObj(nil)
    end
end

function class:clearObj()
    for _, obj in pairs(self.objects) do
        obj:removeSelf()
    end
    self.objects = {}

    self.camera:setFollowObj(nil)
end


function class:updateMapObj()
    -- for _, obj in pairs(self.objects) do
    --     local isInShade = self.map:isShade(obj)
    --     obj:setOpacity(isInShade and 100 or 255)
    -- end
end

function class:updatePlayer()
    if not self.player then 
        return 
    end 

    local posx, posy = self.player:getPosition()
    for _, pointInfo in pairs(self.jumpPoint) do
        if posx > pointInfo.x - pointInfo.w/2 and posx < pointInfo.x + pointInfo.w/2 
            and posy > pointInfo.y - pointInfo.h/2 and posy< pointInfo.y + pointInfo.h/2 then

      --      log4temp:debug(pointInfo)
        end

    end
end