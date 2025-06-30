module(..., package.seeall)

local Define = require "UI.Mgr.Define"
local DialogLayer = require "UI.Mgr.UILayer.DialogLayer"
local WindowLayer = require "UI.Mgr.UILayer.WindowLayer"
local BgMask = require "UI.Mgr.UILayer.BgMask"
local WINDOW_TYPE = Define.WINDOW_TYPE
local WINDOW_TOUCH_TYPE = Define.WINDOW_TOUCH_TYPE


class = objectlua.Object:subclass()

function class:initialize(mgr)
	super.initialize(self)

	self.mgr = mgr
	self.dialogLayer = DialogLayer.class:new(self)
	self.windowLayer = WindowLayer.class:new(self)
	self.bgMask 	 = BgMask.class:new(self)
end

function class:dispose()
	super.dispose(self)
end

function class:add(name, layer)
	local winTouchType = layer:getWinTouchType()
	if winTouchType == WINDOW_TOUCH_TYPE.SWALLOW then
		layer:addTouchSwallow()
	end

	self.bgMask:addWindow(layer)

	local winType = layer:getWindowType()
	if winType == WINDOW_TYPE.DIALOG then
		self.dialogLayer:addDialog(name, layer)

	elseif winType == WINDOW_TYPE.DIALOGPROMPT then
		self.dialogLayer:addDialogPrompt(name, layer)

	elseif winType == WINDOW_TYPE.WINDOW then
		self.windowLayer:addWindow(name, layer)

	else
		assert(false)
	end
end

function class:del(nameOrLayer)
	local layer, name = self:getLayer(nameOrLayer)
	if nil == layer then
		return
	end
	log4ui:info("UI:LayerMgr:del:" .. (name or "nil"))

	local winType = layer:getWindowType()
	if winType == WINDOW_TYPE.DIALOG then
		self.dialogLayer:delDialog(name)

	elseif winType == WINDOW_TYPE.DIALOGPROMPT then
		self.dialogLayer:delDialogPrompt(name)

	elseif winType == WINDOW_TYPE.WINDOW then
		self.windowLayer:delWindow(name)

	else
		assert(false)
	end

	self.bgMask:delWindow(layer)
end

function class:getLayer(nameOrLayer)
	local name
	if type(nameOrLayer) == "string" then
		name = nameOrLayer
	else
		name = nameOrLayer:getName()
	end

	local layer = self.dialogLayer:getLayer(name)
	if nil == layer then
		-- self.dialogLayer:dump()
		layer = self.windowLayer:getLayer(name)
	end

	return layer, name 
end

function class:moveLayerToTop(layer)
	--只支持dialog和window
	local winType = layer:getWindowType()
	if winType == WINDOW_TYPE.DIALOG then
		self.dialogLayer:moveDialogToTop(layer:getName())

	elseif winType == WINDOW_TYPE.DIALOGPROMPT then
		self.dialogLayer:moveDialogPromptToTop(layer:getName())

	elseif winType == WINDOW_TYPE.WINDOW then
		self.windowLayer:moveWindowToTop(layer:getName())

	else
		assert(false)
	end
end

function class:clear()
	log4ui:info("UI:LayerMgr:clear")
	self.dialogLayer:clear()
	self.windowLayer:clear()
end

function class:getParentNode(layer)
	local winType = layer:getWindowType()
	if winType == WINDOW_TYPE.DIALOG then
		return self.mgr:getDialogRootNode()

	elseif winType == WINDOW_TYPE.DIALOGPROMPT then
		return  self.dialogLayer:getParentNode(layer:getName())

	elseif winType == WINDOW_TYPE.WINDOW then
		return self.mgr:getWindowRootNode()

	else
		assert(false)
	end

	return nil
end

--cocos studio  button控件有ZOrder属性 导致prompt挂载到dialog上层级错误
function class:getLayerZOrder(layer)
	local winType = layer:getWindowType()
	return Define.WINDOW_ZORDER[winType] or 0
end

function class:getTopLayer()
	return self.windowLayer:getTopLayer() 
		or self.dialogLayer:getTopLayer()
end

