local AlgoBlock = require "Map.Algorithm.AlgoBlock"

module(..., package.seeall)

class = objectlua.Object:subclass()
class:include(Events.ReceiveClass)

function class:initialize(map, node, camera, data, creator)
    super.initialize(self)
    Events.ReceiveClass.initialize(self)
    
    self.map = map

    self.creator = creator
    self.viewSize = camera:getViewSize()
    self.algorithm = AlgoBlock.class:new(map, camera:getViewSize(), data)

    self.node = cc.Node:create()
    self.node:setContentSize(node:getContentSize())
    node:addChild(self.node)

    self.items = {}

    self.bInitObj = false
    self.creatorTask = {}
    self.creatorTaskMap = {}
end

function class:dispose()
    Events.ReceiveClass.dispose(self)
    super.dispose(self)
end

function class:update(x, y)
    self.algorithm:update(x, y)

    local indices = self.algorithm:getItems()
    if table.empty(indices) then
        return
    end

    self:updateItems(indices)
end

--  private  --
function class:updateItems(indices)
    local items = self.items

    local invertTb = table.invert(indices)
    for index, node in pairs(items) do
        if invertTb[index] == nil then
            node:removeFromParent(true)
            items[index] = nil
        end
    end

    for _, index in ipairs(indices) do
        if items[index] == nil then
            if self.bInitObj then
                if not self.creatorTaskMap[index] then 
                    table.insert(self.creatorTask, index)
                    self.creatorTaskMap[index] = 1
                end
            else
                local node = self.creator(index)
                if node ~= nil then
                    self.node:addChild(node)
                    items[index] = node
                end
            end
        end
    end

    if self.bInitObj then
        self:dealCreateTask()
    end
    self.bInitObj = true
end

function class:dealCreateTask()
    if self:existEvent("createTask") then
        return
    end

    
    local afterEvent = self:createEvent("createTask", 
        function ()
            if #self.creatorTask == 0 then
                return
            end

            local index = table.remove(self.creatorTask, 1)
            self.creatorTaskMap[index] = nil
            local node = self.creator(index)
            if node ~= nil then
                self.node:addChild(node)
                self.items[index] = node
            end

            self:dealCreateTask()
        end)

    util.timer:after(0, afterEvent)
end


