net.msg:import(..., function()
	local id = "mod01"
	local protocolType = "json"

	local cmdsSC =
	{
		["Test01"] =
		{
			"cmd01",
			{
				-- {
				-- 	name="abc", age=10, list={1,3,5,7,9},
				-- 	name2="lskdjflskjdfkljklsdjfkljsdkllskdjflksjdfkljlskdjfklsjdfkljskldfjlksdjf",
				-- 	name3="lksdjflksjdfkljsdfkljskldfjklsjdfljsdfkljskldfjklsjdfkljsdfkllksdjf",
				-- 	name4="lksdjflkjsdfkljsdfkljklsdfjklsjdfkljsdklfjklsdjflkaaa",
				-- }
			}, 
		},

		["Test02"] =
		{
			"cmd02",
			{
			}, 
		},
	}

	local cmdsCS =
	{
		["Test01"] =
		{
			"cmd01",
			{
			-- {
			-- 	name="abc", age=10, list={1,3,5,7,9},
			-- }
			},
		},
	}

	local types =  
	{
		['AccountState'] = enum
		{	
			-- 正常
			[0] = 'NORMAL',
			-- 锁定
			[1] = 'BLOCK',
		},
	}

	return id, cmdsSC, cmdsCS, types, protocolType
end
)