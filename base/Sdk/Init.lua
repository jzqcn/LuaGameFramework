require "Sdk.Config"
require "Sdk.Platform"
require "Sdk.Feedback"
require "Sdk.Account"
require "Sdk.YvVoice"


module ("sdk", package.seeall)

function registModule(_, name, obj)
	rawset(_M, name, obj)
end

function unregistModule(_, name)
	rawset(_M, name, nil)
end

