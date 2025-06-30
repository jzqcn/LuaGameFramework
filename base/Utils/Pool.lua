-- support: cc.node, custom lua object, ccb file object

module(..., package.seeall)

local ccbRefactor = {}
class = objectlua.Object:subclass()

function class:initialize()
	super.initialize(self)
	self.objects = {}
end

function class:dispose()
    super.dispose(self)
    self:drainAllPools()
end

-- convenient for tableView creator
function class:getCreator()
	return function(ccb, parent)
		    	return self:getFromPool(function()
		    	    return Controller:load(ccb, parent)
		    	end, ccb)
		    end
end

function class:cacheObjects(clsOrCreator, name, count)
	local objects = {}
	for i = 1, count do
		table.insert(objects, self:getFromPool(clsOrCreator, name))
	end

	for _, object in ipairs(objects) do
		self:putInPool(name, object)
	end
end

function class:putInPool(name, object)
	self.objects[name] = self.objects[name] or {}
	table.insert(self.objects[name], object)
	object:retain()
end

function class:getFromPool(clsOrCreator, name, ...)
	local object = nil
	local cache = self.objects[name] or {}
	if #cache > 0 then
		object = cache[#cache]
		table.remove(cache)
		object:autorelease()
		return object
	end

	if type(clsOrCreator) == "function" then
		object = clsOrCreator(name, ...)
	elseif type(clsOrCreator) == "string" then
		object = cc[clsOrCreator]:create(name, ...)
	else
		object = clsOrCreator:new(name, ...)
	end

	-- ccb object
	if object.__ccbChildren ~= nil then
		local collector = bind(self.putInPool, self, name)
		ccbRefactor:setupPoolMgr(collector, object)
	end

	return object
end

function class:hasObject(name)
	local cache = self.objects[name] or {}
	return #cache > 0
end

function class:removeObject(name, object)
	local cache = self.objects[name] or {}
	if #cache == 0 then
		return false
	end

	for _, o in ipairs(cache) do 
		if o == object then
			if object.dispose ~= nil then
				object:dispose()
			end
			object:release()
			return true
		end
	end

	return false
end

function class:drainAllPools()
	for _, cache in pairs(self.objects) do
		for _, object in ipairs(cache) do 
			if object.dispose ~= nil then
				object:dispose()
			end
			object:release()
		end
	end

	self.objects = {}
end

instance = class:new()
-------------------------------------------
-- support: custom lua object with the cc.node,
-- note: your pool object should be inherited from this class 

viewClass = objectlua.Object:subclass()

function viewClass:initialize()
	super.initialize(self)
	self.node = self:create()
end

-- public
function viewClass:create()
	assert(false)
	-- return node
end

-- public
function viewClass:refresh(...)
end

function viewClass:getNode()
	return self.node
end

function viewClass:autorelease()
	self.node:autorelease()
end

function viewClass:retain()
	self.node:retain()
end

function viewClass:release()
	self.node:release()
end

-------------------------------------------
-- support: ccb file with the "Controller.load" function
-- note: your pool object should be inherited from this class, include the cbb children

function ccbRefactor:setupPoolMgr(poolFunc, root)
	local collector = bind(poolFunc, root)

	self:refactorRoot(root, collector)
	self:refactorChildren(root)
end

function ccbRefactor:startStateForPool(ccb)
	mixin.initialize(ccb)
	Controller.ControlManager:push(ccb)
end

function ccbRefactor:cleanStateForPool(ccb)
	Controller.ControlManager:remove(ccb)
end

function ccbRefactor:refactorRoot(root, collector)
	self:refactorChild(root)
	local oldExit = bind(root.exit, root)
	root.exit = function()
		oldExit()
		collector()
	end

	local oldDispose = bind(root.dispose, root)
	root.dispose = function()
		oldDispose()
		self:disposeChildren(root)
	end
end

-- manager ccb children about enter, exit, cleanup, Events and ControlManager
function ccbRefactor:refactorChildren(root)
	for _, child in ipairs(root.__ccbChildren) do
		self:refactorChild(child)
	end
end

-- release animationMgr of ccb children when dispose
function ccbRefactor:disposeChildren(root)
	for _, child in ipairs(root.__ccbChildren) do
		child:dispose()
	end
end

function ccbRefactor:releaseAnimationMgr(ccb)
	if ccb.animationMgr ~= nil then
		ccb.animationMgr:release()
		ccb.animationMgr = nil
	end
end

function ccbRefactor:refactorChild(ccb)
	local oldEnter = bind(ccb.enter, ccb)
	ccb.enter = function(_, ...)
		self:cleanStateForPool(ccb)
		self:startStateForPool(ccb)
		oldEnter(...)
	end

	local oldExit = bind(ccb.exit, ccb)
	ccb.exit = function(_, ...)
		oldExit(...)
		self:cleanStateForPool(ccb)
	end

	ccb.cleanup = function()
		-- do nothing
	end

	ccb.dispose = function()
		self:releaseAnimationMgr(ccb)
	end

	-- for TableViewBase refactor with registerOnEnter
	ccb.__oldEnter = ccb.enter
	ccb.__oldExit = ccb.exit
end