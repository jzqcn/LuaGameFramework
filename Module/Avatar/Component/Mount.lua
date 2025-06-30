local Component = require "Avatar.Component.Component"

module (..., package.seeall)



class = Component.class:subclass()

function class:initialize(name)
    super.initialize(self, name)
end

function class:dispose()
    super.dispose(self)
end
