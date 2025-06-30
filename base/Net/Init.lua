
require 'Net.Msg'
require "Net.Mgr"
require "Net.Http"
require "Net.Assist"
require "Net.Monitor"

module ("net", package.seeall)

function registModule(_, name, obj)
	rawset(_M, name, obj)
end

function unregistModule(_, name)
	rawset(_M, name, nil)
end

