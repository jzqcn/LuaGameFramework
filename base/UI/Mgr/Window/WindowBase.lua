local Define = require "UI.Mgr.Define"

module(..., package.seeall)

local TAG_BG = 100
local TAG_MASK = 101
local TOUCHES_BG = 102

local ORDER_BG = -1
local ORDER_MASK = -2
local TEST_BG = false

prototype = Controller.prototype:subclass()


function prototype:initialize(...)
	super.initialize(self, ...)

	self.windowType = Define.WINDOW_TYPE.WINDOWBASE
	self.windowTouchType = Define.WINDOW_TOUCH_TYPE.SWALLOW
end

function prototype:cleanup( ... )
	ui.mgr:delLayer(self.__NAME)
	super.cleanup(self)
end

function prototype:getReOpenType()
	return Define.RE_OPEN_TYPE.ONLY
end

function prototype:getWindowType()
	return self.windowType
end

function prototype:getWinTouchType()
	return self.windowTouchType
end

function prototype:isFullWinodwMode()
	return true
end

-- 防止穿透
function prototype:addTouchSwallow()
	local layout = self:createLayout(ORDER_BG, TAG_BG, bind(self.onBtnBgInside, self), false)
	if TEST_BG then
		layout:setBackGroundColorType(LAYOUT_COLOR_SOLID)
		layout:setBackGroundColor(cc.c3b(200, 17, 17))
		layout:setBackGroundColorOpacity(165)
	end
	self:addTouchesSwallow()
end

--多点的防穿透
function prototype:addTouchesSwallow()
	local layout = cc.Layer:create()
	layout:setAnchorPoint(cc.p(0.5, 0.5))
	layout:setPositionNormalized(cc.p(0.5, 0.5))

	local size = self.rootNode:getContentSize()

	layout:setContentSize(size)

    layout:registerScriptTouchHandler(function(state, ...)
        return true
    end, true, 0, true)
    layout:setTouchEnabled(true)
    self.rootNode:addChild(layout, ORDER_BG, TOUCHES_BG)
end

function prototype:hasBgMask()
	return true
end

-- 半透区域
function prototype:addBgMask()
	if not self:hasBgMask()
	   or self.rootNode:getChildByTag(TAG_MASK) then
		return
	end

	local layout = self:createLayout(ORDER_MASK, TAG_MASK, bind(self.onBtnBgOutside, self), true)
	layout:setBackGroundColorType(LAYOUT_COLOR_SOLID)
	layout:setBackGroundColor(cc.c3b(17, 17, 17))
	layout:setBackGroundColorOpacity(165)
end

function prototype:removeBgMask()
	if not self:hasBgMask() then
		return
	end

	local layout = self.rootNode:getChildByTag(TAG_MASK)
	if layout then
		layout:setBackGroundColorType(LAYOUT_COLOR_NONE)
	end
end

function prototype:onBtnBgInside()
end

function prototype:onBtnBgOutside()
	self:close()
end

function prototype:onBtnClose()
	self:close()
end

function prototype:getOpenAction()
	return nil
end

function prototype:getCloseAction()
	return nil
end

function prototype:isWindow()
	return true
end

function prototype:onTransData(data)
	log4ui:w("onTransData:no ccb receive this data")
end



------------------------------
--private
function prototype:createLayout(order, tag, clickCb, useSceneSize)
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(cc.p(0.5, 0.5))
	layout:setPositionNormalized(cc.p(0.5, 0.5))

	local size
	if useSceneSize then
		local info = self:getLoader():getViewPortInfo()
		size = cc.size(info.w, info.h)
	else
		size = self.rootNode:getContentSize()
	end

	layout:setContentSize(size)
	layout:setTouchEnabled(true)
	layout:addClickEventListener(clickCb)
	self.rootNode:addChild(layout, order, tag)
	return layout
end

