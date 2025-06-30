require "cocos.init"
require 'Lib.Init'

require 'Events.EventClass'
require 'Utils.Init'
require 'GameLogger'

__G__TRACKBACK__ = function(msg)
    local msg = debug.traceback(msg, 2)
    log(msg)

    if util:getPlatform() == "win32" then
	    DbgPrtOut(msg)  --OutputDebugString  输出到vs
	end
    return msg
end

-- cc.FileUtils:getInstance():addSearchPath("resource", true)
if util:getPlatform() == "win32" then
	-- cc.Label:setDefaultFontName("resource/fonts/mnjzy.ttf")
	cc.Label:setDefaultFontName("resource/fonts/YaHei.ttf")
else
	cc.Label:setDefaultFontName("")
end

require "UI.Init"
require "DB.Init"
require "Net.Init"
require "Sdk.Init"
require "AutoPatch.Init"
require "System.Init"

require 'Entry.Init'  --入口OnSysStartup


StartStrickCheck()




