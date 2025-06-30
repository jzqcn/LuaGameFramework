module (..., package.seeall)

local EXTRA_DIS = 20
class = objectlua.Object:subclass()

function class:initialize()
	self.focusSender = nil
	self.keyboardShow = false
	self.keyboardHeight = 0
	self.lastDis = 0
end

function class:onKeyboardInput(show, height)
	if height > 0 then
		self.keyboardHeight = height
	end

	if show and self.focusSender then
		local rst, dis = self:checkMoveDis(self.focusSender, self.keyboardHeight)
		if not rst then
			return
		end

		self:onKeyboardUp(dis)
		self.lastDis = dis
	else
		self:onKeyboardDown()
	end
end

function class:onTextFiledWithIme(sender, attach)
	if attach then
		if sender ~= self.focusSender then
			self:restoreMovePos()
			self.focusSender = sender
			--取消此处方法调用。Android或ios会通过全局方法OnKeyboardInput调用，不然连续两次位置不准
			-- self:onKeyboardInput(true, 0)
		else
			self.focusSender = sender
		end
	else
		if sender == self.focusSender then
			self.focusSender = nil
			self:onKeyboardInput(false, 0)
		end
	end
end


------------privatge--------------
function class:restoreMovePos()
	if not self.keyboardShow then
		return
	end

	ui.mgr:moveScene(-1 * self.lastDis, 0.15)
	self.keyboardShow = false
end

function class:onKeyboardUp(height)
	if self.keyboardShow then
		self:restoreMovePos()
	end

	ui.mgr:moveScene(height, 0.15)
	self.keyboardShow = true
end

function class:onKeyboardDown()
	self:restoreMovePos()
end

function class:checkMoveDis(sender, height)
	local rootNode = ui.mgr:getRootNode()

	local eglView = cc.Director:getInstance():getOpenGLView()
	local hKeyboard = height / eglView:getScaleX() + EXTRA_DIS

	local posSenderZero, sizeSender = Assist:getNodePosAR(sender)
	if posSenderZero.y > hKeyboard then
		return false, 0
	end

	local dis = hKeyboard - posSenderZero.y
    local designSize = eglView:getDesignResolutionSize()
	if posSenderZero.y + sizeSender.height + dis > designSize.height then
		dis = designSize.height - posSenderZero.y - sizeSender.height
	else
	end

	return true, dis
end