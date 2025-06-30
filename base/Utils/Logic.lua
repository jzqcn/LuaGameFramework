module(..., package.seeall)

local mgr = {}

--------------------------------------------------------------------------------
-- static

function get(_, name)
	name = 'Logic.' .. name

	local chunk = require(name)
	local logic = mgr.logics[name]
	if logic ~= nil then
		assert(logic, "loop or previous error loading logic '%s'", name)
		return logic, chunk
	end
	
	-- detect loop loading
	mgr.logics[name] = false
	
	local obj = chunk.class:new()
	mgr.logics[name] = obj

	return obj, chunk
end

function delete(_, name)
	local obj = mgr.logics[name]
	if nil == obj then
		return
	end

	mgr.logics[name] = nil
	obj:dispose()
end

function reset(_)
	for k, v in pairs(mgr.logics) do
		mgr.logics[k] = nil
		if type(v) == 'table' then
			v:dispose()
		end
	end
end

function load(_, t)
	for _, name in ipairs(t) do
		get(_, name)
	end
end

--------------------------------------------------------------------------------

class = objectlua.Object:subclass()
function class:initialize()
	super.initialize(self)
end

function class:dispose()
	super.dispose(self)
end

function class:setValue(type, value)
	self[type] = value
end

function class:getValue(type)
	return self[type]
end


--------------------------------------------------------------------------------
-- static(private)

mgr.logics = {}

--------------------------------------------------------------------------------
