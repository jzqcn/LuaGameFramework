module(..., package.seeall)

class = GameStage.class:subclass()

function class:initialize()
	super.initialize(self)
end

function class:onStageActive()
	ui.mgr:replaceScene("Login/GameLoading")
end

function class:onStageClose()

end