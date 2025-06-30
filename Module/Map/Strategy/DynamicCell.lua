local AlgoCell = require "Map.Algorithm.AlgoCell"

module(..., package.seeall)

class = objectlua.Object:subclass()
class:include(Events.ReceiveClass)

function class:initialize(map, node, camera, creator, collector)
    super.initialize(self)
    Events.ReceiveClass.initialize(self)

    self.map = map
    self.algorithm = AlgoCell.class:new(map, camera:getViewSize())

    self.creator = creator
    self.collector = collector
    self.pos = { x = math.huge, y = math.huge, }
    self.cells = {}

    self.node = cc.Node:create()
    self.node:setContentSize(node:getContentSize())
    node:addChild(self.node)

    self.creatorTask = {}
    self.creatorTaskMap = {}
end

function class:dispose()
    Events.ReceiveClass.dispose(self)
    super.dispose(self)
end

function class:update(x, y)
    self.algorithm:update(x, y)

    local indices = self.algorithm:getCells()
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
            if not self.creatorTaskMap[index] then
                table.insert(self.creatorTask, index)
                self.creatorTaskMap[index] = 1
            end
        end
    end

   self:dealCreateTask()
end

function class:dealCreateTask()
    if self:existEvent("createTask") then
        return
    end

    local afterEvent = self:createEvent("createTask", 
        function ()
            for i = 1, 5 do 
                if #self.creatorTask == 0 then
                    return
                end

                local index = table.remove(self.creatorTask, 1)
                self.creatorTaskMap[index] = nil
                local node = self.creator(index)
                if node ~= nil then
                    local cellx, celly = self.map:index2cell(index)

                    node:setPosition(self.map:cell2world(cellx, celly))
                    self.node:addChild(node)
                    self.cells[index] = node
                end
            end

            self:dealCreateTask()
        end)

    util.timer:after(0, afterEvent)
end
