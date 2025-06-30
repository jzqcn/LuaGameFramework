module(..., package.seeall)


class = GameStage.class:subclass()

function class:initialize()
	super.initialize(self)
end

function class:onStageActive()
	ui.mgr:replaceScene('Root')

	self:postMsg()
end

function class:onStageClose()
	Model:Reset()
end

function class:postMsg()
	MsgCommand:post("CMD_PARSER", {command = {"mail", 1, 0}})
end
