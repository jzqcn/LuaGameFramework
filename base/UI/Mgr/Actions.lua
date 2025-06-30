module(..., package.seeall)

class = objectlua.Object:subclass()


function class:initialize(owner, cbFunc)
	super.initialize(self)

	self.owner = owner
	self.cbFunc = cbFunc 
end

function class:dispose()
	super.dispose(self)
end

function class:callback()
	if self.cbFunc then 
		self.cbFunc() 
	end
end

function class:exec(...)
end
