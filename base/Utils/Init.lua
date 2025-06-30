
--global
require "StringUtil"
require "MiscGlobal"
require "Misc"
require "StrictCheck"
require "Zip"
require "Quicklz"
require "AsyncFile"
require "Coordinate"

--class
require "Synchroniser"
require "Model"
require "Logic"
-- require "Pool"
-- require "Report"   --上传warn log到服务器


function IsDevMode()
	return sdk.platform:isDevMode()
end


--工具类 模块库
module ("util", package.seeall)

function registModule(_, name, obj)
	rawset(_M, name, obj)
end

function unregistModule(_, name)
	rawset(_M, name, nil)
end

