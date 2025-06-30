module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:enter(itemId)
	self.itemId = itemId
	self.btnAli:setVisible(true)
	self.btnWeixin:setVisible(false)
	self.btnUnion:setVisible(false)
end

function prototype:onBtnAliClick()
	Model:get("Item"):requestCharge(self.itemId, item_pb.Alipay)
	self:close()
end

function prototype:onBtnWeixinClick()
	Model:get("Item"):requestCharge(self.itemId, item_pb.Wx)
	self:close()
end

function prototype:onBtnUnionClick()
	Model:get("Item"):requestCharge(self.itemId, item_pb.UnionPay)
	self:close()
end

function prototype:onPanelCloseClick()
	self:close()
end
