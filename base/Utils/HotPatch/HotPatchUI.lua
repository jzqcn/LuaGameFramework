module (..., package.seeall)


class = objectlua.Object:subclass()

function class:initialize(mgr)
	super.initialize(self)
	self.mgr = mgr
	self.isWorking = false
end

function class:dispose()
	super.dispose(self)
end

function class:sceneChange(scene)
	if util:getPlatform() ~= "win32" then
		return
	end

	local node = cc.Node:create()
	scene:addChild(node, 9999)
	self.rootNode = node

	local btn = cc.ControlButton:create(cc.Scale9Sprite:create("resource/csbimages/Login/alphabg.png"))
    btn:setPreferredSize(cc.size(60, 30))
    btn:setPosition(cc.p(1300, 730))
    btn:setOpacity(80)
    btn:registerControlEventHandler(bind(self.patchBtnTouchEvent, self, "touchdown"), cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
    btn:registerControlEventHandler(bind(self.patchBtnTouchEvent, self, "upinside"), cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
    btn:registerControlEventHandler(bind(self.patchBtnTouchEvent, self, "upoutside"), cc.CONTROL_EVENTTYPE_TOUCH_UP_OUTSIDE)
    node:addChild(btn, 1)
	self.patchBtn = btn

    local layer = cc.Layer:create()
	layer:registerScriptTouchHandler(bind(self.layerTouchEvent, self))
	layer:setTouchEnabled(true)
	layer:setSwallowsTouches(false)
	node:addChild(layer, 2)
end

function class:layerTouchEvent(event, x, y)
    if event == "began" then
    	self.isMoving = false
        return true
    elseif event == "moved" then
    	if self.isInButton then
    		self.isMoving = true
        	local pos = self.rootNode:convertToNodeSpace(cc.p(x, y))
        	self.patchBtn:setPosition(pos)
    	end
    end
end

function class:patchBtnTouchEvent(types)
	if types == "touchdown" then
	    self.isInButton = true

	elseif types == "upoutside" then
	    self.isInButton = false

	elseif types == "upinside" then
		self.isInButton = false
		if self.isMoving then
			return
		end

		self:onBtnHotPatch()
	end
end

function class:onBtnHotPatch()
	local _hotPatch = function ()
		self.isWorking = not self.isWorking
		if self.isWorking then
			self.mgr:startWork()
		else
			self.mgr:stopWork()
		end
	end
	local _coldPatch = function ()
		cc.Director:getInstance():replaceScene(CCScene:create())
		CEnvRoot:GetSingleton():SetReloadAll()
	end

	do return _hotPatch() end

	local info =
	{
		content = "hot patch!",
		okFunc = _hotPatch,
		okBtnTitle = "hot",
		cancelFunc = _coldPatch,
		cancelBtnTitle = "reboot",
	}
	ui.confirm:open(info)
end
