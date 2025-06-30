module(..., package.seeall)

class = GameStage.class:subclass()

function class:initialize(bAutoEnter)
	super.initialize(self)

	self.bAutoEnter = bAutoEnter or false
end

function class:onStageActive()
	--协议文件加载
	Model:load({
		"Account",
		"HeartBeat",
		"Currency",
		"SynData",
		"Hall",
		"Chat",
		"Item",
		"Position",
		"User",
		"Rank",
		"GamePerformance",
		"Games/Kadang",
		"Games/Niuniu",
		"Games/Paodekuai",
		"Games/Shisanshui",
		"Games/Mushiwang",
		"Games/Dantiao",
		"Games/Longhudou"
	})

	ui.mgr:replaceScene("Login/GameLogin", self.bAutoEnter)

	Model:get("HeartBeat"):stopUpdateHeart()

	util.timer:after(500, self:createEvent("playMusic"))
end

function class:playMusic()
	sys.sound:playMusic("LOGIN")
end

function class:onStageClose()

end
