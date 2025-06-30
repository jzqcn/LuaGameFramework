module(..., package.seeall)

class = Model.class:subclass()

function class:initialize()
    super.initialize(self)

    self.silverTable = {}
    self.goldTable = {}
    -- self.gameName = ""
end

function class:getSilverTable()
	return self.silverTable
end

function class:getGoldTable()
	return self.goldTable
end

