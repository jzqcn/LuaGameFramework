local Account = require "Model.Account"

module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local SEL_TYPE = Enum
{
	"PROMOTION_MEMBER",
	"PROMOTION_COURSE",
	"PROMOTION_DETAIL",
}

--http://{API_ROOT}/promotion?playerId=100100000366&token=xxxxx

function prototype:enter()
	self:setSelectType(SEL_TYPE.PROMOTION_MEMBER)

	-- ui.mgr:setSceneImageBg(self.imgBg, true)

	--获取推广信息
	Model:get("Account"):getPromotionInfo(bind(self.initPromotionInfo, self))

	--[[local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)]]

	local isVisible = Model:get("User"):checkPromotionRedPoint()
	-- self.imgMemNew:setVisible(not isVisible)
	self.imgMemNew:setVisible(false)
	self.imgCourseNew:setVisible(not isVisible)
	self.imgDetailNew:setVisible(not isVisible)

	Model:get("User"):requestQueryIncome()
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))

	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))

	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.rootNode, actionOver)
	sys.sound:playEffectByFile("resource/audio/Hall/yuerubaiwan_enter.mp3")
end

function prototype:initPromotionInfo(promotionInfo)
	self.nodeMemInfo:setPromotionInfo(promotionInfo.data)
	self.nodeCourse:setPromotionInfo(promotionInfo.data)
	self.nodeDetail:setPromotionInfo(promotionInfo.data)
end

function prototype:setSelectType(_type)
	if self.selectType == _type then
		return
	end

	if _type == SEL_TYPE.PROMOTION_MEMBER then
		self.imgMemSel:setVisible(true)		
		self.imgCourseSel:setVisible(false)
		self.imgDetailSel:setVisible(false)
		self.nodeMemInfo:setVisible(true)
		self.nodeCourse:setVisible(false)
		self.nodeDetail:setVisible(false)
		self.imgMemNew:setVisible(false)

	elseif _type == SEL_TYPE.PROMOTION_COURSE then
		self.imgMemSel:setVisible(false)		
		self.imgCourseSel:setVisible(true)
		self.imgDetailSel:setVisible(false)
		self.nodeMemInfo:setVisible(false)
		self.nodeCourse:setVisible(true)
		self.nodeDetail:setVisible(false)
		self.imgCourseNew:setVisible(false)

	else

		self.imgMemSel:setVisible(false)		
		self.imgCourseSel:setVisible(false)
		self.imgDetailSel:setVisible(true)
		self.nodeMemInfo:setVisible(false)
		self.nodeCourse:setVisible(false)
		self.nodeDetail:setVisible(true)
		self.imgDetailNew:setVisible(false)
	end

	self.selectType = _type

	self.nodeDetail:closeSelectDate()
end

function prototype:onBtnMemClick()
	self:setSelectType(SEL_TYPE.PROMOTION_MEMBER)	
end

function prototype:onBtnCourseClick()
	self:setSelectType(SEL_TYPE.PROMOTION_COURSE)
end

function prototype:onBtnDetailClick()
	self:setSelectType(SEL_TYPE.PROMOTION_DETAIL)
end

function prototype:onPanelCloseClick()
	self:close()
end
