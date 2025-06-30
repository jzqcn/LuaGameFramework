require "Protol.GMService_pb"

module (..., package.seeall)

prototype = Window.prototype:subclass()

function prototype:enter()
	
end

function prototype:onTFNameClick(sender)
	if self.tfName:getPlaceHolder() == "请输入" then
		self.tfName:setPlaceHolder("")
	end
end

function prototype:onBtnConfirmClick(sender)
	local content = self.tfName:getString()
	self:gmMsgRequest(content)
	self:close()
end

function prototype:gmMsgRequest(content)
	local request = GMService_pb.MsgGMRequest()
	request.gMType = GMService_pb.GM_COMMAND
	request.content = content
	net.msg:send(MsgDef_pb.MSG_GM, request:SerializeToString())
end

function prototype:onBtnCancelClick(sender)
	self:close()
end

function prototype:onBtnAddGold()
	self:gmMsgRequest("ADDCOIN#3|10000")
end

function prototype:onBtnSubGold()
	self:gmMsgRequest("ADDCOIN#3|-10000")
end

function prototype:onBtnAddSilver()
	self:gmMsgRequest("ADDCOIN#2|10000")
end

function prototype:onBtnSubSilver()
	self:gmMsgRequest("ADDCOIN#2|-10000")
end