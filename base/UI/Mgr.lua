--------------------------------------------------
-- UI管理类  负责窗口打开 关闭 层级关系
--
-- 2016.8.15
--------------------------------------------------

local Controller = require "UI.Controller"
local LayerMgr = require "UI.Mgr.UILayer.LayerMgr"
local Define = require "UI.Mgr.Define"

local HotPatch = require "Utils.HotPatch.HotPatch"


module(..., package.seeall)

class = Events.class:subclass()

function class:initialize()
	super.initialize(self)

	self.layerMgr = LayerMgr.class:new(self)
	self.hotPatch = HotPatch.class:new()
end

function class:dispose()
	super.dispose(self)
end


----------------------------------------------
-- scene相关
--
function class:replaceScene(ccsName, data)
	log4ui:info("UI:replaceScene:" .. ccsName)

	local scene = self:loadScene(ccsName, data)
	if nil == scene then 
		return 
	end
	
	self:clearScene()
	local director = cc.Director:getInstance()
	director:replaceScene(scene)
	self.delayScene = scene

	--移除缓存特效
	CEffectManager:GetSingleton():removeUnusedEffect()

	local textureCache = director:getTextureCache()

	-- log("------before clear-----")
	-- log(textureCache:getCachedTextureInfo())
	-- log("-----------------------")
	--清理纹理资源
	-- textureCache:removeUnusedTextures()

	--延迟释放纹理资源。当前帧释放不会生效
	util.timer:after(0.2*1000, self:createEvent("removeCacheImages"))

	-- log("--------end clear-------")
	-- log(textureCache:getCachedTextureInfo())
	-- log("-----------------------")

	self.hotPatch:sceneChange(scene)

	--倒计时消息，始终显示在窗口上层
	local item = Model:get("Announce"):getCountDownMsg()
	if item then
		self:open("CountdownView", item)
	end

	return scene
end

function class:removeCacheImages()
	local textureCache = cc.Director:getInstance():getTextureCache()

	-- log("-------------before clear-----------")
	-- log(textureCache:getCachedTextureInfo())
	-- log("-------------before clear-----------")

	textureCache:removeUnusedTextures()

	-- log("*************end clear*************")
	-- log(textureCache:getCachedTextureInfo())
	-- log("*************end clear*************")
end

function class:clearScene()
	self.layerMgr:clear()
end

--support edit. not use for open action.
function class:moveScene(dis, time)
	local layer = self.delayScene:getChildByTag(999)
	local action = cc.MoveBy:create(time, cc.p(0, dis))
	layer:runAction(action)
end
--
---------------------------------------------


----------------------------------------------
-- 窗口打开 关闭 传数据
--
function class:open(ccsName, enterData)
	-- log4ui:i("[=UI:open:" .. ccsName)
	local findLayer, oldLayer = self:doReOpen(ccsName)
	if findLayer then
		return oldLayer
	end

	local layer = self:loadLayer(ccsName, enterData)
	self.layerMgr:add(ccsName, layer)

	local parentNode = self.layerMgr:getParentNode(layer)
	local zOrder = self.layerMgr:getLayerZOrder(layer)
	layer:addToParent(parentNode, zOrder)

	self:runOpenAction(layer, function ()
			self:fireEvent(Define.WINDOW_EVT.OPEN, ccsName)
		end)

	return layer
end

function class:doReOpen(ccsName)
	local layer, name = self:getLayer(ccsName)
	if nil == layer then
		return false, nil
	end

	local reOpenType = layer:getReOpenType()
	if reOpenType == Define.RE_OPEN_TYPE.OPEN_NEW then
	    return false, nil
    end

	if reOpenType == Define.RE_OPEN_TYPE.CLOSE_BEFORE then
		self:close(ccsName)
        return false, nil
	end

	if reOpenType == Define.RE_OPEN_TYPE.ONLY then
		self.layerMgr:moveLayerToTop(layer)
	    return true, layer
    end

	return false, nil
end

function class:close(nameOrLayer)
	log4ui:i("[=UI:close") 
	local layer, name = self:getLayer(nameOrLayer)
	if nil == layer then
		--log4ui:w("[=UI:close :: layer is not exist, name : "..nameOrLayer) 
		return
	end

	local callback = function ()
		layer:removeSelf(true)
		self:fireEvent(Define.WINDOW_EVT.CLOSE, name)
	end

	if self:runCloseAction(layer, callback) then
		return
	end

	callback()
end

function class:isOpen(nameOrLayer)
	return self:getLayer(nameOrLayer) ~= nil
end

--窗口间传递数据
function class:transData(nameOrLayer, data)
	local layer = self:getLayer(nameOrLayer)
	if nil == layer then
		return
	end

	if layer.onTransData then
		layer:onTransData(data)
	end
end

function class:getLayer(nameOrLayer)
	local layer, name = self.layerMgr:getLayer(nameOrLayer)
	return layer, name
end

function class:delLayer(nameOrLayer)
	self.layerMgr:del(nameOrLayer)
end
--
---------------------------------------------



----------------------------------------------
-- ccs加载相关
--
function class:loadScene(ccsName, data)
	log4ui:info("UI:loadScene:" .. ccsName)

	local scene, layer = ui.loader:loadAsScene(ccsName)

	self:registerOnEnter(layer, data)
	self:registerClose(layer)
	return scene
end


function class:loadLayer(ccsName, enterData)
	local layer = ui.loader:loadAsLayer(ccsName)

	self:registerOnEnter(layer, enterData)
	self:registerClose(layer)
	return layer
end

function class:registerOnEnter(layer, data)
	local enterCall = layer.enter or nil
	layer.enter = function ()
		if enterCall then
			enterCall(layer, data)
		end
	end
end

function class:registerClose(layer)
	layer.close = bind(self.close, self, layer)
end

--
---------------------------------------------



----------------------------------------------
-- 层级相关
--
function class:getRootNode()
	if self.delayScene then
		return self.delayScene:getChildByTag(999)
	end

	local scene = cc.Director:getInstance():getRunningScene()
	local layer = scene:getChildByTag(999)
	if layer then 
		return layer
	end

	return nil
end

function class:getDialogRootNode()
	local root = self:getRootNode()
	assert(root)
	return root:getChildByTag(999)
end

function class:getWindowRootNode()
	local root = self:getRootNode()
	assert(root)
	return root:getChildByTag(998)
end
--
---------------------------------------------








----------------------------------------------
-- 窗口动画
--

function class:runOpenAction(layer, callback)
	local actionName, actionParam = layer:getOpenAction()
	
	if nil == actionName or "" == actionName then
		return false
	end

	log4ui:i("[=UI:runOpenAction:" .. actionName)

	local action = require ("UI.Mgr.Actions." .. actionName).class:new(layer, callback, "open")
	action:exec(actionParam)

	return true
end

function class:runCloseAction(layer, realClose, callback)
	local actionName, actionParam = layer:getCloseAction()

	if nil == actionName  or "" == actionName then
		return false
	end

	log4ui:i("[=UI:runCloseAction:" .. actionName)

	local cbkFunc = function ()
				realClose()
				if callback then
					callback()
				end
			end

	local action = require ("UI.Mgr.Actions." .. actionName).class:new(layer, cbkFunc, "close")
	action:exec(actionParam)

	return true
end

--
---------------------------------------------

--所有带背景截面图
function class:setSceneImageBg(imgWidget, isVague)
	if not imgWidget then
		return
	end

	isVague = isVague or false

	local index = db.var:getUsrVar("SCENE_BG_INDEX")
	if nil == index or index < 0 then
		index = 0
	end

	if isVague then
		imgWidget:loadTexture(string.format("resource/csbimages/Hall/Bg/vagueBg_%d.png", index))
	else
		imgWidget:loadTexture(string.format("resource/csbimages/Hall/Bg/bg_%d.png", index))
	end
end


