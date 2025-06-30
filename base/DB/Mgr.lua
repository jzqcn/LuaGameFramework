--------------------------------------------------
-- 数据管理对象 包含策划表 
--
-- 2016.12.26
--------------------------------------------------

module(..., package.seeall)


local singleton
function getSingleton(_)
	assert(singleton ~= nil)
	return singleton
end

class = objectlua.Object:subclass()

function class:initialize()
	super.initialize(self)

	assert(nil == singleton)
	singleton = self

	self.data = {}

	self:load()
end

function class:dispose()
	super.dispose(self)
end

function class:load()
	local path = "resource/db/db.lst"
	local data = util:openFile(path, true)
	local _, list = pcall(loadstring(data))
	-- log(list)

	local curIdx = 1
	local function LoadNextFile()
		local name = list[curIdx]
		curIdx = curIdx + 1
		self:loadByName(name)

		if curIdx > #list then
			util.timer:unbind(LoadNextFile)
			return
		end
	end

	util.timer:repeats(1, LoadNextFile)
end

function class:loadByName(name)
	local path = "resource/db/" .. name .. ".dat"
	local data = util:openFile(path, true)

	local status, db = pcall(loadstring(data))
	-- log(db)
	
	assert(status) 
	db.head2Idx = table.invert(db.head)

	self:makeId2Idx(db)
	self.data[name] = db
end

function class:makeId2Idx(db)
	if db.key == nil then
		--部分表 没有id
		return
	end

	local id = db.key
	local colIdx = db.head2Idx[id]

	local t = {}
	for line, info in ipairs(db.data) do
		-- log(line)
		-- log(info)
		t[info[colIdx]] = line
	end
	db.id2Idx = t
end


function class:getDB(name, data)
	if type(data) == "table" then
		return self:mapDB(name, function (info)
				for k, v in pairs(data) do
					if info[k] ~= v then
						return false 
					end
				end
				return true 
			end)
	else
		return self:getDBById(name, data)
	end
end

function class:getDBById(name, id)
	local db = self.data[name]
	assert(db and db.key, "current " .. name .. " excel not have id field! please use {name=value}")

	local lineIdx = db.id2Idx[id]
	return self:makeLineToMap(db, lineIdx)
end

function class:getDBByIdx(name, idx)
	local db = self.data[name]
	return self:makeLineToMap(db, idx)
end

function class:getDBSize(name)
	local db = self.data[name]
	return db and #db.data or 0
end

function class:mapDB(name, func)
	local db = self.data[name]
	local t = {}
	if db then
		for idx = 1, #db.data do
			local map = self:makeLineToMap(db, idx)
			if func(map) then
				table.insert(t, map)
			end
		end
	end
	return t
end

function class:makeLineToMap(db, idx)
	local t = {}
	local line = db.data[idx]
	for idx, name in ipairs(db.head) do
		t[name] = line[idx]
	end
	return t
end

