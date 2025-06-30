
module(..., package.seeall)

class = objectlua.Object:subclass()

function class:initialize(avatar)
    super.initialize(self)
    self.avatar = avatar
end

function class:dispose()
	if self.state then
		self.state:release()
	end
	super:dispose()
end

function class:setShader(name, ...)
	local arg = {...}
	self.arg = arg
	local function call(part)
		local view = part:getViewNode()
		if name == "gray" then
			self.state = Assist.Shader:createGray(view)
		elseif name == "shade" then
			local imgShade, needUpdate = unpack(arg)
			self.state = Assist.Shader:createShade(view, imgShade, needUpdate)
		end 
		self.state:retain()
	end

	self.avatar:mapComponent(call)
end

function class:addComponent(part)
	if nil == self.state then
		return
	end

	-- local imgShade, needUpdate = unpack(self.arg)
	-- Assist.Shader:createShade(part:getViewNode(), imgShade, needUpdate)

	part:getViewNode():setGLProgramState(self.state)
end

