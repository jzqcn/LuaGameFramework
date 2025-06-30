module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(viewSize, tileSize, node, creator)
    self.viewSize = viewSize
    self.tileSize = tileSize

    local tiles = self:createTiles(creator)
    self.offset = tiles.offset
    self.node = tiles.node
    node:addChild(self.node)
end

function class:getNode()
    return self.node
end

function class:update(x, y)
    x = self.offset.x + x
    y = self.offset.y + y

    local cx, cy = self.node:getPosition()
    local size = self.viewSize
    if math.abs(cx - x) < self.tileSize.w and math.abs(cy - y) < self.tileSize.h then
        return
    end

    local ox = (cx - x) % self.tileSize.w
    local oy = (cy - y) % self.tileSize.h
    self.node:setPosition(x + ox, y + oy)
end

function class:createTiles(creator)
    local offset =
    {
        x = self.viewSize.width  / 2,
        y = self.viewSize.height / 2,
    }

    local cw = math.ceil(self.viewSize.width / self.tileSize.w) + 3
    local ch = math.ceil(self.viewSize.height / self.tileSize.h) + 3
    local ox, oy = -self.tileSize.w * cw / 2, -self.tileSize.h * ch / 2

    local node = cc.Node:create()
    for i = 1, cw do
        for j = 1, ch do
            local tile = creator()
            local x = ox + self.tileSize.w * (i - 0.5)
            local y = oy + self.tileSize.h * (j - 0.5)
            tile:setPosition(x, y)
            node:addChild(tile)
        end
    end

    return { offset = offset, node = node, }
end
