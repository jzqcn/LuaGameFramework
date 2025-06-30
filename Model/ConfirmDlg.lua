module(..., package.seeall)

MSG_ID = 
{
	DIALOG_MSG = 64,
}

EVT = Enum
{
	"DIALOG_MSG",
}

class = Model.class:subclass()

function class:initialize()
	super.initialize(self)
	MsgOther:on("DIALOG_MSG", self:createEvent("onDialogMsg"), false)
end

function class:onDialogMsg(info)
	local data = self:parseDialogMsg(info)
	self:fireEvent(EVT.DIALOG_MSG, data)
end

function class:parseDialogMsg(info)
	local data = {}
	local stream = structex:new({data = info})

	data.type = stream:readByte("s")
	if data.type == 2 then
		data.confirmContent = stream:readWString()
		data.leftKeyScript = stream:readWString()
		data.rightKeyScript = stream:readWString()
	end

	return data
end