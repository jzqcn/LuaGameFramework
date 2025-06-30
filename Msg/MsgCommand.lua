net.msg:import(..., function()
	local id = 0x20

	local cmdsSC =
	{
	}

	local cmdsCS =
	{
		--提交命令
		["CMD_PARSER"] =
		{
			0x05,
			{
				-- attr("command", "table"),
			},
		},
	}

	local types =
	{
		-- 账号状态
		['ACCOUNT_STATE'] = enum
		{	
			'NORMAL',  -- 正常
			'BLOCK',  -- 锁定
		},
	}

	return id, cmdsSC, cmdsCS, types
end
)