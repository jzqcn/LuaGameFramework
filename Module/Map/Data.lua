local Define = require "Map.Define"
local AvatarDefine = require"Avatar.Define"

module (..., package.seeall)

local class
local preloads = {}

function preload(self, path)
    if preloads[path] then
        return
    end
    preloads[path] = class:new(path):getResult()
end

function get(self, path)
    if not preloads[path] then
        preloads[path] = class:new(path):getResult()
    end

    return preloads[path]
end

class = objectlua.Object:subclass()

function class:initialize(path)
    super.initialize(self)

    local data = self:read(path)
    if data == nil then
        error(string.format("failed to load map file:%s", path))
    end

    self.result = {}
    self.result.info = self:getMapInfo(data)
    self.result.layers = self:loadLayers(data)
end

function class:getResult()
    return self.result
end

--  private  --
function class:read(path)
    local prePath = Define.MAP_FILE_PRE_PATH
    if not string.match(path, prePath) then
        path = prePath .. path
    end
    path = path .. ".lua"

    local data = util:openFile(path)
    if nil == data or #data == 0 then
        return nil
    end
    
    local status, info = pcall(loadstring(data))
    assert(status) 
    return info
end

function class:getMapInfo(data)
    local mapInfo = data.mapInfo

    local info =
    {
        rows = mapInfo.tileNum,
        cols = mapInfo.tileNum,
        ox = mapInfo.tileWidth * mapInfo.tileNum / 2,
        oy = mapInfo.tileHeight / 2,
        cw = mapInfo.tileWidth,
        ch = mapInfo.tileHeight,
        mRows = (mapInfo.maskTileNum or mapInfo.tileNum),
        mCols = (mapInfo.maskTileNum or mapInfo.tileNum),
        mOx = (mapInfo.maskTileWidth or mapInfo.tileWidth) * (mapInfo.maskTileNum or mapInfo.tileNum) / 2,
        mOy = (mapInfo.maskTileHeight or mapInfo.tileHeight) / 2,
        mw = (mapInfo.maskTileWidth or mapInfo.tileWidth),
        mh = (mapInfo.maskTileHeight or mapInfo.tileHeight),
        w = mapInfo.tileNum * mapInfo.tileWidth,
        h = mapInfo.tileNum * mapInfo.tileHeight,
        vx = mapInfo.viewOrgX or 0,
        vy = mapInfo.viewOrgY or 0,
        vw = mapInfo.viewWidth or mapInfo.tileNum * mapInfo.tileWidth,
        vh = mapInfo.viewHeight or mapInfo.tileNum * mapInfo.tileHeight,
    }

    local maskInfo = mapInfo.maskInfo
    if (maskInfo) then
        info.blockList = maskInfo.blockList
        info.blockListMap = table.invert(maskInfo.blockList)
        info.shadeList = maskInfo.shadeList
        info.shadeListMap = table.invert(maskInfo.shadeList)
        info.partBlockList = maskInfo.partBlockList
        info.partBlockListMap = table.invert(maskInfo.partBlockList)
    end
    --控制线
    local lineInfo = mapInfo.lineInfoList
    if(lineInfo) then
        info.blockLineList = lineInfo.blockLineList or {}
        info.blockLineListMap = self:getLineMap(lineInfo.blockReferList or {})
        info.shadeLineList = lineInfo.maskLineList or {}
        info.shadeLineListMap = self:getLineMap(lineInfo.maskReferList or {})
    end
    return info
end

function class:getLineMap(list)
    local map = {}
    for lineNum, cellList in pairs(list) do 
        for _, cell in pairs(cellList) do 
            map[cell] = lineNum
        end
    end

    return map
end

function class:loadLayers(data)
    local layers = {}
    for _, info in ipairs(data.layers) do
        if info.type == "TileMapLayer" then
            local tile = self:loadTileMapLayer(info)
            table.insert(layers, tile)
            
        elseif info.type == "ObjectMapLayer" then
            table.insert(layers, self:loadObjectMapLayer(info))

        elseif info.type == "BgMapLayer" then
            table.insert(layers, self:loadBgMapLayer(info))

        elseif info.type == "FarMapLayer" then
            table.insert(layers, self:loadFarMapLayer(info))

        elseif info.type == "CloseMapLayer" then
            table.insert(layers, self:loadCloseMapLayer(info))

        elseif info.type == "ControlMapLayer" then 
            table.insert(layers, self:loadControlMapLayer(info))
        else
            assert(false)
        end
    end
    return layers
end


local function _getCellImgPath(cell)
    local imgPath = Define.MAP_IMAGE_PRE_PATH .. cell.imageList[cell.imgIdx].name
    return imgPath
end

function class:loadTileMapLayer(data)
    local cells = {}
    for idx, imgPath in ipairs(data.imageList) do 
        for _, cellIdx in ipairs(data.data[idx]) do
            local cell = {}
            cell.imgIdx = idx
            cell.imageList = data.imageList
            cell.getImgPath = _getCellImgPath
            cells[cellIdx] = cell
        end
    end

    local layer = {}
    layer.type = data.type
    layer.cells = cells
    layer.moveSpeed = data.moveSpeed
    return layer
end

local function _getItemImgPath(layer, item)
    local imgInfo = layer.imageList[item.info.imageIndex + 1]
    if nil == imgInfo then
        log4map:w("getImagePath failed:" .. item.info.imageIndex .. " " .. tostring(layer.imageList))
        return nil
    end

    local imgPath = Define.MAP_IMAGE_PRE_PATH .. imgInfo.name

    local effPath
    if item.info.effectIndex then
        local effInfo = layer.effectList[item.info.effectIndex + 1] 
        effPath = effInfo.name
    end
    return imgPath, effPath
end

local function _getEffPath(layer, item)
    local effPath
    if item.info.effectIndex then
        local effInfo = layer.effectList[item.info.effectIndex + 1] 
        effPath = effInfo.name
    end
    return effPath
end

--存储的值 以中心为基准
local function _getItemImgPosition(layer, item)
    local imgInfo = layer.imageList[item.info.imageIndex + 1]
    assert(imgInfo, "wrong index:" .. item.info.imageIndex)

    local size = {width = imgInfo.size[1], height = imgInfo.size[2]}
    local pos = {x = item.info.x, y = item.info.y}
    return pos, size
end

function class:loadObjectMapLayer(data)
    local layer = {}
    layer.type = data.type
    layer.imageList = data.imageList
    layer.effectList = data.effectList
    layer.moveSpeed = data.moveSpeed

    local funcGetImgPath = bind(_getItemImgPath, layer)
    local funcGetItemImgPos = bind(_getItemImgPosition, layer)

    local items = {}
    for idx, itemInfo in ipairs(data.data) do
        local item = {}
        item.idx = idx
        item.info = itemInfo
        item.getImgPath = funcGetImgPath
        item.getImgPosition = funcGetItemImgPos

        table.insert(items, item)
    end

    layer.items = items
    return layer 
end

function class:loadBgMapLayer(data)
    return self:loadObjectMapLayer(data)
end

function class:loadFarMapLayer(data)
    return self:loadObjectMapLayer(data)
end

function class:loadCloseMapLayer(data)
    return self:loadObjectMapLayer(data)
end

local function _getItemNpcName(layer, role)
    local npcInfo = layer.npcList[role.info.npcIndex + 1]
    if nil == npcInfo then
        log4map:w("_getItemNpcName failed:" .. role.info.npcIndex .. " " .. tostring(layer.npcList))
        return nil
    end
    local npcName = npcInfo.name

    local mount = role.info.mount
    local wing = role.info.wing
    local weapon = role.info.weapon
    return npcName, mount, wing, weapon
end

local function _getNpcPosition(layer, role)
    local pos = {x = role.info.x, y = role.info.y}
    return pos
end

function class:loadControlMapLayer(data)
    local layer = {}
    layer.type = data.type
    layer.imageList = data.imageList
    layer.effectList = data.effectList
    layer.moveSpeed = data.moveSpeed
    layer.npcList = data.npcList

    local funcGetImgPath = bind(_getItemImgPath, layer)
    local funcGetItemImgPos = bind(_getItemImgPosition, layer) 
    local funcGetEffPath = bind(_getEffPath, layer)

    local models = {}
    for idx, itemInfo in ipairs(data.data) do
        local item = {}
        item.type = Define.MAP_STATIC_MODEL.ITEM
        item.info = itemInfo
        item.getImgPath = funcGetImgPath
        item.getImgPosition = funcGetItemImgPos
        table.insert(models, item)
    end

    local funcGetNpcName = bind(_getItemNpcName, layer)
    local funcGetNpcPos  = bind(_getNpcPosition, layer)

    local roles = {}
    for idx, roleInfo in ipairs(data.npcInfoList) do 
        local role = {}
        role.type = Define.MAP_STATIC_MODEL.ROLE
        role.info = roleInfo
        role.getEffPath = funcGetEffPath
        role.getItemNpcName = funcGetNpcName
        role.getNpcPosition = funcGetNpcPos
        role.dir = AvatarDefine.numToDir[roleInfo.dir + 1]
        table.insert(models, role)
    end

    layer.models = models 
    return layer 
end