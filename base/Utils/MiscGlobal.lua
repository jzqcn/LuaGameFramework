

function Enum(t)
	return table.invert(t)
end
enum = Enum

function Singleton(class)
	if rawget(class, "getSingleton") ~= nil then
		return class:getSingleton()
	end
	
	return class.instance
end

function RunInCoroutine(f, ...)
	local thread = coroutine.create(f)
	
	local ret = pack(coroutine.resume(thread, ...))
	
	local succ = table.remove(ret, 1)
	if not succ then
		error(debug.traceback(thread, ret[1]))
	end
	
	return unpack(ret)
end


function try(...)
	local status = (...)
	if not status then
		error({ (select(2, ...)) }, 0)
	end
	return ...
end

function newtry(finalizer)
	return function (...)
		local status = (...)
		if not status then
			pcall(finalizer, select(2, ...))
			error({ (select(2, ...)) }, 0)
		end
		return ...
	end
end

local function statusHandler(status, ...)
	if status then
		return ...
	end
	
	local err = (...)
	if type(err) ~= "table" then
		error(err)
	end
	return nil, err[1]
end

function protect(func)
	return function (...)
		return statusHandler(pcall(func, ...))
	end
end





