
--@todo
do return end

--@todo
module(..., package.seeall)
Assist.Edit = _M

local class = objectlua.Object:subclass()
class:include(Events.ReceiveClass)

function create(_)
	local obj = class:new()
	return obj
end


function class:initialize()
    super.initialize(self)
    Events.ReceiveClass.initialize(self)
end

function class:dispose()
    Events.ReceiveClass.dispose(self)
	super.dispose(self)
end

--data
-- {
		-- edit  		edit对象
		-- slider 		slider对象
		-- initValue 	初始值
		-- minValue 	最小值
		-- maxValue 	最大值
		-- allowValue 	允许的最大值
		-- func 		值改变回调
-- }
----------------------外部调用----------------

--初始化
function class:initControl(data)
	self.data = data
	self:setSlider()
	self:setEdit()
end

--加1
function class:onAddOne()
	local value = math.floor(tonumber(self.edit:getString()))
	if value == self.data.maxValue then return end

	self.edit:setString(value + 1)
	self.slider:setValue(value + 1)

    self:callback()
end

--减1
function class:onSubOne()
	local value = math.floor(tonumber(self.edit:getString()))
	if value == self.data.minValue then return end

	self.edit:setString(value - 1)
	self.slider:setValue(value - 1)

    self:callback()
end

--设置slider最大允许值
function class:setAllowValue(value)
	self.data.allowValue = value
	self.slider:setMaximumAllowedValue(self.data.allowValue)
end

--设置slider最大值
function class:setMaxValue(value)
	self.data.maxValue = value
    self.originValue = nil
	self.slider:setMaximumValue(self.data.maxValue)
end

--设置值
function class:setValue(value)
	self.data.initValue = value
	self.edit:setString(value)
	self.slider:setValue(value)
end
---------------------------------------------------

function class:setSlider()
	self.slider = self.data.slider
	self.slider:setMinimumValue(self.data.minValue)
	self.slider:setMaximumValue(self.data.maxValue)
	self.slider:setValue(self.data.initValue)

	if self.data.allowValue then
		self.slider:setMaximumAllowedValue(self.data.allowValue)
	end

	if self.data.allowMinValue then
		self.slider:setMinimumAllowedValue(self.data.allowMinValue)
	end
	self.slider:bind(self)
end

function class:onValueChange(node, value)
    if value == self.originValue then
        return
    end
    self.originValue = value
    self:onSliderValueChange()

    if self.data.minValue == self.data.maxValue and self.data.maxValue ~= 0 then
        self.slider:setMaximumValue(self.data.maxValue + 1)
        self.slider:setValue(self.data.maxValue + 1)
    end

    if nil == self.data.func then
        return
    end

    self.data.func()
end

function class:onStopSlider(node, value)
    if self.data.stopSlider ~= nil then
        self.data.stopSlider()
    end
end

function class:onSliderValueChange()
	local value = math.floor(self.slider:getValue())
	self.edit:setString(value)
end

function class:setEdit()
	self.edit = self.data.edit
	self.edit:setPlaceHolder("")
    self.edit:setInputMode(2)
    self.edit:setCallback(bind(self.onEditValueChange,self))
    self.edit:setString(self.data.initValue)
end

function class:onEditValueChange(eventType)
	local editStr = self.edit:getString()
	local value = tonumber(editStr)
	if value == nil then
		value = 0
	end

    value = math.min(value, self.data.maxValue)
    self.edit:setString(value)

    if eventType ~= "ended" then
        return
    end

	if self.data.allowValue and value > self.data.allowValue then
		value = self.data.allowValue
	end

	self.slider:setValue(value)

    if util:getPlatform() == "win32" then
        return self:callback()
    end

    self:callback()
end

function class:callback()
    if self.data.func ~= nil then
        self.data.func()
    end

    if self.data.stopSlider ~= nil then
        self.data.stopSlider()
    end
end

