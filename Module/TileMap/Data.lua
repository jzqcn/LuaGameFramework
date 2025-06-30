local Coordinate = require "TileMap.Coordinate"

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
    return preloads[path] or class:new(path):getResult()
end

class = objectlua.Object:subclass()

function class:initialize(path)
    self.data = self:read(path)
    if self.data == nil then
        error(string.format("failed to load map file <%s>", path))
    end

    self.cells = {}
    self.info = self:getInfo()
    self.coordinate = Coordinate.class:new(self.info)

    self:loadTilesets()
    self:loadLayers()

    preloads[path] = self:getResult()
end

function class:getResult()
    return 
    {
        info    = self.info,
        layers  = self.layers,
        cells   = self.cells,
        islands = self.islands,
        water   = self.data.ocean,
    }
end

--  private  --
function class:read(path)
    if string.match(path, ".json") then
        local data = util:openFile(path)
        if nil == data or #data == 0 then
            return nil
        end

        local info = json.decode(data)
        return info
    elseif string.match(path, ".lua") then 
        --没走package  用时15ms
        -- local status, info = pcall(loadfile(path)) 
        -- assert(status) 

        --用时2ms  
        local data = util:openFile(path)
        if nil == data or #data == 0 then
            return nil
        end
        
        --用时15ms  
        local status, info = pcall(loadstring(data))
        assert(status) 
        return info
    else
        assert("wrong map file:" .. path)
    end
end

function class:getInfo()
    local info =
    {
        rows = self.data.height,
        cols = self.data.width,
        ox = self.data.tilewidth * self.data.width / 2,
        oy = self.data.tileheight / 2,
        cw = self.data.tilewidth,
        ch = self.data.tileheight,
        w = self.data.width * self.data.tilewidth,
        h = self.data.height * self.data.tileheight,
    }
    return info
end

function class:getTile(tileset, index, x, y)
    local blocked = nil
    local property = tileset.tileproperties[tostring(index)]
    if property ~= nil and property.block == "1" then
        blocked = true
    end

    local rect = cc.rect(tileset.tilewidth * x,
                         tileset.tileheight * y,
                         tileset.tilewidth,
                         tileset.tileheight)

    local tile = {}
    tile.image   = tileset.image
    tile.rect    = rect
    tile.blocked = blocked
    return tile
end

function class:loadTilesets()
    local tilesets = { offsets = {}, tiles = {}, }

    for _, tileset in ipairs(self.data.tilesets) do
        tileset.tileproperties = tileset.tileproperties or {}

        local offsets = {}
        tilesets.offsets[tileset.firstgid] = offsets

        local cols = tileset.imagewidth  / tileset.tilewidth
        local rows = tileset.imageheight / tileset.tileheight
        local ox = -math.floor(cols / 2)
        local oy = -math.floor(rows / 2)

        for i = 0, rows - 1 do
            for j = 0, cols - 1 do
                local index = cols * i + j
                local id = tileset.firstgid + index
                tilesets.tiles[id] = self:getTile(tileset, index, j, i)
                offsets[index] = { x = ox + j, y = oy + i, }
            end
        end
    end

    self.tilesets = tilesets
end

function class:refCell(x, y)
    local index = self.coordinate:cell2index(x, y)
    local cell = self.cells[index]
    if cell == nil then
        cell = {}
        self.cells[index] = cell
    end
    return cell
end

function class:loadLayers()
    self.layers = {}

    for _, layer in ipairs(self.data.layers) do
        local typeId, data = layer["type"], layer["data"]

        if typeId == "ScrollLayer" and data == "Map/MapBg" then
            table.insert(self.layers, "Water")
        end

        if typeId == "ScrollLayer" and data == "Map/MapWater" then
            table.insert(self.layers, "Wave")
        end

        if typeId == "TmxTileLayer" then
            table.insert(self.layers, "Depth")
            self:loadDepthData(layer)
        end

        if typeId == "TmxImgLayer" then
            table.insert(self.layers, "Island")
            self:loadIslandData(layer)
        end
    end

    table.insert(self.layers, "Border")
end

function class:loadDepthData(layer)
    for id, arr in pairs(layer.data.gids) do
        local tile = self.tilesets.tiles[tonumber(id)]
        for _, pos in ipairs(arr) do
            local x, y = self.coordinate:world2cell(unpack(pos))
            local cell = self:refCell(x, y)
            cell.depth = tile
        end
    end
end

function class:loadIslandData(layer)
    local islands = {}

    for i, item in ipairs(layer.data.imgs) do
        for _, pos in ipairs(layer.data.pos[i]) do
            local x, y = self.coordinate:world2cell(unpack(pos))
            local cell = self:refCell(x, y)
            cell.island = item

            for index, offset in pairs(self.tilesets.offsets[item.firstgid]) do
                local tile = self.tilesets.tiles[item.firstgid + index]
                local cx = x + offset.x
                local cy = y + offset.y
                local cell = self:refCell(cx, cy)
                cell.blocked = tile.blocked

                table.insert(islands, {x = cx, y = cy})
            end
        end
    end

    self:islandsAreaClassify(islands)
end

function class:islandsAreaClassify( islands )
    self.islands = {}

    for _, v in pairs(islands or {}) do
        local i = math.ceil(v.x / 10)   
        if not self.islands[i] then
            self.islands[i] = {} 
        end

        local j = math.ceil(v.y / 10)
        if not self.islands[i][j] then
            self.islands[i][j] = {}
        end

        table.insert(self.islands[i][j], v)
    end
end
