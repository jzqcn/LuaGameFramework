module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(map, node, dynamicCells, creator, collector)
    self.map = map
    self.dynamicCells = dynamicCells

    self.creator = creator
    self.collector = collector
    self.pos = { x = math.huge, y = math.huge, }
    self.cells = {}

    self.node = cc.Node:create()
    self.node:setContentSize(node:getContentSize())
    node:addChild(self.node)
end

function class:dispose()
    super.dispose(self)
end

function class:update(x, y)
    local indices = self.dynamicCells:getCells()
    if table.empty(indices) then
        return
    end

    self:updateTiles(indices)
end

--  private  --

function class:updateTiles(indices)
    local cells = self.cells

    for index, node in pairs(cells) do
        if indices[index] == nil then
            if self.collector ~= nil then
                self.collector(node, index)
            end
            node:removeFromParent(true)
            cells[index] = nil
        end
    end

    for index in pairs(indices) do
        if cells[index] == nil then
            local node = self.creator(index)
            if node ~= nil then
                node:setPosition(self.map:cell2world(self.map:index2cell(index)))
                self.node:addChild(node)
                cells[index] = node
            end
        end
    end
end
