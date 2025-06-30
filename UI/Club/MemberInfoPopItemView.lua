module (..., package.seeall)

local TAG_BG = 100
local TAG_MASK = 101
local TOUCHES_BG = 102

local ORDER_BG = -1
local ORDER_MASK = -2

prototype = Window.prototype:subclass()

function prototype:initialize(...)
    super.initialize(self, ...)

    -- self.windowTouchType = Define.WINDOW_TOUCH_TYPE.SWALLOW
end

function prototype:hasBgMask()
    return false
end

--不用半透明遮罩
-- function prototype:addBgMask()
-- 	if not self:hasBgMask()
-- 	   or self.rootNode:getChildByTag(TAG_MASK) then
-- 		return
-- 	end

-- 	local layout = self:createLayout(ORDER_MASK, TAG_MASK, bind(self.onBtnBgOutside, self), true)
-- 	layout:setBackGroundColorType(LAYOUT_COLOR_SOLID)
-- 	layout:setBackGroundColor(cc.c3b(17, 17, 17))
-- 	--透明度设置为0
-- 	layout:setBackGroundColorOpacity(0)
-- end

function prototype:enter(info)
	if info.isOwner then
		self.btnSetManager:setVisible(not info.data.isManager)
		self.btnDelManager:setVisible(info.data.isManager)
	elseif info.isManager then
		self.btnSetManager:setVisible(false)
		self.btnDelManager:setVisible(false)
		self.btnRemoveMem:setPositionY(110)
	end

	self.data = info.data
end

function prototype:setMenuPos(pos)
	-- local eglView = cc.Director:getInstance():getOpenGLView()
	-- local frameSize = eglView:getFrameSize()
	-- local screenScale = frameSize.width / frameSize.height
	-- local defaultScale = 1334 / 750

	self.imgPop:setPosition(pos)
end

function prototype:onPanelCloseClick()
	self:close()
end

--设置管理员
function prototype:onBtnSetManagerClick()
	Model:get("Club"):requestClubManager(self.data.clubId, self.data.userId, false)
	self:close()
end

--取消管理员
function prototype:onBtnDelManagerClick()
	Model:get("Club"):requestClubManager(self.data.clubId, self.data.userId, true)
	self:close()
end

--踢出成员
function prototype:onBtnRemoveMemClick()
	local exitFunc = function ()
		Model:get("Club"):requestDeleteMember(self.data.clubId, self.data.userId)
	end

	local data = {
		okFunc = exitFunc,
		content = string.format("是否确认将玩家【%s】踢出俱乐部？", self.data.userName)
	}
	ui.mgr:open("Dialog/ConfirmDlg", data)

	self:close()
end

