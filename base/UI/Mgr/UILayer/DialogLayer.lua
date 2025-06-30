local UIStack = require "UI.Mgr.UILayer.UIStack"

module(..., package.seeall)

--层级图
-- dialoglayer = 
-- {
--     {dialog = {
--         {dialogprompt}
--         {dialogprompt}
--         {dialogprompt}
--         }},
--     {dialog = {}},
--     {dialog = {}},
-- }

class = objectlua.Object:subclass()

function class:initialize(layerMgr)
    super.initialize(self)

    self.layerMgr = layerMgr
    self.mapNameStack = {}
    self.treeDialog = {}   --dialog层级树
    self.stackDialog = UIStack:new(bind(self.checkDialog, self))
    self.parentMap = {}  --子dialogprompt映射到父dialog
end

function class:dispose()
    super.dispose(self)
end

function class:getLayer(name)
    return self.mapNameStack[name]
end

function class:addDialog(name, layer)
    self.mapNameStack[name] = layer

    self.stackDialog:add(name)
    self.treeDialog[name] = UIStack:new(bind(self.checkDialogPrompt, self))
end

function class:addDialogPrompt(name, layer)
    self.mapNameStack[name] = layer

    --加载到最近的dialog上
    local topDialogName = self.stackDialog:top()
    local stack = self.treeDialog[topDialogName]
    stack:add(name)

    self.parentMap[name] = topDialogName
end

function class:delDialog(name)
    self.mapNameStack[name] = nil

    local stackChild = self.treeDialog[name]
    stackChild:foreach(function (nameChild) 
            self.parentMap[nameChild] = nil
        end)
    self.treeDialog[name] = nil

    self.stackDialog:del(name)
end

function class:delDialogPrompt(name)
    self.mapNameStack[name] = nil

    local parent = self.parentMap[name]
    local stackChild = self.treeDialog[parent]
    if nil == stackChild then
        --可能父窗口关闭时就被清楚掉了
        return
    end
    stackChild:del(name)
    self.parentMap[name] = nil
end

function class:clear()
    self.mapNameStack = {}
    self.treeDialog = {} 
    self.stackDialog:clear()
    self.parentMap = {} 
end

function class:checkDialog(name, elem)
    return name == elem
end

function class:checkDialogPrompt(name, elem)
    return name == elem
end

function class:moveDialogToTop(name)
    if self.stackDialog:top() == name then
        return
    end
    
    self.stackDialog:moveToTop(name)

    local layer = self.mapNameStack[name]
    local parentNode = layer:getParent()
    layer:retain()
    layer:removeFromParent(false)
    parentNode:addChild(layer)
    layer:release()
end

function class:moveDialogPromptToTop(name)
    local parentName = self.parentMap[name]
    local stack = self.treeDialog[parentName]
    if stack:top() == name then
        return
    end

    stack:moveToTop(name)
    
    local layer = self.mapNameStack[name]
    local parent = layer:getParent()
    layer:retain()
    layer:removeFromParent(false)
    parent:addChild(layer)
    layer:release()
end

function class:getParentNode(name)
    local parentName = self.parentMap[name]
    local parent = self.mapNameStack[parentName]

    return parent
end

function class:getTopLayer()
    local topDialogName = self.stackDialog:top()
    local stack = self.treeDialog[topDialogName]
    if stack ~= nil then
        local topPromptDialogName = stack:top()
        
        if topPromptDialogName ~= nil then
            return self.mapNameStack[topPromptDialogName]
        end
    end

    return self.mapNameStack[topDialogName]
end

function class:dump()
    log("-----dump dialoglayer------")
    log("mapNameStack num:" .. table.size(self.mapNameStack))
    for k in pairs(self.mapNameStack) do
        log("   " .. k)
    end

    log("treeDialog:" .. table.size(self.treeDialog))
    for k, v in pairs(self.treeDialog) do
        log("   " .. k)
        v:dump()
    end

    log("stackDialog:")
    self.stackDialog:dump()

    log("parentMap:")
    log(self.parentMap)
end
