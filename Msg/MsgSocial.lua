net.msg:import(..., function()
	local id = 0x70

	local cmdsSC =
	{
		["SOCIAL_INFO"] =
		{
			1,
			{
			-- 	attr("socialType", "byte"),
			-- 	attr("selfMood", "wstring"),
			-- 	array("list", {
			-- 		attr("uuid", "longstring"),
			-- 		attr("isOnline", "byte"),
			-- 		attr("operaID", "byte"),
			-- 		attr("name", "wstring"),
			-- 		attr("level", "ubyte"),
			-- 		attr("job", "byte"),
			-- 		attr("pic", "ushort"),
			-- 		attr("mood", "wstring"),
			-- 	}),
			},
		},
		["SOCIAL_GIFTLIST"] = 
		{
			2,
			{
			},
		},

		["SOCIAL_GLAMOR"] = 
		{
			3,
			{
			},
		},
	}

	local cmdsCS =
	{
	}

	local types =  
	{
	}

	return id, cmdsSC, cmdsCS, types
end
)