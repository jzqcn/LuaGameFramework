module(..., package.seeall)

class = Events.class:subclass()

function class:initialize()
	super.initialize(self)
	
	self.music = 
	{ 
		LOGIN	= "resource/audio/bg/loading.mp3", 
		HALL	= "resource/audio/bg/hall.mp3", 
		KADANG	= "resource/audio/Kadang/bg_music.mp3", 
		NIUNIU	= "resource/audio/Niuniu/bg_music.mp3", 
	}

	self.effect =
	{
		CLICK       	= "resource/audio/public/button_click.mp3",
		CLICK_CARD		= "resource/audio/public/clickCard.mp3",
		PHOTO			= "resource/audio/public/audio_photo.mp3",
		CLOCK			= "resource/audio/public/clock.mp3",
		COINS_BET 		= "resource/audio/public/coins_bet.mp3",
		COINS_FLY 		= "resource/audio/public/coins_fly.mp3",
		COINS_FLY_IN	= "resource/audio/public/coins_fly_in.mp3",
		COINS_FLY_OUT 	= "resource/audio/public/coins_fly_out.mp3",
		COMMON_WIN		= "resource/audio/public/common_win.mp3",
		COMMON_LOSE		= "resource/audio/public/common_lose.mp3",
		ENTER			= "resource/audio/public/enter.mp3",
		LEAVE			= "resource/audio/public/leave.mp3",
		WARNING			= "resource/audio/public/warning.mp3",
		SHAIZI			= "resource/audio/public/shaizi.mp3",
		OUT_CARD		= "resource/audio/public/out_card.mp3",
		DEAL			= "resource/audio/public/deal_one.mp3",
		DEAL_LONG		= "resource/audio/public/dealCard_1.mp3",
		CHOOSE_DEALER	= "resource/audio/public/choose_banker.mp3",
		CHOOSE_DEALER_END = "resource/audio/public/choose_banker_end.mp3",
		NOTICE			= "resource/audio/public/notice.mp3",
		READY			= "resource/audio/public/ready.mp3",
		SNATCH			= "resource/audio/public/snatch.mp3",
		BET_COIN		= "resource/audio/public/bet_coin.wav",
	}

	self.propertyEff = 
	{
		BOMB       	= "resource/audio/public/property/bomb.mp3",
		CHIKEN		= "resource/audio/public/property/chiken.mp3",
		FLOWER		= "resource/audio/public/property/flower.mp3",
		FOOT		= "resource/audio/public/property/foot.mp3",
		TOMATO 		= "resource/audio/public/property/tomato.mp3",
		WATER 		= "resource/audio/public/property/water.mp3",
	}

	self.curFile = ""

	self:initVolume()

	-- self:preloadEffects(self.effect)
end

function class:initVolume()
	local volume = db.var:getSysVar("MUSIC_VOLUME") or 1
	AudioEngine.setMusicVolume(tonumber(volume))

	local volume = db.var:getSysVar("EFFECT_VOLUME") or 1
	AudioEngine.setEffectsVolume(tonumber(volume))
end


function class:dispose()
	super.dispose(self)
end

function class:preloadEffects(effects)
	local file = ""
	for K, v in pairs(effects) do
		file = util:getFullPath(v)
		AudioEngine.preloadEffect(file)
	end
end

function class:unloadEffects(effects)
	local file = ""
	for K, v in pairs(effects) do
		file = util:getFullPath(v)
		AudioEngine.unloadEffect(file)
	end
end

------------------------------------------------------------------
-- public: music control
function class:playMusic(name)
	if self.music[name] == nil then 
		return
	end

	self.lastMusicName = self.music[name]
	self:switchMusic(self.music[name])
end

function class:playMusicByFile(file)
	self.lastMusicName = file
	self:switchMusic(file)
end

function class:stopMusic(name)
	if name then
		local file = self.music[name]
		if nil == file or file ~= self.curFile then
			return
		end
	end

	self.curFile = ""
	AudioEngine.stopMusic()
end

function class:pauseMusic(name)
	local file = self.music[name]
	if nil == file or file ~= self.curFile then
		return 
	end

	AudioEngine.pauseMusic()
end

function class:resumeMusic(name)
	local file = self.music[name]
	if nil == file or file ~= self.curFile then
		return 
	end

	AudioEngine.resumeMusic()
end


function class:getMusicVolume()
	return AudioEngine.getMusicVolume()
end

-- volume:[0-1]
function class:setMusicVolume(volume)
	AudioEngine.setMusicVolume(volume)
	db.var:setSysVar("MUSIC_VOLUME", volume)
end
------------------------------------------------------------------
-- public: effect control
function class:playEffect(name)
	local file = self.effect[name]
	if file == nil then
		return
	end
	self:playEffectByFile(file)
end

function class:playEffectByFile(file)
	if not self:isEffectEnable() then 
		return 
	end

	if file == nil or file == "" then
		return
	end
	
	file = string.gsub(file, "\\", "/")
	file = util:getFullPath(file)

	-- log("[Sound::playEffectByFile] file path ====== "..file)

	AudioEngine.playEffect(file)
end

function class:playPropertyEffect(name)
	name = string.upper(name)
	local file = self.propertyEff[name]
	if file == nil then
		return
	end
	self:playEffectByFile(file)
end

function class:pauseEffect()
	AudioEngine.pauseAllEffects()
end

function class:resumeEffect()
	AudioEngine.resumeAllEffects()
end

function class:getEffectVolume()
	return AudioEngine.getEffectsVolume()
end

-- volume:[0-1]
function class:setEffectVolume(volume)
	AudioEngine.setEffectsVolume(volume)
	db.var:setSysVar("EFFECT_VOLUME", volume)
end

function class:stopAllEffect()
	AudioEngine.stopAllEffects()
end

------------------------------------------------------------------
-- private: music fading control
function class:isMusicEnable()
	return 1 ~= db.var:getSysVar("CLOSE_MUSIC")
end

function class:isEffectEnable()
	return 1 ~= db.var:getSysVar("CLOSE_EFFECT")
end

function class:setEnableMusic(value)
	db.var:setSysVar("CLOSE_MUSIC", value and 0 or 1)
	if value then
		if self.lastMusicName then
			self:playMusicByFile(self.lastMusicName)
		end
	else
		self:stopMusic()
	end
end

function class:setEnableEffect(value)
	db.var:setSysVar("CLOSE_EFFECT", value and 0 or 1)
	if not value then
		self:stopAllEffect()
	end
end

function class:switchMusic(file, loop)
	if self.curFile == file then
		return
	end

	loop = nil == loop and true or loop
	if not self:isMusicEnable() then 
		return 
	end

	if self.curFile == "" then
		self.curFile = file
		local fullpath = util:getFullPath(file)
		AudioEngine.playMusic(fullpath, loop)
	else
		if not self:existEvent("FADE_CLOSE") then
			util.timer:repeats(50, self:createEvent("FADE_CLOSE", "onFadeClose"))
		end

		self.nextFile = {["file"] = file, ["loop"] = loop} 
	end
end

function class:onFadeClose()
	local volume = AudioEngine.getMusicVolume() * 100
	volume = volume - 15
	volume = math.max(volume, 0)
	AudioEngine.setMusicVolume(volume / 100)

	if volume == 0 then
		self:onFadeCloseFinish()
	end
end

function class:onFadeCloseFinish()
	self:cancelEvent("FADE_CLOSE")
    
	AudioEngine.stopMusic()

	if nil ~= self.nextFile and nil ~= self.nextFile.file then		
		local fullpath = util:getFullPath(self.nextFile.file)
		AudioEngine.playMusic(fullpath, self.nextFile.loop)

		self.curFile = self.nextFile.file
		self.nextFile = nil

		if not self:existEvent("FADE_OPEN") then
			util.timer:repeats(50, self:createEvent("FADE_OPEN", "onFadeOpen"))
		end
	end
end 

function class:onFadeOpen()
	local saveVolume = (db.var:getSysVar("MUSIC_VOLUME") or 1) * 100
	local volume = AudioEngine.getMusicVolume() * 100
	volume = volume + 5
	volume = math.min(volume, saveVolume)
	AudioEngine.setMusicVolume(volume / 100)

	if volume == saveVolume then
		self:cancelEvent("FADE_OPEN")
	end
end
