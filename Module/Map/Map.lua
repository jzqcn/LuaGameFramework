local Data       = require "Map.Data"
local Coordinate = require "Map.Coordinate"
local AStar      = require "Map.AStar"
local Camera     = require "Map.Camera"
local Layers     = require "Map.Layers"

local PreLoad    = require "UI.PreLoad"

module (..., package.seeall)

function preload(self, path)
    Data:preload(path)
end

class = objectlua.Object:subclass()
class:include(Events.ReceiveClass)

function class:initialize(path, viewSize)
    super.initialize(self)
    Events.ReceiveClass.initialize(self)

    viewSize.width = math.floor(viewSize.width)
    viewSize.height = math.floor(viewSize.height)

    self.objects = {}

    self.path = path
    self.data = Data:get(path, self)

    self.rootNode = cc.Node:create()
    self.rootNode:setContentSize(cc.size(self.data.info.w, self.data.info.h))
    self.rootNode:scheduleUpdateWithPriorityLua(bind(self.update, self), 0)

    self.coordinate = Coordinate.class:new(self)
    self.astar = AStar.class:new(self)
    self.camera = Camera.class:new(self, viewSize)
    self.layers = Layers.class:new(self, self.camera, self.data)

    util.timer:repeats(2*60*1000, self:createEvent("recoveryCacheImages"))
end

function class:dispose()
    self:clearObj()
    self.layers:dispose()
    self.camera:dispose()

    Events.ReceiveClass.dispose(self)
    super.dispose(self)
end

function class:getNode()
    return self.rootNode
end

function class:getInfo()
    return self.data.info
end

function class:getInteractiveLayer()
    return self.layers:getInteractiveLayer()
end

function class:getControlLayer()
    return self.layers:getControlLayer()
end

function class:setPos(x, y)
    self.camera:setPos(x, y)
end

function class:getPos()
    return self.camera:getPos()
end


function class:update()
    if self.camera:update() then
        self.layers:viewportChanged(self.camera:getPos())
    end

    self.layers:controlLayerChenged(self.camera:getPos())
end

function class:recoveryCacheImages()
    PreLoad:clearCache()
end

--------------------------
-- TileLayer

function class:isShade(obj)
    local cx, cy = obj:getPosCell()
    local posX, posY = obj:getPos()
    if(self.data.info.shadeListMap) then
        if nil == cy then
            cx, cy = cx.x, cx.y
        end

        local cellIdx = self.coordinate:maskCell2index(cx, cy)
        if (self.data.info.shadeListMap[cellIdx]) then
            if(not self.data.info.shadeLineListMap[cellIdx]) then
                return true
            end 

            local lineIndex = self.data.info.shadeLineListMap[cellIdx]
            local line = self.data.info.shadeLineList[lineIndex]
            local pA = cc.p(posX, posY)
            local pB = cc.p(0, 0)
            local posList = self.coordinate:getIntersectPointList(line, pA, pB)
            if(table.empty(posList) or #posList%2 == 0) then
                return false
            else 
                return true
            end
        else
            return false
        end
    end

    return self.layers:isShade(cx, cy)
end

function class:isBlock(cx, cy)
    if(self.data.info.blockListMap) then
         local cellIdx
        if nil == cy then
            cellIdx = cx
        else
            cellIdx = self.coordinate:maskCell2index(cx, cy)
        end

        return self.data.info.blockListMap[cellIdx]
    end

    return self.layers:isBlock(cx, cy)
end

function class:showCellsByList(list, imgPath)
    return self.layers:showCellsByList(list, imgPath)
end

function class:getCtrlLine(cx, cy, p1, p2)
    return self.coordinate:getCtrlLine(cx, cy, p1, p2)
end

function class:getBlockIntersectPos(cx, cy, p1, p2)
    return self.coordinate:getBlockIntersectPos(cx, cy, p1, p2)
end
--
--------------------------

--------------------------
--AStar
function class:parseAStarPathArg(...)
    local arg = {...}
    local startIdx, endIdx
    if #arg == 4 then
        startIdx = self:maskCell2index(arg[1], arg[2])
        endIdx = self:maskCell2index(arg[3], arg[4])
    elseif #arg == 2 then
        startIdx = arg[1]
        endIdx = arg[2]
    end
    return startIdx, endIdx
end

function class:getPath(...)
    local startIdx, endIdx = self:parseAStarPathArg(...)
    return self.astar:getPath(startIdx, endIdx)
end

function class:getPathEx(...)
    local startIdx, endIdx = self:parseAStarPathArg(...)
    local path = self.astar:getPath(startIdx, endIdx)
    if table.empty(path) then
        return path
    end

    local function _isInLine(idx1, idx2)
        local x1, y1 = self:maskIndex2cell(idx1)
        local x2, y2 = self:maskIndex2cell(idx2)
        if x1 == x2 or y1 == y2 then
            return true, 0
        end

        if math.abs(x1 - x2) == math.abs(y1 - y2) then
            return true, 1
        end
        return false, -1
    end

    local filter = {}
    local lastIdx = startIdx
    for i = 2, #path do
        local preIdx = path[i-1]
        local curIdx = path[i]
        local _, flag1 = _isInLine(curIdx, preIdx)
        local isLine, flag2 = _isInLine(curIdx, lastIdx)

        if not isLine or flag1 ~= flag2 then
            table.insert(filter, preIdx)
            lastIdx = preIdx
        end
    end

    table.insert(filter, path[#path])
    return filter
end
--
--------------------------


--------------------------
-- camera
function class:getCamera()
    return self.camera
end

function class:setFollowObj(obj)
    self.camera:setFollowObj(obj)
end
--
--------------------------


--------------------------
--coordinate
--tileMap
function class:getCoordinate()
    return self.coordinate
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

--MaskMap
function class:getCellAround(cx, cy)
    return self.coordinate:getCellAround(cx, cy)
end

function class:maskCell2world(cx, cy)
    return self.coordinate:maskCell2world(cx, cy)
end

function class:maskWorld2cell(x, y)
    return self.coordinate:maskWorld2cell(x, y)
end

function class:maskCell2index(cx, cy)
    return self.coordinate:maskCell2index(cx, cy)
end

function class:maskIndex2cell(index)
    return self.coordinate:maskIndex2cell(index)
end

function class:getBlockCellList(bPosx, bPosy, cellx1, celly1, cellx2, celly2, ePosx, ePosy)
    return self.coordinate:getBlockCellList(bPosx, bPosy, cellx1, celly1, cellx2, celly2, ePosx, ePosy)
end
--
--------------------------




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
        obj:createAvatar(modelname)
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
    for _, obj in pairs(self.objects) do
        local isInShade = self:isShade(obj)
        obj:setOpacity(isInShade and 100 or 255)
    end
end
--
--------------------------


