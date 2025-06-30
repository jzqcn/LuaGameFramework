require "Protol.Chat_pb"

module(..., package.seeall)

EVT = Enum
{
	"PUSH_CHAT_MSG",
	"PUSH_VOICE_FINISH_PLAY",
	"PUSH_VOICE_FINISH_RECORD",
}

--聊天动画
ACTION_INFO = {
	{name = "action_bomb", frames = 20, isRotate = true, music = "bomb"},
	{name = "action_flower", frames = 23, isRotate = false, music = "flower"},
	{name = "action_chicken", frames = 17, isRotate = false, music = "chiken"},
	{name = "action_tomato", frames = 14, isRotate = true, music = "tomato"},
	{name = "action_foot", frames = 10, isRotate = true, music = "foot"},
}

--简短语音音效
SHORT_VOICE_MAN = {
	{key = "Man_Chat_0", word = "大家好，很高兴见到各位", music = "resource/audio/chat/man/Man_Chat_0.mp3"},
	{key = "Man_Chat_1", word = "和你合作真是太愉快了哦", music = "resource/audio/chat/man/Man_Chat_1.mp3"},
	{key = "Man_Chat_2", word = "快点啊，都等得我花儿都谢了", music = "resource/audio/chat/man/Man_Chat_2.mp3"},
	{key = "Man_Chat_15", word = "快点啦，牌都在你手上下蛋了", music = "resource/audio/chat/man/Man_Chat_15.mp3"},
	{key = "Man_Chat_16", word = "时代在变，为何你的速度总是不变", music = "resource/audio/chat/man/Man_Chat_16.mp3"},
	{key = "Man_Chat_17", word = "时间就是金钱，我的朋友", music = "resource/audio/chat/man/Man_Chat_17.mp3"},
	{key = "Man_Chat_3", word = "你的牌打得也挺好的", music = "resource/audio/chat/man/Man_Chat_3.mp3"},
	{key = "Man_Chat_4", word = "不要吵了，不要吵了", music = "resource/audio/chat/man/Man_Chat_4.mp3"},
	{key = "Man_Chat_5", word = "再不快点，花儿都谢了", music = "resource/audio/chat/man/Man_Chat_5.mp3"},
	{key = "Man_Chat_6", word = "抱歉，有要紧事要离开下", music = "resource/audio/chat/man/Man_Chat_6.mp3"},
	{key = "Man_Chat_7", word = "加个好友吧，能告诉我联系方式吗", music = "resource/audio/chat/man/Man_Chat_7.mp3"},
	{key = "Man_Chat_8", word = "不好意思，网络太差了", music = "resource/audio/chat/man/Man_Chat_8.mp3"},
	{key = "Man_Chat_9", word = "咱们明日再战！", music = "resource/audio/chat/man/Man_Chat_9.mp3"},
	{key = "Man_Chat_10", word = "大家好，很高兴和你们打牌", music = "resource/audio/chat/man/Man_Chat_10.mp3"},
	{key = "Man_Chat_11", word = "不要走，决战到天亮！", music = "resource/audio/chat/man/Man_Chat_11.mp3"},
	{key = "Man_Chat_12", word = "合作愉快！", music = "resource/audio/chat/man/Man_Chat_12.mp3"},
	{key = "Man_Chat_13", word = "谢谢！", music = "resource/audio/chat/man/Man_Chat_13.mp3"},
	{key = "Man_Chat_14", word = "不敢出手，你怕了？", music = "resource/audio/chat/man/Man_Chat_14.mp3"},
	
	{key = "Man_Chat_18", word = "无尽的等待，真让人闹心", music = "resource/audio/chat/man/Man_Chat_18.mp3"},
	{key = "Man_Chat_19", word = "想啥呢，快出牌啊", music = "resource/audio/chat/man/Man_Chat_19.mp3"},
	{key = "Man_Chat_20", word = "老天不公呀！", music = "resource/audio/chat/man/Man_Chat_20.mp3"},
}

SHORT_VOICE_WOMAN = {
	{key = "Woman_Chat_0", word = "大家好，很高兴见到各位", music = "resource/audio/chat/lady/Woman_Chat_0.mp3"},
	{key = "Woman_Chat_1", word = "和你合作真是太愉快了哦", music = "resource/audio/chat/lady/Woman_Chat_1.mp3"},
	{key = "Woman_Chat_2", word = "快点啊，都等得我花儿都谢了", music = "resource/audio/chat/lady/Woman_Chat_2.mp3"},
	{key = "Woman_Chat_15", word = "快点啦，牌都在你手上下蛋了", music = "resource/audio/chat/lady/Woman_Chat_15.mp3"},
	{key = "Woman_Chat_16", word = "浪费我的青春，你赔得起吗", music = "resource/audio/chat/lady/Woman_Chat_16.mp3"},
	{key = "Woman_Chat_17", word = "你要耽误人家约会了", music = "resource/audio/chat/lady/Woman_Chat_17.mp3"},
	{key = "Woman_Chat_3", word = "你的牌打得也挺好的", music = "resource/audio/chat/lady/Woman_Chat_3.mp3"},
	{key = "Woman_Chat_4", word = "不要吵了，不要吵了", music = "resource/audio/chat/lady/Woman_Chat_4.mp3"},
	{key = "Woman_Chat_5", word = "再不快点，花儿都谢了", music = "resource/audio/chat/lady/Woman_Chat_5.mp3"},
	{key = "Woman_Chat_6", word = "抱歉，有要紧事要离开下", music = "resource/audio/chat/lady/Woman_Chat_6.mp3"},
	{key = "Woman_Chat_7", word = "加个好友吧，能告诉我联系方式吗", music = "resource/audio/chat/lady/Woman_Chat_7.mp3"},
	{key = "Woman_Chat_8", word = "不好意思，网络太差了", music = "resource/audio/chat/lady/Woman_Chat_8.mp3"},
	{key = "Woman_Chat_9", word = "咱们明日再战！", music = "resource/audio/chat/lady/Woman_Chat_9.mp3"},
	{key = "Woman_Chat_10", word = "大家好，很高兴和你们打牌", music = "resource/audio/chat/lady/Woman_Chat_10.mp3"},
	{key = "Woman_Chat_11", word = "不要走，决战到天亮！", music = "resource/audio/chat/lady/Woman_Chat_11.mp3"},
	{key = "Woman_Chat_12", word = "合作愉快！", music = "resource/audio/chat/lady/Woman_Chat_12.mp3"},
	{key = "Woman_Chat_13", word = "谢谢！", music = "resource/audio/chat/lady/Woman_Chat_13.mp3"},
	{key = "Woman_Chat_14", word = "就你这样的速度，什么时候是个头啊", music = "resource/audio/chat/lady/Woman_Chat_14.mp3"},
	
	{key = "Woman_Chat_18", word = "时代在变，为何你的速度总是不变", music = "resource/audio/chat/lady/Woman_Chat_18.mp3"},
	{key = "Woman_Chat_19", word = "快点出啊，别磨磨蹭蹭", music = "resource/audio/chat/lady/Woman_Chat_19.mp3"},
	{key = "Woman_Chat_20", word = "这位哥哥，太阳要落山了", music = "resource/audio/chat/lady/Woman_Chat_20.mp3"},
}
--表情聊天
CHAT_FACE = {
    {key = "FACE_CHAT_0",frames = 4, num = 1,res = "resource/csbimages/Chat/face/emoji_0/emoji_0-obj-"},
	{key = "FACE_CHAT_1",frames = 2, num = 2,res = "resource/csbimages/Chat/face/emoji_1/emoji_1-obj-"},
    {key = "FACE_CHAT_2",frames = 8, num = 1,res = "resource/csbimages/Chat/face/emoji_2/emoji_2-obj-"},
    {key = "FACE_CHAT_3",frames = 4, num = 1,res = "resource/csbimages/Chat/face/emoji_3/emoji_3-obj-"},
    {key = "FACE_CHAT_4",frames = 2, num = 2,res = "resource/csbimages/Chat/face/emoji_4/emoji_4-obj-"},
    {key = "FACE_CHAT_5",frames = 2, num = 2,res = "resource/csbimages/Chat/face/emoji_5/emoji_5-obj-"},
    {key = "FACE_CHAT_6",frames = 8, num = 1,res = "resource/csbimages/Chat/face/emoji_6/emoji_6-obj-"},
    {key = "FACE_CHAT_7",frames = 3, num = 1,res = "resource/csbimages/Chat/face/emoji_7/emoji_7-obj-"},
    {key = "FACE_CHAT_8",frames = 8, num = 1,res = "resource/csbimages/Chat/face/emoji_8/emoji_8-obj-"},
    {key = "FACE_CHAT_9",frames = 3, num = 2,res = "resource/csbimages/Chat/face/emoji_9/emoji_9-obj-"},
    {key = "FACE_CHAT_10",frames = 4, num = 2,res = "resource/csbimages/Chat/face/emoji_10/emoji_10-obj-"},
    {key = "FACE_CHAT_11",frames = 4, num = 2,res = "resource/csbimages/Chat/face/emoji_11/emoji_11-obj-"},
    {key = "FACE_CHAT_12",frames = 4, num = 2,res = "resource/csbimages/Chat/face/emoji_12/emoji_12-obj-"},
    {key = "FACE_CHAT_13",frames = 4, num = 2,res = "resource/csbimages/Chat/face/emoji_13/emoji_13-obj-"},
    {key = "FACE_CHAT_14",frames = 8, num = 2,res = "resource/csbimages/Chat/face/emoji_14/emoji_14-obj-"},
    {key = "FACE_CHAT_15",frames = 5, num = 2,res = "resource/csbimages/Chat/face/emoji_15/emoji_15-obj-"},
    {key = "FACE_CHAT_16",frames = 4, num = 2,res = "resource/csbimages/Chat/face/emoji_16/emoji_16-obj-"},
    {key = "FACE_CHAT_17",frames = 3, num = 3,res = "resource/csbimages/Chat/face/emoji_17/emoji_17-obj-"},
    {key = "FACE_CHAT_18",frames = 4, num = 2,res = "resource/csbimages/Chat/face/emoji_18/emoji_18-obj-"},
    {key = "FACE_CHAT_19",frames = 2, num = 2,res = "resource/csbimages/Chat/face/emoji_19/emoji_19-obj-"},
    {key = "FACE_CHAT_20",frames = 2, num = 2,res = "resource/csbimages/Chat/face/emoji_20/emoji_20-obj-"},
}

class = Model.class:subclass()

--消息公告
function class:initialize()
    super.initialize(self)

    net.msg:on(MsgDef_pb.MSG_CHAT, self:createEvent("onChatResponse"))

    self.textMsgTab = {}
    self.voiceMsgTab = {}
    self.faceMsgTab = {}

    self.chatSelType = 1
end

function class:requestTextMsg(text)
	local request = Chat_pb.ChatRequest()
	request.type = Chat_pb.Text
	request.text = text
   
	-- log(text)

	net.msg:send(MsgDef_pb.MSG_CHAT, request:SerializeToString())
end

function class:requestVoiceMsg(voiceUrl)
	local request = Chat_pb.ChatRequest()
	request.type = Chat_pb.Voice
	request.voiceUrl = voiceUrl

	net.msg:send(MsgDef_pb.MSG_CHAT, request:SerializeToString())
end

function class:requestActionMsg(actionName, targetId)
	local actionId = 1
	for i, v in ipairs(ACTION_INFO) do
		if v.name == actionName then
			actionId = i
			break
		end
	end

	-- log("actionName:"..actionName..", targetId:"..targetId)
	
	local request = Chat_pb.ChatRequest()
	request.type = Chat_pb.Action
	request.actionId = actionId
	request.targetId = targetId

	net.msg:send(MsgDef_pb.MSG_CHAT, request:SerializeToString())
end

function class:requestFaceMsg(text)
	local request = Chat_pb.ChatRequest()
	request.type = Chat_pb.Text
	request.text = text
   
	log(text)
	net.msg:send(MsgDef_pb.MSG_CHAT, request:SerializeToString())
end

function class:onChatResponse(data)
	local chatData = Chat_pb.ChatResponse()
	chatData:ParseFromString(data)

	if chatData.isSuccess then
		local item = {}
		item.type = chatData.type
		item.playerId = chatData.playerId

		if item.type == Chat_pb.Text then
			item.text = chatData.text
			table.insert(self.textMsgTab, item)

		elseif item.type == Chat_pb.Voice then
			item.isRead = false
			item.voiceUrl = chatData.voiceUrl
			table.insert(self.voiceMsgTab, item)

		elseif item.type == Chat_pb.Action then
			item.actionId = chatData.actionId
			item.targetId = chatData.targetId

			local info
			if item.actionId <= #ACTION_INFO then
				info = ACTION_INFO[item.actionId]
			else
				info = ACTION_INFO[1]
			end

			item.actionName = info.name
			item.frames = info.frames
			item.isRotate = info.isRotate
			item.music = info.music

			-- log(item)
		end

		self:fireEvent(EVT.PUSH_CHAT_MSG, item)
	else
		--失败不用处理。自己发送消息，服务器返回对应处理的是false，但是会受到广播
		-- local data = {
		-- 	content = chatData.tips
		-- }
		-- ui.mgr:open("Dialog/ConfirmDlg", data)
	end
end

function class:clearVoiceMsg()
	self.voiceMsgTab = {}
end

function class:getNextNewVoice()
	for _, v in ipairs(self.voiceMsgTab) do
		if v.isRead == false then
			return v
		end
	end

	return nil
end

function class:onRecordFinish()
	self:fireEvent(EVT.PUSH_VOICE_FINISH_RECORD)
end

function class:onVoiceFinish()
	self:fireEvent(EVT.PUSH_VOICE_FINISH_PLAY)
end

function class:setChatSelectType(_type)
	self.chatSelType = _type
end

function class:getChatSelectType()
	return self.chatSelType
end

