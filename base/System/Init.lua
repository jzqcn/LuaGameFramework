require "System.Sound"

module ("sys", package.seeall)

function registModule(_, name, obj)
	rawset(_M, name, obj)
end

function unregistModule(_, name)
	rawset(_M, name, nil)
end

