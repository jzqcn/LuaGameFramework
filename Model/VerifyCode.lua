module(..., package.seeall)

--手机验证码
class = Model.class:subclass()

EVT = Enum
{
	"SEND_VERIFY_CODE_SUCCESS",
}

local VerifyCode_pb = VerifyCode_pb

function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_SENDVERIFYCODE, self:createEvent("onVerifyCodeResponse"))
end

function class:sendVerifyCode(telphone, handleType)
	local request = VerifyCode_pb.SendVerifyCodeRequest()
	request.telphone = telphone
	request.handleType = handleType

	net.msg:send(MsgDef_pb.MSG_SENDVERIFYCODE, request:SerializeToString())
end

function class:onVerifyCodeResponse(data)
	local response = VerifyCode_pb.SendVerifyCodeResponse()
	response:ParseFromString(data)
	
	local isSuccess = response.isSuccess
	if isSuccess then 
		local data = {
			content = "验证码已发送",
		}
		ui.mgr:open("Dialog/DialogView", data)
		-- self:fireEvent(EVT.SEND_VERIFY_CODE_SUCCESS)
	else
		local errMsg = response.errMsg
		if not errMsg or errMsg == "" then			 
			errMsg = "验证码发送失败"
		end

		local data = {
			content = errMsg,
		}
		ui.mgr:open("Dialog/DialogView", data)
	end
end
