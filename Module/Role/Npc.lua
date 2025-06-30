local RoleBase = require "Role.Base"

module(..., package.seeall)

class = RoleBase.class:subclass()

function class:initialize(...)
    super.initialize(self, ...)
end

function class:dispose()
    super.dispose(self)
end

function class:doAI()
	if not self.avatar then 
		return 
	end 

	if not self.defaultPos then
		self.defaultPos = {}
		self.defaultPos.x, self.defaultPos.y = self:getPosCell()
		self.defaultPos.x = self.defaultPos.x - 5;
		self.defaultPos.y = self.defaultPos.y - 5;
	end

	local startx , starty = self:getPosCell()
	local endx = math.random(self.defaultPos.x , self.defaultPos.x + 10);
	local endy = math.random(self.defaultPos.y , self.defaultPos.y + 10);
	local path = self.map:getPathEx(startx, starty, endx, endy)
	self:moveByPath(path)
end
