local Actions = require "UI.Mgr.Actions"
local Define = require "UI.Mgr.Define"

module(..., package.seeall)

class = Actions.class:subclass()


function class:exec(target)
	--添加黑色背景
	local eglView = cc.Director:getInstance():getOpenGLView()
	local size = eglView:getFrameSize()
	local mask = CCLayerColor:create(cc.c4b(0, 0, 0, 140), size.width, size.height)

	--判断是否有自定义背景, 有的话不添加黑色背景层
	local diyBgImg = target:getChildByTag(6666)
	if diyBgImg == nil then 
		self.owner:addChild(mask, -1000, Define.MASK_BG_TAG)
		mask:setScale(10)
	else
		mask = nil
	end

	self.owner:setPositionY(1000)

	local arrAction = {}
	table.insert(arrAction, CCFadeTo:create(0, 0))
	table.insert(arrAction, CCSpawn:create(CCMoveBy:create(0.3, cc.p(0, -1000)),
										   CCFadeTo:create(0.4, 255)
										   ))

	table.insert(arrAction, CCCallFunc:create(function ()
											if mask then
												mask:removeFromParent(true)
											end
											self:callback()										
										end))

	self.owner:runAction(CCSequence:create(arrAction))
end
