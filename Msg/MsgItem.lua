net.msg:import(..., function()
	local id = 0xB0

	local cmdsSC =
	{
		["ITEM_COMFIRM"] =
		{
			1,
			{
				attr("type", "byte"),
				attr("b1", "byte"),
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