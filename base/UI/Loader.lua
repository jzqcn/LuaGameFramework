local AutoLoader = require "UI.Loader.Auto"
local ManualLoader = require "UI.Loader.Manual"

module (..., package.seeall)

local fileUtils = cc.FileUtils:getInstance()

local singleton
function getSingleton(_)
	assert(singleton ~= nil)
	return singleton
end


class = objectlua.Object:subclass()
function class:initialize()
	super.initialize(self)
	assert(nil == singleton)
	singleton = self

	self.autoLoader = AutoLoader.class:new(self)
	self.manualLoader = ManualLoader.class:new(self)
end

function class:loadAsScene(ccsname)
	local info = self:getViewPortInfo()
	local scene = cc.Scene:create()

	local rootNode = cc.Node:create()
	rootNode:setScaleX(info.scale)
    rootNode:setScaleY(info.scale)
	scene:addChild(rootNode, 0, 999)

	local layer = self:loadAsLayer(ccsname)
	rootNode:addChild(layer, 0, 999)

	local prompt = cc.Node:create()
	prompt:setContentSize(cc.size(info.w, info.h))
	rootNode:addChild(prompt, 0, 998)
	
	return scene, layer
end


function class:loadAsLayer(ccsname)
	local file = string.format("resource/csb/%s.csb", ccsname)
	if not fileUtils:isFileExist(file) then
		file = string.format("resource/%s.csb", ccsname)
		-- log("[Loader::loadAsLayer] load not csb folder file : " .. file)
	end

	local layer = cc.CSLoader:createNode(file)

    local actionTime = cc.CSLoader:createTimeline(file)
    actionTime:retain()
    self:loadLuaClass(ccsname, layer, actionTime)

    local info = self:getViewPortInfo()
    local size = layer:getContentSize()
    if layer:isFullWinodwMode() and self.designSize.w == size.width and self.designSize.h == size.height then
	    layer:setContentSize(cc.size(info.w, info.h))
	    ccui.Helper:doLayout(layer)
    end

	return layer
end

function class:loadAsNode(ccsname)
	local file = string.format("resource/csb/%s.csb", ccsname)
	if not fileUtils:isFileExist(file) then
		file = string.format("resource/%s.csb", ccsname)
		-- log("[Loader::loadAsNode] load not csb folder file : " .. file)
	end
	
	local node = cc.CSLoader:createNode(file)

	local widget = self:castWidget(node)
	assert(widget)

    local property = widget:getCustomProperty()
    assert(property ~= "")

    local luaName = "UI.Control." .. property
	local actionTime = cc.CSLoader:createTimeline(file)
    actionTime:retain()

    self:loadLuaClass(luaName, node, actionTime)
	return node
end

function class:loadFromClone(ccsname, node)
	self:loadLuaClass(ccsname, node)
	local widget = self:castWidget(node)
	if widget then
		widget:rebindLocateCallbackAll()
	end
end


function class:getType(node)
	return CCBLayerProxy:getType(node)
end


function class:castWidget(node)
	local widgets =
	{
		["ui::Widget"] = "ccui.Widget",
		["ui::Text"] = "ccui.Text",
		["ui::TextAtlas"] = "ccui.TextAtlas",
		["ui::TextBMFont"] = "ccui.TextBMFont",
		["ui::TextField"] = "ccui.TextField",
		["ui::CheckBox"] = "ccui.CheckBox",
		["ui::ImageView"] = "ccui.ImageView",
		["ui::LoadingBar"] = "ccui.LoadingBar",
		["ui::RichText"] = "ccui.RichText",
		["ui::Slider"] = "ccui.Slider",
		["ui::Button"] = "ccui.Button",
		["ui::Layout"] = "ccui.Layout",
		["ui::LayoutComponent"] = "ccui.LayoutComponent",
		["ui::RelativeBox"] = "ccui.RelativeBox",
		["ui::VBox"] = "ccui.VBox",
		["ui::HBox"] = "ccui.HBox",
		["ui::ListView"] = "ccui.ListView",
		["ui::PageView"] = "ccui.PageView",
		["ui::ScrollView"] = "ccui.ScrollView",
	}

	local types = self:getType(node)
	if types == "ui::Widget" then
		return node
	end

	if not widgets[types] then
		return nil
	end

	return tolua.cast(node, "ccui.Widget")
end

function class:onLocateClick( ... )
	sys.sound:playEffect("CLICK")
end


--设置手机布局
--@param orientation 横向(landscape)、纵向(portrait)
--@param strategy  适配策略 
function class:setLayout(orientation)
    self.orientation = orientation or 'portrait'
    
    if self.orientation == 'portrait' then
    	self.strategy = cc.ResolutionPolicy.FIXED_HEIGHT
    else
    	self.strategy = cc.ResolutionPolicy.FIXED_WIDTH
    end

    -- local width, height = 1280, 720
    local width, height = 1334, 750
    if self.orientation == "portrait" then
        width, height = height, width
    end

    local size = {w = width, h = height}
    size.width = width
    size.height = height
    self.designSize = size

    local eglView = cc.Director:getInstance():getOpenGLView()
    --注意：内部会修改设计分辨率为有效区域 
    -- 所以getDesignResolutionSize出的值不一致
    eglView:setDesignResolutionSize(width, height, self.strategy)
end

function class:getViewPortInfo()
	if self.viewPortInfo == nil then
		self.viewPortInfo = self:calcViewPortInfo()
	end
	
	return self.viewPortInfo
end

function class:getDesignSize()
	local eglView = cc.Director:getInstance():getOpenGLView()
	local newSize = eglView:getDesignResolutionSize()
	return self.designSize, newSize
end




-----------------private----------------------
function class:calcViewPortInfo()
	local eglView		= cc.Director:getInstance():getOpenGLView()
	local frameSize		= eglView:getFrameSize()

	local designScale	= self.designSize.w / self.designSize.h
	local frameScale	= frameSize.width / frameSize.height
	-- log("calcViewPortInfo:: designSize w="..self.designSize.w..", h="..self.designSize.h..", frameSize w="..frameSize.width..", h="..frameSize.height)

	local info = {}
	local scale = 1
	if designScale <= frameScale then --宽屏
		scale = frameSize.height / self.designSize.h
	else  
		scale = frameSize.width / self.designSize.w
	end

	info.w = frameSize.width / scale
	info.h = frameSize.height / scale
	info.scale = scale / eglView:getScaleX()

	-- log(info)
	
	return info
end


function class:loadLuaClass(ccsname, layer, actionTime)
	assert(layer)

	-- log4ui:w("[=UI:loadLuaClass:" .. ccsname)

	local prototype = require(ccsname).prototype
	local proxy = prototype:new(ccsname, layer)
	proxy._actionTime = actionTime
    tolua.setpeer(layer, proxy)

    if proxy:isWindow() then
    	local widget = self:castWidget(layer)
    	assert(widget, "Must set class as Widget in CocosBuilder:" .. ccsname)
    end

    self.autoLoader:loadLuaClass(proxy, layer)
    self.manualLoader:loadLuaClass(proxy, layer)

	self:registerUIEvent(proxy)
    layer:registerScriptHandler(bind(self.callScriptHandler, self, proxy))
end

function class:callScriptHandler(proxy, name, ...)
	if proxy[name] == nil then
		return nil
	end
	return proxy[name](proxy, ...)
end


function class:registerUIEvent(proxy)
	proxy._uiEvent = {}
	proxy.bindUIEvent = function (self, name, funcName)
		assert(self[funcName], "function " .. funcName .. " not exist!")
		proxy._uiEvent[name] = bind(self[funcName], self)
	end
	proxy.getUIEvent = function (self, name)
		return proxy._uiEvent[name]
	end
end

