
local TextField = ccui.TextField


-- ccui.TextFiledEventType =
-- {
--     attach_with_ime = 0,
--     detach_with_ime = 1,
--     insert_text = 2,
--     delete_backward = 3,
-- }
local function eventListener(sender, evtType)
	Assist.TextField:onEvent(sender, evtType)
end

local old = TextField.addEventListener
	TextField.addEventListener = function (self, callback)
	old(self, function (sender, evtType) 
			eventListener(sender, evtType)
			callback(sender, evtType)
		end)
end

