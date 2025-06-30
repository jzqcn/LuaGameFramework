local Chat = require "Model.Chat"

module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("Chat.EVT.PUSH_CHAT_MSG", "onPushChatMsg")
	self:bindModelEvent("Chat.EVT.PUSH_VOICE_FINISH_PLAY", "onPushVoiceFinishPlay")
	self:bindModelEvent("Chat.EVT.PUSH_VOICE_FINISH_RECORD", "onPushVoiceFinishRecord")
end

function prototype:setModelData(data)
	self.modelData = data
end

--聊天消息
function prototype:onPushChatMsg(data)
	if not data then
		return
	end

	if data.type == Chat_pb.Text then
		if string.find(data.text, "FACE_CHAT") then
			self:playFaceMsg(data)
		else
			self:playTextMsg(data)
		end
	elseif data.type == Chat_pb.Voice then
		--语音
		self:playVoiceMsg(data)
	elseif data.type == Chat_pb.Action then
		--动画
		self:playActionMsg(data)
	end
end

--简短语言文字、语音消息
function prototype:playTextMsg(item)
	if not item then
		return
	end
    
	local parentLayer = self.rootNode:getParent()
	--适配坐标，控件包含了一个界面的子控件（需要查找父控件的父控件，即界面UI）
	local parentProxy = tolua.getpeer(parentLayer:getParent())
	if parentProxy then
		local modelData = self.modelData or parentProxy.modelData
		if not modelData then
			return
		end

		local playerId = item.playerId
		local index = modelData:getPlayerSeatIndex(playerId)	
		local pos = parentProxy["nodeRole_"..index]:getHeadPos()
		local SHORT_VOICE			
		if string.find(item.text, "Man") then
			SHORT_VOICE = Chat.SHORT_VOICE_MAN		
		else
			SHORT_VOICE = Chat.SHORT_VOICE_WOMAN
		end

		for _, v in ipairs(SHORT_VOICE) do
			if item.text == v.key then
				local showTextNode = self:getLoader():loadAsLayer("Chat/ChatTextShowItem")
				if showTextNode then
					local anchorPos = parentProxy["nodeRole_"..index]:getLabelAnchorPoint()
					showTextNode:setString(v.word)										
					if anchorPos.x == 0 then
						showTextNode:setAnchorPoint(cc.p(0, 0.5))
						showTextNode:setPosition(cc.p(pos.x + 50, pos.y))
					else
						showTextNode:setAnchorPoint(cc.p(1, 0.5))
						showTextNode:setPosition(cc.p(pos.x - 50, pos.y))
					end
					
					self.rootNode:addChild(showTextNode)

					local delay = cc.DelayTime:create(2.5)
				    local funAction = cc.CallFunc:create(function(sender)
				    		sender:removeFromParent()
				    	end)

				    local action = cc.Sequence:create(delay, funAction)
				    showTextNode:runAction(action)
				end

				sys.sound:playEffectByFile(v.music)
				break
			end
		end
	else
		log4ui:warn("get parent view failed")
	end
end

--表情聊天消息
function prototype:playFaceMsg(item)
	if not item then
		return
	end

	local parentLayer = self.rootNode:getParent()
	--适配坐标，控件包含了一个界面的子控件（需要查找父控件的父控件，即界面UI）
	local parentProxy = tolua.getpeer(parentLayer:getParent())
	if parentProxy then
		local modelData = self.modelData or parentProxy.modelData
		if not modelData then
			return
		end

		local playerId = item.playerId
		local index = modelData:getPlayerSeatIndex(playerId)	
		local pos = parentProxy["nodeRole_"..index]:getHeadPos()

		for _, v in ipairs(Chat.CHAT_FACE) do
			if item.text == v.key then
                local faceFirstSprite= cc.Sprite:create(v.res.."1.png")
				if faceFirstSprite then
					local anchorPos = parentProxy["nodeRole_"..index]:getLabelAnchorPoint()									
					if anchorPos.x == 0 then
						faceFirstSprite:setAnchorPoint(cc.p(0, 0.5))
						faceFirstSprite:setPosition(cc.p(pos.x + 50, pos.y))
					else
						faceFirstSprite:setAnchorPoint(cc.p(1, 0.5))
						faceFirstSprite:setPosition(cc.p(pos.x - 50, pos.y))
					end
					
					self.rootNode:addChild(faceFirstSprite)

                     local animationFace = cc.Animation:create()
                     for i = 1, v.frames do
		                animationFace:addSpriteFrameWithFile(v.res..i..".png")
		             end
		            
                    animationFace:setDelayPerUnit(0.7 / v.frames)		                      
                    animationFace:setRestoreOriginalFrame(true) 
                    animationFace:setLoops(v.num)  
                    local showAction = cc.Animate:create(animationFace)
				    local funAction = cc.CallFunc:create(function(sender)
				    		sender:removeFromParent()
				    	end)

				    local action = cc.Sequence:create(showAction,funAction)				                  
                    faceFirstSprite:runAction(action)                   
				end
				break
			end
		end
	else
		log4ui:warn("get parent view failed")
	end
end

--播放语音
function prototype:playVoiceMsg(item)
	local isPlaying = sdk.yvVoice:playRecord(item.voiceUrl, "", "")
	if isPlaying then
		item.isRead = true

		local parentLayer = self.rootNode:getParent()
		--适配坐标，控件包含了一个界面的子控件（需要查找父控件的父控件，即界面UI）
		local parentProxy = tolua.getpeer(parentLayer:getParent())
		if parentProxy then
			local modelData = self.modelData or parentProxy.modelData
			if not modelData then
				return
			end

			local playerId = item.playerId
			local index = modelData:getPlayerSeatIndex(playerId)	
			local pos = parentProxy["nodeRole_"..index]:getHeadPos()
			local anchorPos = parentProxy["nodeRole_"..index]:getLabelAnchorPoint()

			if self.voicePro == nil then
				-- self.voicePro = cc.ProgressTimer:create(cc.Sprite:create("resource/csbimages/Chat/playVoice.png"))
			 --    self.voicePro:setType(cc.PROGRESS_TIMER_TYPE_BAR)
			 --    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
			 --    self.voicePro:setMidpoint(cc.p(0, 0))
			 --    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
			 --    self.voicePro:setBarChangeRate(cc.p(1, 0))

			 	self.voicePro = cc.Sprite:create("resource/csbimages/Chat/playVoice.png")
			    self.voicePro:setAnchorPoint(cc.p(0.5, 0.5))
				self.rootNode:addChild(self.voicePro)
			end

			local sprite = self.voicePro
			if sprite then
				sprite:setVisible(true)
				sprite:stopAllActions()

				if anchorPos.x == 0 then
					sprite:setScaleX(1)
					sprite:setPosition(cc.p(pos.x + 50, pos.y))
				else
					sprite:setScaleX(-1)
					sprite:setPosition(cc.p(pos.x - 50, pos.y))
				end

				-- sprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ProgressTo:create(1.0, 100), cc.ProgressTo:create(0.1, 0))))
				sprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.3), cc.FadeOut:create(0.3))))

			    log("voicePro runAction")
			end
		end
	end
end

--语音播放结束
function prototype:onPushVoiceFinishPlay()
	local msg = Model:get("Chat"):getNextNewVoice()
	if msg then
		self:playVoiceMsg(msg)
	else
		AudioEngine.resumeMusic()

		if self.voicePro then
			self.voicePro:stopAllActions()
			self.voicePro:setVisible(false)
		end
	end
end

--录音结束
function prototype:onPushVoiceFinishRecord()
	local msg = Model:get("Chat"):getNextNewVoice()
	if msg then
		self:playVoiceMsg(msg)
	else
		AudioEngine.resumeMusic()
	end
end

--播放消息动画
function prototype:playActionMsg(item)
	if not item then
		return
	end

	local parentLayer = self.rootNode:getParent()
	--适配坐标，控件包含了一个界面的子控件（需要查找父控件的父控件，即界面UI）
	local parentProxy = tolua.getpeer(parentLayer:getParent())
	if parentProxy then
		local modelData = self.modelData or parentProxy.modelData
		if not modelData then
			log4ui:warn("[GameChatNode:playActionMsg] error : can not find modelData !")
			return
		end

		-- local modelData = Model:get("Games/Kadang")
		local playerId = item.playerId
		local targetId = item.targetId

		local fromIndex = modelData:getPlayerSeatIndex(playerId)	
		local fromPos = parentProxy["nodeRole_"..fromIndex]:getHeadPos()

		local toIndex = modelData:getPlayerSeatIndex(targetId)
		local toPos = parentProxy["nodeRole_"..toIndex]:getHeadPos()

		local sprite = cc.Sprite:create(string.format("resource/csbimages/Games/Actions/%s.png", item.actionName))
		if sprite then
			sprite:setPosition(fromPos)
			parentProxy.panelPop:addChild(sprite)

			local dis = cc.pGetDistance(fromPos, toPos)
			local time = 0.6

			local isRotate = item.isRotate
			local moveAction
			if isRotate then
				moveAction = cc.Spawn:create(
					cc.MoveTo:create(time, toPos),
					cc.RotateBy:create(time, 360))
			else
				moveAction = cc.MoveTo:create(time, toPos)
			end

			local animation = cc.Animation:create()
			local name
		    for i = 1, item.frames do				
		        name = string.format("resource/csbimages/Games/Actions/%s/%d.png", item.actionName, i)
		        animation:addSpriteFrameWithFile(name)
		    end

		    animation:setDelayPerUnit(1.0 / item.frames)

		    local showAction = cc.Animate:create(animation)
		    local funAction = cc.CallFunc:create(function()
		    		sprite:removeFromParent()
		    	end)

		    local action = cc.Sequence:create(moveAction, showAction, funAction)
		    sprite:runAction(action)
		    --音效
		    sys.sound:playPropertyEffect(item.music)
		end

	else
		log4ui:warn("[GameChatNode:playActionMsg] error : parentProxy is nil")

	end
end


