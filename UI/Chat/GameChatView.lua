local Chat = require "Model.Chat"

module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local Chat_Type = Enum
{
	"TEXT",
	"FACE"	
}

function prototype:hasBgMask()
	return false
end

function prototype:enter(data)
	--UI事件
	self:bindUIEvent("GameChat.Text", "uiEvtGameChatText")

	local userInfo = Model:get("Account"):getUserInfo()
	local sex = userInfo.sex --性别,1-男、2-女
	local textList = {}
	local SHORT_VOICE
	if sex == 1 then
		SHORT_VOICE = Chat.SHORT_VOICE_MAN
	else
		SHORT_VOICE = Chat.SHORT_VOICE_WOMAN
	end

	if data == nil then
		for i, v in ipairs(SHORT_VOICE) do
			if i > 8 then
				break
			end
			textList[#textList+1] = v
		end
	else
		for i, v in ipairs(data) do
			textList[#textList+1] = SHORT_VOICE[v]
		end
	end

	local param = 
	{
		data = textList,
		ccsNameOrFunc = "Chat/ChatTextItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}

    self.listText:createItems(param)

    local faceList = {}
    local lineData = {}
	for i, v in ipairs(Chat.CHAT_FACE) do
		if i > 20 then
			break
		end

		lineData[#lineData + 1] = v 
		if #lineData == 5 then
			faceList[#faceList+1] = lineData
			lineData = {}
		end
	end

    param = 
	{
		data = faceList,
		ccsNameOrFunc = "Chat/ChatFaceItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}

    self.listFace:createItems(param)


    self:selectType(Model:get("Chat"):getChatSelectType())
	-- self:selectType(Chat_Type.TEXT)
end

function prototype:uiEvtGameChatText(data)
	Model:get("Chat"):requestTextMsg(data.key)
	self:close()
end

function prototype:selectType(_type)
	if _type == self.chatType then
		return
	end

	self.imgTxtSel:setVisible(_type == Chat_Type.TEXT)
	self.imgTextIcon:setVisible(_type == Chat_Type.TEXT)
	self.listText:setVisible(_type == Chat_Type.TEXT)

	self.imgFaceSel:setVisible(_type == Chat_Type.FACE)
	self.imgFaceIcon:setVisible(_type == Chat_Type.FACE)
	self.listFace:setVisible(_type == Chat_Type.FACE)

	self.chatType = _type

	Model:get("Chat"):setChatSelectType(_type)
end

function prototype:onBtnTextClick()
	self:selectType(Chat_Type.TEXT)
end

function prototype:onBtnFaceClick()
	self:selectType(Chat_Type.FACE)
end

function prototype:onPanelCloseClick()
	self:close()
end