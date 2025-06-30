local Define = require "Map.Define"
local AvatarDefine = require"Avatar.Define"

module (..., package.seeall)

local class
local preloads = {}

function preload(self, path)
    if preloads[path] then
        return
    end
    preloads[path] = class:new(path):getResult()
end

function get(self, path)
    if not preloads[path] then
        preloads[path] = class:new(path):getResult()
    end

    return preloads[path]
end

class = objectlua.Object:subclass()

function class:initialize(path)
    super.initialize(self)

    local data = self:read(path)
    if data == nil then
        error(string.format("failed to load skill file:%s", path))
    end

    self.result = {}
    self.result.info = self:getSkillInfo(data)
end

function class:getResult()
    return self.result
end

--  private  --
function class:read(path)
    local prePath = Define.SKILL_FILE_PRE_PATH
    if not string.match(path, prePath) then
        path = prePath .. path
    end
    path = path .. ".lua"

    local data = util:openFile(path)
    if nil == data or #data == 0 then
        return nil
    end
    
    local status, info = pcall(loadstring(data))
    assert(status) 
    return info
end

function class:getSkillInfo(data)
    local skillInfo = data.skillInfo
    return skillInfo
end
