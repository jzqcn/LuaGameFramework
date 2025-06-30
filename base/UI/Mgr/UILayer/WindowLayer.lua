local UIStack = require "UI.Mgr.UILayer.UIStack"

module(..., package.seeall)

--层级图  没有子windowprompt
-- windowlayer = 
-- {
--     {window}
--     {window},
--     {window},
-- }

class = objectlua.Object:subclass()

function class:initialize()
    super.initialize(self)

    self.mapNameStack = {}
    self.stackWindow = UIStack:new(bind(self.checkWindow, self))
end

function class:dispose()
    super.dispose(self)
end

function class:getLayer(name)
    return self.mapNameStack[name]
end

function class:addWindow(name, layer)
    self.mapNameStack[name] = layer
    self.stackWindow:add(name)
end


function class:delWindow(name)
    self.mapNameStack[name] = nil
    self.stackWindow:del(name)
end

function class:checkWindow(name, elem)
    return name == elem
end

function class:clear()
    self.mapNameStack = {}
    self.stackWindow:clear()
end

function class:moveWindowToTop(name)
    if self.stackWindow:top() == name then
        return
    end
    
    self.stackWindow:moveToTop(name)

    local layer = self.mapNameStack[name]
    local parent = layer:getParent()
    layer:retain()
    layer:removeFromParent(false)
    parent:addChild(layer)
    layer:release()
end

function class:getTopLayer()
    local name = self.stackWindow:top()
    if name == nil then
        return
    end

    return self.mapNameStack[name]
end

function class:getWindowLayer()
    return self.layerMgr:getWindowLayer()
end