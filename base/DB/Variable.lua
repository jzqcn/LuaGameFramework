module(..., package.seeall)


local singleton
function getSingleton(_)
	assert(singleton ~= nil)
	return singleton
end


local internal = {}
class = objectlua.Object:subclass()

function class:initialize(...)
	super.initialize(self)

	assert(nil == singleton)
	singleton = self

	self.useEncrypt = false
end

function class:dispose()
	super.dispose(self)
end

function class:getDocDir(name)
	return internal:getDocDir(name)
end

--游服登录成功后调用  每个玩家的文件名都是不一样的
function class:setUsrVarFileName(filename)
	internal:setUsrVarFileName(filename .. ".xml")
	internal:loadUsrVar()
end

function class:getSysVar(key)
	if type(key) == "number" then   --底层用枚举作为key
		return internal:getSysVar(key)
	else  --lua层的扩展 直接用字符串
		return self:getSysMiscVar(key)
	end
end

function class:setSysVar(key, value)
	assert(key and value)
	if type(key) == "number" then
		return internal:setSysVar(key, value)
	else 
		return self:setSysMiscVar(key, value)
	end
end

function class:getUsrVar(key)
	if type(key) == "number" then
		return internal:getUsrVar(key)
	else 
		return self:getUsrMiscVar(key)
	end
end

function class:setUsrVar(key, value)
	assert(key and value)
	if type(key) == "number" then
		return internal:setUsrVar(key, value)
	else 
		return self:setUsrMiscVar(key, value)
	end
end

--用于保存独立的信息到文件 如战报 一般比较大
--filepath:一个相对于doc的文件路径 如：gamemap/city.db
function class:readFile(filepath, mode)
	local fullpath = self:getDocDir("var/" .. filepath)
	local str = io.readFile(fullpath, mode)
	if nil == str then
		log4misc:warn("read file error ! str is nil ! filepath : "..fullpath)
		return nil
	end

	if self.useEncrypt then
		str = util:decrypt(str)
	end
	return str
end

function class:writeFile(filepath, data, mode)
	if self.useEncrypt then
		data = util:encrypt(data)
	end

	local fullpath = self:getDocDir("var/" .. filepath)
	io.writeFile(fullpath, data, mode)
end







--------------private------------------
function class:getSysMiscVar(name)
	return self:getMiscVar(name, true)
end

function class:setSysMiscVar(name, value)
	self:setMiscVar(name, value, true)
end

function class:getUsrMiscVar(name)
	return self:getMiscVar(name, false)
end

function class:setUsrMiscVar(name, value)
	self:setMiscVar(name, value, false)
end

function class:getMiscVar(name, isSys)
	local str = self:rawGetMiscVar(isSys)
	if nil == str then
		return nil
	end

	local info = json.decode(str)
	return info and info[name]
end

function class:setMiscVar(name, value, isSys)
	local str = self:rawGetMiscVar(isSys)
	local info
	if nil == str or "" == str then
		info = {}
	else
		info = json.decode(str) or {}
	end
	info[name] = value

	local strSave = json.encode(info)
	self:rawSetMiscVar(strSave, isSys)
end


function class:rawGetMiscVar(isSys)
	local str
	if isSys then
		str = internal:getSysVar(GV_MISC)
	else
		str = internal:getUsrVar(UV_MISC)
	end

	if nil == str or "" == str then
		return nil
	end

	if self.useEncrypt then
		str = util:decrypt(str)
	end
	return str
end

function class:rawSetMiscVar(str, isSys)
	if self.useEncrypt then
		str = util:encrypt(str)
	end

	if isSys then
		internal:setSysVar(GV_MISC, str)
	else
		internal:setUsrVar(UV_MISC, str)
	end
end




-------------internal c++------------
internal.system = CVariableSystem:GetSingleton() 

function internal:getDocDir(subFolder)
	local dir = self:getSysVar(GV_DOCPATH) .. (subFolder or '')
	CDirUtils:MkDir(dir)

	return dir 
end

---system variable
function internal:getSysVar(key)
	return self.system:GetSysVariable(key) or ''
end

function internal:setSysVar(key, value)
	self.system:SetSysVariable(key, value)
	self.system:SaveSysVariable()
end

---user variable
function internal:setUsrVarFileName(filename)
	assert(filename and filename ~= "")
	self.usrFilePath = filename  --不需要加doc 底层会自动加doc/var/
end

function internal:loadUsrVar()
	self.system:LoadUsrVariable(self.usrFilePath)
end

function internal:setUsrVar(key, value)
	self.system:SetUsrVariable(key, tostring(value))
	self.system:SaveUsrVariable(self.usrFilePath)
end

function internal:getUsrVar(key)
	return self.system:GetUsrVariable(key)
end


