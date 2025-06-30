local AlgoModel = require "Map.Algorithm.AlgoModel"

module(..., package.seeall)

class = objectlua.Object:subclass()
class:include(Events.ReceiveClass)

function class:initialize(map, node, camera, data, creator, delelteModel)
    super.initialize(self)
    Events.ReceiveClass.initialize(self)
    
    self.map = map

    self.creator = creator
    self.delelteModel = delelteModel
    self.viewSize = camera:getViewSize()
    self.algorithm = AlgoModel.class:new(map, camera:getViewSize(), data)

    self.node = cc.Node:create()
    self.node:setContentSize(node:getContentSize())
    node:addChild(self.node)

    self.models = {}
    self.controlModels = {}
    self.player = nil

    self.creatorTask = {}
    self.creatorTaskMap = {}
end

function class:dispose()
    Events.ReceiveClass.dispose(self)
    super.dispose(self)
end

function class:addPlayer(node)
    self.player = node
end

function class:getParentNode()
    return self.node
end

function class:delModle(id)
    if self.models and self.models[id] then
        self.delelteModel(id, self.models[id])
        self.models[id] = nil
    end
end

function class:addControlModel(id, node)
   if self.controlModels and not self.controlModels[id] then
        self.controlModels[id]  = node 
    end
end

function class:delControlModel(id)
    if self.controlModels and self.controlModels[id] then
        self.controlModels[id]  = nil 
    end   
end

--------------------------------------
function class:update(x, y)
    self.algorithm:update(x, y)

    self.sortTb = {}
    local indices = self.algorithm:getItems()
    if not table.empty(indices) then
        self:updateItems(indices)
    end

    local controlIndices = self.algorithm:getControls()
    if not table.empty(controlIndices) then
        self:udpateControlModels(controlIndices)
    end

    self:sortElement()
end

--  private  --
function class:updateItems(indices)
    local models = self.models

    local invertTb = table.invert(indices)
    for index, node in pairs(models) do
        if invertTb[index] == nil then
            self.delelteModel(index, node)
            models[index] = nil
        end
    end

    for _, index in ipairs(indices) do
        if models[index] == nil then
            if not self.creatorTaskMap[index] then
                table.insert(self.creatorTask, index)
                self.creatorTaskMap[index] = 1
            end
        else 
            local node = models[index]
            table.insert(self.sortTb, node)
        end
    end

    self.models = models
    self:dealCreateTask()
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
            local node = self.creator(index, self.node)
            if node ~= nil then
                self.models[index] = node
            end

            self:dealCreateTask()
        end)

    util.timer:after(0, afterEvent)
end


function class:udpateControlModels(controlIndices)
    for _, id in pairs(controlIndices) do
        if self.controlModels[id] then
            table.insert(self.sortTb, self.controlModels[id])
        end 
    end
end

function class:sortElement()
    if table.empty(self.sortTb) then
        return
    end

    table.insert(self.sortTb, self.player)

    table.sort(self.sortTb, function (a, b)
        return a:getPositionY() > b:getPositionY()
    end)

    local order  = 1

    for _, node in ipairs(self.sortTb) do
        node:setLocalZOrder(order)
        order = order + 3
    end
end



