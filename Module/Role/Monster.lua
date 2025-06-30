local RoleBase = require "Role.Base"

module(..., package.seeall)

class = RoleBase.class:subclass()

function class:initialize(...)
    super.initialize(self, ...)
end

function class:dispose()
    super.dispose(self)
end
