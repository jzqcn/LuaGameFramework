local Base = require "UI.Control.Base"

module(..., package.seeall)


prototype = Base.prototype:subclass()

function prototype:initialize(...)
    super.initialize(self, ...)
end

function prototype:dispose()
    super.dispose(self)
end



