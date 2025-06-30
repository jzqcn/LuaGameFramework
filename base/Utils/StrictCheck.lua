
local getinfo, error, rawset, rawget = debug.getinfo, error, rawset, rawget

local function InjectStrictCheck(m, ...)
  local mt = getmetatable(m)
  if mt == nil then
    mt = {}
    setmetatable(m, mt)
  end
  
  mt.__declared = {}
  
  local function what ()
    local d = getinfo(3, "S")
    return d and d.what or "C"
  end
  
  mt.__newindex = function (t, n, v)
    if not mt.__declared[n] then
      local w = what()
      if w ~= "main" and w ~= "C" then
        log4misc:warn("assign to undeclared variable '"..n.."'")
      end
      mt.__declared[n] = true
    end
    rawset(t, n, v)
  end
  
  local __index = mt.__index
  mt.__index = function (t, n)
    local v = rawget(t, n)
    
    if not v and type(__index) == 'table' then
      v = rawget(__index, n)
    end
    
    if not v and type(__index) == 'function' then
      v = __index(t, n)
    end
    
    if not v and not mt.__declared[n] and what() ~= "C" then
      WriteLog(debug.traceback("variable '"..n.."' is not declared", 2))
    end
    return v
  end
end

local module = _G.module
local setfenv = setfenv
local getfenv = getfenv

local _module = function(...)
  local envOld = getfenv(1)
  
  module(...)
  setfenv(2, getfenv(1))
  
  setfenv(1, envOld)
  
  InjectStrictCheck(require(...))
end


function StopStrictCheck()
  _G.module = module
  setmetatable(_G, nil)
end

function StartStrickCheck()
  if util:getPlatform() ~= "win32" then
    return
  end
  InjectStrictCheck(_G)
  _G.module = _module
end

