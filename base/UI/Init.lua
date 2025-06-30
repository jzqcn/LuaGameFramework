
require "UI.UIExtend.LoadingBar"
require "UI.UIExtend.UIEditBox"
require "UI.UIExtend.UITextField"
require "UI.UIExtend.ProgressTimer"

require "UI.Assist"
require "UI.Loader"

Controller = require "UI.Controller"
Dialog = require "UI.Mgr.Window.Dialog"
DialogPrompt = require "UI.Mgr.Window.DialogPrompt"
Window = require "UI.Mgr.Window.Window"

require "UI.AniMgr"
require "UI.EditMgr"
require "UI.Animation"
require "UI.Control.Timer"
require "UI.Confirm"
require "UI.Mgr"
require "UI.EffectLoader"


module ("ui", package.seeall)

function registModule(_, name, obj)
	rawset(_M, name, obj)
end

function unregistModule(_, name)
	rawset(_M, name, nil)
end


