net.msg:import(..., function()
	local id = 0x40

	local cmdsSC =
	{
		["NOTICE"] = 
		{
			2,
			{
				attr("info", "wstring"),
			},
		},

		["DIALOG_MSG"] = 
		{
			0,
			{
			},
		},

		["CHAT"] = 
		{
			4,
			{
				attr("chatType", "byte"),
				attr("uid", "longstring"),
				attr("name", "wstring"),
				attr("sex", "byte"),
				attr("text", "wstring"),
				attr("time", "wstring"),
			},
		},

		["TASK_LIST"] = 
		{
			5,
			{},
		},

		["TASK_DETAIL"] = 
		{
			6,
			{},
		},

		["UPDATE_TASKLIST"] = 
		{
			9,
			{},
			{},
		}
	}

	local cmdsCS =
	{
		["DIALOG_MSG"] = 
		{
			0,
			{
				attr("text", "wstring"),
				attr("uuid", "longstring"),
				attr("mode", "byte"),
			},
		},
	}

	local types =  
	{
	}

	return id, cmdsSC, cmdsCS, types
end
)