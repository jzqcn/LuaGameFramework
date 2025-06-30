local Data       = require "TileMap.Data"
local Coordinate = require "TileMap.Coordinate"
local Camera     = require "TileMap.Camera"
local Layers     = require "TileMap.Layers"

module (..., package.seeall)

function preload(self, path)
    Data:preload(path)
end

class = objectlua.Object:subclass()

function class:initialize(path, viewSize)
    super.initialize(self)
    self.objects = {}

    self.path = path
    self.data = Data:get(path)

    self.rootNode = cc.Node:create()
    self.rootNode:setContentSize(cc.size(self.data.info.w, self.data.info.h))
    self.rootNode:scheduleUpdateWithPriorityLua(bind(self.update, self), 0)

    self.coordinate = Coordinate.class:new(self.data.info)
    self.camera = Camera.class:new(self, viewSize)
    self.layers = Layers.class:new(self, self.camera, self.data)
end

function class:dispose()
    self:clearObj()
    self.layers:dispose()
    self.camera:dispose()
    super.dispose(self)
end

function class:getNode()
    return self.rootNode
end

function class:getInteractiveLayer()
    return self.layers:getInteractiveLayer()
end

function class:getCamera()
    return self.camera
end

function class:setPos(x, y)
    self.camera:setPos(x, y)
end

function class:getPos()
    return self.camera:getPos()
end

function class:setFollowObj(obj)
    self.camera:setFollowObj(obj)
end

function class:update()
    if self.camera:update() then
        self.layers:viewportChanged(self.camera:getPos())
    end
end

function class:getInfo()
    return self.data.info
end

function class:isBlocked(cellx, celly)
    return self.layers:isBlocked(cellx, celly)
end

function class:cell2world(cx, cy)
    return self.coordinate:cell2world(cx, cy)
end

function class:world2cell(x, y)
    return self.coordinate:world2cell(x, y)
end

function class:cell2index(cx, cy)
    return self.coordinate:cell2index(cx, cy)
end

function class:index2cell(index)
    return self.coordinate:index2cell(index)
end


--------------------------
--map object
local _objIdx = 100
local function getObjIdx()
    _objIdx = _objIdx + 1
    return _objIdx
end

local _mapObjType =
{
    ["player"]    = "Role.Player",
    ["pet"]       = "Role.Pet",
    ["monster"]   = "Role.Monster",
    ["hero"]      = "Role.Hero",
}

function class:createObj(typename, modelname)
    local types = _mapObjType[typename]
    assert(types, "wrong object type:" .. typename)

    local id = getObjIdx()
    local obj = require(types).class:new(id, self)
    self.objects[id] = obj

    if modelname then
        local layer = self:getInteractiveLayer()
        local parent = layer:getRootNode()
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
--
--------------------------
