
package.loaded["lfs"] = lfs  --use c library

-----------json------------
--
local old = cjson.decode
cjson.decode = function(s)
	local succ, data = pcall(old, s)
	if not succ then
		return nil
	end
	return data
end

local old = cjson.encode
cjson.encode = function(t)
	local succ, s = pcall(old, t)
	if not succ then
		return nil
	end
	return s 
end
rawset(_G, "json", cjson)
--
-------------------------

---------base64------------
--
local old = base64.encode
base64.encode = function(str)
	local succ, s = pcall(old, str)
	if not succ then
		return nil
	end
	return s 
end

local old = base64.decode
base64.decode = function(str)
	local succ, s = pcall(old, str)
	if not succ then
		return nil
	end
	return s 
end
--
-------------------------


require 'std'
require 'objectlua.init'
require 'objectlua.Mixin'

require 'Lib.lualib_ext'
require 'Lib.cocos_ext'

